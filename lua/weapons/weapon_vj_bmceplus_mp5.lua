AddCSLuaFile() 

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "MP5"
SWEP.Author = "Netberg1"
SWEP.Spawnable = true 

table.insert(BMCE.WEAPONS, {
    Base = "weapon_vj_bmceplus_mp5",
    Name = SWEP.PrintName
})

SWEP.UseHands = false
SWEP.ViewModelFOV = 90

SWEP.ViewModel = "models/weapons/viewmodel/v_mp5.mdl"
SWEP.WorldModel = "models/weapons/global/w_mp5.mdl"

SWEP.Contact = "https://steamcommunity.com/id/typeerrorrust/"
SWEP.Category = "BMCE+ Weapons"

SWEP.NPC_CustomSpread = 1
SWEP.NPC_NextPrimaryFire = 0.11
SWEP.NPC_ReloadSound = {
    "vj_bmce/weapons/mp5/reload/reload_long.wav", 
    "vj_bmce/weapons/mp5/reload/reload_long2.wav"
}

SWEP.NPC_HasSecondaryFire = true
SWEP.NPC_SecondaryFireSound = "vj_bmce/weapons/mp5/fire/double.wav"

SWEP.NPC_SecondaryFireChance = 1
SWEP.HasReloadSound = true 
SWEP.Reload_TimeUntilAmmoIsSet = 1.5
SWEP.ReloadSound = { 
	"vj_bmce/weapons/mp5/reload/reload.wav"
}

SWEP.HoldType = "smg"
SWEP.Primary.Damage = 6
SWEP.Primary.ClipSize = 30 

SWEP.SwayScale = 1
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Sound = {
    "vj_bmce/weapons/mp5/fire/single1.wav",
    "vj_bmce/weapons/mp5/fire/single1a.wav",
    "vj_bmce/weapons/mp5/fire/single2.wav",
    "vj_bmce/weapons/mp5/fire/single2a.wav",
    "vj_bmce/weapons/mp5/fire/single3.wav",
}

SWEP.PrimaryEffects_ShellType = "ShellEject"
SWEP.PrimaryEffects_ShellAttachment = "1"


SWEP.Primary.Delay = 0.11
SWEP.Primary.Automatic = true 

SWEP.HasSecondaryAmmo = true 
SWEP.Secondary.Ammo = "SMG1_Grenade"
SWEP.Secondary.ClipSize = 2
SWEP.Secondary.Delay = 1.5 
SWEP.Secondary.Damage = 200
SWEP.Secondary.Automatic = false 
SWEP.Secondary.Sound = {
    "vj_bmce/weapons/mp5/fire/double.wav"
}

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	return true
end


function SWEP:OnSecondaryAttack()
	local owner = self:GetOwner()
	owner:ViewPunch(Angle(-self.Primary.Recoil * 3, 0, 0))

	VJ.EmitSound(self, "vj_bmce/weapons/mp5/fire/double.wav", 85)

	if SERVER then
		local proj = ents.Create(self.NPC_SecondaryFireEnt)
		proj:SetPos(owner:GetShootPos())
		proj:SetAngles(owner:GetAimVector():Angle())
		proj:SetOwner(owner)
		proj:Spawn()
		proj:Activate()
		
		if proj.Damage then proj.Damage = 200 end

		local phys = proj:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(owner:GetAimVector() * 2000)
		end
	end
end
