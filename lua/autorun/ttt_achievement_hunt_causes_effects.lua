if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

local function CheckForPlayer(arg1, arg2)
    local ply = false

    if GetGlobalInt("AHRandomatCause", 0) == 7 then
        if IsPlayer(arg1) and IsPlayer(arg2) then
            ply = arg1
        end
    else
        if IsPlayer(arg1) then
            ply = arg1
        elseif IsPlayer(arg2) then
            ply = arg2
        end
    end

    return ply
end

-- All of the possible randomat causes and effects, to make a custom randomat from in the randomat factory
AHCauses = {}

AHCauses.death = {
    ["id"] = "death",
    ["PropID"] = 8,
    ["Hooks"] = {"DoPlayerDeath", "TTTOnCorpseCreated"},
    ["Desc"] = "After you die"
}

AHCauses.near = {
    ["id"] = "near",
    ["PropID"] = 7,
    ["Hooks"] = {"ShouldCollide"},
    ["Desc"] = "After you get near another player"
}

AHCauses.buy = {
    ["id"] = "buy",
    ["PropID"] = 6,
    ["Hooks"] = {"TTTOrderedEquipment"},
    ["Desc"] = "After you buy something"
}

AHCauses.damage = {
    ["id"] = "damage",
    ["PropID"] = 5,
    ["Hooks"] = {"PostEntityTakeDamage"},
    ["Desc"] = "After you take damage"
}

AHCauses.weapon = {
    ["id"] = "weapon",
    ["PropID"] = 4,
    ["Hooks"] = {"PlayerSwitchWeapon"},
    ["Desc"] = "After you switch weapons"
}

AHCauses.chat = {
    ["id"] = "chat",
    ["PropID"] = 3,
    ["Hooks"] = {"PlayerSay"},
    ["Desc"] = "After you send a chat message"
}

AHCauses.footstep = {
    ["id"] = "footstep",
    ["PropID"] = 2,
    ["Hooks"] = {"PlayerFootstep"},
    ["Desc"] = "After you walk"
}

AHCauses.bodysearch = {
    ["id"] = "bodysearch",
    ["PropID"] = 1,
    ["Hooks"] = {"TTTCanSearchCorpse"},
    ["Desc"] = "After you search a body"
}

AHEffects = {}

AHEffects.sound = {
    ["id"] = "sound",
    ["PropID"] = 8,
    ["Desc"] = "you make a sound (on a cooldown)",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if ply.AHSoundRandomatCooldown then return end

            timer.Create("AHSoundRandomatPlayCooldown" .. ply:EntIndex(), 0.1, 1, function()
                local randomNum = math.random()

                if randomNum < 0.33 then
                    ply:EmitSound("ttt_achievement_hunt/custom_sounds/villager.mp3")
                elseif randomNum < 0.66 then
                    ply:EmitSound("ttt_achievement_hunt/custom_sounds/villager2.mp3")
                else
                    ply:EmitSound("ttt_achievement_hunt/custom_sounds/villager3.mp3")
                end
            end)

            ply.AHSoundRandomatCooldown = true

            timer.Create("AHSoundRandomatCooldown" .. ply:EntIndex(), 10, 1, function()
                ply.AHSoundRandomatCooldown = false
            end)
        end
    }
}

AHEffects.bighead = {
    ["id"] = "bighead",
    ["PropID"] = 7,
    ["Desc"] = "your head gets bigger",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            local mult = 1.2

            if ply.HeadScale then
                mult = ply.HeadScale + 0.2
            end

            local scale = Vector(mult, mult, mult)
            local boneId = ply:LookupBone("ValveBiped.Bip01_Head1")

            if boneId ~= nil then
                ply:ManipulateBoneScale(boneId, scale)
                ply.HeadScale = mult
            end
        end,
        function(arg1)
            if IsValid(arg1) then
                timer.Simple(0.1, function()
                    local ent = arg1
                    local ply = CORPSE.GetPlayer(ent)
                    if not IsPlayer(ply) then return end
                    local mult = ply.HeadScale or 1.2
                    local scale = Vector(mult, mult, mult)
                    local boneId = ent:LookupBone("ValveBiped.Bip01_Head1")

                    if boneId ~= nil then
                        ent:ManipulateBoneScale(boneId, scale)
                        ent.HeadScale = mult
                    end
                end)
            end
        end
    },
    ["Reset"] = function()
        for _, ply in ipairs(player.GetAll()) do
            ply.HeadScale = 1
        end
    end
}

