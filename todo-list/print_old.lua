function SplitLines(str)
    local lines = {}
    for line in str:gmatch("[^\r\n]+") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    return lines
end

local mon = peripheral.find("monitor")
local file = fs.open("todo.txt", "r")

local content = file.readAll()
file.close()

local lines = SplitLines(content)

mon.clear()

for i, line in pairs(lines) do
    line = " - " .. line
    print(line)
    mon.setCursorPos(1, i)
    mon.write(line)
end

print("INFO: Use 'edit todo.txt' to edit the todos.")
print("INFO: Expand the monitor if needed.")
print("INFO: To save and exit, press CTRL, then use the arrowkeys.")

