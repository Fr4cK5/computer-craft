local port = 12000
local modem = peripheral.find("modem")
local mon = peripheral.find("monitor")
local messageHistory = {}
local textScale = .5

function monWrite(str)
    table.insert(messageHistory, str)
    local width, height = mon.getSize()
    if #messageHistory == height - 1 then
        shiftBack(messageHistory, 1)
    end

    mon.clear()
    for i = 1, #messageHistory do
        mon.setCursorPos(1, i)
        mon.write(messageHistory[i])
    end
end

function shiftBack(list, index)
    for i = 1, #list - index do list[i] = list[i + index] end
    table.remove(list, #list)
end

function main()
    if modem == nil then
        print("No Modem connected; Shutting down...")
        return
    end

    if mon ~= nil then
        mon.setTextColor(colors.white)
        mon.clear()
        mon.setTextScale(textScale)
    end

    modem.open(port)
    while true do
        local event, side, channel, replyChannel, message, dist
        repeat
            event, side, channel, replyChannel, message, dist = os.pullEvent("modem_message")
        until channel == port
        print(tostring(message))

        if mon ~= nil then
            monWrite(tostring(message))
        end
    end
end

main()