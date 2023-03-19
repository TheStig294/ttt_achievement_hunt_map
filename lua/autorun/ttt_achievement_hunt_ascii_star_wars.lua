if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
if not CLIENT then return end
local f = file.Open("lua/autorun/ttt_achievement_hunt_ascii.lua", "r", "GAME")
local frameLines = 13
print("=====")
-- Skip past the initial lua comment out line: "--[["
f:Skip(6)

local function PrintFrame()
    for i = 1, frameLines + 1 do
        if i == 1 then
            print("Hold seconds:", f:ReadLine())
        else
            print(f:ReadLine())
        end
    end
end

for i = 1, 10 do
    PrintFrame()
end

f:Close()