if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
if not CLIENT then return end
local f = file.Open("lua/autorun/ttt_achievement_hunt_ascii.lua", "r", "GAME")
local frameLines = 13
local currentFrame = 1
local drawingFrame = false
local frame = ""
local holdFrames = 1
local fps = 20
-- Skip past the initial lua comment out line: "--[["
f:Skip(6)

local function GetFrameText()
    if not drawingFrame then
        frame = ""
        holdFrames = 1

        for i = 1, frameLines + 1 do
            if i == 1 then
                holdFrames = f:ReadLine()
                holdFrames = tonumber(holdFrames)
            else
                local line = f:ReadLine()

                if line then
                    frame = frame .. line .. "\n"
                else
                    frame = frame .. "\n"
                end
            end
        end

        currentFrame = currentFrame + 1
        drawingFrame = true

        -- Right now we're displaying 1 frame per second, doing some maths on this timer delay will change the fps
        timer.Simple(holdFrames / fps, function()
            drawingFrame = false
        end)
    end

    return frame
end

local drawStarWars = false

hook.Add("PostDrawOpaqueRenderables", "AHDrawAsciiStarWars", function()
    if not drawStarWars then return end
    cam.Start3D2D(Vector(2950, -1959, 955), Angle(0, 180, 90), 0.3)
    local text = GetFrameText()
    draw.DrawText(text, "DebugFixed", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
    cam.End3D2D()
end)