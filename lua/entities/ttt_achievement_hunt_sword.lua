if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

if SERVER then
    AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Diamond Sword"

-- Set the prop to a diamond sword that can be picked up
function ENT:Initialize()
    if SERVER then
        self:SetTrigger(true)
        SetGlobalBool("AHSwordActivate", false)
    end

    self:SetModel("models/ttt_achievement_hunt/mcmodelpack/items/sword.mdl")
    self:SetSkin(4)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():SetMass(0.5)

    -- If the prop is parented to the minecart,
    -- it becomes responsible for making the minecart "run over" players
    if SERVER and IsValid(self:GetParent()) then
        self:SetNoDraw(true)
        self.Parented = true
    end
end

-- Kill anything that touches it
function ENT:StartTouch(ply)
    if not (IsValid(ply) and ply:IsPlayer()) then return end
    if ply.IsSpec and ply:IsSpec() and not ply:Alive() then return end

    -- Don't let the minecart kill people when it isn't moving
    if self.Parented then
        local v = self:GetParent():GetPhysicsObject():GetVelocity()
        if math.abs(v.x) < 10 and math.abs(v.y) < 10 then return end
        if not GetGlobalBool("AHSwordActivate") then return end
    end

    -- Set the damage object
    local dmg = DamageInfo()
    dmg:SetDamage(ply:Health() + 1)

    if self.Parented then
        dmg:SetDamageType(DMG_VEHICLE)
        dmg:SetInflictor(self:GetParent())
        dmg:SetAttacker(self:GetParent())
        AHEarnAchievement("minecart")
    else
        dmg:SetDamageType(DMG_CLUB)
        dmg:SetInflictor(self)
        dmg:SetAttacker(self)
        AHEarnAchievement("sword")
    end

    -- Launch the entity forwards when hit 
    local aimVector = self:GetForward()

    -- But if a player is holding the sword, use the direction they are looking at
    if not self.Parented then
        for _, holdingPly in ipairs(player.GetAll()) do
            if holdingPly:HasWeapon("weapon_zm_carry") then
                local entHolding = holdingPly:GetWeapon("weapon_zm_carry").EntHolding

                if entHolding == self then
                    aimVector = holdingPly:GetAimVector()
                    break
                end
            end
        end
    end

    ply:SetVelocity(ply:GetVelocity() + Vector(aimVector.x, aimVector.y, math.max(1, aimVector.z + .35)) * math.Rand(500 * .8, 500 * 1.2) * 2)

    -- And kill it, if not immune to the damage
    timer.Simple(0.1, function()
        ply:TakeDamageInfo(dmg)
        self:EmitSound("ttt_achievement_hunt/custom_sounds/cartoon_fling_sound.mp3")
    end)
end