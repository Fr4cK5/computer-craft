-- Farming V2

-- Settings
SLEEP_TIME_SECS = 300
FIELD_LENGTH = 20

function Forward(n)
	for i = 1, n do
		turtle.forward()
	end
end

function LeftTurn()
	turtle.turnLeft()
end

function RightTurn()
	turtle.turnLeft()
end

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