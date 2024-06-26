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

        print("Handling payload: " .. payload)

        if payload == Handler.cnc_discover then
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
    end,

    ParseCommand = function(key)
        if key == "w" then
            return Handler.cnc_move .. "-forward"
        elseif key == "s" then
            return Handler.cnc_move .. "-back"
        elseif key == "a" then
            return Handler.cnc_rot .. "-left"
        elseif key == "d" then
            return Handler.cnc_rot .. "-right"
        elseif key == "f" then
            return Handler.cnc_attack
        elseif key == "r" then
            return Handler.cnc_return
        elseif key == "space" then
            return Handler.cnc_discover
        elseif key == "q" then
            return Handler.cnc_disconnect
        end
    end

}