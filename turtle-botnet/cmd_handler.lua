function string.starts_with(s, pattern)
    return s:sub(1, pattern:len()) == pattern
end

Handler = {

    cnc_discover = "cnc_discover",
    cnc_bot = "cnc_bot",
    cnc_check_move = "cnc_check_move",
    cnc_move = "cnc_move",
    cnc_rot = "cnc_rot",
    cnc_attack = "cnc_attack",
    cnc_return = "cnc_return",
    cnc_disconnect = "cnc_disconnect",
    bot_connect = "connected",
    bot_disconnect = "disconnected",
    bot_action = "action",

    Handle = function(payload, id)
        if payload == Handler.cnc_discover then
            sleep(.25)
            rednet.send(id, Handler.cnc_bot)
            return Handler.bot_connect

        elseif payload == Handler.cnc_check_move then
            rednet.send(not turtle.detect())
        elseif payload:starts_with(Handler.cnc_move) then
            if payload:match("forward$") ~= nil then
                turtle.forward()
            elseif payload:match("back$") ~= nil then
                turtle.back()
            end

        elseif payload:starts_with(Handler.cnc_rot) then
            if payload:match("right$") ~= nil then
                turtle.turnRight()
            elseif payload:match("left$") ~= nil then
                turtle.turnLeft()
            end

        elseif payload == Handler.cnc_attack then
            turtle.attack()

        elseif payload == Handler.cnc_disconnect then
            return Handler.bot_disconnect

        end

        return Handler.bot_action
    end
}