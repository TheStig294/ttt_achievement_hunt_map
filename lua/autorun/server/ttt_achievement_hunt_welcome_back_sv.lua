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

util.AddNetworkString("WelcomeBackPopup")
util.AddNetworkString("WelcomeBackEnd")

local function Begin()
    -- Puts the intro popup on the screen for all players
    local randomIntroSound = "ttt_achievement_hunt/custom_sounds/intro" .. math.random(3) .. ".mp3"
    net.Start("WelcomeBackPopup")
    net.WriteString(randomIntroSound)
    net.Broadcast()

    if CR_VERSION then
        SetGlobalInt("ttt_lootgoblin_announce", GetConVar("ttt_lootgoblin_announce"):GetInt())
        SetGlobalInt("ttt_lootgoblin_notify_mode", GetConVar("ttt_lootgoblin_notify_mode"):GetInt())
    end

    -- Continually checks for players' roles, in case roles change
    timer.Create("WelcomeBackRandomatCheckRoleChange", 1, 0, function()
        for _, ply in ipairs(GetAlivePlayers()) do
            ply:SetNWBool("WelcomeBackIsDetectiveLike", false)
            ply:SetNWBool("WelcomeBackIsGoodDetectiveLike", false)
            ply:SetNWBool("WelcomeBackJester", false)
            ply:SetNWBool("WelcomeBackTraitor", false)
        end

        for _, ply in ipairs(GetAlivePlayers()) do
            if IsGoodDetectiveLike(ply) then
                ply:SetNWBool("WelcomeBackIsGoodDetectiveLike", true)
                ply:SetNWBool("WelcomeBackIsDetectiveLike", true)
            elseif IsEvilDetectiveLike(ply) then
                ply:SetNWBool("WelcomeBackTraitor", true)
                ply:SetNWBool("WelcomeBackIsDetectiveLike", true)
            elseif IsDetectiveLike(ply) then
                ply:SetNWBool("WelcomeBackIsDetectiveLike", true)
            elseif IsJesterTeam(ply) then
                ply:SetNWBool("WelcomeBackJester", true)
            elseif IsTraitorTeam(ply) or ply.IsGlitch and ply:IsGlitch() then
                ply:SetNWBool("WelcomeBackTraitor", true)
            end

            if ply.IsGlitch and ply:IsGlitch() then
                SetGlobalBool("WelcomeBackGlitchExists", true)
            end
        end
    end)

    -- Reveals the role of a player when a corpse is searched
    hook.Add("TTTBodyFound", "WelcomeBackCorpseSearch", function(_, deadply, rag)
        -- If the dead player has disconnected, they won't be on the scoreboard, so skip them
        if not IsPlayer(deadply) then return end
        -- Get the role of the dead player from the ragdoll itself so artificially created ragdolls like the dead ringer aren't given away
        deadply:SetNWBool("WelcomeBackCrossName", true)
    end)

    -- Reveals the role of a player when a corpse is searched
    hook.Add("TTTCanIdentifyCorpse", "WelcomeBackCorpseSearch", function(_, ragdoll)
        local ply = CORPSE.GetPlayer(ragdoll)
        -- If the dead player has disconnected, they won't be on the scoreboard, so skip them
        if not IsPlayer(ply) then return end
        ply:SetNWInt("WelcomeBackScoreboardRoleRevealed", ragdoll.was_role)
    end)

    -- Reveals the loot goblin's death to everyone if it is announced
    hook.Add("PostPlayerDeath", "WelcomeBackDeath", function(ply)
        if ply.IsLootGoblin and ply:IsLootGoblin() and ply:IsRoleActive() and GetGlobalInt("ttt_lootgoblin_notify_mode") == 4 then
            ply:SetNWBool("WelcomeBackCrossName", true)
            ply:SetNWInt("WelcomeBackScoreboardRoleRevealed", ply:GetRole())
        end
    end)

    -- Starts fading in the role overlay and displays the event's name without making the randomat alert sound
    timer.Create("WelcomeBackAHDrawOverlay", 3.031, 1, function()
        net.Start("AHRandomatAlertSilent")
        net.WriteBool(true)
        net.WriteString("Welcome back to TTT!")
        net.WriteUInt(5, 8)
        net.Broadcast()
    end)
end

local function End()
    -- Removes all popups on the screen
    timer.Remove("WelcomeBackRandomatDrawOverlay")
    timer.Remove("WelcomeBackRandomatCheckRoleChange")
    hook.Remove("TTTBodyFound", "WelcomeBackCorpseSearch")
    hook.Remove("TTTCanIdentifyCorpse", "WelcomeBackCorpseSearch")
    hook.Remove("PostPlayerDeath", "WelcomeBackDeath")
    net.Start("WelcomeBackEnd")
    net.Broadcast()

    -- Removes all flags set
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWBool("WelcomeBackIsDetectiveLike", false)
        ply:SetNWBool("WelcomeBackIsGoodDetectiveLike", false)
        ply:SetNWBool("WelcomeBackJester", false)
        ply:SetNWBool("WelcomeBackTraitor", false)
        ply:SetNWInt("WelcomeBackScoreboardRoleRevealed", -1)
        ply:SetNWBool("WelcomeBackCrossName", false)
    end

    SetGlobalBool("WelcomeBackGlitchExists", false)
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

        if STIG_ROLE_OVERLAY_MOD_INSTALLED then
            ply:PrintMessage(HUD_PRINTCENTER, "You have a role overlay mod installed that already does what this button does!")

            timer.Simple(2, function()
                ply:PrintMessage(HUD_PRINTCENTER, "You have a role overlay mod installed that already does what this button does!")
            end)

            timer.Simple(4, function()
                ply:PrintMessage(HUD_PRINTCENTER, "You have a role overlay mod installed that already does what this button does!")
            end)
        else
            Begin()

            hook.Add("TTTEndRound", "WelcomeBackAHCleanup", function()
                End()
                hook.Remove("TTTEndRound", "WelcomeBackAHCleanup")
            end)
        end
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