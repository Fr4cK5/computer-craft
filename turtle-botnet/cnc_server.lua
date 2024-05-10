MODEM_SIDE = "left"

require("cmd_handler")

local function recv_for(time_seconds)
    print("Waiting " .. time_seconds .. " second(s)")
    local start = os.clock()
    local requests = {}
    while os.clock() - start < time_seconds do
        local id, msg = rednet.receive(os.clock() - start)
        if msg == Handler.cnc_bot then
            table.insert(requests, id)
        end
    end

    print("Collected " .. #requests .. " bot id(s)")

    return requests
end

local function discover()
    print("Discovering")
    rednet.broadcast(Handler.cnc_discover)
    local bots = recv_for(.25)

    return bots
end

local function main()

    rednet.open(MODEM_SIDE)

    -- bots = [id: number]
    local bots = discover()

    while true do

        local event, vk = os.pullEvent("key")
        local key = keys.getName(vk)

        local command = Handler.ParseCommand(key)

        for i, id in ipairs(bots) do
            print("Bot #" .. i .. " ID: " .. id .. " Cmd: " .. command)
            rednet.send(id, command)
        end

        if command == Handler.cnc_disconnect then
            print("Quitting...")
            break
        end
    end


    rednet.close(MODEM_SIDE)
end

main()