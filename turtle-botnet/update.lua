Files = {
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/turtle-botnet/cnc_server.lua",
		filename = "cnc_server.lua",
		ignore = false,
	},
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/turtle-botnet/bot.lua",
		filename = "bot.lua",
		ignore = false,
	},
	{
		url = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/turtle-botnet/cmd_handler.lua",
		filename = "cmd_handler.lua",
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
