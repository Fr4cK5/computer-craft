
function GeneratePrefix(line)
    local whitespace = line:match("^%s+")
    if whitespace == nil then
        return ""
    end

    line = line:sub(#whitespace + 1)
    return ("  "):rep(#whitespace)
end

local s = "  aye yo"

local prefix = GeneratePrefix(s)
print(s:sub((#prefix / 2) + 1))


local name = "ae2:quartz_cluster"

if name:match("ae2:quartz_cluster") then
	print("balls in your jaws")
end
