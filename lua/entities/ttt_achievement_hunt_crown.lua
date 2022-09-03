if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

if SERVER then
    AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Crown"

-- Set the prop to a crown that can be picked up by standing near it for a second
function ENT:Initialize()
    self:SetModel("models/ttt_achievement_hunt/crown.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():SetMass(0.5)
    self:SetAngles(Angle(-90, 0, 0))
    self:SetModelScale(2, 0.1)

    if SERVER then
        util.AddNetworkString("AHDrawCrownHalo")
        net.Start("AHDrawCrownHalo")
        net.Broadcast()

        timer.Simple(2, function()
            timer.Create("AHCrownNearbyPlayerCheck", 1, 0, function()
                if not IsValid(self) then
                    timer.Remove("AHCrownNearbyPlayerCheck")

                    return
                end

                local nearEnts = ents.FindInSphere(self:GetPos(), 100)

                for _, ent in ipairs(nearEnts) do
                    if IsPlayer(ent) then
                        -- Earning the achievement for getting the crown and setting the flags to say the crown has been obatined
                        AHEarnAchievement("reward")
                        SetGlobalBool("AHOneAchievementLeft", false)
                        SetGlobalBool("AHCrownObtained", true)

                        -- Putting the crown on everyone's heads
                        for _, ply in ipairs(player.GetAll()) do
                            AHCrownPlayers[ply:SteamID()] = true
                        end

                        -- Showing in-map text to everyone saying it's the end of the map
                        local textEnt = ents.FindByName("text_credits_1")[1]
                        textEnt:Fire("Display")

                        timer.Simple(4, function()
                            textEnt = ents.FindByName("text_credits_2")[1]
                            textEnt:Fire("Display")
                        end)

                        timer.Simple(9, function()
                            local message = "Press '" .. GetGlobalString("ttt_achievement_hunt_crown_key", "k") .. "' to toggle your crown!"
                            PrintMessage(HUD_PRINTCENTER, message)
                            PrintMessage(HUD_PRINTTALK, message)

                            timer.Simple(1.5, function()
                                PrintMessage(HUD_PRINTCENTER, message)
                            end)
                        end)

                        timer.Remove("AHCrownNearbyPlayerCheck")
                        self:Remove()

                        return
                    end
                end
            end)
        end)
    end

    -- Drawing an outline around the crown when spawned
    if CLIENT then
        net.Receive("AHDrawCrownHalo", function()
            local entTbl = {self}

            hook.Add("PreDrawHalos", "AHDrawCrownHalo", function()
                if GetGlobalBool("AHCrownObtained") then
                    hook.Remove("PreDrawHalos", "AHDrawCrownHalo")

                    return
                end

                halo.Add(entTbl, Color(0, 255, 0), 0, 0, 1, true, true)
            end)
        end)
    end
end