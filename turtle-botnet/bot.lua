require("cmd_handler")

local function wait_for_connect()
    repeat
        local id, resp = rednet.receive()
    until resp == Handler.bot_connect
end

local function main()
    local modem = peripheral.find("modem")
    rednet.open(modem)

    wait_for_connect()

    while true do
        local id, msg = rednet.receive()
        local action = Handler.Handle(msg, id)

        if action == Handler.bot_disconnect then
            wait_for_connect()
        end
    end

    rednet.close()
end

main()