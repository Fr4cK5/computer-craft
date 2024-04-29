function logInfo(s) print("[INFO] " .. getTime() .. " | " .. s) end
function logWarn(s) print("[WARN] " .. getTime() .. " | " .. s) end
function getTime() return textutils.formatTime(os.time(), true) end

local fuel_chest = peripheral.wrap("left")
local waste_chest = peripheral.wrap("right")

local modem = peripheral.find("modem")

local chnl_in = 420
local chnl_out = 1337

function main()
    modem.open(chnl_in)
    while true do
        local event, side, channel, replyChannel, message, distance
        repeat
            event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        until channel == chnl_in
        message = tostring(message)

        if message == "get_item_count" then
            logInfo("Processing request '" .. message .. "'...")
            local fuel_count = unpack(fuel_chest.list()).count
            local waste_count = unpack(waste_chest.list()).count
            modem.transmit(chnl_out, chnl_in, {fuel = fuel_count, waste = waste_count})
        else
            logWarn("Recieved unknown message '" .. message .. "'.")
        end
    end
end

main()