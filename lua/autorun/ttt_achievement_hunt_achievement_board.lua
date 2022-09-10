-- Logic that runs outside of ttt_achievement_hunt map, the reward for getting all achievements on that map: a wearable crown!
function AHGiveHat(ply, model)
    if not IsValid(ply) or IsValid(ply.hat) then return end
    model = model or "models/player/items/humans/top_hat.mdl"
    local hat = ents.Create("ttt_hat_deerstalker")
    if not IsValid(hat) then return end
    local pos = ply:GetPos()
    hat:SetPos(pos)
    hat:SetAngles(ply:GetAngles())
    hat:SetParent(ply)

    -- Hat doesn't like being set a lot of the time, so attempt to create it twice
    timer.Simple(0, function()
        hat:SetModel(model)
    end)

    timer.Simple(0.1, function()
        if not IsValid(hat) then
            hat = ents.Create("ttt_hat_deerstalker")
            hat:SetPos(pos)
            hat:SetAngles(ply:GetAngles())
            hat:SetParent(ply)
            hat:SetModel(model)
            hat:Spawn()
        else
            hat:SetModel(model)
        end
    end)

    ply.hat = hat
    hat:Spawn()
end

if SERVER then
    util.AddNetworkString("AHCrownButtonPressed")

    CreateConVar("ttt_achievement_hunt_crown", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether the wearable crown is enabled or not", 0, 1)

    CreateConVar("ttt_achievement_hunt_crown_key", "k", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "What key toggles the wearable crown if enabled", 0, 1)

    hook.Add("TTTPrepareRound", "AHSyncCrownConvars", function()
        SetGlobalBool("ttt_achievement_hunt_crown", GetConVar("ttt_achievement_hunt_crown"):GetBool())
        SetGlobalString("ttt_achievement_hunt_crown_key", string.lower(GetConVar("ttt_achievement_hunt_crown_key"):GetString()))
    end)

    -- Sets the players that had the crown equipped from last map
    SetGlobalBool("AHCrownObtained", file.Exists("ttt_achievement_hunt/crownplayers.txt", "DATA"))
    AHCrownPlayers = {}

    if GetGlobalBool("AHCrownObtained") then
        local fileContents = file.Read("ttt_achievement_hunt/crownplayers.txt", "DATA")
        AHCrownPlayers = util.JSONToTable(fileContents) or {}
    end

    -- Re-applies the crown if a player has it on between rounds
    local function CheckForCrown()
        if not GetGlobalBool("ttt_achievement_hunt_crown") then return end

        -- Check if the player is alive, if not remove the crown
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsSpec() or not ply:Alive() then
                if IsValid(ply.hat) then
                    ply.hat:Remove()
                    ply.hat = nil
                end

                continue
            end

            if AHCrownPlayers[ply:SteamID()] then
                AHGiveHat(ply, "models/ttt_achievement_hunt/crown.mdl")
            end
        end
    end

    timer.Create("AHGiveCrownTimer", 1, 0, CheckForCrown)
    hook.Add("TTTBeginRound", "AHGiveCrown", CheckForCrown)
    hook.Add("TTTPrepareRound", "AHGiveCrown", CheckForCrown)

    -- Toggles crown on and off for a player when they press the crown key bind
    net.Receive("AHCrownButtonPressed", function(len, ply)
        local id = ply:SteamID()

        if not AHCrownPlayers[id] then
            AHCrownPlayers[id] = true
            ply:ChatPrint("Crown enabled")
        else
            if IsValid(ply.hat) then
                ply.hat:Remove()
                ply.hat = nil
            end

            AHCrownPlayers[id] = nil
            ply:ChatPrint("Crown disabled")
        end
    end)

    hook.Add("ShutDown", "AHSaveCrownPlayers", function()
        if not GetGlobalBool("AHCrownObtained") or not GetGlobalBool("ttt_achievement_hunt_crown") then return end
        local fileContents = util.TableToJSON(AHCrownPlayers, true)
        file.Write("ttt_achievement_hunt/crownplayers.txt", fileContents)
    end)
end

if CLIENT then
    -- Checking if the bind pressed by a player is the hat key bind, then toggle the crown for the player on the server
    hook.Add("PlayerButtonDown", "AHToggleCrown", function(ply, button)
        if not GetGlobalBool("AHCrownObtained") then return end
        if button ~= input.GetKeyCode(GetGlobalString("ttt_achievement_hunt_crown_key", "k")) then return end

        timer.Create("AHCrownToggleCooldown", 0.1, 1, function()
            net.Start("AHCrownButtonPressed")
            net.SendToServer()
        end)
    end)

    -- Showing a one-time message each map, to players to remind players of the crown toggle button
    hook.Add("TTTPrepareRound", "AHCrownButtonMessage", function()
        if GetGlobalBool("AHCrownObtained") then
            chat.AddText("Press '" .. GetGlobalString("ttt_achievement_hunt_crown_key", "k") .. "' to toggle your crown")
        end

        hook.Remove("TTTPrepareRound", "AHCrownButtonMessage")
    end)
end

if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
local oneAchievementSpritePos = Vector(2660.538086, -1462.968750, 1662.448486)
local spriteMaterial = Material("ttt_achievement_hunt/custom_textures/exclamation_mark")

-- Handles the achievement board and final reward logic for the achievements on the map ttt_achievement_hunt
if SERVER then
    util.AddNetworkString("AHDisplayAchievement")
    util.AddNetworkString("AHOneAchievementLeftIndicator")
    local earnedAchievements = {}
    local fileContent
    local totalAchievementCount
    local finaleLeverPos = Vector(2658, -1502, 2500)
    local leverPressed = false

    -- Displays and records an achievement being earned
    function AHEarnAchievement(achievement)
        -- If the achievement doesn't exist or is already earned, don't try to earn the achievement
        if not isstring(achievement) or not AHAchievements[achievement] or earnedAchievements[achievement] then return end
        earnedAchievements[achievement] = true
        achievement = AHAchievements[achievement]

        timer.Simple(achievement.delay, function()
            -- Removes the achievement's sprite on the achievement board to indicate it is earned
            for _, ent in ipairs(ents.FindByName("achievement_*")) do
                if string.EndsWith(ent:GetName(), achievement.id) then
                    ent:Remove()
                    break
                end
            end

            net.Start("AHDisplayAchievement")
            net.WriteString(achievement.id)
            net.Broadcast()
        end)
    end

    hook.Add("InitPostEntity", "AHReadAchievementFile", function(ply, transition)
        -- Create stats file if it doesn't exist
        if file.Exists("ttt_achievement_hunt/achievements.txt", "DATA") then
            fileContent = file.Read("ttt_achievement_hunt/achievements.txt")
            earnedAchievements = util.JSONToTable(fileContent) or {}
        else
            file.CreateDir("ttt_achievement_hunt")
        end

        -- This hook captures all achievements triggered through map IO rather than lua
        -- Map has lua_run entities that set AHAchievements.(id).mapearned = true, which triggers achievements
        hook.Add("Think", "AHMapAchievementTrigger", function()
            for id, achievement in pairs(AHAchievements) do
                if achievement.mapearned and not earnedAchievements[id] then
                    AHEarnAchievement(id)
                end
            end
        end)

        totalAchievementCount = table.Count(AHAchievements)
    end)

    hook.Add("TTTPrepareRound", "AHAchievmentResets", function()
        leverPressed = false

        -- Removes all light sprites corresponding to earned achievements on the achievement board
        -- That would be placed back by the round/map restarting
        timer.Simple(0.1, function()
            for _, ent in ipairs(ents.FindByName("achievement_*")) do
                for id, _ in pairs(earnedAchievements) do
                    if string.EndsWith(ent:GetName(), id) then
                        ent:Remove()
                        break
                    end
                end
            end

            -- Removes the spectator spawn ents facing the achievement board if the crown has been earned
            -- As well as the message on going up the ladder to the finale room
            if GetGlobalBool("AHCrownObtained") then
                for _, ent in ipairs(ents.FindByClass("ttt_spectator_spawn")) do
                    ent:Remove()
                end

                for _, ent in ipairs(ents.FindByClass("trigger_ladder_up_message")) do
                    ent:Remove()
                end
            end
        end)

        -- Prints a message to everyone to mention an achievement still to earn
        timer.Simple(4, function()
            local earnedAchievementCount = table.Count(earnedAchievements)

            for id, achievement in RandomPairs(AHAchievements) do
                if earnedAchievements[id] then continue end
                if id == "reward" and (earnedAchievementCount < totalAchievementCount - 1) then continue end
                PrintMessage(HUD_PRINTTALK, "Random achievement still to earn: " .. achievement.name .. "\n" .. achievement.desc)
                break
            end

            -- If there is one achievement to be unlocked, it is the final reward achievement
            -- So, set a global bool to flag the final reward room to open and the key to spawn
            if earnedAchievementCount == totalAchievementCount - 1 then
                PrintMessage(HUD_PRINTTALK, "Everyone, go to the '!' indicator, and pull the lever!")
                SetGlobalBool("AHOneAchievementLeft", true)
                net.Start("AHOneAchievementLeftIndicator")
                net.Broadcast()
            end

            -- Preventing the way up the giant squid if the crown is not obtained or there is more than one achievement left to unlock
            -- And displaying a message instead
            if GetGlobalBool("AHCrownObtained") or GetGlobalBool("AHOneAchievementLeft") then
                for _, ent in ipairs(ents.FindByName("trigger_ladder_up_*")) do
                    if ent:GetName() == "trigger_ladder_up_message" then
                        ent:Remove()
                    end

                    if ent:GetName() == "trigger_ladder_up_teleport" then
                        ent:Fire("Enable")
                    end
                end
            end
        end)
    end)

    -- Record all earned achievements in the achievements file when server shuts down/changes maps
    hook.Add("ShutDown", "AHWriteAchievementFile", function()
        fileContent = util.TableToJSON(earnedAchievements, true)
        file.Write("ttt_achievement_hunt/achievements.txt", fileContent)
    end)

    -- Triggers the finale when the lever in the finale room is pressed, triggering effects in the room and spawning the crown to be picked up
    hook.Add("PlayerUse", "AchievementHuntFinaleInteraction", function(ply, useEnt)
        local name = useEnt:GetName()
        if not isstring(name) then return end
        if not string.StartWith(name, "finale_") then return end
        -- Prevent players from triggering the finale before the last achievement is to be earned
        if not GetGlobalBool("AHOneAchievementLeft") then return false end
        if leverPressed then return false end

        -- Disabling the finale while the among us event is active
        if GetGlobalBool("AHAmongUsEventActive") then
            ply:PrintMessage(HUD_PRINTCENTER, "Disabled during Among Us event!")

            return false
        end

        -- If there aren't an unreasonable amount of people on the server, require everyone to be present before starting the finale
        if player.GetCount() < 10 then
            local nearEnts = ents.FindInSphere(useEnt:GetPos(), 300)
            local nearPlys = {}

            for _, ent in ipairs(nearEnts) do
                if IsPlayer(ent) then
                    nearPlys[ent] = true
                end
            end

            if table.Count(nearPlys) < #player.GetHumans() then
                ply:PrintMessage(HUD_PRINTCENTER, "All players must be nearby before activating the reward!")

                for _, farPly in ipairs(player.GetAll()) do
                    if not nearPlys[ply] then
                        farPly:PrintMessage(HUD_PRINTCENTER, "Go to the '!', the finale is starting!")
                    end
                end

                return false
            end
        end

        timer.Create("AchievementHuntFinaleUseCooldown", 0.1, 1, function()
            if name == "finale_lever" then
                leverPressed = true
                BroadcastLua("surface.PlaySound(\"ttt_achievement_hunt/custom_sounds/finale.mp3\")")
                local textEnt = ents.FindByName("finale_text_1")[1]
                textEnt:Fire("Display")

                timer.Simple(2, function()
                    textEnt = ents.FindByName("finale_text_2")[1]
                    textEnt:Fire("Display")
                end)

                timer.Simple(4, function()
                    for _, ent in ipairs(ents.FindByName("finale_smoke")) do
                        ent:Fire("Toggle")
                    end
                end)

                timer.Simple(8.358, function()
                    local explosionEnts = ents.FindByName("finale_spark")

                    timer.Create("AHFinaleSpark", 0.5, 24, function()
                        local spark = table.Random(explosionEnts)
                        spark:Fire("SparkOnce")
                    end)
                end)

                timer.Simple(15.5, function()
                    util.ScreenShake(finaleLeverPos, 10, 5, 12, 5000)
                end)

                timer.Simple(22, function()
                    local explosionEnts = ents.FindByName("finale_explosion")

                    timer.Create("AHFinaleExplosions", 0.5, 12, function()
                        local explosion = table.Random(explosionEnts)
                        explosion:Fire("Explode")
                    end)

                    for _, fadePly in ipairs(player.GetAll()) do
                        fadePly:ScreenFade(SCREENFADE.OUT, Color(255, 255, 255, 255), 5, 0)
                    end
                end)

                timer.Simple(27.134, function()
                    for _, fadePly in ipairs(player.GetAll()) do
                        fadePly:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 200), 0, 0)
                    end

                    timer.Remove("AHFinaleSpark")
                    timer.Remove("AHFinaleExplosions")

                    for _, ent in ipairs(ents.FindByName("finale_*")) do
                        ent:Remove()
                    end

                    local crown = ents.Create("ttt_achievement_hunt_crown")
                    crown:SetPos(finaleLeverPos)
                    crown:Spawn()
                end)
            end
        end)
    end)

    -- Adds a slash command to reset the progress of all achievements
    hook.Add("PlayerSay", "AHAchievementReset", function(ply, text)
        if not ply:IsAdmin() then return end
        local lowerText = string.lower(text)

        if lowerText == "/ahresetachievements" then
            for id, achievement in pairs(AHAchievements) do
                achievement.mapearned = false
            end

            table.Empty(earnedAchievements)
            table.Empty(AHCrownPlayers)
            SetGlobalBool("AHCrownObtained", false)
            PrintMessage(HUD_PRINTTALK, "All achievements reset! This will take effect next round")

            return ""
        end
    end)
