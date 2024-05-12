COLOR_NORMAL = colors.white
COLOR_HIGHLIGHT = colors.red
COLOR_TICK = colors.lightBlue

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

        local prefix = GeneratePrefix(line)

        line = line:gsub("%s+", "")
        if #line == 0 then
            y = y + 1
            goto continue
        end

        mon.setCursorPos(1, y)

        mon.write(prefix)
        mon.setTextColor(COLOR_TICK)
        mon.write(" - ")

        if #prefix == 0 then
            mon.setTextColor(COLOR_HIGHLIGHT)
        else
            mon.setTextColor(COLOR_NORMAL)
        end

        mon.write(line)

        -- line = prefix .. " - " .. line
        -- mon.write(line)

        y = y + 1

        ::continue::
    end
end

Main()