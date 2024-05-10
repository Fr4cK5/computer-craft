MODEM_SIDE = "left"

require("cmd_handler")

local function recv_for(time_seconds)
    local start = os.clock()
    local requests = {}
    while os.clock() - start < time_seconds do
        local id, msg = rednet.receive()
        if msg == Handler.cnc_bot then
            requests:insert(id)
        end
    end

    return requests
end

local function discover()
    rednet.broadcast(Handler.cnc_discover)
    local bots = recv_for(1)

    return bots
end

local function main()

    rednet.open(MODEM_SIDE)

    -- bots = [id: number]
    local bots = discover()
    for id in bots do
        rednet.send(id, Handler.cnc_rot .. "-right")
    end

    rednet.close(MODEM_SIDE)
end

main()