AHEffects.randomat = {
    ["id"] = "randomat",
    ["PropID"] = 6,
    ["Desc"] = "a randomat triggers! (Once per player)",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if not Randomat then return end
            if not Randomat.TriggerRandomEvent then return end
            -- Add a hard cap to the number of randomats that can be active at once before triggering another
            if Randomat.ActiveEvents and #Randomat.ActiveEvents > 10 then return end
            if ply.AHRandomatEffectTriggered then return end
            Randomat:TriggerRandomEvent()
            ply.AHRandomatEffectTriggered = true
        end
    },
    ["Reset"] = function()
        for _, ply in ipairs(player.GetAll()) do
            ply.AHRandomatEffectTriggered = false
        end
    end
}

AHEffects.fling = {
    ["id"] = "fling",
    ["PropID"] = 5,
    ["Desc"] = "you get flung away! (On a cooldown)",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if ply.AHLaunchRandomatCooldown then return end
            local pos = ply:GetPos()
            pos.z = pos.z + 10
            ply:SetPos(pos)
            local velocity = Vector(1000, 1000, 1000)
            local randX = math.random()

            if randX < 0.33 then
                velocity.x = -1000
            elseif randX < 0.66 then
                velocity.x = 0
            end

            local randY = math.random()

            if randY < 0.33 then
                velocity.y = -1000
            elseif randY < 0.66 then
                velocity.y = 0
            end

            ply:SetVelocity(velocity)
            ply:EmitSound("ttt_achievement_hunt/custom_sounds/cartoon_fling_sound.mp3")
            ply.AHLaunchRandomatCooldown = true

            timer.Create("AHLaunchRandomatCooldown" .. ply:EntIndex(), 10, 1, function()
                ply.AHLaunchRandomatCooldown = false
            end)
        end
    }
}

AHEffects.timeofday = {
    ["id"] = "timeofday",
    ["PropID"] = 4,
    ["Desc"] = "the weather or time of day sometimes changes",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if ply.AHRelayRandomatCooldown then return end

            local relays = {"day", "night", "clear", "rain"}

            local relay = "relay_" .. relays[math.random(#relays)]

            for _, ent in ipairs(ents.FindByName(relay)) do
                ent:Fire("Trigger")
            end

            ply.AHRelayRandomatCooldown = true

            timer.Create("AHRelayRandomatCooldown" .. ply:EntIndex(), 10, 1, function()
                ply.AHRelayRandomatCooldown = false
            end)
        end
    }
}

local models

AHEffects.model = {
    ["id"] = "model",
    ["PropID"] = 3,
    ["Desc"] = "you randomly change playermodel (On a cooldown)",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if ply.AHModelRandomatCooldown then return end

            if not models then
                models = list.Get("PlayerOptionsModel")
            end

            FindMetaTable("Entity").SetModel(ply, table.Random(models))
            ply.AHModelRandomatCooldown = true

            timer.Create("AHModelRandomatCooldown" .. ply:EntIndex(), 10, 1, function()
                ply.AHModelRandomatCooldown = false
            end)
        end
    }
}

AHEffects.health = {
    ["id"] = "health",
    ["PropID"] = 2,
    ["Desc"] = "your health is randomly changed",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            ply:SetHealth(math.random(100))
        end
    }
}

AHEffects.meme = {
    ["id"] = "meme",
    ["PropID"] = 1,
    ["Desc"] = "you see a random meme (On a cooldown)",
    ["Functions"] = {
        function(arg1, arg2)
            local ply = CheckForPlayer(arg1, arg2)
            if not ply then return end
            if ply.AHMemeRandomatCooldown then return end
            net.Start("AHRandomatAlert")
            net.WriteBool(false)
            net.WriteString("AHMemeRandomatEffect")
            net.WriteUInt(5, 8)
            net.Send(ply)
            ply.AHMemeRandomatCooldown = true

            timer.Create("AHMemeRandomatCooldown" .. ply:EntIndex(), 10, 1, function()
                ply.AHMemeRandomatCooldown = false
            end)
        end
    }
}