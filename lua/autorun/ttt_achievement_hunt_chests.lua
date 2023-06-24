if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

-- This lua file purely handles the effects of opening the chests inside the chest house
if SERVER then
    util.AddNetworkString("AHDrawTomChestHalo")
    local lowerChestOpened = false
    local upperChestOpened = false

    hook.Add("PlayerUse", "AchievementHuntChestInteraction", function(ply, ent)
        local name = ent:GetName()
        if not isstring(name) then return end
        if not string.StartWith(name, "chest_") then return end
        -- Prevent players from triggering the effects of opening chests after they are already opened
        if GetGlobalBool(ent:GetName() .. "_opened") then return false end

        -- Disabling the chest house while the among us event is active
        if GetGlobalBool("AHAmongUsEventActive") then
            ply:PrintMessage(HUD_PRINTCENTER, "Disabled during Among Us event!")

            return false
        end

        -- Prevent players from opening chests if they've already opened one
        if ply.AHOpenedChest then
            ply:PrintMessage(HUD_PRINTCENTER, "You can only open one chest per round. Get someone else or come back next round!")

            timer.Simple(1.5, function()
                ply:PrintMessage(HUD_PRINTCENTER, "You can only open one chest per round. Get someone else or come back next round!")
            end)

            return false
        end

        -- Prevents the senate's chest from erroring when the player cap is reached
        if player.GetCount() == game.MaxPlayers() and name == "chest_senate" then
            ply:PrintMessage(HUD_PRINTCENTER, "Max players! Someone must disconnect!")

            timer.Create("AHMaxPlayerWarning", 0.1, 1, function()
                ply:PrintMessage(HUD_PRINTTALK, "Server's max players reached! Someone must disconnect for this chest to work!")
            end)

            return false
        end

        SetGlobalBool(name .. "_opened", true)
        ply.AHOpenedChest = true
        ent:Fire("Toggle")

        timer.Create("AchievementHuntChestUseCooldown", 0.1, 1, function()
            if name == "chest_mattymel" then
                lowerChestOpened = true
                ent:EmitSound("ambient/creatures/seagull_idle1.wav")
                -- Makes the player's head 5x bigger
                -- Taken from Malivil's 'Big Head Mode' randomat
                local boneId = ply:LookupBone("ValveBiped.Bip01_Head1")

                if boneId ~= nil then
                    ply:ManipulateBoneScale(boneId, Vector(5, 5, 5))
                end
            elseif name == "chest_chungus" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_chungus_meme.mp3")
            elseif name == "chest_stig" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_stig_some_say.mp3")
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_stig_some_say.mp3")
            elseif name == "chest_killerbrut" then
                lowerChestOpened = true

                -- Re-creates having a sticky bomb planted on the player that opened the chest, which explodes after 30 seconds
                timer.Create("chest_killerbrut_beep", 3, 0, function()
                    if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then
                        timer.Remove("chest_killerbrut_beep")

                        return
                    end

                    ply:EmitSound("weapons/c4/c4_beep1.wav")
                end)

                timer.Create("chest_killerbrut_explosion", 30, 1, function()
                    if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then
                        timer.Remove("chest_killerbrut_explosion")

                        return
                    end

                    timer.Remove("chest_killerbrut_beep")
                    ply:EmitSound("ttt_achievement_hunt/custom_sounds/chest_killerbrut_wtf.mp3")

                    timer.Simple(0.773, function()
                        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
                        local explode = ents.Create("env_explosion")
                        explode:SetPos(ply:GetPos())
                        explode:SetOwner(ply)
                        explode:Spawn()
                        explode:SetKeyValue("iMagnitude", "200")
                        explode:SetKeyValue("iRadiusOverride", "256")
                        explode:Fire("Explode", 0, 0)
                    end)
                end)

                hook.Add("TTTPrepareRound", "AHRemoveKillerbrutChest", function()
                    timer.Remove("chest_killerbrut_beep")
                    timer.Remove("chest_killerbrut_explosion")
                end)
            elseif name == "chest_remag" then
                lowerChestOpened = true
            elseif name == "chest_apple_pie" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_apple_pie.mp3")
                ply:SetModelScale(0.5, 1)
                ply:SetGravity(1.5)
                ply:SetStepSize(18 * 0.5)
                ply:SetHull(Vector(-16, -16, 0) * 0.5, Vector(16, 16, 72) * 0.5)
                ply:SetHullDuck(Vector(-16, -16, 0) * 0.5, Vector(16, 16, 36) * 0.5)

                if SERVER then
                    ply:SetHealth(ply:Health() * 0.5)
                    ply:SetMaxHealth(ply:Health())
                end

                local OGHeight = {ply:GetViewOffset().z, ply:GetViewOffsetDucked().z}

                timer.Create("AHApplePieChestShrink", 0.01, 100, function()
                    local counter = 100 - timer.RepsLeft("AHApplePieChestShrink")

                    if counter < 50 then
                        ply:SetViewOffset(Vector(0, 0, OGHeight[1] - (counter * OGHeight[1] / 100)))
                        ply:SetViewOffsetDucked(Vector(0, 0, OGHeight[2] - (counter * OGHeight[2] / 100)))
                    end
                end)
            elseif name == "chest_microsoft_word" then
                lowerChestOpened = true

                -- Plays the prop blaster sound and explodes the chest
                timer.Simple(2, function()
                    ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_microsoft_word_blast.mp3")
                end)

                timer.Simple(4, function()
                    local explode = ents.Create("env_explosion")
                    explode:SetPos(ent:GetPos())
                    explode:SetOwner(ply)
                    explode:Spawn()
                    explode:SetKeyValue("iMagnitude", "200")
                    explode:SetKeyValue("iRadiusOverride", "256")
                    explode:Fire("Explode", 0, 0)
                    ent:Remove()

                    for _, e in ipairs(ents.FindByName("brush_chest_microsoft_word")) do
                        e:Remove()
                    end
                end)
            elseif name == "chest_slimex" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_slimex.mp3")
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_slimex.mp3")
            elseif name == "chest_keoz" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_keoz.mp3")
            elseif name == "chest_dungeon" then
                lowerChestOpened = true
            elseif name == "chest_spazz" then
                upperChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_spazz.mp3")
            elseif name == "chest_tj" then
                upperChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_tj.mp3")
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_tj.mp3")
            elseif name == "chest_alex" then
                upperChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_alex.mp3")
            elseif name == "chest_jonas" then
                upperChestOpened = true
            elseif name == "chest_mal" then
                upperChestOpened = true
            elseif name == "chest_mark" then
                upperChestOpened = true
            elseif name == "chest_bulba" then
                upperChestOpened = true
            elseif name == "chest_dingy" then
                upperChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_dingy.mp3")

                timer.Simple(3.9, function()
                    local wonderWeapons = {"tfa_acidgat", "tfa_blundergat", "tfa_jetgun", "tfa_raygun", "tfa_raygun_mark2", "tfa_scavenger", "tfa_shrinkray", "tfa_sliquifier", "tfa_staff_wind", "tfa_thundergun", "tfa_vr11", "tfa_wavegun", "tfa_wintershowl", "tfa_wunderwaffe", "tfa_staff_lightning"}

                    for _, wep in RandomPairs(wonderWeapons) do
                        if weapons.Get(wep) ~= nil then
                            ply:Give(wep)
                            break
                        end
                    end
                end)
            elseif name == "chest_neil" then
                upperChestOpened = true
            elseif name == "chest_noxx" then
                upperChestOpened = true
            elseif name == "chest_kobus" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_kobus.mp3")
            elseif name == "chest_angie" then
                lowerChestOpened = true
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_angie.mp3")
            elseif name == "chest_bruce" then
                lowerChestOpened = true
                -- Turns you invisible and puts a pig model on top of you the follows you around an faces the way you do
                local pig = ents.Create("prop_dynamic")
                pig:SetModel("models/ttt_achievement_hunt/mcmodelpack/mobs/mob.mdl")
                pig:SetSkin(3)
                pig:Spawn()
                ply:SetNoDraw(true)
                SetGlobalEntity("AHPigModelPlayer", ply)

                hook.Add("Think", "AHPigModel", function()
                    -- Remove the pig and set the player to normal after they die
                    if not IsValid(pig) or (IsValid(ply) and not ply:Alive() and ply:IsSpec()) then
                        ply:SetNoDraw(false)
                        SetGlobalEntity("AHPigModelPlayer", nil)

                        if IsValid(pig) then
                            pig:Remove()
                        end

                        hook.Remove("Think", "AHPigModel")

                        return
                    end

                    -- If the player isn't there for whatever reason, remove the pig and the hook
                    if not IsValid(ply) then
                        SetGlobalEntity("AHPigModelPlayer", nil)

                        if IsValid(pig) then
                            pig:Remove()
                        end

                        hook.Remove("Think", "AHPigModel")

                        return
                    end

                    pig:SetPos(ply:GetPos())
                    -- Makes the pig look the same direction as the player
                    -- Pig spawns rotated 90 degrees the wrong way for some reason...
                    local angles = ply:GetAngles()
                    angles.y = angles.y + 90
                    pig:SetAngles(angles)
                end)
            elseif name == "chest_tom" then
                lowerChestOpened = true
            elseif name == "chest_spirit" then
                lowerChestOpened = true
            elseif name == "chest_crimson" then
                lowerChestOpened = true
            elseif name == "chest_lewis" then
                upperChestOpened = true
                -- Plays a "Hwapoon" sound and gives the player a harpoon, if installed
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_lewis.mp3")

                if weapons.Get("ttt_m9k_harpoon") then
                    ply:Give("ttt_m9k_harpoon")
                elseif weapons.Get("weapon_ttt_hwapoon") then
                    ply:Give("weapon_ttt_hwapoon")
                end

                -- Gives them the lewis playermodel, if installed
                if util.IsValidModel("models/bradyjharty/yogscast/lewis.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/bradyjharty/yogscast/lewis.mdl")
                    ply:SetViewOffset(Vector(0, 0, 64))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                hook.Add("PlayerButtonDown", "AHChestLewis", function(buttonply, button)
                    if not IsFirstTimePredicted() then return end

                    if button == MOUSE_LEFT and IsValid(buttonply:GetActiveWeapon()) and (buttonply:GetActiveWeapon():GetClass() == "ttt_m9k_harpoon" or ply:GetActiveWeapon():GetClass() == "weapon_ttt_hwapoon") then
                        buttonply:EmitSound("ttt_achievement_hunt/custom_sounds/chest_lewis.mp3")
                        hook.Remove("PlayerButtonDown", "AHChestLewis")
                    end
                end)
            elseif name == "chest_ben" then
                upperChestOpened = true
                -- Plays a "Blegh" sound
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_ben.mp3")

                -- Gives them the ben playermodel, if installed
                if util.IsValidModel("models/bradyjharty/yogscast/sharky.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/bradyjharty/yogscast/sharky.mdl")
                    ply.oldViewOffset = ply:GetViewOffset()
                    ply.oldViewOffsetDucked = ply:GetViewOffsetDucked()
                    ply:SetViewOffset(Vector(0, 0, 40))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                -- Everyone hears a "Blegh!" sound the next time they die
                hook.Add("DoPlayerDeath", "AHChestBen", function(deathPly, attacker, dmginfo)
                    -- Silence the usual death noise
                    dmginfo:SetDamageType(DMG_SLASH)
                    BroadcastLua("surface.PlaySound(\"ttt_achievement_hunt/custom_sounds/chest_ben.mp3\")")
                    hook.Remove("DoPlayerDeath", "AHChestBen")
                end)
            elseif name == "chest_duncan" then
                upperChestOpened = true
                -- Plays a "O rubber tree" sound
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_duncan.mp3")

                -- Gives them the doncon playermodel, if installed
                if util.IsValidModel("models/player/Doncon/doncon.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/player/Doncon/doncon.mdl")
                    ply:SetViewOffset(Vector(0, 0, 64))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                if weapons.Get("doncmk2_swep") then
                    ply:Give("doncmk2_swep")
                end
            elseif name == "chest_rythain" then
                upperChestOpened = true
                -- Plays a "Objection!" sound
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_rythain.mp3")
                -- Turns you invisible and puts a chair model on top of you the follows you around an faces the way you do
                ply.oldViewOffset = ply:GetViewOffset()
                ply.oldViewOffsetDucked = ply:GetViewOffsetDucked()
                ply:SetViewOffset(Vector(0, 0, 40))
                ply:SetViewOffsetDucked(Vector(0, 0, 28))
                local chair = ents.Create("prop_dynamic")
                chair:SetModel("models/nova/chair_plastic01.mdl")
                chair:Spawn()
                ply:SetNoDraw(true)
                SetGlobalEntity("AHChairModelPlayer", ply)

                hook.Add("Think", "AHChairModel", function()
                    -- Remove the chair and set the player to normal after they die
                    if not IsValid(chair) or (IsValid(ply) and (not ply:Alive() or ply:IsSpec())) then
                        ply:SetNoDraw(false)
                        SetGlobalEntity("AHChairModelPlayer", nil)

                        if IsValid(chair) then
                            chair:Remove()
                        end

                        hook.Remove("Think", "AHChairModel")

                        return
                    end

                    -- If the player isn't there for whatever reason, remove the chair and the hook
                    if not IsValid(ply) then
                        SetGlobalEntity("AHChairModelPlayer", nil)

                        if IsValid(chair) then
                            chair:Remove()
                        end

                        hook.Remove("Think", "AHChairModel")

                        return
                    end

                    chair:SetPos(ply:GetPos())
                    -- Makes the chair look the same direction as the player
                    -- Chair spawns rotated 90 degrees the wrong way for some reason...
                    local angles = ply:GetAngles()
                    angles.y = angles.y - 90
                    chair:SetAngles(angles)
                end)

                hook.Add("TTTOnCorpseCreated", "AHChairModelDeath", function(rag)
                    local ragPly = CORPSE.GetPlayer(rag)

                    if not IsValid(ply) or not IsValid(GetGlobalEntity("AHChairModelPlayer", nil)) then
                        SetGlobalEntity("AHChairModelPlayer", nil)

                        if IsValid(chair) then
                            chair:Remove()
                        end

                        hook.Remove("TTTOnCorpseCreated", "AHChairModelDeath")

                        return
                    end

                    if ragPly == ply then
                        rag:SetNoDraw(true)
                        local corpseChair = ents.Create("prop_dynamic")
                        corpseChair:SetModel("models/nova/chair_plastic01.mdl")
                        corpseChair:SetPos(rag:GetPos())
                        corpseChair:SetParent(rag)
                        corpseChair:Spawn()
                    end
                end)
            elseif name == "chest_zylus" then
                upperChestOpened = true

                -- Gives them the detective kermit playermodel, if installed
                if util.IsValidModel("models/player/jenssons/kermit.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/player/jenssons/kermit.mdl")
                    ply:SetViewOffset(Vector(0, 0, 64))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                -- Display non-canon round message on death
                hook.Add("PostPlayerDeath", "AHChestZylus", function(deathPly)
                    if IsValid(ply) and ply == deathPly then
                        timer.Create("AHChestZylusMessageTimer", 1, 3, function()
                            ply:PrintMessage(HUD_PRINTCENTER, "This was a non-canon round...")
                        end)
                    end

                    hook.Remove("PostPlayerDeath", "AHChestZylus")
                end)

                -- Sets your role to detective, or impersonator if you are a traitor, if installed
                if ply.IsTraitorTeam then
                    if ply:IsTraitorTeam() then
                        ply:SetRole(ROLE_IMPERSONATOR)
                        ply:HandleDetectiveLikePromotion()
                    else
                        ply:SetRole(ROLE_DETECTIVE)
                    end
                else
                    ply:SetRole(ROLE_DETECTIVE)
                end

                SendFullStateUpdate()
            elseif name == "chest_senate" then
                upperChestOpened = true
                AHEarnAchievement("tom")
                -- Plays a clip of Tom
                BroadcastLua("surface.PlaySound(\"ttt_achievement_hunt/custom_sounds/chest_senate.mp3\")")
                -- Spawns a bot with a "Palpatine" playermodel, if installed, and sets them to the Old Man role if possible
                net.Start("AHDrawTomChestHalo")
                net.Broadcast()

                timer.Simple(0.5, function()
                    RunConsoleCommand("bot")
                end)

                timer.Simple(2, function()
                    -- Get the last bot, which will be the one we just spawned
                    local tom = player.GetBots()[#player.GetBots()]
                    tom:SpawnForRound(true)

                    if util.IsValidModel("models/player/emperor_palpatine.mdl") then
                        tom:SetModel("models/player/emperor_palpatine.mdl")
                    end

                    tom:SetRole(ROLE_OLDMAN or ROLE_INNOCENT)
                    tom:SetHealth(100)
                    tom:SetMaxHealth(100)
                    tom:SetNWString("PlayerName", "Angor")
                    tom:Give("weapon_zm_sledge")
                    tom:SelectWeapon("weapon_zm_sledge")
                    SendFullStateUpdate()

                    -- Forcing the Tom bot to be an old man each round
                    hook.Add("TTTSelectRoles", "AHTomForceOldMan", function(choices, prevRoles)
                        if not IsValid(tom) then
                            hook.Remove("TTTSelectRoles", "AHTomForceOldMan")

                            return
                        end

                        for _, choicePly in ipairs(choices) do
                            if choicePly == tom then
                                tom:SetRole(ROLE_OLDMAN)
                            end
                        end
                    end)

                    hook.Add("TTTPrepareRound", "AHForceTomPlayermodel", function()
                        if not IsValid(tom) then
                            hook.Remove("TTTPrepareRound", "AHForceTomPlayermodel")

                            return
                        end

                        timer.Simple(0.1, function()
                            if util.IsValidModel("models/player/emperor_palpatine.mdl") then
                                tom:SetModel("models/player/emperor_palpatine.mdl")
                            end

                            tom:SetHealth(100)
                            tom:SetMaxHealth(100)
                        end)
                    end)

                    hook.Add("TTTBeginRound", "AHForceTomPlayermodel", function()
                        if not IsValid(tom) then
                            hook.Remove("TTTBeginRound", "AHForceTomPlayermodel")

                            return
                        end

                        timer.Simple(0.1, function()
                            if util.IsValidModel("models/player/emperor_palpatine.mdl") then
                                tom:SetModel("models/player/emperor_palpatine.mdl")
                            end

                            tom:SetHealth(100)
                            tom:SetMaxHealth(100)

                            if not tom.GotShotgun then
                                tom:StripWeapons()
                                tom:Give("weapon_zm_shotgun")
                                tom:SelectWeapon("weapon_zm_shotgun")
                                tom:EmitSound("ttt_achievement_hunt/tom/shotgun1.mp3")
                                tom.GotShotgun = true
                            end
                        end)
                    end)

                    -- Whenever tom-bot takes damage, dies, etc. he makes a sound
                    hook.Add("EntityTakeDamage", "AHTomDamaged", function(dmgEnt, dmg)
                        if not IsPlayer(tom) or not IsPlayer(dmgEnt) then return end

                        if dmgEnt ~= tom then
                            -- If a player is somehow damaged by tom, then both the player and tom make a sound
                            if IsValid(dmg:GetAttacker()) and dmg:GetAttacker() == tom then
                                timer.Create("AHTomKillCooldown", 0.5, 1, function()
                                    dmgEnt:EmitSound("ttt_achievement_hunt/tom/kill1.mp3")
                                    if not IsValid(tom) then return end
                                    tom:EmitSound("ttt_achievement_hunt/tom/kill1.mp3")
                                end)
                            end

                            return
                        end

                        timer.Create("AHTomHurtCooldown", 0.5, 1, function()
                            if not IsValid(tom) then return end
                            local randomNum = math.random(1, 12)
                            tom:EmitSound("ttt_achievement_hunt/tom/hurt" .. randomNum .. ".mp3")
                            tom:EmitSound("ttt_achievement_hunt/tom/hurt" .. randomNum .. ".mp3")
                        end)
                    end)

                    -- Tom is killed
                    hook.Add("PostPlayerDeath", "AHTomDead", function(dmgEnt)
                        if not IsPlayer(tom) or not IsPlayer(dmgEnt) then return end
                        if dmgEnt ~= tom then return end

                        timer.Create("AHTomDeathCooldown", 0.5, 1, function()
                            if not IsValid(tom) then return end
                            local randomNum = math.random(1, 5)
                            tom:EmitSound("ttt_achievement_hunt/tom/death" .. randomNum .. ".mp3")
                            tom:EmitSound("ttt_achievement_hunt/tom/death" .. randomNum .. ".mp3")
                        end)
                    end)

                    -- The round ends and tom is dead
                    hook.Add("TTTEndRound", "AHTomLose", function(result)
                        for _, bot in ipairs(player.GetBots()) do
                            if bot == tom and (not tom:Alive() or tom:IsSpec()) then
                                tom:EmitSound("ttt_achievement_hunt/tom/lose1.mp3", 0)
                            end
                        end
                    end)

                    -- Tom is near another player
                    timer.Create("AHTomTouchPlayer", 2, 0, function()
                        if not IsValid(tom) then
                            timer.Remove("AHTomTouchPlayer")

                            return
                        end

                        local foundEnts = ents.FindInSphere(tom:GetPos(), 50)

                        for _, foundEnt in ipairs(foundEnts) do
                            if IsPlayer(foundEnt) and foundEnt ~= tom then
                                -- If the close entity is wearing the sharky playermodel, play special sounds once
                                if foundEnt:GetModel() == "models/bradyjharty/yogscast/sharky.mdl" then
                                    if not tom.PlayedBen1 then
                                        tom:EmitSound("ttt_achievement_hunt/tom/ben1.mp3")
                                        tom:EmitSound("ttt_achievement_hunt/tom/ben1.mp3")
                                        tom.PlayedBen1 = true

                                        return
                                    elseif not tom.PlayedBen2 then
                                        tom:EmitSound("ttt_achievement_hunt/tom/ben2.mp3")
                                        tom:EmitSound("ttt_achievement_hunt/tom/ben2.mp3")
                                        tom.PlayedBen2 = true

                                        return
                                    end
                                end

                                local randomNum = math.random(1, 10)
                                tom:EmitSound("ttt_achievement_hunt/tom/bump" .. randomNum .. ".mp3")
                                tom:EmitSound("ttt_achievement_hunt/tom/bump" .. randomNum .. ".mp3")

                                return
                            end
                        end
                    end)
                end)
            elseif name == "chest_zoey" then
                upperChestOpened = true
                -- Plays a a "Homerun!" sound
                ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_zoey.mp3")

                -- Gives them the zoey playermodel, if installed
                if util.IsValidModel("models/Luria/Night_in_the_Woods/Playermodels/Mae.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/Luria/Night_in_the_Woods/Playermodels/Mae.mdl")
                    ply.oldViewOffset = ply:GetViewOffset()
                    ply.oldViewOffsetDucked = ply:GetViewOffsetDucked()
                    ply:SetViewOffset(Vector(0, 0, 40))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                if weapons.Get("weapon_ttt_homebat") then
                    ply:Give("weapon_ttt_homebat")
                end
            elseif name == "chest_ravs" then
                upperChestOpened = true
                SetGlobalEntity("AHRavsChestPlayer", ply)

                -- Gives them a "Buff Garfield" playermodel, if installed
                if util.IsValidModel("models/player/garfield/buff_garfield.mdl") then
                    FindMetaTable("Entity").SetModel(ply, "models/player/garfield/buff_garfield.mdl")
                    ply:SetViewOffset(Vector(0, 0, 64))
                    ply:SetViewOffsetDucked(Vector(0, 0, 28))
                end

                -- Makes player invisible while they holster and crouch
                local isCrouching = false

                hook.Add("PlayerButtonDown", "AHRavsChestCrouch", function(buttonPly, button)
                    if not IsValid(ply) then
                        hook.Remove("PlayerButtonDown", "AHRavsChestCrouch")

                        return
                    end

                    if ply ~= buttonPly or (button ~= KEY_LCONTROL and button ~= KEY_RCONTROL) then return end
                    isCrouching = true
                end)

                hook.Add("PlayerButtonUp", "AHRavsChestUncrouch", function(buttonPly, button)
                    if not IsValid(ply) then
                        hook.Remove("PlayerButtonUp", "AHRavsChestUncrouch")

                        return
                    end

                    if ply ~= buttonPly or (button ~= KEY_LCONTROL and button ~= KEY_RCONTROL) then return end
                    isCrouching = false
                end)

                hook.Add("Think", "AHRavsChestHolsterChest", function()
                    if not IsValid(ply) then
                        hook.Remove("Think", "AHRavsChestHolsterChest")

                        return
                    end

                    local wep = ply:GetActiveWeapon()

                    if IsValid(wep) and isCrouching and wep:GetClass() == "weapon_ttt_unarmed" then
                        ply:SetColor(Color(255, 255, 255, 0))
                        ply:SetMaterial("sprites/heatwave")
                    else
                        ply:SetColor(Color(255, 255, 255, 255))
                        ply:SetMaterial("")
                    end
                end)
            end

            -- Earn an achievement for opening at least one chest in the bottom floor, and one in the top floor of the chest house
            if lowerChestOpened and upperChestOpened then
                AHEarnAchievement("chests")
            end
        end)
    end)

    -- Unlock and close chests if they haven't been opened before
    -- (The map has been set up so the chests spawn already open)
    hook.Add("TTTPrepareRound", "AHCloseChests", function()
        for _, ent in ipairs(ents.FindByName("chest_*")) do
            if not GetGlobalBool(ent:GetName() .. "_opened") then
                ent:Fire("Unlock")
                ent:Fire("Close")
            end
        end

        -- Reset any player who opened the Bruce chest to not appear as a pig anymore
        local pigPlayer = GetGlobalEntity("AHPigModelPlayer", nil)

        if IsValid(pigPlayer) then
            pigPlayer:SetNoDraw(false)
            SetGlobalEntity("AHPigModelPlayer", nil)
        end

        -- Reset any player who opened the Rythian chest to not appear as a chair anymore
        local chairPlayer = GetGlobalEntity("AHChairModelPlayer", nil)

        if IsValid(chairPlayer) then
            chairPlayer:SetNoDraw(false)
            SetGlobalEntity("AHChairModelPlayer", nil)
        end

        -- Set any player that opened the ravs chest to be visible again
        local ravsChestPlayer = GetGlobalEntity("AHRavsChestPlayer", nil)

        if IsValid(ravsChestPlayer) then
            ravsChestPlayer:SetColor(Color(255, 255, 255, 255))
            ravsChestPlayer:SetMaterial("")
            SetGlobalEntity("AHRavsChestPlayer", nil)
            hook.Remove("PlayerButtonDown", "AHRavsChestCrouch")
            hook.Remove("PlayerButtonUp", "AHRavsChestUncrouch")
            hook.Remove("Think", "AHRavsChestHolsterChest")
        end

        timer.Simple(1, function()
            for _, ply in ipairs(player.GetAll()) do
                -- Letting everyone open a chest again
                ply.AHOpenedChest = false

                -- Resetting everyone's view offset that was changed by a chest
                if ply.oldViewOffset then
                    ply:SetViewOffset(ply.oldViewOffset)
                    ply.oldViewOffset = nil
                end

                if ply.oldViewOffsetDucked then
                    ply:SetViewOffsetDucked(ply.oldViewOffsetDucked)
                    ply.oldViewOffsetDucked = nil
                end
            end
        end)
    end)
end

if CLIENT then
    -- Drawing an outline around the Tom NPC when spawned after opening Tom's chest
    net.Receive("AHDrawTomChestHalo", function()
        chat.AddText(Color(156, 253, 156), "Player Angor has joined the game")

        -- Suppressing the "Bot01 has joined the game" message from appearing
        hook.Add("ChatText", "AHSupressTomJoinMessage", function(index, name, text, type)
            if type == "joinleave" then return true end
        end)

        timer.Simple(3, function()
            hook.Remove("ChatText", "AHSupressTomJoinMessage")
            local tom = player.GetBots()[#player.GetBots()]

            local tomTable = {tom}

            -- Adding a halo around Tom for the first round he's spawned in
            hook.Add("PreDrawHalos", "AHDrawTomHalo", function()
                if not IsValid(tom) then
                    hook.Remove("PreDrawHalos", "AHDrawTomHalo")

                    return
                end

                -- Don't draw a halo around Tom if he's dead
                if not tom:Alive() or tom:IsSpec() then return end
                halo.Add(tomTable, Color(0, 255, 0), 0, 0, 1, true, true)
            end)

            -- Changing the name of the tom bot to "Angor" on the scoreboard
            hook.Add("TTTScoreboardPlayerName", "AHTomScoreboardName", function(ply, client, currentName)
                if not IsValid(tom) then
                    hook.Remove("TTTScoreboardPlayerName", "AHTomScoreboardName")

                    return
                end

                if ply == tom then return "Angor" end
            end)

            -- Changing the name of the tom bot to "Angor" when players look at them
            hook.Add("TTTTargetIDPlayerName", "AHTomName", function(ply, client, text, clr)
                if not IsValid(tom) then
                    hook.Remove("TTTTargetIDPlayerName", "AHTomName")

                    return
                end

                if ply == tom then return "Angor", clr end
            end)

            -- Changing the name of the tom bot to "Angor" when players look at them
            hook.Add("TTTScoringSummaryRender", "AHTomNameSummary", function(ply, roleFileName, groupingRole, roleColor, nameLabel, startingRole, finalRole)
                if not IsValid(tom) then
                    hook.Remove("TTTScoringSummaryRender", "AHTomNameSummary")

                    return
                end

                if ply == tom then return roleFileName, groupingRole, roleColor, "Angor" end
            end)

            -- Removing the halo at the end of the round
            hook.Add("TTTPrepareRound", "AHRemoveTomChestHalo", function()
                hook.Remove("PreDrawHalos", "AHDrawTomHalo")
                hook.Remove("TTTPrepareRound", "AHRemoveTomChestHalo")
            end)
        end)
    end)
end