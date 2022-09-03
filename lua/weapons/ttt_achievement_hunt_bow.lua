if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

if (SERVER) then
    AddCSLuaFile()
end

if (CLIENT) then
    SWEP.PrintName = "Minecraft Bow"
    SWEP.Author = "The Stig"
    SWEP.Category = "Weapon"
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/ttt_achievement_hunt/mcmodelpack/items/bow.mdl"
SWEP.WorldModel = "models/ttt_achievement_hunt/mcmodelpack/items/bow.mdl"
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.Weight = 1
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.CSMuzzleFlashes = false
SWEP.Primary.Damage = 40
SWEP.Primary.ClipSize = 20
SWEP.Primary.Delay = 0.75
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Arrow"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 5
SWEP.Base = "weapon_tttbase"
SWEP.Kind = 456
SWEP.Slot = 6
SWEP.InLoadoutFor = nil
SWEP.AutoSpawnable = false
SWEP.AllowDrop = true
SWEP.Arrows = {}

function SWEP:Initialize()
    self:SetHoldType("revolver")
    self.Arrows = {}
end

--[[---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
    if CLIENT then return end
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsPlayer(owner) then return end
    local arrow = ents.Create("ttt_achievement_hunt_arrow")
    -- Set the arrow forwards
    local forward = owner:GetForward()
    arrow:SetAngles(forward:Angle())
    arrow:SetPos(owner:GetShootPos())
    arrow.Damage = self.Primary.Damage
    arrow.Attacker = owner
    arrow:Spawn()
    arrow:GetPhysicsObject():AddAngleVelocity(Vector(0, 100, 0))
    arrow:GetPhysicsObject():AddVelocity(forward * 10000)
    table.insert(self.Arrows, arrow)

    -- Remove arrows if there are too many on the ground
    if #self.Arrows > 20 then
        if IsValid(self.Arrows[1]) then
            self.Arrows[1]:Remove()
        end

        table.remove(self.Arrows, 1)
    end

    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    owner:SendLua("surface.PlaySound(\"ttt_achievement_hunt/minecraft_sounds/bow_shoot.mp3\")")
    self:EmitSound("ttt_achievement_hunt/minecraft_sounds/bow_shoot.mp3", 100, 100, 1, CHAN_WEAPON)
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

-- Adjust these variables to move the viewmodel's position
SWEP.IronSightsPos = Vector(20.49, 0, -30.371)
SWEP.IronSightsAng = Vector(12, 65, -20.19)

function SWEP:GetViewModelPosition(EyePos, EyeAng)
    local Mul = 1.0
    local Offset = self.IronSightsPos

    if (self.IronSightsAng) then
        EyeAng = EyeAng * 1
        EyeAng:RotateAroundAxis(EyeAng:Right(), self.IronSightsAng.x * Mul)
        EyeAng:RotateAroundAxis(EyeAng:Up(), self.IronSightsAng.y * Mul)
        EyeAng:RotateAroundAxis(EyeAng:Forward(), self.IronSightsAng.z * Mul)
    end

    local Right = EyeAng:Right()
    local Up = EyeAng:Up()
    local Forward = EyeAng:Forward()
    EyePos = EyePos + Offset.x * Right * Mul
    EyePos = EyePos + Offset.y * Forward * Mul
    EyePos = EyePos + Offset.z * Up * Mul

    return EyePos, EyeAng
end

if CLIENT then
    local WorldModel = ClientsideModel(SWEP.WorldModel)
    -- Settings...
    WorldModel:SetSkin(1)
    WorldModel:SetNoDraw(true)

    function SWEP:DrawWorldModel()
        local _Owner = self:GetOwner()

        if (IsValid(_Owner)) then
            -- Specify a good position
            local offsetVec = Vector(5, -2.7, -3.4)
            local offsetAng = Angle(180, -90, 0)
            local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
            if not boneid then return end
            local matrix = _Owner:GetBoneMatrix(boneid)
            if not matrix then return end
            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
            WorldModel:SetPos(newPos)
            WorldModel:SetAngles(newAng)
            WorldModel:SetupBones()
        else
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
        end

        WorldModel:DrawModel()
    end
end