if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Server-side logic for the among us event
-- A lot of stuff goes between the client and server...
util.AddNetworkString("AHAmongUsVoteBegin")
util.AddNetworkString("AHAmongUsVoteEnd")
util.AddNetworkString("AHAmongUsPlayerVoted")
util.AddNetworkString("AHAmongUsEventBegin")
util.AddNetworkString("AHAmongUsEventRoundEnd")
util.AddNetworkString("AHAmongUsEmergencyMeeting")
util.AddNetworkString("AHAmongUsEmergencyMeetingCall")
util.AddNetworkString("AHAmongUsSqulech")
util.AddNetworkString("AHAmongUsShhPopup")
util.AddNetworkString("AHAmongUsVictimPopup")
util.AddNetworkString("AHAmongUsBodyReportedPopup")
util.AddNetworkString("AHAmongUsEmergencyMeetingPopup")
util.AddNetworkString("AHAmongUsEmergencyMeetingBind")
util.AddNetworkString("AHAmongUsMeetingCheck")
util.AddNetworkString("AHAmongUsTaskBarUpdate")
util.AddNetworkString("AHAmongUsForceSound")
util.AddNetworkString("AHAmongUsDrawSprite")
util.AddNetworkString("AHAmongUsStopSprite")
util.AddNetworkString("AHAmongUsAlarm")
util.AddNetworkString("AHAmongUsAlarmStop")

