-- ComputerCraft: Tweaked Mining Turtle farming script V1.0

----- Constants (These, you can change to fit your needs!) -----
-- "FIELD_LENGTH" should be one less than the actual in-game field length.
-- "FIELD_WIDTH" shound be the exact field width including any separation blocks.
local FIELD_LENGTH = 20
local FIELD_WIDTH = 18

-- You must use this layout for the script to work!

-- The Block layers should look exactly like this.
-- Height | Blocks in the layer
-- -------|-------------------------------------------
--    69  | This Mining Turtle
--    68  | Crops (eg. wheat(_seeds)), Separation Blocks
--    67  | Farmland, Water

-- F = Farmland
-- W = Water, directly above it will be a separation block of you choice (I like to use slabs).
-- C = Chest
-- O = Free space
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- FFFFWFFFFFFFFWFFFF
-- ------------------
-- ---------------CCC
-- ---------------CCC   <- Double chests; Order from left to right: Fuel, Seeds, Crops

-- The farm is expandable to the left and right, but make sure you place the chests as shown in the top-down view (Always bottom-right hand corner).
--      The chests (assuming up in the top-down view is north) range from north to south. There are 3 double-chests total.

-- Make sure to name the items correctly!
local FUEL = "minecraft:coal"
local CROP = "minecraft:wheat"
local SEEDS = "minecraft:wheat_seeds"
local SEPARATION_BLOCK = "minecraft:birch_slab"

-- How many separation blocks/lines (for water between the fields) are there on the field.
local SEPARATION_BLOCK_COUNT = 3

-- How long to wait for next harvesting run. Time is in seconds.
local SLEEP_TIME = 600

-- Minimum stack count of the wanted seeds
local MIN_SEED_STACKS = 2

----- Variables -----

local shouldRefuel = false


----- Functions -----

function CheckSolid()
    local block_solid, data = turtle.inspectDown()

    if(block_solid) then
        return textutils.serialise(data, {true, false})
    else
        return nil
    end
end

-----

function GetItemIndex(name)
    for i = 1, 16 do
        local itemDetail = turtle.getItemDetail(i)
        local itemDetail_str = textutils.serialise(itemDetail)
        local is_item = string.match(itemDetail_str, name .. "\",")

        if(is_item) then
            return i
        end
    end
    return nil
end

-----

function CheckCrop()

    if(CheckSolid() == nil) then
        if(GetCount(SEEDS) > 0) then
            if(GetItemIndex(SEEDS) ~= nil) then
                turtle.select(GetItemIndex(SEEDS))
                turtle.placeDown()
            end
        end

    elseif(string.match(CheckSolid(), "age = 7")) then
        if(GetCount(SEEDS) > 0) then

            if(GetItemIndex(SEEDS) ~= nil) then
                turtle.digDown()
                turtle.select(GetItemIndex(SEEDS))
                turtle.placeDown()
            end

        else
            Log("No more seeds.")
        end

    end
end

-----

function CheckFuel()

    if(turtle.getFuelLevel() < 128) then
        if(GetItemIndex(FUEL) ~= nil) then
            if(turtle.getItemCount(GetItemIndex(FUEL)) > 0) then
                turtle.select(GetItemIndex(FUEL))
                turtle.refuel()
            end
        end
    end

    if(GetCount(FUEL) < 10) then
        if(not shouldRefuel) then
            SceduleRefuel()
            Log("Fuel low, sceduling refuel...")
        end
    end
end

-----

function SceduleRefuel()
    shouldRefuel = true
end

-----

function DropAllOfName(item_name)

    for i = 1, 16 do
        local itemDetail = turtle.getItemDetail(i)
        local itemDetail_str = textutils.serialise(itemDetail)


        if(string.match(itemDetail_str, item_name .. "\",")) then

            turtle.select(i)
            turtle.dropDown()

        end

    end

end

-----

function GetCount(item_name)

    local item_count = 0

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        local item_str = textutils.serialise(item)
        local isRightItem = string.match(item_str, item_name .. "\"")

        if(isRightItem) then
            item_count = item_count + turtle.getItemCount(i)
        end
    end

    return item_count

end

-----

function Move()
    for i = 1, FIELD_LENGTH do
        CheckCrop()
        CheckFuel()
        turtle.forward()
    end
end

-----

function Right()
    turtle.turnRight()
    CheckCrop()
    CheckFuel()
    turtle.forward()
    CheckCrop()
    CheckFuel()
    turtle.turnRight()
end

------

function Left()
    turtle.turnLeft()
    CheckCrop()
    CheckFuel()
    turtle.forward()
    CheckCrop()
    CheckFuel()

    local isSolid, block = turtle.inspectDown()
    local block_str = textutils.serialise(block)
    local shouldMoveMore = string.match(block_str, SEPARATION_BLOCK)

    if(shouldMoveMore) then
        turtle.forward()
    end

    turtle.turnLeft()
end

-----

function MoveUpDown()
    Move()
    Right()
    Move()
    Left()
    DropOverflowSeeds()
    DropAllOfName("rootsclassic:verdant_sprig")
end


-----

function ManageSeedStock()

    Log("Handling seed count...")

    DropAllOfName(SEEDS)

    for i = 1, MIN_SEED_STACKS do
        turtle.suckDown()
    end

end

function DropOverflowSeeds()

    while(GetCount(SEEDS) > 64 * MIN_SEED_STACKS and GetItemIndex(SEEDS) ~= nil) do

        turtle.select(GetItemIndex(SEEDS))
        turtle.dropDown()

    end

end

-----

function HandleFuelScedule()

    Log("Refueling...")

    shouldRefuel = false
    turtle.suckDown(32 - GetCount(FUEL))

end

-----

function HandleItems()

    turtle.forward()
    turtle.forward()
    turtle.turnRight()

    local crop_count = GetCount(CROP)

    DropAllOfName(CROP)
    Log("Dropping off " .. crop_count .. " crops...")

    turtle.forward()

    ManageSeedStock()

    turtle.forward()

    HandleFuelScedule()

    for _ = 1, FIELD_WIDTH - SEPARATION_BLOCK_COUNT do
        turtle.forward()
    end

    turtle.turnRight()

    for _ = 1, 2 do
        turtle.forward()
    end
end

-----

function Log(s)
    local time = textutils.formatTime(os.time(), true)
    print("[LOG] " .. time .. " | " .. s)
end

----- Main -----

CheckFuel()

while(true) do

    for i = 1, math.floor((FIELD_WIDTH - SEPARATION_BLOCK_COUNT) / 2 - 1) do
       MoveUpDown()
    end

    Move()
    Right()
    Move()

    HandleItems()

    Log("Waiting for " .. SLEEP_TIME / 60 .. " minutes to save fuel...")

    sleep(SLEEP_TIME)

    Log("Starting again!")
end
