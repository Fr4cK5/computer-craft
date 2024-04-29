local _, dat = turtle.inspectDown()

-- namespace:tag
local tag_type = "minecraft"

for k, v in pairs(dat["tags"]) do
	if string.find(k, tag_type) ~= nil then
		print(k, " ", v)
	end
end
