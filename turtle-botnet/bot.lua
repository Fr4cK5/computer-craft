MODEM_SIDE = "left"

require("cmd_handler")

local function wait_for_connect()
    print("Waiting for connection...")
    repeat
        local id, msg = rednet.receive()
        print("Got handshake message: " .. msg)
        local action = Handler.Handle(msg, id)
    until action == Handler.bot_connect
    print("Handshake complete")
end

local function main()
    rednet.open(MODEM_SIDE)

    wait_for_connect()

    while true do
        local id, msg = rednet.receive()
        print("Got command: " .. msg)

        local action = Handler.Handle(msg, id)

        if action == Handler.bot_disconnect then
            wait_for_connect()
        end
    end

    rednet.close(MODEM_SIDE)
end

main()