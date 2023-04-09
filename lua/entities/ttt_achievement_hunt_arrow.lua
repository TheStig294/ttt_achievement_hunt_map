if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

if SERVER then
    AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Arrow"

-- Set the prop to a bucket
function ENT:Initialize()
    if SERVER then
        self:SetTrigger(true)
    end

    self:SetModel("models/ttt_achievement_hunt/mcmodelpack/entities/arrow.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():SetMass(4)
end

-- Hurt any player that touches it
function ENT:StartTouch(ent)
    if self.Disabled then
        if IsPlayer(ent) and ent:HasWeapon("ttt_achievement_hunt_bow") then
            local bow = ent:GetWeapon("ttt_achievement_hunt_bow")
            bow:SetClip1(bow:Clip1() + 1)
            self:EmitSound("ttt_achievement_hunt/minecraft_sounds/item_pickup.mp3", 100, 100, 1, CHAN_ITEM)

            if SERVER then
                AHEarnAchievement("bow")
            end

            self:Remove()
        end
    else
        if IsPlayer(ent) and ent:Alive() and not ent:IsSpec() then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Damage or 40)
            dmg:SetDamageType(DMG_CLUB)
            dmg:SetInflictor(self)
            dmg:SetAttacker(self.Attacker or self)
            ent:TakeDamageInfo(dmg)
            self:Remove()
        end
    end
end

function ENT:Think()
    if CLIENT or self.Disabled then return end

    if self:GetPhysicsObject():GetVelocity().z < 1 and self:GetPhysicsObject():GetVelocity().z > -10 then
        self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
        self:DropToFloor()
        self:SetMoveType(MOVETYPE_NONE)
        self:SetNotSolid(true)
        self:AddSolidFlags(bit.bor(FSOLID_TRIGGER, FSOLID_USE_TRIGGER_BOUNDS))
        self.Disabled = true

        return
    end

    self:GetPhysicsObject():AddVelocity(Vector(0, 0, -300))
end