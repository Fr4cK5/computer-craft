-- TODO
--      2-Way Data Transmission between remote logging client and reactor control program.

-- Globals :)
local REACTOR = peripheral.find("BiggerReactors_Reactor")
local REMOTE_CONN = peripheral.wrap("right")
local HAS_REMOTE = false
local IS_TEST_ENV = false -- Set automatically
local CONN_TIMEOUT = 1.5
local REMOTE_LOGGING_CLIENT_PORT = 12000
local DIRECTION_REACTOR_AND_ITEM_SERVER = "back"
local PORT_REACTOR_AND_ITEM_SERVER_OUT = 420
local PORT_REACTOR_AND_ITEM_SERVER_IN = 1337
local MAX_FAILS = 120 -- 1.5 - 2 Hours, deptends on server performance
local MIN_BATTERY_TO_UPDATE_MORE_FREQUENTLY = 10

-- Macro Functions
function logInfo(s) logWithRemote("[INFO] " .. getTime() .. " | " .. s) end
function logWarn(s) logWithRemote("[WARN] " .. getTime() .. " | " .. s) end
function logErr(s) logWithRemote("[ERR] " .. getTime() .. " | " .. s) end
function logDebug(s) logWithRemote("[DEBUG] " .. s) end
function getTime() return textutils.formatTime(os.time(), true) end

function logWithRemote(message)
    print(message)
    if HAS_REMOTE then
        REMOTE_CONN.transmit(REMOTE_LOGGING_CLIENT_PORT, 0, message)
    end
end

function lerp(from, to, delta) return from * delta + to * (1 - delta) end
function getBatteryPercentage(input)
    local cap = REACTOR.battery().capacity()
    return input / cap * 100
end
function round(number, places) return tonumber(string.format("%." .. places .. "f", number)) end
function request(conn, port_out, port_in, message, timeout)
    if timeout == nil then
        timeout = CONN_TIMEOUT
    end

    conn.open(port_in)
    conn.transmit(port_out, port_in, message)

    local event, side, port, portReply, replyMessage, distance
    local timer = os.clock()
    local hasTimedOut = false

    repeat
        event, side, port, portReply, replyMessage, distance = os.pullEvent("modem_message")
        hasTimedOut = os.clock() - timer > timeout
    until port == port_in or hasTimedOut
    conn.close(port_in)

    if hasTimedOut then
        return nil
    end

    return {
        event = event,
        side = side,
        port = port,
        replyPort = portReply,
        message = replyMessage,
        dist = distance
    }
end
function deltaString(num)
    if num > 0 then
        return "+" .. tostring(num)
    end

    return tostring(num)
end

-- Big-Boy Functions
local internalBattery_min = 20
local internalBattery_max = 70
local chargingBehaviour_lastFuel = -1
local chargingBehaviour_lastWaste = -1

function regulateInternalBattery()

    local battery = REACTOR.battery()
    local stored = battery.stored()
    local cap = battery.capacity()
    local percentage = stored / cap * 100
    local modem = peripheral.wrap(DIRECTION_REACTOR_AND_ITEM_SERVER)

    -- Keep internal battery between min and max
    if percentage < internalBattery_min and not REACTOR.active() then
        REACTOR.setActive(true)
        logInfo("Internal battery is below " .. internalBattery_min .. "%; Reactor is going back online.")
        local response = request(modem, PORT_REACTOR_AND_ITEM_SERVER_OUT, PORT_REACTOR_AND_ITEM_SERVER_IN, "get_item_count", CONN_TIMEOUT)
        if response ~= nil then
            chargingBehaviour_lastWaste = response.message.waste
            chargingBehaviour_lastFuel = response.message.fuel
        else
            logErr("Connection to item count server timed out.")
        end

    elseif percentage > internalBattery_max and REACTOR.active() then
        REACTOR.setActive(false)
        logInfo("Internal battery is above " .. internalBattery_max .. "%; Reactor is going back offline.")
        local response = request(modem, PORT_REACTOR_AND_ITEM_SERVER_OUT, PORT_REACTOR_AND_ITEM_SERVER_IN, "get_item_count", CONN_TIMEOUT)
        if response ~= nil then
            local newFuel, newWaste = response.message.fuel, response.message.waste
            local fuelChange, wasteChange = newFuel - chargingBehaviour_lastFuel, newWaste - chargingBehaviour_lastWaste
            local fuelChangePercent, wasteChangePercent = fuelChange / chargingBehaviour_lastFuel * 100, wasteChange / chargingBehaviour_lastWaste * 100
            logInfo("Charging Complete.")
            logInfo("Fuel: " .. newFuel .. " (" .. deltaString(round(fuelChangePercent, 2)) .. "%)")
            logInfo("Waste: " .. newWaste .. " (" .. deltaString(round(wasteChangePercent, 2)) .. "%)")
        end
    end
end

function printStartingInfo()
    local batteryStatus = getBatteryPercentage(REACTOR.battery().stored())
    if batteryStatus >= internalBattery_min then
        logInfo("Internal Battery: " .. round(batteryStatus, 2) .. "%")
    elseif batteryStatus > 0 then
        logWarn("Internal Battery below " .. internalBattery_min .. "%")
    else
        logWarn("Internal Battery Empty!")
    end
