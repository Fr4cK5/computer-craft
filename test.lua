

local t = {
    [0] = "!",
    [1] = "aye",
    [2] = "yo",
}

for i = 0, 10 do
    print(t[i % (#t + 1)])
end
