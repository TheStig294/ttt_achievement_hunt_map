if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

-- A special version of the randomat SWEP, specially made for running dynamically created randomats on the map: "ttt_achievement_hunt"
if CLIENT then
    SWEP.PrintName = "Randomat-4000"
    SWEP.Slot = 7
    SWEP.ViewModelFOV = 60
    SWEP.ViewModelFlip = false
end

SWEP.ViewModel = "models/weapons/gamefreak/c_csgo_c4.mdl"
SWEP.WorldModel = "models/weapons/gamefreak/w_c4_planted.mdl"
SWEP.Weight = 2
SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.HoldType = "slam"
SWEP.AdminSpawnable = true
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
SWEP.Kind = 4001
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true
SWEP.UseHands = true
SWEP.HeadshotMultiplier = 0
SWEP.CanBuy = nil
SWEP.AmmoEnt = nil
SWEP.Primary.Delay = 10
SWEP.Primary.Recoil = 0
SWEP.Primary.Automatic = false
SWEP.Primary.NumShots = 1
SWEP.Primary.Damage = 0
SWEP.Primary.Cone = 0
SWEP.Primary.Ammo = nil
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Sound = ""
local activeCustomRandomats = {}
local customRandomatResets = {}
local noOfRandomatsMade = 0

hook.Add("TTTPrepareRound", "AHRemoveCustomRandomatEffects", function()
    for hookID, hookType in pairs(activeCustomRandomats) do
        hook.Remove(hookType, hookID)
    end

    for _, resetFunc in ipairs(customRandomatResets) do
        resetFunc()
    end

    table.Empty(customRandomatResets)
    table.Empty(activeCustomRandomats)
end)

function SWEP:Initialize()
    util.PrecacheSound("ttt_achievement_hunt/custom_sounds/randomat_activate.mp3")
    self:SetModelScale(2, 0.5)

    if SERVER then
        AHEarnAchievement("randomat")
        noOfRandomatsMade = noOfRandomatsMade + 1

        if noOfRandomatsMade == 3 then
            AHEarnAchievement("randomat3")
        end
    end
end

function SWEP:PrimaryAttack()
    if not SERVER then return end
    if not IsFirstTimePredicted() then return end
    if GetGlobalInt("AHRandomatCause", 0) == 0 or GetGlobalInt("AHRandomatEffect", 0) == 0 then return end
    local causeID = GetGlobalInt("AHRandomatCause")
    local effectID = GetGlobalInt("AHRandomatEffect")
    local cause
    local effect

    -- Converting the map prop's ID to its cause or effect
    for _, causeTable in pairs(AHCauses) do
        if causeTable.PropID == causeID then
            cause = causeTable
            break
        end
    end

    for _, effectTable in pairs(AHEffects) do
        if effectTable.PropID == effectID then
            effect = effectTable
            break
        end
    end

    if not cause or not effect then return end

    -- The magic of the dynamic randomat,
    -- dynamically creates all the hooks needed for the specific combination of a randomat's cause and effect
    for index, hookName in ipairs(cause.Hooks) do
        -- If an effect has less functions than a cause has hooks, only apply as many hooks as an effect has functions, in order of the hooks listed in the cause
        if not effect.Functions[index] then break end
        local hookID = hookName .. cause.id
        hook.Add(hookName, hookID, function(...) return effect.Functions[index](...) end)
        activeCustomRandomats[hookID] = hookName

        if effect.Reset then
            table.insert(customRandomatResets, effect.Reset)
        end
    end

    -- Displays the randomat's yellow-and-black message for everyone
    -- Displays the name
    local eventName = GetGlobalString("AHRandomatName", "Custom Event!")
    local eventDesc = cause.Desc .. ", " .. effect.Desc
    net.Start("AHRandomatAlert")
    net.WriteBool(true)
    net.WriteString(eventName)
    net.WriteUInt(5, 8)
    net.Broadcast()

    -- Displays the description
    timer.Simple(0, function()
        net.Start("AHRandomatAlertSilent")
        net.WriteBool(false)
        net.WriteString(eventDesc)
        net.WriteUInt(5, 8)
        net.Broadcast()
    end)

    PrintMessage(HUD_PRINTTALK, "[RANDOMAT] " .. eventName .. " | " .. eventDesc)
    self:SetNextPrimaryFire(CurTime() + 10)
    self:Remove()
end