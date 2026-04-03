AddCSLuaFile() 


SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Colt Python"
SWEP.Author = "Netberg1"
SWEP.Spawnable = true 

table.insert(BMCE.WEAPONS, {
    Base = "weapon_vj_bmceplus_colt",
    Name = SWEP.PrintName
})
SWEP.UseHands = false
SWEP.ViewModelFOV = 90

SWEP.ViewModel = "models/weapons/viewmodel/v_357.mdl"
SWEP.WorldModel = "models/weapons/global/w_357.mdl"


SWEP.Contact = "https://steamcommunity.com/id/typeerrorrust/"
SWEP.Category = "BMCE+ Weapons"

SWEP.NPC_NextPrimaryFire = 0.8
SWEP.NPC_CustomSpread = 0.3
SWEP.NPC_ReloadSound = {
    "vj_bmce/weapons/357/reload/reload.wav"
}

SWEP.HasReloadSound = true 
SWEP.Reload_TimeUntilAmmoIsSet = 1.5
SWEP.ReloadSound = SWEP.NPC_ReloadSound

SWEP.HoldType = "pistol"
SWEP.Primary.Damage = 45
SWEP.Primary.ClipSize = 6

SWEP.Primary.Cone = 0.1

SWEP.SwayScale = 1
SWEP.Primary.Ammo = "357"
SWEP.Primary.Sound = {
    "vj_bmce/weapons/357/fire/single.wav",
    "vj_bmce/weapons/357/fire/single_real.wav"
}

SWEP.PrimaryEffects_ShellType = "ShellEject"
SWEP.PrimaryEffects_ShellAttachment = "1"

SWEP.Primary.Delay = 0.8
SWEP.Primary.Automatic = true

function SWEP:SecondaryAttack()
    if (not IsFirstTimePredicted()) then return end
end

function SWEP:OnPrimaryAttack()
    local Owner = self:GetOwner() 
    
    if IsValid(Owner) and Owner:IsPlayer() then 
        if Owner:KeyDown(IN_ATTACK2) then 
            Owner:SetViewPunchAngles(Angle(0,0,0))
        end
    end
end

if CLIENT then
	local aimPos = Vector(-3, 1.5, -8)
	local aimAng = Angle(0, 0, 0)

	SWEP.IronSightsMul = 0 

    function SWEP:GetViewModelPosition(pos, ang)
        local ft = FrameTime()

        local owner = self:GetOwner()
        local isAiming = owner:KeyDown(IN_ATTACK2)

        if isAiming then
            self.IronSightsMul = math.Approach(self.IronSightsMul, 1, ft * 5)
            owner:SetFOV(60, 0.05)
        else
            self.IronSightsMul = math.Approach(self.IronSightsMul, 0, ft * 5)
            if owner:GetFOV() != 90 then owner:SetFOV(0, 0.05) end
        end
        if self.IronSightsMul <= 0 then return pos, ang end

        local currentPos = aimPos * self.IronSightsMul
        local currentAng = aimAng * self.IronSightsMul

        ang:RotateAroundAxis(ang:Right(), currentAng.x)
        ang:RotateAroundAxis(ang:Up(), currentAng.y)
        ang:RotateAroundAxis(ang:Forward(), currentAng.z)

        pos = pos + currentPos.x * ang:Right()
        pos = pos + currentPos.y * ang:Up()
        pos = pos + currentPos.z * ang:Forward()

        return pos, ang
    end

    return true
end