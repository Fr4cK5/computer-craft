MODEM_SIDE = "left"

require("cmd_handler")

local function wait_for_connect()
    repeat
        local id, msg = rednet.receive()
        local action = Handler.Handle(msg, id)
    until action == Handler.bot_connect
end

local function main()
    rednet.open(MODEM_SIDE)

    wait_for_connect()

    while true do
        local id, msg = rednet.receive()
        local action = Handler.Handle(msg, id)

        if action == Handler.bot_disconnect then
            wait_for_connect()
        end
    end

    rednet.close(MODEM_SIDE)
end

main()