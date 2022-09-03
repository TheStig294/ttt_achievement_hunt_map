if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Client-side logic for the "Welcome back to TTT!" event on the ttt_achievement_hunt map
local introPopup
local overlayPositions = {}
local YPos = 50
local alpha = 0
local iconSize = 32
local playerNames = {}

-- Displays the intro popup and plays the intro sound chosen by the server
net.Receive("WelcomeBackAHPopup", function()
    local randomIntroSound = net.ReadString()
    overlayPositions = {}
    RunConsoleCommand("stopsound")

    for i = 1, 2 do
        timer.Simple(0.1, function()
            surface.PlaySound("ttt_achievement_hunt/custom_sounds/intro_sound.mp3")

            timer.Simple(3.031, function()
                surface.PlaySound(randomIntroSound)
            end)
        end)
    end

    local pixelOffset = 20
    local offsetLength = 1
    introPopup = vgui.Create("DFrame")
    local xSize = 875 - pixelOffset
    local ySize = 373 - pixelOffset
    local posX = (ScrW() - xSize) / 2
    local posY = (ScrH() - ySize) / 2
    introPopup:SetPos(posX, posY)
    introPopup:SetSize(xSize, ySize)
    introPopup:ShowCloseButton(false)
    introPopup:SetTitle("")
    introPopup:MakePopup()
    introPopup.Paint = function(self, w, h) end
    local image = vgui.Create("DImage", introPopup)
    image:SetImage("materials/ttt_achievement_hunt/custom_textures/ttt_popup.png")
    image:SetPos(0, 0)

    timer.Create("WelcomeBackAHIntroPopupTimer", offsetLength / pixelOffset, pixelOffset * offsetLength, function()
        local repetitions = pixelOffset - timer.RepsLeft("WelcomeBackAHIntroPopupTimer")
        local currentXSize = xSize + repetitions
        local currentYSize = ySize + repetitions
        posX = (ScrW() - currentXSize) / 2
        posY = (ScrH() - currentYSize) / 2
        introPopup:SetPos(posX, posY)
        introPopup:SetSize(currentXSize + repetitions, currentYSize + repetitions)
        image:SetSize(currentXSize + repetitions, currentYSize + repetitions)
        image:Center()
    end)

    timer.Create("WelcomeBackAHCloseIntroPopup", 3.031, 1, function()
        introPopup:Close()
    end)
end)

surface.CreateFont("WelcomeBackAHOverlayFont", {
    font = "Trebuchet24",
    size = 24,
    weight = 1000
})

