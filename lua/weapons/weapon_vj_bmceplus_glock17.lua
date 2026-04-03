AddCSLuaFile() 

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Glock 17"
SWEP.Author = "Netberg1"
SWEP.Spawnable = true 

table.insert(BMCE.WEAPONS, {
    Base = "weapon_vj_bmceplus_glock17",
    Name = SWEP.PrintName
})

SWEP.UseHands = false
SWEP.ViewModelFOV = 90

SWEP.ViewModel = "models/weapons/viewmodel/v_glock.mdl"
SWEP.WorldModel = "models/weapons/global/w_glock.mdl"

SWEP.Contact = "https://steamcommunity.com/id/typeerrorrust/"
SWEP.Category = "BMCE+ Weapons"

SWEP.NPC_NextPrimaryFire = 0.4 
SWEP.NPC_CustomSpread = 0.1
SWEP.NPC_ReloadSound = {
    "vj_bmce/weapons/glock/reload/reload_roundchambered.wav"
}

SWEP.HasReloadSound = true 
SWEP.Reload_TimeUntilAmmoIsSet = 1.5
SWEP.ReloadSound = {
    "vj_bmce/weapons/glock/reload/reload.wav",
}

SWEP.HoldType = "pistol"
SWEP.Primary.Damage = 8
SWEP.Primary.ClipSize = 17

SWEP.SwayScale = 1
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Sound = {
    "vj_bmce/weapons/glock/fire/single.wav"
}

SWEP.PrimaryEffects_ShellType = "ShellEject"
SWEP.PrimaryEffects_ShellAttachment = "1"

SWEP.Primary.Delay = 0.4
SWEP.Primary.Automatic = true

SWEP.Secondary.Sound = SWEP.Primary.Sound
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "Pistol" 
SWEP.Secondary.TakeAmmo = 0

function SWEP:OnSecondaryAttack()
    if CurTime() < self:GetNextPrimaryFire() then return end
    
    self.Primary.Delay = 0.2
    self:PrimaryAttack()

    self.Primary.Delay = 0.4
    self:SetNextSecondaryFire(CurTime() + 0.2)
end