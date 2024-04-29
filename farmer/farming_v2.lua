-- Farming V2

-- Settings
SLEEP_TIME_SECS = 300
FIELD_LENGTH = 20

function Forward(n)
	for i = 1, n do
		turtle.forward()
	end
end

function Main()
	while true do
		sleep(SLEEP_TIME_SECS)
	end
end

-- Main()
Forward(FIELD_LENGTH - 1)