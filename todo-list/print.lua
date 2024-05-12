COLOR_NORMAL = colors.white
COLOR_HIGHLIGHT = colors.red
COLOR_TICK = colors.lightBlue

INDENT_COLORS = {
    [0] = colors.red,
    [1] = colors.lightBlue,
    [2] = colors.pink,
    [3] = colors.lime,
    [4] = colors.cyan,
}

function GeneratePrefix(line)
    local whitespace = line:match("^%s+")
    if whitespace == nil then
        return 0
    end
    return #whitespace
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

        line = line:sub(prefix + 1)
        if #line:gsub("%s+", "") == 0 then
            y = y + 1
            goto continue
        end

        mon.setCursorPos(prefix * 2, y)

        mon.setTextColor(colors.white)
        mon.write(" - ")

        local idx = prefix % (#INDENT_COLORS + 1)
        local text_color = INDENT_COLORS[idx]

        mon.setTextColor(text_color)
        mon.write(line)

        y = y + 1

        ::continue::
    end
end

Main()