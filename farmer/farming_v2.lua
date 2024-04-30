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
-- 20 Minutes
SLEEP_TIME_SECS = 1200

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
MIN_SEED_COUNT = 64
MAX_SEED_COUNT = 128

-- Width of the water lane between chunks
WATER_LANE_WIDTH = 1

-- Width of each chunk divided by four. 1 2 1 -> 4 8 4
FIELD_SCHEME = { 1, 2, 1 }

-- Global
CROP_TAG_FILTER = "minecraft:crops"
-- MIN_FUEL_FOR_HARVEST_RUN = SumArray(FIELD_SCHEME) * FIELD_LENGTH

-- General functions
-- General functions
-- General functions
-- General functions
-- General functions

-- Find the last free slot.left_bound is the lowest - 1 possible index
-- @param {int} left_bound Lowest - 1 possible index
-- @returns {int|nil} Index, if between Lowest + 1 and 16 (inventory size). nil otherwise
function FindLastFreeSlot(left_bound)
	for i = 16, 1, -1 do
		if i <= left_bound then
			return nil
		end
		if turtle.getItemDetail(i) == nil then
			return i
		end
	end

	return nil
end

-- Push / Stack all items in the turtle's inventory to the back
function StackItems()
	local get_next_idx_of_same_item = function(start, name)
		if start >= 16 then
			return nil
		end

		for i = start, 16 do
		 	local info = turtle.getItemDetail(i)
			if info ~= nil then
				if info["name"] == name then
					return i
				end
			end
		end

		return nil
	end

	for i = 1, 16 do
		local info = turtle.getItemDetail(i)
		if info ~= nil then
			local next_idx = get_next_idx_of_same_item(i + 1, info["name"])
			turtle.select(i)

			if next_idx ~= nil then
				turtle.transferTo(next_idx)
				if turtle.getItemDetail(i) ~= nil then
					local last_idx = FindLastFreeSlot(i)
					if last_idx ~= nil then
						turtle.transferTo(last_idx)
					end
				end
			else
				local last_idx = FindLastFreeSlot(i)
				if last_idx ~= nil then
					turtle.transferTo(last_idx)
				end
			end
		end
	end
end

function DropIdx(idx)
	turtle.select(idx)
	turtle.dropDown()
end

-- @param {function(item_info)} predicate The filter function
-- @param {function(idx)} fn The function to apply to each item
function InvFilterForeach(predicate, fn)
	for i = 1, 16 do
		local item_info = turtle.getItemDetail(i)
		if item_info ~= nil and predicate(item_info) then
			fn(i)
		end
	end
end

-- @returns {table|nil} Block data of the below block, or nil
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

-- @param {string} name The full item identifier eg. minecraft:wheat_seeds
-- @returns {int} Index [1-16] if found, 0 otherwise
function ItemIndex(name)
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

-- @returns {int} The item count
function TotalItemCount(name)
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

-- @returns {float} The fill percentage
function FuelPercentage()
	return turtle.getFuelLevel() / turtle.getFuelLimit()
end

-- @param {string} replacement_seed The name of the replacement crop to be planted
-- @param {string} filter The tag to filter for before harvesting
function HarvestIfValid(filter)
	local data = GetBlockDetailsBelow()
	if data == nil then
		return
	end

	if CheckBlockValid(data, filter) and CheckCropAgeMature(data) then
		turtle.digDown()
	end
end

function TryReplant(seed_item)
	local maybe_idx = ItemIndex(seed_item)
	if maybe_idx == 0 then
		return
	end

	local idx = maybe_idx

	turtle.select(idx)
	turtle.placeDown()
end

-- @param {int} min_fuel The minimum amount of fuel the turtle must have
-- @param {string} fuel_item The item to be consumed as fuel
function TryRefuelIfNeeded(fuel_item)
	if FuelPercentage() < 50 then
		local idx = ItemIndex(fuel_item)
		if idx ~= 0 then
			turtle.select(idx)
			turtle.refuel()
		end
	end
end

-- Movement functions
-- Movement functions
-- Movement functions
-- Movement functions
-- Movement functions

-- @param {int} n How my blocks to move
function Forward(n)
	for i = 1, n do
		HarvestIfValid(CROP_TAG_FILTER)
		TryReplant(SEED_ITEM_NAME)
		TryRefuelIfNeeded(FUEL_ITEM_NAME)
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

-- Scripted Item handling
-- Scripted Item handling
-- Scripted Item handling
-- Scripted Item handling
-- Scripted Item handling

-- @param {table} crops A list of item identifiers to deposit
function DropCrops(crops)
	InvFilterForeach(
		function(item_info)
			for _, crop in ipairs(crops) do
				if item_info["name"] == crop then
					return true
				end
			end
			return false
		end,
		DropIdx
	)
end

-- @param {string} seed_item Seed item identifier
-- @param {int} min_seed_count The minimum seeds the turtle must have while harvesting
-- @param {int} max_seed_count The maximum seeds the turtle should have while harvesting
function RegulateSeeds(seed_item, min_seed_count, max_seed_count)
	local total = TotalItemCount(seed_item)
	local diff = min_seed_count - total

	if diff > 0 then
		turtle.suckDown(diff)
	else
		while TotalItemCount(seed_item) > max_seed_count do
			DropIdx(ItemIndex(seed_item))
		end
	end
end

-- @param {string} fuel_item The fuel item's full identifier
function TakeFuel(fuel_item)
	turtle.select(FindLastFreeSlot(1))

	local perc = FuelPercentage()
	while perc < 50 do
		local got_item = turtle.suckDown()
		if not got_item then
			return
		end
		turtle.refuel() -- Refueling works since we selected a free slot
						-- and the turtle sucks items into its current slot
	end

	-- Drop all the remaining fuel items
	InvFilterForeach(
		function(item_info)
			return item_info["name"] == fuel_item
		end,
		DropIdx
	)
end

function HandleItems()
	Forward(2)
	TurnRight()

	DropCrops(POSSIBLE_HAREVESTS)
	Forward(1)

	RegulateSeeds(SEED_ITEM_NAME, MIN_SEED_COUNT, MAX_SEED_COUNT)
	Forward(1)

	TakeFuel(FUEL_ITEM_NAME)
	Forward(1)

	--               						        * 4 -> The user inputs the amount of 4-wide chunks instead of the block count.
	local remaining_width = (SumArray(FIELD_SCHEME) * 4 - 4) + ((#FIELD_SCHEME - 1) * WATER_LANE_WIDTH)
	Forward(remaining_width)

	TurnRight()
	Forward(2)
end

function DropOverflowSeeds(seed_item, max_seed_count)
	local total = TotalItemCount(seed_item)
	local diff = total - max_seed_count

	while diff > max_seed_count do
		local idx = ItemIndex(seed_item)
		local info = turtle.getItemDetail(idx)
		local smallest = math.min(64, diff, info["count"])

		turtle.select(idx)
		turtle.dropDown(smallest)

		diff = diff - smallest
	end
end

-- Main
-- Main
-- Main
-- Main
-- Main

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
				DropOverflowSeeds(SEED_ITEM_NAME, MAX_SEED_COUNT)
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
		StackItems()
		sleep(SLEEP_TIME_SECS)
	end
end

Main()