end

local status_lastUpdateTime = "_"
local stats_lastBattery = -1
local stats_lastFuel, stats_lastWaste = -1, -1
function printStatistics()
    local timeStr = getTime()
    local colonIndex = string.find(timeStr, ":")
    local sub = ""
    if colonIndex then
        sub = string.sub(timeStr, colonIndex + 1, string.len(timeStr))
        local updateBatteryStatus = getBatteryPercentage(REACTOR.battery().stored())
        local update = ((sub == "00" or sub == "15" or sub == "30" or sub == "45") and sub ~= status_lastUpdateTime) or updateBatteryStatus < MIN_BATTERY_TO_UPDATE_MORE_FREQUENTLY

        if update then
            checkFailsafe()

            -- Internal Battery
            status_lastUpdateTime = sub
            local batteryStatus = REACTOR.battery().stored()

            if stats_lastBattery == -1 then
                stats_lastBattery = batteryStatus
            end

            local diff = deltaString(round(getBatteryPercentage(batteryStatus) - getBatteryPercentage(stats_lastBattery), 2))

            logInfo("Battery: " .. round(getBatteryPercentage(batteryStatus), 2) .. "% (" .. diff .."%)")
            stats_lastBattery = batteryStatus

            -- Fuel & Waste
            local modem = peripheral.wrap(DIRECTION_REACTOR_AND_ITEM_SERVER)

            if modem ~= nil then
                local response = request(modem, PORT_REACTOR_AND_ITEM_SERVER_OUT, PORT_REACTOR_AND_ITEM_SERVER_IN, "get_item_count", CONN_TIMEOUT)

                if response ~= nil then
                    local message = response.message
                    local fuel, waste = message.fuel, message.waste

                    if stats_lastFuel == -1 then
                        stats_lastFuel = fuel
                    end
                    if stats_lastWaste == -1 then
                        stats_lastWaste = waste
                    end

                    logInfo("Fuel: " .. fuel .. "; Waste: " .. waste)
                else
                    logErr("Connection to item count server timed out.")
                    return
                end
            else
                logErr("Item count server & the reactor must both be hooked into the same routing cable and connect into the back of this Computer.")
                return
            end
        end
    else
        logErr("Couldn't find ':' in " .. timeStr .. " :skull:")
    end
end

local failsafe_fail_count = 0
function checkFailsafe()
    local batteryStatus = getBatteryPercentage(REACTOR.battery().stored())
    if batteryStatus < MIN_BATTERY_TO_UPDATE_MORE_FREQUENTLY then
        failsafe_fail_count = failsafe_fail_count + 1
        if failsafe_fail_count > MAX_FAILS then
            logWarn("Unable to recover from low battery state for 1 hour.")
            logWarn("Halting system until further engineer instructions.")
            logInfo("To continue management, press enter on the onsite main management system.")
            REACTOR.setActive(false)
            read()
        end
    else
        failsafe_fail_count = 0
    end
end


function initRemote()
    HAS_REMOTE = REMOTE_CONN ~= nil
end

function printFancyReactorStartingSequence() 
    logInfo("Initializing Reactor Health Checks...")
    sleep(.15)
    logInfo("Fuelrods.........................OK")
    sleep(.15)
    logInfo("Core Pressure....................OK")
    sleep(.15)
    logInfo("Turbine..........................OK")
    sleep(.15)
    logInfo("Pressure Control Valves..........OK")
    sleep(.15)
    logInfo("Coolant Pumps....................OK")
    sleep(.15)
    logInfo("Core Hull Integrity..............OK")
    sleep(.15)
end

-- Main Function
function main()

    print("input some...")
    read()

    initRemote()

    for i = 1, 20 do
        logInfo(" ")
    end

    logInfo("Reislamazur Nuclear Power Plant Control System v1.2")
    sleep(.5)
    logInfo("Setting Up Stack...")
    sleep(.05)
    logInfo("RUNTIME.USE_HEAP = false")
    sleep(.05)
    logInfo("RUNTIME.MEMORY_MANAGEMENT.SCOPE_BASED_OBJECT_LIFETIME = true")
    sleep(.15)
    logInfo("Starting Core...")
    sleep(.75)
    logInfo("Finalizing Core Startup...")

    sleep(1.25)
    if not IS_TEST_ENV then
        logInfo("Establishing connection with reactor... (120 sec Timeout)")

        sleep(.5)
        local findReactorTimeout = 120
        local noReactorFoundTimer = os.clock()
        local findReactorTimedOut = false
        while REACTOR == nil or findReactorTimedOut do
            REACTOR = peripheral.find("BiggerReactors_Reactor")
            findReactorTimedOut = os.clock() - noReactorFoundTimer > findReactorTimeout
        end

        if findReactorTimedOut then
            logErr("Unable to find reactor; Shutting down...")
            return
        end

        printFancyReactorStartingSequence()
        printStartingInfo()
        while true do
            regulateInternalBattery()
            printStatistics()
            sleep(.5)
        end
    elseif IS_TEST_ENV then
        while true do
            logInfo("TESTING")
            sleep(1)
        end
    end
end

-- Start that badboi up!
main()