-- Farming V2

-- Settings --

function SumArray(arr)
	local sum = 0
	for _, v in ipairs(arr) do
		sum = sum + v
	end
	return sum
end

-- Pause time in between harvest runs
SLEEP_TIME_SECS = 300

-- Length of the field
FIELD_LENGTH = 20

-- Items
-- https://feed-the-beast.fandom.com/wiki/Turtle
FUEL_ITEM_NAME = "minecraft:coal"
CURRENT_FUEL_ITEM_EFFICIENCY = 80
SEED_ITEM_NAME = "minecraft:wheat_seeds"
POSSIBLE_HAREVESTS = {
	"minecraft:wheat"
}
MIN_SEED_COUNT = 128

-- Width of the water lane between chunks
WATER_LANE_WIDTH = 1

-- Width of each chunk divided by four. 1 2 1 -> 4 8 4
FIELD_SCHEME = { 1, 2, 1 }

-- Global
CROP_TAG_FILTER = "minecraft:crops"
MIN_FUEL_FOR_HARVEST_RUN = SumArray(FIELD_SCHEME) * FIELD_LENGTH


-- @returns {table} Block data of the below block, or nil
function GetBlockDetailsBelow()
	local block_exists, data = turtle.inspectDown()
	if not block_exists then
		return nil
	end
	return data
end

-- @param {table} data Block state data
-- @param {string} tag_key Tag
-- @returns {bool} If the block below contains tag_key
function CheckBlockValid(data, tag_key)
	if data == nil then
		return false
	end

	for k, v in pairs(data["tags"]) do
		if string.find(k, tag_key) ~= nil then
			return true
		end
	end

	return false
end

-- @param {table} data Block state data
-- @returns {bool} If the crop is mature eg. its age value is set to 7
function CheckCropAgeMature(data)
	if data == nil or data["state"] == nil or data["state"]["age"] == nil then
		return false
	end

	return data["state"]["age"] == 7
end

-- @param {string} replacement_seed The name of the replacement crop to be planted
-- @param {string} filter The tag to filter for before harvesting
function HarvestIfValid(replacement_seed, filter)
	local data = GetBlockDetailsBelow()
	if data == nil then
		return
	end

	if CheckBlockValid(data, filter) and CheckCropAgeMature(data) then
		ReplaceBelow(replacement_seed)
	end
end

-- @param {string} repl The replacement seed
function ReplaceBelow(repl)
	turtle.digDown()
	local maybe_idx = HasItemInInventory(repl)
	if maybe_idx == 0 then
		return
	end

	local idx = maybe_idx

	turtle.select(idx)
	turtle.placeDown()
end

-- @param {string} name The full item identifier eg. minecraft:wheat_seeds
-- @returns {int} Index [1-16] if found, 0 otherwise
function HasItemInInventory(name)
	for i = 1, 16 do -- Inventory size == 16
		local detail = turtle.getItemDetail(i)
		if detail ~= nil then
			if detail["name"] == name then
				return i
			end
		end
	end

	return 0
end

function GetTotalItemCount(name)
	local total = 0
	for i = 1, 16 do
		local detail = turtle.getItemDetail(i)
		if detail ~= nil then
			if detail["name"] == name then
				total = total + detail["count"]
			end
		end
	end

	return total
end

-- @param {int} min_fuel The minimum amount of fuel the turtle must have
-- @param {string} fuel_item The item to be consumed as fuel
function CheckFuelLevels(min_fuel, fuel_item)
	local turtle_fuel_level = turtle.getFuelLevel()
	if turtle_fuel_level < min_fuel then
		local diff = min_fuel - turtle_fuel_level
		local idx = HasItemInInventory(fuel_item)

		if idx == 0 then
			return
		end

		local item_info = turtle.getItemDetail(idx)
		turtle.select(idx)
		turtle.refuel(math.ceil(diff / CURRENT_FUEL_ITEM_EFFICIENCY)) 
	end
end

-- @param {int} n How my blocks to move
function Forward(n)
	for i = 1, n do
		HarvestIfValid(SEED_ITEM_NAME, CROP_TAG_FILTER)
		CheckFuelLevels(MIN_FUEL_FOR_HARVEST_RUN, FUEL_ITEM_NAME)
		turtle.forward()
	end
end

function TurnLeft()
	turtle.turnLeft()
end

function TurnRight()
	turtle.turnRight()
end

-- Traverse the one chunk of the field
-- @param {int} len The length of the field
function TraverseFourByLen(len)
	local lane_right = function()
		TurnRight()
		Forward(1)
		TurnRight()
	end

	local lane_left = function()
		TurnLeft()
		Forward(1)
		TurnLeft()
	end

	Forward(len)
	lane_right()
	Forward(len)
	lane_left()
	Forward(len)
	lane_right()
	Forward(len)
end

-- @param {table} crops A list of item identifiers to deposit
function DropCrops(crops)
	for _, crop in ipairs(crops) do
		local idx = HasItemInInventory(crop)
		while idx ~= 0 do
			turtle.select(idx)
			turtle.dropDown()
			idx = HasItemInInventory(crop)
		end
	end
end

function RegulateSeeds(seed_item, min_seed_count)
	local total = GetTotalItemCount(seed_item)
	local diff = min_seed_count - total

	-- While this is a softlock situation if the provider inventory
	-- runs out of fuel items, the turtle woudn't have made it a whole run
	-- anyways, so I think that's alright.
	while diff > 0 do
		if diff > 64 then
			turtle.suckDown(64)
			diff = diff - 64
		else
			turtle.suckDown(diff)
			break
		end
	end
end


-- @param {string} fuel_item The fuel item's full identifier
function TakeFuel(fuel_item)
	local total = GetTotalItemCount(fuel_item)
	local min_fuel_items = MIN_FUEL_FOR_HARVEST_RUN / CURRENT_FUEL_ITEM_EFFICIENCY
	turtle.suckDown(math.ceil(min_fuel_items - total))
end

function HandleItems()
	Forward(2)
	TurnRight()

	DropCrops(POSSIBLE_HAREVESTS)
	Forward(1)

	RegulateSeeds(SEED_ITEM_NAME, MIN_SEED_COUNT)
	Forward(1)

	TakeFuel(FUEL_ITEM_NAME)
	Forward(1)

	local remaining_width = (SumArray(FIELD_SCHEME) * 4 - 4) + ((#FIELD_SCHEME - 1) * WATER_LANE_WIDTH)
	print("Remaining Width: " .. remaining_width)
	Forward(remaining_width)

	TurnRight()
	Forward(2)
end

function Main()
	while true do
		for chunk_idx, v in ipairs(FIELD_SCHEME) do
			for i = 1, v do
				-- If there are thicc 8-wide fields, this is how we'll position correctly
				if i >= 2 and i % 2 == 0 then
					TurnLeft()
					Forward(1)
					TurnLeft()
				end
				TraverseFourByLen(FIELD_LENGTH)
			end

			-- We don't want to go to the next lane the last time, as it doesn't exist!
			if chunk_idx == #FIELD_SCHEME then
				break
			end

			TurnLeft()
			Forward(WATER_LANE_WIDTH + 1)
			TurnLeft()
		end

		HandleItems()
		sleep(SLEEP_TIME_SECS)
	end
end

Main()