-- Most of the usual Among Us options, plus more! (change these in the console or via the randomat ULX mod)
CreateConVar("ah_amongus_voting_timer", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds voting time lasts", 0, 300)

CreateConVar("ah_amongus_discussion_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds discussion time lasts, set to 0 to disable", 0, 120)

CreateConVar("ah_amongus_votepct", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Vote percentage required to eject", 0, 100)

CreateConVar("ah_amongus_freeze", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Freeze players in place while voting", 0, 1)

CreateConVar("ah_amongus_knife_cooldown", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Traitor knife kill cooldown in seconds", 10, 60)

CreateConVar("ah_amongus_emergency_delay", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Emergency meeting delay in seconds", 0, 60)

CreateConVar("ah_amongus_confirm_ejects", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Notify everyone of a player's role when voted out", 0, 1)

CreateConVar("ah_amongus_emergency_meetings", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "No. of emergency meetings per player", 0, 9)

CreateConVar("ah_amongus_anonymous_voting", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Anonymous voting", 0, 1)

CreateConVar("ah_amongus_innocent_vision", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Innocent vision multiplier", 0.2, 5)

CreateConVar("ah_amongus_traitor_vision", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Traitor vision multiplier", 0.2, 5)

CreateConVar("ah_amongus_taskbar_update", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Only update taskbar at meetings", 0, 1)

CreateConVar("ah_amongus_task_threshhold", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds until tasks/guns aren't found too quickly", 0, 120)

local sprintingCvar = CreateConVar("ah_amongus_sprinting", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable sprinting during the randomat", 0, 1)

CreateConVar("ah_amongus_music", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play the Among Us drip music", 0, 1)

-- Variables needed across multiple functions
local playerColors = {}
local playersVoted = {}
local aliveplys = {}
local corpses = {}
local numvoted = 0
local wepspawns = 0
local weaponsFound = 0
local meetingActive = false
local roundOver = true
local removeHurt = false
local playervotes = {}
local votableplayers = {}
local secondsPassedDiscussion = 0
local secondsPassedVoting = 0
local numaliveplayers = 0
local meetingActiveTimeLeft = 0
local traitorCount = 0
local sprintingWasOn = false
SetGlobalBool("AHAmongUsEventActive", false)

local dripMusic = {Sound("ttt_achievement_hunt/amongus/dripmusic1.mp3"), Sound("ttt_achievement_hunt/amongus/dripmusic2.mp3"), Sound("ttt_achievement_hunt/amongus/dripmusic3.mp3")}

local activeHooks = {}

-- The RGB values for each Among Us player colour as per the Among Us Wiki
local auColors = {
    Red = Color(197, 17, 17),
    Blue = Color(19, 46, 209),
    Green = Color(17, 127, 45),
    Pink = Color(237, 84, 186),
    Orange = Color(239, 125, 14),
    Yellow = Color(246, 246, 88),
    Black = Color(63, 71, 78),
    White = Color(214, 224, 240),
    Purple = Color(107, 49, 188),
    Brown = Color(113, 73, 30),
    Cyan = Color(56, 254, 219),
    Lime = Color(80, 239, 57)
}

-- Convars don't exist on the client... So global variables are used instead
local function AHAmongUsConVarResync()
    SetGlobalInt("ah_amongus_voting_timer", GetConVar("ah_amongus_voting_timer"):GetInt())
    SetGlobalInt("ah_amongus_discussion_timer", GetConVar("ah_amongus_discussion_timer"):GetInt())
    SetGlobalInt("ah_amongus_votepct", GetConVar("ah_amongus_votepct"):GetInt())
    SetGlobalBool("ah_amongus_freeze", GetConVar("ah_amongus_freeze"):GetBool())
    SetGlobalInt("ah_amongus_knife_cooldown", GetConVar("ah_amongus_knife_cooldown"):GetInt())
    SetGlobalInt("ah_amongus_emergency_delay", GetConVar("ah_amongus_emergency_delay"):GetInt())
    SetGlobalBool("ah_amongus_confirm_ejects", GetConVar("ah_amongus_confirm_ejects"):GetBool())
    SetGlobalInt("ah_amongus_emergency_meetings", GetConVar("ah_amongus_emergency_meetings"):GetInt())
    SetGlobalBool("ah_amongus_anonymous_voting", GetConVar("ah_amongus_anonymous_voting"):GetBool())
    SetGlobalFloat("ah_amongus_innocent_vision", GetConVar("ah_amongus_innocent_vision"):GetFloat())
    SetGlobalFloat("ah_amongus_traitor_vision", GetConVar("ah_amongus_traitor_vision"):GetFloat())
    SetGlobalBool("ah_amongus_taskbar_update", GetConVar("ah_amongus_taskbar_update"):GetBool())
    SetGlobalInt("ah_amongus_task_threshhold", GetConVar("ah_amongus_task_threshhold"):GetInt())
    SetGlobalBool("ah_amongus_sprinting", GetConVar("ah_amongus_sprinting"):GetBool())
    SetGlobalBool("ah_amongus_music", GetConVar("ah_amongus_music"):GetBool())
end

local function GetAlivePlayers()
    local plys = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            table.insert(plys, ply)
        end
    end

    return plys
end

local function SmallNotify(msg)
    net.Start("AHRandomatAlert")
    net.WriteBool(false)
    net.WriteString(msg)
    net.WriteUInt(5, 8)
    net.Broadcast()
end

local function AddHook(hookType, hookFunc)
    local id = hookType .. "AHAmongUs"
    hook.Add(hookType, id, function(...) return hookFunc(...) end)
    activeHooks[id] = hookType
end

-- Functions to set/reset playermodels without having to deal with networking
-- Other than avoiding jankyness with the timing of net messages, 
-- this function ensures playermodel changing randomats reset players to their actual playermodels
-- when multiple playermodel changing randomats trigger in one round
function GetPlayerModelData(ply)
    local data = {}
    data.model = ply:GetModel()
    data.viewOffset = ply:GetViewOffset()
    data.viewOffsetDucked = ply:GetViewOffsetDucked()
    data.playerColor = ply:GetPlayerColor()
    data.skin = ply:GetSkin()
    data.bodyGroups = ply:GetBodyGroups()
    data.bodygroupValues = {}

    for _, value in ipairs(ply:GetBodyGroups()) do
        data.bodygroupValues[value.id] = ply:GetBodygroup(value.id)
    end

    return data
end

local playermodelData = {}

hook.Add("TTTBeginRound", "AHGetBeginPlayermodels", function()
    for _, ply in ipairs(player.GetAll()) do
        playermodelData[ply] = GetPlayerModelData(ply)
    end
end)

local function ForceSetPlayermodel(ply, data)
    if IsPlayer(ply) then
        -- If just a model by itself is passed, just set the model and leave it at that
        if not istable(data) then
            if (not isstring(data)) or not util.IsValidModel(data) then return end
            FindMetaTable("Entity").SetModel(ply, data)

            return
        end

        -- Else, set everything that's in the data table
        if util.IsValidModel(data.model) then
            FindMetaTable("Entity").SetModel(ply, data.model)
        end

        if data.playerColor then
            ply:SetPlayerColor(data.playerColor)
        end

        if data.skin then
            ply:SetSkin(data.skin)
        end

        if data.bodyGroups then
            for _, value in pairs(data.bodyGroups) do
                ply:SetBodygroup(value.id, data.bodygroupValues[value.id])
            end
        elseif data.bodygroupValues then
            for id = 0, #data.bodygroupValues do
                ply:SetBodygroup(id, data.bodygroupValues[id])
            end
        end

        timer.Simple(0.1, function()
            if data.viewOffset then
                ply:SetViewOffset(data.viewOffset)
            else
                ply:SetViewOffset(Vector(0, 0, 64))
            end

            if data.viewOffsetDucked then
                ply:SetViewOffsetDucked(data.viewOffsetDucked)
            else
                ply:SetViewOffsetDucked(Vector(0, 0, 28))
            end
        end)
    end
end

local function ForceResetAllPlayermodels()
    for _, ply in ipairs(player.GetAll()) do
        if playermodelData[ply] then
            ForceSetPlayermodel(ply, playermodelData[ply])
        end
    end
end

local function HandleReplicatedValue(onreplicated, onglobal)
    if isfunction(CRVersion) and CRVersion("1.9.3") then return onreplicated() end

    return onglobal()
end

local function AHAmongUsVoteEnd()
    -- Unfreeze all players, if convar enabled
    if GetConVar("ah_amongus_freeze"):GetBool() then
        for _, ply in pairs(GetAlivePlayers()) do
            ply:Freeze(false)
            ply:SetMoveType(MOVETYPE_WALK)
            ply:GodDisable()
            ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 200), 0, 0)
            removeHurt = false
        end

        RunConsoleCommand("phys_timescale", "1")
        RunConsoleCommand("ragdoll_sleepaftertime", "1")
    end

    -- Tally up votes and the players who are alive and can therefore vote
    local votenumber = 0

    for k, v in pairs(playervotes) do
        votenumber = votenumber + v
    end

    for k, v in RandomPairs(GetAlivePlayers()) do
        table.insert(aliveplys, v)
    end

    -- If the threshold of votes has been reached...
    if votenumber >= #aliveplys * (GetConVar("ah_amongus_votepct"):GetInt() / 100) and votenumber ~= 0 then
        -- Selects whoever got the most votes to be ejected
        local slainply = table.GetWinningKey(playervotes)
        local winingvotes = playervotes[slainply]
        -- Check if there are multiple people with the most votes
        local winingplys = table.KeysFromValue(playervotes, winingvotes)

        -- If there is a tie, kill no-one
        if #winingplys > 1 then
            SmallNotify("No one was ejected. (Tie)")
            -- If there are enough votes to skip
        elseif slainply == "[Skip Vote]" then
            SmallNotify("No one was ejected. (Skipped)")
        elseif IsPlayer(slainply) then
            -- If a player was voted for
            slainply:Kill()
            traitorCount = 0

            for i, ply in pairs(GetAlivePlayers()) do
                if ply:GetRole() == ROLE_TRAITOR then
                    traitorCount = traitorCount + 1
                end
            end

            if GetConVar("ah_amongus_confirm_ejects"):GetBool() then
                if slainply:GetRole() == ROLE_INNOCENT then
                    if traitorCount ~= 1 then
                        SmallNotify(slainply:Nick() .. " was not a Traitor. " .. traitorCount .. " Traitors remain.")
                    else
                        SmallNotify(slainply:Nick() .. " was not a Traitor. 1 Traitor remains.")
                    end
                else
                    if traitorCount ~= 1 then
                        SmallNotify(slainply:Nick() .. " was a Traitor. " .. traitorCount .. " Traitors remain.")
                    else
                        SmallNotify(slainply:Nick() .. " was a Traitor. 1 Traitor remains.")
                    end
                end
            else
                SmallNotify(slainply:Nick() .. " was ejected.")
            end
        else
            SmallNotify("The voted player is no longer valid. They may have disconnected.")
        end
        -- If nobody votes
    elseif votenumber == 0 then
        SmallNotify("No one voted. (Skipped)")
    else -- If not enough people vote to pass the configured vote threshold
        SmallNotify("Not enough people voted. (Skipped)")
    end

    -- Removing all bodies after a vote
    timer.Simple(0.1, function()
        for i = 1, #corpses do
            corpses[i]:Remove()
        end

        table.Empty(corpses)
    end)

    -- Cleaning up voting tables and variables for the next vote
    secondsPassedDiscussion = 0
    secondsPassedVoting = 0
    numaliveplayers = 0
    numvoted = 0
    meetingActive = false
    table.Empty(playersVoted)
    table.Empty(aliveplys)
    table.Empty(playervotes)
    table.Empty(votableplayers)
    timer.Stop("votekilltimerAHAmongUs")

    for k, v in pairs(playervotes) do
        playervotes[k] = 0
    end

    -- Close the vote window on clients
    net.Start("AHAmongUsVoteEnd")
    net.Broadcast()

    -- Resume any timers, e.g. if knives were on cooldown when the vote started
    for _, ply in ipairs(player.GetAll()) do
        local timerName = "AHAmongUsKnifeTimer" .. ply:SteamID64()

        if timer.Exists(timerName) then
            timer.UnPause(timerName)
        end
    end

    if timer.Exists("AHAmongUsEmergencyMeetingTimer") then
        timer.UnPause("AHAmongUsEmergencyMeetingTimer")
    end

    if timer.Exists("AHAmongUsTotalWeaponDecrease") then
        timer.UnPause("AHAmongUsTotalWeaponDecrease")
    end

    if timer.Exists("AHAmongUsPlayTimer") then
        timer.UnPause("AHAmongUsPlayTimer")
    end

    if timer.Exists("AHAmongUsSabotageO2") then
        timer.UnPause("AHAmongUsSabotageO2")
    end

    if timer.Exists("AHAmongUsSabotageReactor") then
        timer.UnPause("AHAmongUsSabotageReactor")
    end

    for _, ply in pairs(GetAlivePlayers()) do
        -- Remind players of the emergency meeting keybind in chat after the vote is over
        net.Start("AHAmongUsEmergencyMeetingBind")
        net.Send(ply)
    end

    -- Play the Among Us text sound, with a 1 second delay so it doesn't play over the randomat alert sound
    timer.Simple(1, function()
        if not roundOver then
            net.Start("AHAmongUsForceSound")
            net.WriteString("ttt_achievement_hunt/amongus/votetext.mp3")
            net.Broadcast()

            timer.Simple(2.5, function()
                if not roundOver then
                    local chosenMusic = dripMusic[math.random(1, #dripMusic)]
                    net.Start("AHAmongUsForceSound")
                    net.WriteString(chosenMusic)
                    net.Broadcast()
                end
            end)
        end
    end)
end

local function AHAmongUsVote(findername, emergencyMeeting)
    -- Clear anything from a previous vote so current vote has a clean slate
    meetingActiveTimeLeft = GetGlobalFloat("ttt_round_end") - CurTime()
    meetingActive = true
    net.Start("AHAmongUsMeetingCheck")
    net.Broadcast()

    -- Pause any timers including knife cooldowns of traitors, if currently running
    for _, ply in ipairs(player.GetAll()) do
        local timerName = "AHAmongUsKnifeTimer" .. ply:SteamID64()

        if timer.Exists(timerName) then
            timer.Pause(timerName)
        end
    end

    if timer.Exists("AHAmongUsEmergencyMeetingTimer") then
        timer.Pause("AHAmongUsEmergencyMeetingTimer")
    end

    if timer.Exists("AHAmongUsTotalWeaponDecrease") then
        timer.Pause("AHAmongUsTotalWeaponDecrease")
    end

    if timer.Exists("AHAmongUsPlayTimer") then
        timer.Pause("AHAmongUsPlayTimer")
    end

    if timer.Exists("AHAmongUsSabotageO2") then
        timer.Pause("AHAmongUsSabotageO2")
    end

    if timer.Exists("AHAmongUsSabotageReactor") then
        timer.Pause("AHAmongUsSabotageReactor")
    end

    -- Updating everyone's taskbar if only update during meetings is enabled
    if GetConVar("ah_amongus_taskbar_update"):GetBool() then
        net.Start("AHAmongUsTaskBarUpdate")
        net.WriteInt(weaponsFound, 16)
        net.Broadcast()
    end

    for k, ply in pairs(GetAlivePlayers()) do
        -- Clear any previously tallied votes
        votableplayers[k] = ply
        playervotes[ply] = 0
        -- Printing all player's colours and names to chat
        PrintMessage(HUD_PRINTTALK, string.upper(ply:GetNWString("AHAmongUsColor", "Unknown")) .. ": " .. ply:Nick())
        -- Count the number of players alive, so the vote instantly finishes if everyone has voted
        numaliveplayers = numaliveplayers + 1
    end

    playervotes["[Skip Vote]"] = 0
    -- Get the set voting and discussion time
    local amongUsVotingtimer = GetConVar("ah_amongus_voting_timer"):GetInt()
    local amongUsDiscussiontimer = GetConVar("ah_amongus_discussion_timer"):GetInt()

    -- Freeze the map and all players in place (if the convar is enabled)
    if GetConVar("ah_amongus_freeze"):GetBool() then
        for i, ply in pairs(GetAlivePlayers()) do
            ply:Freeze(true)
            ply:SetMoveType(MOVETYPE_NOCLIP)
            ply:GodEnable()
            ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 200), 1, 2)

            timer.Simple(2, function()
                ply:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 200), 1, amongUsVotingtimer + amongUsDiscussiontimer - 2)
            end)
        end

        RunConsoleCommand("phys_timescale", "0")
        RunConsoleCommand("ragdoll_sleepaftertime", "0")
        removeHurt = true
    end

    -- Display body report/emergency meeting popup and sound to all players
    if emergencyMeeting then
        net.Start("AHAmongUsEmergencyMeetingPopup")
        net.Broadcast()

        timer.Simple(2, function()
            SmallNotify(findername .. " has called an emergency meeting!")
        end)
    else
        net.Start("AHAmongUsBodyReportedPopup")
        net.Broadcast()

        timer.Simple(2, function()
            SmallNotify(findername .. " has reported a body. Discuss!")
        end)
    end

    -- Delay voting time until discussion time is over
    timer.Create("AHAmongUsDiscussionTimer", 1, amongUsDiscussiontimer, function()
        if amongUsDiscussiontimer ~= 0 then
            secondsPassedDiscussion = secondsPassedDiscussion + 1
            PrintMessage(HUD_PRINTCENTER, "Voting starts in " .. amongUsDiscussiontimer - secondsPassedDiscussion .. " second(s)")
        end

        -- Once discussion time is over, start the vote
        if timer.RepsLeft("AHAmongUsDiscussionTimer") == 0 then
            -- If there is no discussion time, skip the voting has started notification
            if amongUsDiscussiontimer ~= 0 then
                if GetConVar("ah_amongus_freeze"):GetBool() then
                    SmallNotify("Voting has begun, click a name to vote")
                else
                    SmallNotify("Voting has begun, hold TAB to vote")
                end
            end

            -- Let client know vote has started so vote window can be drawn
            net.Start("AHAmongUsVoteBegin")
            net.Broadcast()

            -- Start the timer to end the vote
            timer.Create("votekilltimerAHAmongUs", 1, 0, function()
                secondsPassedVoting = secondsPassedVoting + 1
                PrintMessage(HUD_PRINTCENTER, amongUsVotingtimer - secondsPassedVoting .. " second(s) left to vote")

                if amongUsVotingtimer - secondsPassedVoting == amongUsVotingtimer / 2 then
                    SmallNotify(amongUsVotingtimer / 2 .. " seconds left on voting!")
                elseif amongUsVotingtimer - secondsPassedVoting == amongUsVotingtimer / 4 then
                    SmallNotify(amongUsVotingtimer / 4 .. " seconds left on voting!")
                elseif secondsPassedVoting == amongUsVotingtimer then
                    AHAmongUsVoteEnd()
                end
            end)
        end
    end)
end

local function Begin()
    -- Workaround to prevent the end function from being triggered before the begin function, letting know that the randomat has indeed been activated and the randomat end function is now allowed to be run
    SetGlobalBool("AHAmongUsEventActive", true)
    roundOver = false
    SetGlobalBool("AHAmongUsGunWinRemove", false)
    SetGlobalBool("AHAmongUsTasksTooFast", false)
    AHAmongUsConVarResync()

    -- Turning off the floor weapons giver mod if installed
    if ConVarExists("ttt_floor_weapons_giver") then
        RunConsoleCommand("ttt_floor_weapons_giver", 0)
    end

    -- Counting the number of weapons on the map for the innocent 'task': pick up all weapons on the map to win
    for _, v in pairs(ents.GetAll()) do
        if (v.Kind == WEAPON_HEAVY or v.Kind == WEAPON_PISTOL or v.Kind == WEAPON_NADE) and v.AutoSpawnable then
            wepspawns = wepspawns + 1
        end
    end

    -- Taking away a quarter of guns to find so players don't have to find ALL of them
    wepspawns = wepspawns * 3 / 4

    -- Artificially adding to the guns found counter if a gun hasn't been found in the last 15 seconds to prevent guns that are out of bounds preventing a win to ensure the game is on a timer
    -- The guns are added after a random amount of extra seconds
    timer.Create("AHAmongUsTotalWeaponDecrease", 15, 0, function()
        timer.Simple(math.random(1, 10), function()
            if not (roundOver or meetingActive) then
                weaponsFound = weaponsFound + math.Round(wepspawns * 1 / 30)
                net.Start("AHAmongUsTaskBarUpdate")
                net.WriteInt(weaponsFound, 16)
                net.Broadcast()
            end
        end)
    end)

    -- Mute all sounds that are not from this randomat
    AddHook("EntityEmitSound", function(sounddata)
        if not string.StartWith(sounddata.SoundName, "amongus") then return false end
    end)

    -- Let the player pick up weapons and nades and count them toward the number found, if all are found innocents win (replacement for Among Us tasks)
    AddHook("WeaponEquip", function(wep, ply)
        if wep.AutoSpawnable then
            weaponsFound = weaponsFound + 1
            net.Start("AHAmongUsTaskBarUpdate")
            net.WriteInt(weaponsFound, 16)
            net.Broadcast()
            timer.Start("AHAmongUsTotalWeaponDecrease")
        end
    end)

    -- Adding the colour table to a different table so if more than 12 people are playing, the choosable colours are able to be reset
    local remainingColors = {}
    table.Add(remainingColors, auColors)
    -- Thanks Desmos + Among Us wiki, this number of traitors ensures games do not instantly end with a double kill
    local traitorCap = math.floor((#GetAlivePlayers() / 2) - 1.5)

    if traitorCap <= 0 then
        traitorCap = 1
    end

    for _, ply in RandomPairs(player.GetAll()) do
        -- Fades out the screen, freezes players and shows the among us intro pop-ups
        ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 1, 2)
        ply:Freeze(true)
        -- Turning off blood so traitors are not so easily incriminated
        ply:SetBloodColor(DONT_BLEED)
        ply:SetCredits(0)

        -- Kill any players trying to exploit the skip vote button to avoid any weird behaviour
        if ply:Nick() == "[Skip Vote]" then
            ply:Kill()
            ply:ChatPrint("Your Steam nickname is incompatible with this randomat.")
        end

        -- Setting everyone to either a traitor or innocent, traitors get their 'traitor kill knife'
        if (ply:GetRole() == ROLE_TRAITOR or (ply.IsTraitorTeam and ply:IsTraitorTeam(ply))) and traitorCount < traitorCap then
            ply:SetRole(ROLE_TRAITOR)
            traitorCount = traitorCount + 1

            timer.Simple(5, function()
                ply:Give("ttt_achievement_hunt_knife")
                ply:SelectWeapon("ttt_achievement_hunt_knife")
            end)
        else
            ply:SetRole(ROLE_INNOCENT)
        end

        -- Sets all living players to an among us playermodel
        -- Wait a few seconds for the among us popup to come on screen so we can hide the changing of everyone's playermodels
        timer.Simple(3, function()
            -- Save a player's model colour, to be restored at the end of the round
            playerColors[ply] = ply:GetPlayerColor()
            -- Sets their model to the Among Us model
            -- Sets everyone's view height to be lower as the among us playermodel is shorter than a standard playermodel
            local data = {}
            data.model = "models/ttt_achievement_hunt/amongus/player/player.mdl"
            data.viewOffset = Vector(0, 0, 48)
            data.viewOffsetDucked = Vector(0, 0, 28)
            ForceSetPlayermodel(ply, data)

            -- Resets the choosable colours for everyone's Among Us playermodel if none are left (happens when there are more than 12 players, as there are 12 colours to choose from)
            if remainingColors == {} then
                table.Add(remainingColors, auColors)
            end

            -- Chooses a random colour, prevents it from being chosen by anyone else, and sets the player to that colour
            local randomColor = table.Random(remainingColors)
            table.RemoveByValue(remainingColors, randomColor)
            ply:SetPlayerColor(randomColor:ToVector())
            ply:SetNWString("AHAmongUsColor", table.KeyFromValue(auColors, randomColor))
            -- Makes players able to walk through each other
            ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
            -- Sets a bool to check if a player has pressed the emergency meeting button
            ply:SetNWBool("AHAmongUsPressedEmergencyButton", false)
        end)

        -- Reminding everyone they can press the buy menu button to call an emergency meeting
        timer.Simple(10, function()
            ply:Freeze(false)
            net.Start("AHAmongUsEmergencyMeetingBind")
            net.Send(ply)

            timer.Simple(1, function()
                net.Start("AHAmongUsForceSound")
                net.WriteString("ttt_achievement_hunt/amongus/dripmusic1.mp3")
                net.Send(ply)
            end)

            -- Fail-safe to hopefully prevent screen staying black
            timer.Simple(3, function()
                ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 200), 0, 0)
            end)
        end)
    end

    -- Updating everyone's new role to everyone else, if roles were changed
    SendFullStateUpdate()

    -- Removes all corpses from before the event began
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        ent:Remove()
    end

    -- Setting all hooks
    -- If someone kills someone else as a traitor, they receive another knife after a cooldown (as set by the cooldown length convar)
    AddHook("PostEntityTakeDamage", function(ent, dmginfo, took)
        local attacker = dmginfo:GetAttacker()

        -- Check entity taking damage is a player that took damage...
        -- Then check they were killed with a knife attack, as a traitor, where they are alive and the round isn't over
        if took and IsPlayer(ent) and dmginfo:GetInflictor():GetClass() == "ttt_achievement_hunt_knife" and attacker:GetRole() == ROLE_TRAITOR and not roundOver and attacker:Alive() and not attacker:IsSpec() then
            local cooldown = GetConVar("ah_amongus_knife_cooldown"):GetInt()
            -- Message on screen and in chat on killing someone and playing the kill squlelch sound
            attacker:PrintMessage(HUD_PRINTCENTER, "Knife is on cooldown for " .. cooldown .. " second(s).")
            net.Start("AHAmongUsSqulech")
            net.Send(attacker)

            if ent:IsPlayer() then
                net.Start("AHAmongUsVictimPopup")
                net.Send(ent)
            end

            local timerName = "AHAmongUsKnifeTimer" .. attacker:SteamID64()

            timer.Create(timerName, 1, cooldown, function()
                -- Live onscreen knife cooldown
                if attacker:Alive() and not roundOver then
                    attacker:PrintMessage(HUD_PRINTCENTER, "Knife is on cooldown for " .. timer.RepsLeft(timerName) .. " second(s).")
                end

                -- Message in chat and giving the knife after the cooldown has completely passed and the traitor is still alive
                if timer.RepsLeft(timerName) == 0 and attacker:Alive() and not roundOver then
                    attacker:Give("ttt_achievement_hunt_knife")
                    attacker:SelectWeapon("ttt_achievement_hunt_knife")
                    attacker:PrintMessage(HUD_PRINTCENTER, "No-one can see you holding the knife")
                end
            end)
        end
    end)

    -- Traitors cannot kill eachother, gives back the knife immediately if attempted
    AddHook("EntityTakeDamage", function(ent, dmginfo)
        local attacker = dmginfo:GetAttacker()

        if IsPlayer(attacker) and dmginfo:GetInflictor():GetClass() == "ttt_achievement_hunt_knife" and ent:GetRole() == ROLE_TRAITOR then
            timer.Simple(0.1, function()
                attacker:Give("ttt_achievement_hunt_knife")
                attacker:SelectWeapon("ttt_achievement_hunt_knife")
            end)

            return true
        end
    end)

    -- Replaces the usual ragdoll corpse with an actual crewmate corpse
    -- Adds corpse to a table so as to be removed after the next vote is finished
    AddHook("TTTOnCorpseCreated", function(corpse)
        corpse:SetModel("models/ttt_achievement_hunt/amongus/player/corpse.mdl")
        table.insert(corpses, corpse)
    end)

    -- Various think functions
    AddHook("Think", function()
        -- Stopping corpses from bleeding
        for i, corpse in pairs(corpses) do
            util.StopBleeding(corpse)
        end

        -- Freezing the round timer as the innocent task now serves this purpose (freeze to 4:20 cause Ynaut)
        if GetGlobalBool("AHAmongUsGunWinRemove") == false then
            SetGlobalFloat("ttt_round_end", CurTime() + 261)
            SetGlobalFloat("ttt_haste_end", CurTime() + 261)
        end

        -- Stopping the TTT round timer during a meeting
        if meetingActive then
            SetGlobalFloat("ttt_round_end", CurTime() + meetingActiveTimeLeft)
            SetGlobalFloat("ttt_haste_end", CurTime() + meetingActiveTimeLeft)
        end

        -- Remove any trigger_hurt map entities which could kill a player while frozen mid-vote
        if removeHurt then
            for _, ent in ipairs(ents.FindByClass("trigger_hurt")) do
                ent:Remove()
            end
        end
    end)

    local playTimeCount = 0

    -- Adding serveral custom win conditions
    AddHook("TTTCheckForWin", function()
        -- Counting the number of alive traitors and innocents
        local alivePlayers = GetAlivePlayers()
        local numAliveTraitors = 0

        for i, ply in pairs(alivePlayers) do
            if ply:GetRole() == ROLE_TRAITOR then
                numAliveTraitors = numAliveTraitors + 1
            end
        end

        local numAliveInnocents = #alivePlayers - numAliveTraitors

        -- If all weapons on the map are picked up, innocents win. This win condition is disabled if guns were found in under a minute and the round timer is un-frozen
        if weaponsFound >= wepspawns and playTimeCount >= 5 and not GetGlobalBool("AHAmongUsGunWinRemove") then
            if playTimeCount <= GetConVar("ah_amongus_task_threshhold"):GetInt() then
                SetGlobalBool("AHAmongUsGunWinRemove", true)
                PrintMessage(HUD_PRINTCENTER, "Guns found too easily!")
                PrintMessage(HUD_PRINTTALK, "Guns were found too easily, win by voting out all traitors!")
                timer.Remove("AHAmongUsTotalWeaponDecrease")
            else
                -- Play the Among Us crewmate/impostor win music at the end of the round
                timer.Simple(0.5, function()
                    PrintMessage(HUD_PRINTTALK, "Enough guns found!\nInnocents win!")
                    net.Start("AHAmongUsForceSound")
                    net.WriteString("ttt_achievement_hunt/amongus/crewmatewin.mp3")
                    net.Broadcast()
                end)

                return WIN_INNOCENT
            end
        elseif numAliveInnocents <= numAliveTraitors then
            -- If there are as many traitors as innocents, traitors win
            timer.Simple(0.5, function()
                PrintMessage(HUD_PRINTTALK, "Equal no. of innocents/traitors!\nTraitors win!")
                net.Start("AHAmongUsForceSound")
                net.WriteString("ttt_achievement_hunt/amongus/impostorwin.mp3")
                net.Broadcast()
            end)

            return WIN_TRAITOR
        elseif numAliveTraitors == 0 then
            -- If all traitors are dead, innocents win
            timer.Simple(0.5, function()
                PrintMessage(HUD_PRINTTALK, "All traitors dead!\nInnocents win!")
                net.Start("AHAmongUsForceSound")
                net.WriteString("ttt_achievement_hunt/amongus/crewmatewin.mp3")
                net.Broadcast()
            end)

            return WIN_INNOCENT
        end
    end)

    -- Initiates a vote when a body is inspected
    AddHook("TTTBodyFound", function(finder, deadply, rag)
        AHAmongUsVote(finder:Nick())
    end)

    -- Disabling sprinting
    -- CR Replicated convar
    if not sprintingCvar:GetBool() then
        HandleReplicatedValue(function()
            sprintingWasOn = GetConVar("ttt_sprint_enabled"):GetBool()
            GetConVar("ttt_sprint_enabled"):SetBool(false)
        end, function()
            sprintingWasOn = GetGlobalBool("ttt_sprint_enabled")
            SetGlobalBool("ttt_sprint_enabled", false)
        end)

        AddHook("TTTSprintStaminaPost", function() return 0 end)
    end

    timer.Create("AHAmongUsPlayTimer", 1, 0, function()
        playTimeCount = playTimeCount + 1
    end)

    timer.Simple(1.5, function()
        net.Start("AHAmongUsShhPopup")
        net.WriteUInt(traitorCount, 8)
        net.Broadcast()
    end)

    -- Creating a timer to strip players of any weapons they pick up
    timer.Simple(2, function()
        timer.Create("AHAmongUsInnocentTask", 0.1, 0, function()
            for _, ply in pairs(GetAlivePlayers()) do
                for _, wep in pairs(ply:GetWeapons()) do
                    local class_name = WEPS.GetClass(wep)

                    if class_name ~= "ttt_achievement_hunt_knife" then
                        ply:StripWeapon(class_name)
                        -- Reset FOV to unscope
                        ply:SetFOV(0, 0.2)
                    end
                end
            end
        end)
    end)

    -- Disables sprinting and displays a notification that it's disabled
    -- Disables opening the buy menu, which instead triggers an emergency meeting if the player is alive
    -- Adds fog to lower the distance players can see
    -- Adds the innocent 'task' progress bar
    timer.Simple(2, function()
        net.Start("AHAmongUsEventBegin")
        net.WriteInt(wepspawns, 16)
        net.Broadcast()
    end)
end

-- Emergency meeting starts after the configured delay if someone pressed the emergency meeting keybind
net.Receive("AHAmongUsEmergencyMeeting", function(ln, ply)
    -- Preventing players from calling multiple emergency meetings at once
    net.Start("AHAmongUsEmergencyMeetingCall")
    net.Broadcast()

    timer.Create("AHAmongUsEmergencyMeetingTimer", 1, GetConVar("ah_amongus_emergency_delay"):GetInt(), function()
        if timer.RepsLeft("AHAmongUsEmergencyMeetingTimer") == 0 then
            -- If the player has died since the emergency meeting was called, a meeting is already ongoing, or the round is over, no emergency meeting happens
            if ply:Alive() and not ply:IsSpec() and not meetingActive and not roundOver then
                AHAmongUsVote(ply:Nick(), true)
            elseif not ply:Alive() then
                ply:PrintMessage(HUD_PRINTCENTER, "You are dead, your emergency meeting was not called.")
                ply:PrintMessage(HUD_PRINTTALK, "You are dead, your emergency meeting was not called.")
            end
        end
    end)
end)

-- Handle player voting
net.Receive("AHAmongUsPlayerVoted", function(ln, ply)
    local repeatVote = false
    local votee = net.ReadString()
    local num = 0

    -- Stop a player from voting again
    for k, v in pairs(playersVoted) do
        if k == ply then
            repeatVote = true
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
        end
    end

    -- Play the vote sound to all players, if they are not trying to vote multiple times
    if not repeatVote then
        net.Start("AHAmongUsForceSound")
        net.WriteString("ttt_achievement_hunt/amongus/vote.mp3")
        net.Broadcast()
    end

    -- Searching for the player that was voted for
    for _, v in pairs(votableplayers) do
        -- Find which player was voted for
        if v:Nick() == votee and not repeatVote then
            playersVoted[ply] = v -- insert player and target into table

            -- Tell everyone who they voted for in chat, if enabled
            if not GetConVar("ah_amongus_anonymous_voting"):GetBool() then
                for _, va in pairs(player.GetAll()) do
                    va:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has voted to eject " .. votee)
                end
            end

            -- Inserting their vote into the playervotes table to be used in AHAmongUsVoteEnd()
            playervotes[v] = playervotes[v] + 1
            -- Saving the total number of votes a player has to be sent to the client (below)
            num = playervotes[v]
        end
    end

    -- If they voted to skip vote
    if votee == "[Skip Vote]" and not repeatVote then
        playersVoted[ply] = "[Skip Vote]" -- insert player and target into table

        -- Tell everyone they voted to skip
        for ka, va in pairs(player.GetAll()) do
            va:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has voted to skip")
        end

        -- Add a vote to the '[Skip Vote]' tally
        playervotes["[Skip Vote]"] = playervotes["[Skip Vote]"] + 1
        num = playervotes["[Skip Vote]"]
    end

    -- Updating the total number of votes on the client-side vote window
    net.Start("AHAmongUsPlayerVoted")
    net.WriteString(votee)
    net.WriteInt(num, 32)
    net.Broadcast()

    -- Counting the number of players voted so far, to check if voting can end early
    if not repeatVote then
        numvoted = numvoted + 1

        -- If everyone has voted, end the vote now
        if numaliveplayers == numvoted then
            AHAmongUsVoteEnd()
        end
    end
end)

local function End()
    -- Workaround to prevent the end function from being triggered before the begin function
    if GetGlobalBool("AHAmongUsEventActive") then
        -- Resetting variables
        table.Empty(playersVoted)
        table.Empty(aliveplys)
        table.Empty(corpses)
        table.Empty(playervotes)
        table.Empty(votableplayers)
        numvoted = 0
        wepspawns = 0
        weaponsFound = 0
        roundOver = true
        removeHurt = false
        meetingActive = false
        traitorCount = 0

        -- Turn the floor weapons giver mod back on if installed
        if ConVarExists("ttt_floor_weapons_giver") then
            RunConsoleCommand("ttt_floor_weapons_giver", 1)
        end

        -- Resetting player propterites
        for _, ply in pairs(player.GetAll()) do
            if playerColors[ply] ~= nil then
                ply:SetPlayerColor(playerColors[ply])
            end

            ply:SetBloodColor(BLOOD_COLOR_RED)
            ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
            ply:Freeze(false)
            ply:SetMoveType(MOVETYPE_WALK)
            ply:GodDisable()
            ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 200), 0, 0)
            timer.Remove("AHAmongUsKnifeTimer" .. ply:SteamID64())
        end

        ForceResetAllPlayermodels()
        timer.Remove("votekilltimerAHAmongUs")
        timer.Remove("AHAmongUsDiscussionTimer")
        timer.Remove("AHAmongUsInnocentTask")
        timer.Remove("AHAmongUsTotalWeaponDecrease")
        timer.Remove("AHAmongUsPlayTimer")
        timer.Remove("AHAmongUsEmergencyMeetingTimer")
        timer.Remove("AHAmongUsTotalWeaponDecrease")
        timer.Remove("AHAmongUsSabotageO2")
        timer.Remove("AHAmongUsSabotageReactor")
        RunConsoleCommand("phys_timescale", "1")
        RunConsoleCommand("ragdoll_sleepaftertime", "1")
        -- Close the vote window if it is open
        net.Start("AHAmongUsVoteEnd")
        net.Broadcast()
        -- Letting each player's client know the randomat is over
        net.Start("AHAmongUsEventRoundEnd")
        net.Broadcast()
        -- Disallowing the randomat end function from being run again until the randomat is activated again
        SetGlobalBool("AHAmongUsEventActive", false)

        -- Re-enabling sprinting
        -- CR Replicated convar
        if sprintingWasOn then
            HandleReplicatedValue(function()
                GetConVar("ttt_sprint_enabled"):SetBool(true)
            end, function()
                SetGlobalBool("ttt_sprint_enabled", true)
            end)
        end
    end
end

-- Removing the amongus prop if the round ends so round times can be changed properly
local prepTime

hook.Add("TTTEndRound", "AHPrepareAHAmongUs", function()
    local ent = GetGlobalEntity("AHAHAmongUsEnt")

    if IsValid(ent) then
        ent:Remove()
    end

    if GetGlobalBool("AHNextRoundAmongUs") then
        -- Changing the prepare round time to 1 second to prevent players from interacting with the map before the among us event starts
        prepTime = GetConVar("ttt_preptime_seconds"):GetInt()
        GetConVar("ttt_preptime_seconds"):SetInt(1)
    end

    -- Remove all hooks and reset the among us event
    if GetGlobalBool("AHAmongUsEventActive") then
        End()

        for id, hookType in pairs(activeHooks) do
            hook.Remove(hookType, id)
        end
    end
end)

-- Triggering the among us event and resetting the round prepare time
hook.Add("TTTBeginRound", "AHTriggerAHAmongUs", function()
    if GetGlobalBool("AHNextRoundAmongUs") then
        SetGlobalBool("AHNextRoundAmongUs", false)

        timer.Simple(1, function()
            Begin()
        end)
    end

    -- Reset the round prep time regardless if the among us event is going to trigger or not
    if prepTime then
        timer.Simple(1, function()
            GetConVar("ttt_preptime_seconds"):SetInt(prepTime)
            prepTime = nil
        end)
    end
end)

hook.Add("ShutDown", "AHAmongUsShutDown", function()
    if prepTime then
        GetConVar("ttt_preptime_seconds"):SetInt(prepTime)
    end
end)