end

if CLIENT then
    net.Receive("AHDisplayAchievement", function()
        local id = net.ReadString()
        local achievement = AHAchievements[id]
        local xSize, ySize = 480, 96
        local yOffset = 0
        local xOffset = ScrW()
        -- Drawing the achievement frame on the top right of the screen
        local panel = vgui.Create("DFrame")
        panel:SetPos(xOffset, yOffset)
        panel:SetSize(xSize, ySize)
        panel:SetDraggable(false)
        panel:ShowCloseButton(false)
        panel:SetVisible(true)
        panel:SetDeleteOnClose(true)
        panel:SetTitle("")

        -- Make the achievement popup slide on the screen
        timer.Create("AHAchievementAnimate", 0.02, 50, function()
            xOffset = xOffset - 9.6
            panel:SetPos(xOffset, yOffset)
        end)

        local image = vgui.Create("DImage", panel)
        image:SetImage("materials/ttt_achievement_hunt/achievements/" .. achievement.id .. ".png")
        image:SetPos(0, 0)
        image:SetSize(xSize, ySize)

        -- Playing the longer achievement sound when earning a harder to get achievement
        if achievement.big then
            surface.PlaySound("ttt_achievement_hunt/minecraft_sounds/big_achievement.mp3")
        else
            surface.PlaySound("ttt_achievement_hunt/minecraft_sounds/orb.mp3")
        end

        local colour

        if achievement.big then
            colour = Color(193, 86, 255)
        else
            colour = COLOR_GREEN
        end

        chat.AddText("Everyone has earned the achievement ", colour, "[" .. achievement.name .. "]")

        -- Make the achievement popup slide off the screen and be removed
        timer.Simple(5, function()
            timer.Create("AHAchievementAnimateClose", 0.02, 50, function()
                xOffset = xOffset + 9.6
                panel:SetPos(xOffset, yOffset)
            end)
        end)

        timer.Simple(7, function()
            panel:Close()
        end)
    end)

    -- Drawing an indicator when there is one achievement left to unlock
    net.Receive("AHOneAchievementLeftIndicator", function()
        hook.Add("HUDPaint", "AchievementHuntAmongUsSprite", function()
            if not GetGlobalBool("AHOneAchievementLeft") then return end
            if LocalPlayer():GetPos():Distance(oneAchievementSpritePos) < 300 then return end
            cam.Start3D()
            render.SetMaterial(spriteMaterial)
            render.DrawSprite(oneAchievementSpritePos, 64, 64, COLOR_WHITE)
            cam.End3D()
        end)
    end)
end