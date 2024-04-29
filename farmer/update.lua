local url = ""
local filename = "farming.lua"

shell.run("wget " .. url .. " " .. filename)

-- function DownloadFile(url, filename)
-- 	local req = http.get(url)
-- 	local data = req.readAll()
--
-- 	if fs.exists(filename) then
-- 		fs.delete(filename)
-- 	end
-- 	local file = fs.open(filename, "w")
-- 	file.write(data)
-- 	file.close()
-- end
--
-- DownloadFile(url, filename)
