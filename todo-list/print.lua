function GeneratePrefix(line)
    local whitespace = line:match("^%s+")
    if whitespace == nil then
        return ""
    end

    line = line:sub(#whitespace + 1)
    return ("  "):rep(#whitespace)
end

function Main()
    local mon = peripheral.find("monitor")

    if not fs.exists("todo.txt") then
        print("File 'todo.txt' doesn't exist.")
        return
    end

    mon.clear()

    local y = 1
    for line in io.lines("todo.txt") do

        local prefix = GeneratePrefix(line)

        if #prefix == 0 then
            mon.setTextColor(colors.red)
        else
            mon.setTextColor(colors.white)
        end

        line = prefix .. " - " .. line
        mon.setCursorPos(1, y)
        mon.write(line)
        y = y + 1
    end
end

Main()