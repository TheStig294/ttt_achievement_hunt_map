if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
local f = file.Open("lua/autorun/ttt_achievement_hunt_ascii.lua", "r", "GAME")
print(f:ReadLine())
print(f:ReadLine())
print(f:Tell())
f:Close()