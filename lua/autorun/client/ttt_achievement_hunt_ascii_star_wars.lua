if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
local f = file.Read("lua/autorun/client/ttt_achievement_hunt_ascii.lua", "GAME")
local lineTable = string.Split(f, "\n")
local frameLines = 13
local currentFrame = 0
local drawingFrame = false
local frame = ""
local holdFrames = 1
local fps = 20
local endOfFile = false
-- Skip past the initial lua comment out line: "--[["
table.remove(lineTable, 1)

local function GetFrameText()
    if not drawingFrame then
        frame = ""
        holdFrames = 1

        for i = 1, frameLines + 1 do
            local currentLineIndex = currentFrame * (frameLines + 1) + i

            if i == 1 then
                holdFrames = lineTable[currentLineIndex]
                holdFrames = tonumber(holdFrames)

                if not holdFrames then
                    endOfFile = true

                    return ""
                end
            else
                local line = lineTable[currentLineIndex]

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

hook.Add("PostDrawOpaqueRenderables", "AHDrawAsciiStarWars", function()
    if endOfFile or not GetGlobalBool("AHAsciiStarWars") then return end
    cam.Start3D2D(Vector(2988, -1959, 945), Angle(0, 180, 90), 0.45)
    local text = GetFrameText()
    draw.DrawText(text, "DebugFixed", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
    cam.End3D2D()
end)