Files = {
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/certus-farmer/mine-certus.lua",
		filename = "mine-certus.lua",
		ignore = false,
	},
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
