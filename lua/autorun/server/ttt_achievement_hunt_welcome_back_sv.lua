if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

-- Server-side logic for the "Welcome back to TTT!" event on the ttt_achievement_hunt map
local function GetAlivePlayers()
    local alivePlys = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            table.insert(alivePlys, ply)
        end
    end

    return alivePlys
end

local function IsInnocentTeam(ply, skip_detective)
    local ROLE_GLITCH = ROLE_GLITCH or -1
    local ROLE_PHANTOM = ROLE_PHANTOM or -1
    local ROLE_MERCENARY = ROLE_MERCENARY or -1
    -- Handle this early because IsInnocentTeam doesn't
    if skip_detective and IsGoodDetectiveLike(ply) then return false end
    if ply.IsInnocentTeam then return ply:IsInnocentTeam() end
    local role = ply:GetRole()

    return role == ROLE_DETECTIVE or role == ROLE_INNOCENT or role == ROLE_MERCENARY or role == ROLE_PHANTOM or role == ROLE_GLITCH
end

local function IsTraitorTeam(ply, skip_evil_detective)
    local ROLE_DETRAITOR = ROLE_DETRAITOR or -1
    local ROLE_HYPNOTIST = ROLE_HYPNOTIST or -1
    local ROLE_ASSASSIN = ROLE_ASSASSIN or -1
    -- Handle this early because IsTraitorTeam doesn't
    if skip_evil_detective and IsEvilDetectiveLike(ply) then return false end
    if player.IsTraitorTeam then return player.IsTraitorTeam(ply) end
    if ply.IsTraitorTeam then return ply:IsTraitorTeam() end
    local role = ply:GetRole()

    return role == ROLE_TRAITOR or role == ROLE_HYPNOTIST or role == ROLE_ASSASSIN or role == ROLE_DETRAITOR
end

local function IsJesterTeam(ply)
    if ply.IsJesterTeam then return ply:IsJesterTeam() end
    local role = ply:GetRole()

    return role == ROLE_JESTER or role == ROLE_SWAPPER
end

local function IsDetectiveLike(ply)
    local ROLE_DETRAITOR = ROLE_DETRAITOR or -1
    if ply.IsDetectiveLike then return ply:IsDetectiveLike() end
    local role = ply:GetRole()

    return role == ROLE_DETECTIVE or role == ROLE_DETRAITOR
end

local function IsEvilDetectiveLike(ply)
    local role = ply:GetRole()

    return role == ROLE_DETRAITOR or (IsDetectiveLike(ply) and IsTraitorTeam(ply))
end

local function IsGoodDetectiveLike(ply)
    local role = ply:GetRole()

    return role == ROLE_DETECTIVE or (IsDetectiveLike(ply) and IsInnocentTeam(ply))
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

    if CR_VERSION then
        SetGlobalInt("ttt_lootgoblin_announce", GetConVar("ttt_lootgoblin_announce"):GetInt())
        SetGlobalInt("ttt_lootgoblin_notify_mode", GetConVar("ttt_lootgoblin_notify_mode"):GetInt())
    end

    -- Sets flags on players using randomat functions only available on the server
    for _, ply in ipairs(GetAlivePlayers()) do
        if IsGoodDetectiveLike(ply) then
            ply:SetNWBool("WelcomeBackAHIsGoodDetectiveLike", true)
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif IsEvilDetectiveLike(ply) then
            ply:SetNWBool("WelcomeBackAHTraitor", true)
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif IsDetectiveLike(ply) then
            ply:SetNWBool("WelcomeBackAHIsDetectiveLike", true)
        elseif IsJesterTeam(ply) then
            ply:SetNWBool("WelcomeBackAHJester", true)
        elseif IsTraitorTeam(ply) or ply.IsGlitch and ply:IsGlitch() then
            ply:SetNWBool("WelcomeBackAHTraitor", true)
        end

        if ply.IsGlitch and ply:IsGlitch() then
            SetGlobalBool("WelcomeBackAHGlitchExists", true)
        end
    end

    -- Reveals the role of a player when a corpse is searched
    hook.Add("TTTBodyFound", "WelcomeBackAHCorpseSearch", function(_, deadply, rag)
        -- If the dead player has disconnected, they won't be on the scoreboard, so skip them
        if not IsPlayer(deadply) then return end
        -- Get the role of the dead player from the ragdoll itself so artificially created ragdolls like the dead ringer aren't given away
        deadply:SetNWBool("WelcomeBackAHBodyFound", true)
    end)

    -- Reveals the role of a player when a corpse is searched
    hook.Add("TTTCanIdentifyCorpse", "WelcomeBackAHCorpseSearch", function(_, ragdoll)
        local ply = CORPSE.GetPlayer(ragdoll)
        -- If the dead player has disconnected, they won't be on the scoreboard, so skip them
        if not IsPlayer(ply) then return end
        ply:SetNWInt("WelcomeBackAHScoreboardRoleRevealed", ragdoll.was_role)
    end)

    -- Reveals the loot goblin's death to everyone if it is announced
    hook.Add("PostPlayerDeath", "WelcomeBackAHDeath", function(ply)
        if ply.IsLootGoblin and ply:IsLootGoblin() and ply:IsRoleActive() and GetGlobalInt("ttt_lootgoblin_notify_mode") == 4 then
            ply:SetNWBool("WelcomeBackAHBodyFound", true)
            ply:SetNWInt("WelcomeBackAHScoreboardRoleRevealed", ply:GetRole())
        end
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
        ply:SetNWInt("WelcomeBackAHScoreboardRoleRevealed", -1)
        ply:SetNWBool("WelcomeBackAHBodyFound", false)
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