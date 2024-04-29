-- This turtle script automatically dumps excess items from a smelting system.
-- T = Turtle
-- M = Modem, block version, crafted using the normal, grey wired modem.
-- C = Chest
-- This is how the blocks should be placed:
-- TMC

local divide_by = 3
local modem = peripheral.wrap("front")
local chest = peripheral.find("sophisticatedstorage:chest")
local turtle_name = modem.getNameLocal()

turtle.select(1)

while true do
    for index, item in pairs(chest.list()) do -- Chest Items
        if item.count % divide_by ~= 0 then
            chest.pushItems(turtle_name, index, item.count % divide_by)
            turtle.dropDown() -- This will work since there's only ever gonna be one signel item stack at the time
        end
    end
end