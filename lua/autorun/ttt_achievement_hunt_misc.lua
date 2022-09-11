if SERVER then
    resource.AddWorkshop("2857904452")
    resource.AddFile("materials/ttt_achievement_hunt/custom_textures/star_wars.vmt")
end

if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Miscellaneous logic for the map ttt_achievement_hunt
local spriteMaterial = Material("ttt_achievement_hunt/custom_textures/exclamation_mark")
local amongusSpritePos = Vector(2658.291748, -3586.383789, 665.710266)
local runOnceNight = true
local runOnceRain = true
local playedStillAlive = false
local randomatBlocked = false
local runOnceRandomatMsg = true
local roundCount = 0

if SERVER then
    util.AddNetworkString("AHDrawAmongUsHalo")
    util.AddNetworkString("AHThunderSound")
    SetGlobalBool("AHWelcomeBackButtonPressed", false)

    CreateConVar("ttt_achievement_hunt_block_randomat", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether the ordinary randomat (not the make-a-randomat feature) should be disabled on ttt_achievement_hunt", 0, 1)

    CreateConVar("ttt_achievement_hunt_block_randomat_factory", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether the 'make your own randomat' feature on ttt_achievement_hunt should be disabled", 0, 1)

    CreateConVar("ttt_achievement_hunt_block_among_us", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether the among us event on ttt_achievement_hunt should be disabled", 0, 1)

    -- Displays a center-screen alert for non-innocent players when the amongus is found
    hook.Add("PlayerPostThink", "AHAmongUsAlert", function(ply)
        if ply.ShowedAHAmongUsAlert or not GetGlobalBool("AHAmongUsPickedUp", false) then return end
        local message = "The amongus has been found! Bring it to the \"!\" indicator!"
        net.Start("AHDrawAmongUsHalo")
        net.Send(ply)
        ply:PrintMessage(HUD_PRINTCENTER, message)
        ply:PrintMessage(HUD_PRINTTALK, message)

        timer.Simple(1, function()
            ply:PrintMessage(HUD_PRINTCENTER, message)
        end)

        ply.ShowedAHAmongUsAlert = true
    end)

    hook.Add("Think", "AchievementHuntLightStyleCheck", function()
        -- Darkening the map lighting at night
        if GetGlobalBool("AHNight", false) and runOnceNight then
            engine.LightStyle(0, "b")

            timer.Simple(1, function()
                BroadcastLua("render.RedownloadAllLightmaps(true, true)")
            end)

            AHEarnAchievement("environment")
            runOnceNight = false
        elseif GetGlobalBool("AHNight", false) == false and not runOnceNight then
            engine.LightStyle(0, "m")

            timer.Simple(1, function()
                BroadcastLua("render.RedownloadAllLightmaps(true, true)")
            end)

            runOnceNight = true
        end

        -- Playing a thunder sound while raining intermittently
        if GetGlobalBool("AHRain", false) and runOnceRain then
            timer.Create("AHThunderSoundLoop", 30, 0, function()
                local snd = "ttt_achievement_hunt/minecraft_sounds/thunder" .. math.random(1, 3) .. ".mp3"
                net.Start("AHThunderSound")
                net.WriteString(snd)
                net.Broadcast()
            end)

            AHEarnAchievement("environment")
            runOnceRain = false
        end
    end)

    local lastCorrectNotePlayed = ""

    hook.Add("PlayerUse", "AchievementHuntPlayerInteraction", function(ply, ent)
        local name = ent:GetName()
        if not isstring(name) then return end

        timer.Create("AchievementHuntPlayerUseCooldown", 0.1, 1, function()
            -- Making the steamed hams heal players that press 'e' on them
            if string.StartWith(name, "steamed_ham") then
                timer.Create("AchievmentHunSteamedHamsHeal", 0.1, 1, function()
                    ply:EmitSound("ttt_achievement_hunt/minecraft_sounds/eat.mp3")

                    if ply:Health() + 20 > ply:GetMaxHealth() then
                        ply:SetHealth(ply:GetMaxHealth())
                    else
                        ply:SetHealth(math.min(ply:Health() + 20), ply:GetMaxHealth())
                    end

                    AHEarnAchievement("hams")
                end)
                -- Making the top hat on the map wearable!
                -- Function from wget's "misc. TTT scripts" addon
            elseif name == "prop_top_hat" then
                AHGiveHat(ply)
                ply.hatGiven = true
                ent:Remove()
                AHEarnAchievement("hat")
            elseif playedStillAlive then
                -- Making "Still Alive" play when the 1st 5 notes of the song are played in the correct order, in minecraft note block sounds!
                return false
            elseif name == "button_note_g" then
                lastCorrectNotePlayed = "g"
            elseif name == "button_note_f" then
                if lastCorrectNotePlayed == "g" then
                    lastCorrectNotePlayed = "f#"
                elseif lastCorrectNotePlayed == "e2" then
                    local noteBlockButtons = {}

                    for _, e in ipairs(ents.GetAll()) do
                        local entName = e:GetName()
                        if not isstring(name) then continue end

                        if entName == "note_still_alive" then
                            e:Fire("PlaySound")
                        elseif entName == "note_g" or entName == "note_f#" or entName == "note_e" then
                            e:Fire("Kill")
                        elseif string.StartWith(entName, "button_note") then
                            table.insert(noteBlockButtons, e)
                        end
                    end

                    -- Song is 129 seconds long, so 2*129 = 258
                    -- Press random note block buttons until the song is over
                    timer.Create("PressRandomNoteBlockButtons", 0.2, 645, function()
                        local button = noteBlockButtons[math.random(1, #noteBlockButtons)]

                        if not IsValid(button) then
                            timer.Remove("PressRandomNoteBlockButtons")

                            return
                        end

                        button:Fire("Press")

                        if timer.RepsLeft("PressRandomNoteBlockButtons") == 0 then
                            for _, e in ipairs(ents.FindByName("sprite_note_*")) do
                                e:Fire("Kill")
                            end
                        end
                    end)

                    AHEarnAchievement("stillalive")
                    playedStillAlive = true
                else
                    lastCorrectNotePlayed = ""
                end
            elseif name == "button_note_e" then
                if lastCorrectNotePlayed == "f#" then
                    lastCorrectNotePlayed = "e"
                elseif lastCorrectNotePlayed == "e" then
                    lastCorrectNotePlayed = "e2"
                else
                    lastCorrectNotePlayed = ""
                end
            end
        end)
    end)
end

if CLIENT then
    -- Drawing an "!" marker sprite to guide players where they need to bring the amongus to
    -- The "AHAmongUsPickedUp" global bool is set by lua_run entities on the map
    hook.Add("HUDPaint", "AchievementHuntAmongUsSprite", function()
        if not GetGlobalBool("AHAmongUsPickedUp", false) then return end
        if LocalPlayer():GetPos():Distance(amongusSpritePos) < 300 then return end
        cam.Start3D()
        render.SetMaterial(spriteMaterial)
        render.DrawSprite(amongusSpritePos, 64, 64, COLOR_WHITE)
        cam.End3D()
    end)

    -- Drawing an outline around the amongus for players to see through walls
    net.Receive("AHDrawAmongUsHalo", function()
        local amongusEnt = {GetGlobalEntity("AHAmongUsEnt")}

        hook.Add("PreDrawHalos", "AHDrawAmongUsHalos", function()
            if not GetGlobalBool("AHAmongUsPickedUp", false) then return end
            halo.Add(amongusEnt, Color(255, 0, 0), 0, 0, 1, true, true)
        end)
    end)

    -- Changes the skybox fog colour when nighttime is on
    hook.Add("SetupSkyboxFog", "AHFogToggle", function(scale)
        if GetGlobalBool("AHNight", false) then
            render.FogColor(0, 0, 0)
            render.FogStart(1000 * scale)
            render.FogEnd(2000 * scale)
            render.FogMode(MATERIAL_FOG_LINEAR)

            return true
        end
    end)

    -- Playing a looping rain and thunder sound when it is raining
    hook.Add("Think", "AchievementHuntRainCheck", function()
        if GetGlobalBool("AHRain", false) and runOnceRain then
            runOnceRain = false

            timer.Simple(1, function(arguments)
                surface.PlaySound("ttt_achievement_hunt/minecraft_sounds/rain.mp3")
            end)

            timer.Create("AHRainSoundLoop", 20, 0, function()
                surface.PlaySound("ttt_achievement_hunt/minecraft_sounds/rain.mp3")
            end)
        elseif GetGlobalBool("AHRain", false) == false and not runOnceRain then
            runOnceRain = true
            timer.Remove("AHRainSoundLoop")
            RunConsoleCommand("stopsound")

            timer.Simple(2, function()
                if GetGlobalBool("AHNight", false) then
                    surface.PlaySound("ttt_achievement_hunt/custom_sounds/night.mp3")
                end
            end)
        end

        -- Playing nighttime ambience at night
        if GetGlobalBool("AHNight", false) and runOnceNight then
            runOnceNight = false

            timer.Simple(1, function(arguments)
                -- Preventing the night time sound from playing while it is raining
                if not GetGlobalBool("AHRain", false) then
                    surface.PlaySound("ttt_achievement_hunt/custom_sounds/night.mp3")
                end
            end)

            timer.Create("AHNightSoundLoop", 20, 0, function()
                if GetGlobalBool("AHRain", false) then
                    timer.Remove("AHNightSoundLoop")

                    return
                end

                surface.PlaySound("ttt_achievement_hunt/custom_sounds/night.mp3")
            end)
        elseif GetGlobalBool("AHNight", false) == false and not runOnceNight then
            runOnceNight = true
            timer.Remove("AHNightSoundLoop")
            RunConsoleCommand("stopsound")

            timer.Simple(2, function()
                if GetGlobalBool("AHRain", false) then
                    surface.PlaySound("ttt_achievement_hunt/minecraft_sounds/rain.mp3")
                end
            end)
        end
    end)

    net.Receive("AHThunderSound", function()
        if GetGlobalBool("AHRain", false) == false then return end
        local snd = net.ReadString()
        surface.PlaySound(snd)
    end)
end

hook.Add("TTTEndRound", "AHEndRound", function()
    -- Removing the amongus marker sprite if it's still there, and removing the halo from the amongus
    SetGlobalBool("AHAmongUsPickedUp", false)
    hook.Remove("PreDrawHalos", "AHDrawAmongUsHalos")

    for _, ply in ipairs(player.GetAll()) do
        ply.hatGiven = false
    end
end)

hook.Add("TTTPrepareRound", "AHPrepareRound", function()
    roundCount = roundCount + 1
    -- Resetting the redownload all lightmaps flag on the server
    runOnceNight = true
    runOnceRain = true
    playedStillAlive = false
    SetGlobalBool("AHNight", false)
    SetGlobalBool("AHRain", false)
    timer.Remove("AHRainSoundLoop")
    timer.Remove("AHThunderSoundLoop")
    timer.Remove("AHNightSoundLoop")

    if SERVER then
        engine.LightStyle(0, "m")

        -- Prevent night from happening on the first round as the skybox becomes lit incorrectly (still full-bright even though it is night)
        if roundCount >= 2 then
            timer.Simple(0.1, function()
                for _, ent in ipairs(ents.FindByName("case_day_night")) do
                    ent:Fire("PickRandom")
                end
            end)
        end

        timer.Simple(1, function()
            BroadcastLua("render.RedownloadAllLightmaps(true, true)")

            -- Finding the welcome back button and locking it if the randomat it triggers does not exist, or it has already been pressed before
            if GetGlobalBool("AHWelcomeBackButtonPressed", false) or not (Randomat and Randomat.CanEventRun and Randomat:CanEventRun("welcomeback")) then
                for _, ent in ipairs(ents.FindByName("welcome_back_button")) do
                    ent:Fire("PressIn")
                    ent:Fire("Lock")
                end
            end
        end)

        SetGlobalBool("ttt_achievement_hunt_block_randomat", GetConVar("ttt_achievement_hunt_block_randomat"):GetBool())
        SetGlobalBool("ttt_achievement_hunt_block_randomat_factory", GetConVar("ttt_achievement_hunt_block_randomat_factory"):GetBool())
        SetGlobalBool("ttt_achievement_hunt_block_among_us", GetConVar("ttt_achievement_hunt_block_among_us"):GetBool())

        if GetGlobalBool("ttt_achievement_hunt_block_randomat") and ConVarExists("ttt_randomat_auto") then
            -- Displaying a message every time the ttt_randomat_auto convar is turned back on manually
            if GetConVar("ttt_randomat_auto"):GetBool() then
                randomatBlocked = true
                GetConVar("ttt_randomat_auto"):SetBool(false)

                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("To allow auto-randomat, admins can type in chat: /AHToggleRandomat")
                    end
                end
                -- Displaying the blocked randomat message at the start of the map to admins once, regardless if ttt_randomat_auto is on
            elseif runOnceRandomatMsg then
                for _, ply in ipairs(player.GetAll()) do
                    ply:ChatPrint("The auto-randomat is disabled on this map")

                    if ply:IsAdmin() then
                        ply:ChatPrint("To allow auto-randomat, admins can type in chat: /AHToggleRandomat")
                    end
                end

                runOnceRandomatMsg = false
            end
        end
    end
end)

hook.Add("PlayerSay", "AHToggleRandomatCommand", function(ply, text)
    if not ply:IsAdmin() then return end
    local lowerText = string.lower(text)

    if lowerText == "/ahtogglerandomat" then
        if GetGlobalBool("ttt_achievement_hunt_block_randomat") then
            RunConsoleCommand("ttt_randomat_auto", "1")
            RunConsoleCommand("ttt_achievement_hunt_block_randomat", "0")
            PrintMessage(HUD_PRINTTALK, "Randomat re-enabled!")

            return ""
        else
            RunConsoleCommand("ttt_randomat_auto", "0")
            RunConsoleCommand("ttt_achievement_hunt_block_randomat", "1")
            PrintMessage(HUD_PRINTTALK, "Randomat disabled!")

            return ""
        end
    elseif lowerText == "/ahtogglefactory" then
        if GetGlobalBool("ttt_achievement_hunt_block_randomat_factory") then
            RunConsoleCommand("ttt_achievement_hunt_block_randomat_factory", "0")
            PrintMessage(HUD_PRINTTALK, "Randomat factory enabled!")

            return ""
        else
            RunConsoleCommand("ttt_achievement_hunt_block_randomat_factory", "1")
            PrintMessage(HUD_PRINTTALK, "Randomat factory disabled!")

            return ""
        end
    elseif lowerText == "/ahtoggleamongus" then
        if GetGlobalBool("ttt_achievement_hunt_block_among_us") then
            RunConsoleCommand("ttt_achievement_hunt_block_among_us", "0")
            PrintMessage(HUD_PRINTTALK, "Among Us event enabled!")

            return ""
        else
            RunConsoleCommand("ttt_achievement_hunt_block_among_us", "1")
            PrintMessage(HUD_PRINTTALK, "Among Us event disabled!")
            -- Remove the among us ent and prevent the event from triggering next round if it was returned
            local ent = GetGlobalEntity("AHAmongUsEnt")

            if IsValid(ent) then
                ent:Remove()
            end

            SetGlobalBool("AHNextRoundAmongUs", false)

            return ""
        end
    end
end)

if SERVER then
    hook.Add("TTTBeginRound", "AHBeginRound", function()
        timer.Simple(0.1, function()
            -- Finding the amongus entity to draw a halo around it, and resetting the alert message when it is picked up
            for _, ent in ipairs(ents.FindByName("among_us*")) do
                -- After the amongus event has been done once, remove the amongus until the next map load (So the amongus event can only be done once)
                if GetGlobalBool("AHAmongUsReturned", false) or GetGlobalBool("ttt_achievement_hunt_block_among_us") then
                    ent:Remove()
                end

                SetGlobalEntity("AHAmongUsEnt", ent)
                break
            end

            for _, ply in ipairs(player.GetAll()) do
                ply.ShowedAHAmongUsAlert = false
            end

            -- Give back the top hat if someone equips it before the round starts because TTT removes it... why???
            for _, ply in ipairs(player.GetAll()) do
                if ply.hatGiven then
                    ply.hatGiven = false
                    AHGiveHat(ply)
                end
            end
        end)
    end)
end

hook.Add("ShutDown", "AHMapChange", function()
    if randomatBlocked then
        GetConVar("ttt_randomat_auto"):SetBool(true)
    end
end)