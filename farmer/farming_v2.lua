-- Farming V2

--[[
	turtle.inspect().data {
		state {
			age,
		},
		tags {
			minecraft:crops,
			...,
		},
	},

	turtle.getItemDetail() {
		name,
		count,
	},

]]

-- Settings
SLEEP_TIME_SECS = 300
FIELD_LENGTH = 20
FUEL_ITEM_NAME = "minecraft:coal"
SEED_PLANT_NAME = "minecraft:wheat_seeds"

-- Global
CROP_FILTER = "minecraft:crops"

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
	if data["state"] == nil or data["state"]["age"] == nil then
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

	if CheckBlockValid(filter, data) and CheckCropAgeMature(data) then
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

-- @param {int} n How my blocks to move
function Forward(n)
	for i = 1, n do
		HarvestIfValid()
		turtle.forward()
	end
end

function LeftTurn()
	turtle.turnLeft()
end

function RightTurn()
	turtle.turnRight()
end

-- Traverse the one chunk of the field
-- @param {int} len The length of the field
function TraverseFourByLen(len)
	local lane_right = function()
		RightTurn()
		Forward(1)
		RightTurn()
	end

	local lane_left = function()
		LeftTurn()
		Forward(1)
		LeftTurn()
	end

	Forward(len)
	lane_right()
	Forward(len)
	lane_left()
	Forward(len)
	lane_right()
	Forward(len)
end

function Main()
	while true do
		sleep(SLEEP_TIME_SECS)
	end
end

-- Main()
TraverseFourByLen(5)