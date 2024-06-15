while true do
	local block, data = turtle.inspect()
	if block then
		if data["name"]:match("ae2:quartz_cluster") then
			turtle.dig()
		end
	end

	local block, data = turtle.inspectDown()
	if block then
		if data["name"]:match("ae2:quartz_cluster") then
			turtle.digDown()
		end
	end
end