-- Creates the table of players to be displayed in the role overlay
net.Receive("WelcomeBackAHCreateOverlay", function()
    local playerCount = 0
    local screenWidth = ScrW()

    -- Grabbing player names and the number of them
    for _, ply in ipairs(player.GetAll()) do
        playerCount = playerCount + 1
        playerNames[ply] = ply:Nick()
    end

    -- The magic formula for getting the correct x-coordinates of where each overlay box should be
    -- This is used for getting centred positions of many objects on the screen in a row for HUDs
    -- Sorry for this being a bit of a magic number... took a lot of thought to come up with this formula
    -- Probably would've been faster to google this since I'm probably not the only person to have had this problem to solve, oh well...
    for playerIndex, ply in ipairs(player.GetAll()) do
        overlayPositions[ply] = (playerIndex * screenWidth) / (playerCount + 1)
    end

    -- Fallback colours to use
    local colourTable = {
        [ROLE_INNOCENT] = Color(25, 200, 25, 200),
        [ROLE_TRAITOR] = Color(200, 25, 25, 200),
        [ROLE_DETECTIVE] = Color(25, 25, 200, 200)
    }

    local ROLE_COLORS = ROLE_COLORS or colourTable
    -- Getting the icons for every role if Custom Roles for TTT is installed
    local roleIcons = nil

    if ROLE_STRINGS_SHORT then
        roleIcons = {}

        for roleID, shortName in pairs(ROLE_STRINGS_SHORT) do
            if file.Exists("materials/vgui/ttt/roles/" .. shortName .. "/score_" .. shortName .. ".png", "GAME") then
                roleIcons[roleID] = Material("vgui/ttt/roles/" .. shortName .. "/score_" .. shortName .. ".png")
            else
                roleIcons[roleID] = Material("vgui/ttt/score_" .. shortName .. ".png")
            end
        end
    end

    local defaultColour = Color(100, 100, 100)
    alpha = 0

    timer.Create("WelcomeBackAHFadeIn", 0.01, 100, function()
        alpha = alpha + 0.01
    end)

    hook.Add("DrawOverlay", "WelcomeBackAHDrawNameOverlay", function()
        surface.SetAlphaMultiplier(alpha)

        for ply, XPos in SortedPairsByValue(overlayPositions) do
            if not IsPlayer(ply) then continue end
            local roleColour = defaultColour
            local iconRole

            -- Reveal yourself, searched players, and detectives (when their roles aren't hidden) to everyone
            if ply == LocalPlayer() or ply:GetNWBool("WelcomeBackAHScoreboardRoleRevealed") or (ply:GetNWBool("WelcomeBackAHIsGoodDetectiveLike") and GetGlobalInt("ttt_detective_hide_special_mode", 0) == 0) then
                roleColour = ROLE_COLORS[ply:GetRole()]

                if roleIcons then
                    iconRole = ply:GetRole()
                end
                -- Reveal fellow traitors as plain traitors until they're searched, when there is a glitch
            elseif LocalPlayer():GetNWBool("WelcomeBackAHTraitor") and ply:GetNWBool("WelcomeBackAHTraitor") then
                if GetGlobalBool("WelcomeBackAHGlitchExists") then
                    roleColour = ROLE_COLORS[ROLE_TRAITOR]

                    if roleIcons then
                        iconRole = ROLE_TRAITOR
                    end
                else
                    roleColour = ROLE_COLORS[ply:GetRole()]

                    if roleIcons then
                        iconRole = ply:GetRole()
                    end
                end
            elseif (ply:GetNWBool("WelcomeBackAHIsDetectiveLike") and ply:GetNWBool("HasPromotion")) or (ply:GetNWBool("WelcomeBackAHIsGoodDetectiveLike") and GetGlobalInt("ttt_detective_hide_special_mode", 0) == 1) then
                -- Reveal promoted detective-like players like the impersonator, or special detectives while the hide convar is on, as ordinary detectives
                roleColour = ROLE_COLORS[ROLE_DETECTIVE]

                if roleIcons then
                    iconRole = ROLE_DETECTIVE
                end
            elseif LocalPlayer():GetNWBool("WelcomeBackAHTraitor") and ply:GetNWBool("WelcomeBackAHJester") then
                -- Reveal jesters only to traitors
                roleColour = ROLE_COLORS[ply:GetRole()]

                if roleIcons then
                    iconRole = ROLE_JESTER
                end
            end

            -- Grabbing the name of the player again if they don't have a name yet, but were connected enough to the server to be given an overlay position
            if not playerNames[ply] then
                playerNames[ply] = ply:Nick()
            end

            -- But if the player still doesn't have a name yet, skip them
            if not playerNames[ply] then continue end
            -- Box and player name
            draw.WordBox(16, XPos, YPos, playerNames[ply], "WelcomeBackAHOverlayFont", roleColour, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Role icons
            if iconRole then
                surface.SetMaterial(roleIcons[iconRole])
                surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRect(XPos - iconSize / 2, iconSize / 6, iconSize, iconSize)
            end

            -- Death X
            if not ply:Alive() or ply:IsSpec() then
                -- You have to set the font using surface.SetFont() to use surface.GetTextSize(), even though surface.SetFont() is not used for any drawing
                surface.SetFont("WelcomeBackAHOverlayFont")
                local textWidth, textHeight = surface.GetTextSize(playerNames[ply])
                surface.SetDrawColor(255, 255, 255)
                surface.DrawLine(XPos - (textWidth / 2), YPos - (textHeight / 2), XPos + (textWidth / 2), YPos + (textHeight / 2))
                surface.DrawLine(XPos - (textWidth / 2), YPos + (textHeight / 2), XPos + (textWidth / 2), YPos - (textHeight / 2))
            end
        end
    end)
end)

-- Cleans up everything and slowly fades out the overlay
net.Receive("WelcomeBackAHEnd", function()
    timer.Remove("WelcomeBackAHCloseIntroPopup")
    timer.Remove("WelcomeBackAHFadeIn")

    timer.Create("WelcomeBackAHFadeOut", 0.01, 100, function()
        alpha = alpha - 0.01

        if timer.RepsLeft("WelcomeBackAHFadeOut") == 0 then
            hook.Remove("DrawOverlay", "WelcomeBackAHDrawNameOverlay")
        end
    end)

    if IsValid(introPopup) then
        introPopup:Close()
    end
end)