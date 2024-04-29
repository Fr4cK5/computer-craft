Files = {
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/farmer/farming_v2.lua",
		filename = "farming_v2.lua",
		ignore = false,
	},
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/farmer/farming.lua",
		filename = "farming.lua",
		ignore = true,
	}
}

function DownloadFile(url, filename)
	local req = http.get(url)
	local data = req.readAll()

	if fs.exists(filename) then
		fs.delete(filename)
	end
	local file = fs.open(filename, "w")
	file.write(data)
	file.close()
end

for i = 1, #Files do
	if not Files[i].ignore then
		DownloadFile(
			Files[i].url,
			Files[i].filename
		)
	end
end
