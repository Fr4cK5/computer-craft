URL = "https://raw.githubusercontent.com/Fr4cK5/computer-craft/master/farmer/farming.lua"
FileName = "farming.lua"

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

DownloadFile(URL, FileName)
