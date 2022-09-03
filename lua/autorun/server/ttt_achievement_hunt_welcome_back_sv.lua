if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

-- Server-side logic for the "Welcome back to TTT!" event on the ttt_achievement_hunt map
local function GetAlivePlayers()
    local plys = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            table.insert(plys, ply)
        end
    end

    return plys
end

util.AddNetworkString("WelcomeBackAHPopup")
util.AddNetworkString("WelcomeBackAHCreateOverlay")
util.AddNetworkString("WelcomeBackAHEnd")

local function Begin()
    -- Puts the intro popup on the screen for all players
    local randomIntroSound = "ttt_achievement_hunt/custom_sounds/intro" .. math.random(1, 3) .. ".mp3"
    net.Start("WelcomeBackAHPopup")
    net.WriteString(randomIntroSound)
    net.Broadcast()
    ROLE_JESTER = ROLE_JESTER or -1
    ROLE_SWAPPER = ROLE_SWAPPER or -1
    ROLE_GLITCH = ROLE_GLITCH or -1

    -- Sets flags on players using functions only available on the server
    for _, ply in ipairs(GetAlivePlayers()) do
        if (ply.IsGoodDetectiveLike and ply:IsGoodDetectiveLike()) or ply:GetRole() == ROLE_DETECTIVE then
            ply:SetNWBool("WelcomeBackAHIsGoodDetectiveLike", true)
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif ply.IsEvilDetectiveLike and ply:IsEvilDetectiveLike() then
            ply:SetNWBool("WelcomeBackAHTraitor", true)
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif (ply.IsDetectiveLike and ply:IsDetectiveLike()) or ply:GetRole() == ROLE_DETECTIVE then
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif (ply.IsJesterTeam and ply:IsJesterTeam()) or ply:GetRole() == ROLE_JESTER or ply:GetRole() == ROLE_SWAPPER then
            ply:SetNWBool("WelcomeBackAHJester", true)
        elseif (ply.IsTraitorTeam and ply:IsTraitorTeam()) or ply:GetRole() == ROLE_TRAITOR or ply:GetRole() == ROLE_GLITCH then
            ply:SetNWBool("WelcomeBackAHTraitor", true)
        end

        if ply:GetRole() == ROLE_GLITCH then
            SetGlobalBool("WelcomeBackAHGlitchExists", true)
        end
    end

    -- Reveals the role of a player when a corpse is searched
    hook.Add("TTTCanIdentifyCorpse", "WelcomeBackAHSearch", function(_, ragdoll)
        local ply = CORPSE.GetPlayer(ragdoll)
        ply:SetNWBool("WelcomeBackAHScoreboardRoleRevealed", true)
    end)

    -- Starts fading in the role overlay and displays the event's name without making the randomat alert sound
    timer.Create("WelcomeBackAHDrawOverlay", 3.031, 1, function()
        net.Start("WelcomeBackAHCreateOverlay")
        net.Broadcast()

        timer.Simple(0.1, function()
            net.Start("AHRandomatAlertSilent")
            net.WriteBool(true)
            net.WriteString("Welcome back to TTT!")
            net.WriteUInt(5, 8)
            net.Broadcast()
        end)
    end)
end

local function End()
    -- Removes all popups on the screen
    hook.Remove("TTTCanIdentifyCorpse", "WelcomeBackAHSearch")
    timer.Remove("WelcomeBackAHDrawOverlay")
    net.Start("WelcomeBackAHEnd")
    net.Broadcast()

    -- Removes all flags set
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWBool("WelcomeBackAHIsDetectiveLike", false)
        ply:SetNWBool("WelcomeBackAHIsGoodDetectiveLike", false)
        ply:SetNWBool("WelcomeBackAHJester", false)
        ply:SetNWBool("WelcomeBackAHTraitor", false)
        ply:SetNWBool("WelcomeBackAHScoreboardRoleRevealed", false)
    end

    SetGlobalBool("WelcomeBackAHGlitchExists", false)
end

local buttonPressed = false

-- Runs the event when the welcome back button is pressed
hook.Add("PlayerUse", "WelcomeBackAHButton", function(ply, ent)
    local name = ent:GetName()
    if not isstring(name) then return end
    if name ~= "button_welcome_back" then return end

    timer.Create("WelcomeBackAHButtonCooldown", 0.1, 1, function()
        if buttonPressed then
            ply:PrintMessage(HUD_PRINTCENTER, "This event can only be triggered once")

            return false
        end

        -- More than 8 alive players will result in the overlay going off the screen and causing lag eventually
        if #GetAlivePlayers() > 8 then
            ply:PrintMessage(HUD_PRINTCENTER, "This event requires there to be less than 9 players")

            return false
        end

        buttonPressed = true
        AHEarnAchievement("welcomeback")
        Begin()

        hook.Add("TTTEndRound", "WelcomeBackAHCleanup", function()
            End()
            hook.Remove("TTTEndRound", "WelcomeBackAHCleanup")
        end)
    end)
end)

-- Press in the button that triggers the event to indicate it won't trigger anymore
hook.Add("TTTPrepareRound", "WelcomeBackPressInButton", function()
    if not buttonPressed then return end

    timer.Simple(1, function()
        for _, ent in ipairs(ents.FindByName("button_welcome_back")) do
            ent:Fire("PressIn")
        end
    end)
end)