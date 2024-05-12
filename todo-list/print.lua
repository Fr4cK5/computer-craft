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

    if mon == nil then
        print("No monitor attached.")
        return
    end

    local filename = "todo.txt"

    if not fs.exists(filename) then
        print("File '" .. filename .. "' doesn't exist.")
        return
    end

    mon.clear()

    local y = 1
    for line in io.lines(filename) do

        local trimmed = line:gsub("%s+", "")
        if trimmed ~= nil and #trimmed == 0 then
            y = y + 1
            goto continue
        end

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

        ::continue::
    end
end

Main()