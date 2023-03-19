if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
if not CLIENT then return end
local f = file.Open("lua/autorun/ttt_achievement_hunt_ascii.lua", "r", "GAME")
local frameLines = 13
local currentFrame = 1
local drawingFrame = false
local frame = ""
local holdFrames = 1
print("=====")
-- Skip past the initial lua comment out line: "--[["
f:Skip(6)

local function GetFrameText()
    if not drawingFrame then
        for i = 1, frameLines + 1 do
            if i == 1 then
                holdFrames = f:ReadLine()
                holdFrames = tonumber(holdFrames)
                print("Hold seconds:", holdFrames)
            else
                local line = f:ReadLine()
                print(line)

                if line then
                    frame = frame .. line
                else
                    frame = frame .. "\n"
                end
            end
        end

        currentFrame = currentFrame + 1
        drawingFrame = true

        -- Right now we're displaying 1 frame per second, doing some maths on this timer delay will change the fps
        timer.Simple(holdFrames, function()
            drawingFrame = false
        end)
    end

    return frame
end

local stopDraw = false

timer.Simple(30, function()
    stopDraw = true
    f:Close()
end)

hook.Add("PostDrawOpaqueRenderables", "AHDrawAsciiStarWars", function()
    if stopDraw then return end
    -- Get the game's camera angles
    local angle = EyeAngles()
    -- Only use the Yaw component of the angle
    angle = Angle(0, angle.y, 0)
    -- Apply some animation to the angle
    angle.y = angle.y + math.sin(CurTime()) * 10
    -- Correct the angle so it points at the camera
    -- This is usually done by trial and error using Up(), Right() and Forward() axes
    angle:RotateAroundAxis(angle:Up(), -90)
    angle:RotateAroundAxis(angle:Forward(), 90)
    -- A trace just for a position
    local trace = LocalPlayer():GetEyeTrace()
    local pos = trace.HitPos
    -- Raise the hitpos off the ground by 20 units and apply some animation
    pos = pos + Vector(0, 0, math.cos(CurTime() / 2) + 20)
    -- Notice the scale is small, so text looks crispier
    cam.Start3D2D(Vector(2993, -1951, 896), Angle(0, 180, 90), 0.1)
    -- Get the size of the text we are about to draw
    local text = GetFrameText()
    surface.SetFont("Default")
    local tW, tH = surface.GetTextSize("Testing")
    -- This defines amount of padding for the box around the text
    local pad = 5
    -- Draw a rectable. This has to be done before drawing the text, to prevent overlapping
    -- Notice how we start drawing in negative coordinates
    -- This is to make sure the 3d2d display rotates around our position by its center, not left corner
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(-tW / 2 - pad, -pad, tW + pad * 2, tH + pad * 2)
    -- Draw some text
    draw.SimpleText(text, "Default", -tW / 2, 0, color_white)
    cam.End3D2D()
end)