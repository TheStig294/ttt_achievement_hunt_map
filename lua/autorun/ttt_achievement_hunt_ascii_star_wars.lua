if not CLIENT or not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
local f = file.Open("lua/autorun/ttt_achievement_hunt_ascii.lua", "r", "THIRDPARTY")
local frameLines = 13
local currentFrame = 1
local drawingFrame = false
local frame = ""
local holdFrames = 1
local fps = 20
local endOfFile = false
-- Skip past the initial lua comment out line: "--[["
f:Skip(6)

local function GetFrameText()
    if f:EndOfFile() then
        endOfFile = true
        f:Close()

        return ""
    end

    if not drawingFrame then
        frame = ""
        holdFrames = 1

        for i = 1, frameLines + 1 do
            if i == 1 then
                holdFrames = f:ReadLine()
                holdFrames = tonumber(holdFrames)

                if not holdFrames then
                    endOfFile = true

                    if IsValid(f) then
                        f:Close()
                    end

                    return ""
                end
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

hook.Add("PostDrawOpaqueRenderables", "AHDrawAsciiStarWars", function()
    if endOfFile or not GetGlobalBool("AHAsciiStarWars") then return end
    cam.Start3D2D(Vector(2950, -1959, 955), Angle(0, 180, 90), 0.3)
    local text = GetFrameText()
    draw.DrawText(text, "DebugFixed", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
    cam.End3D2D()
end)