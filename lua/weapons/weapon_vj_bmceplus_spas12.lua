AddCSLuaFile()

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "SPAS-12"
SWEP.Author = "Netberg1"
SWEP.Spawnable = true 

table.insert(BMCE.WEAPONS, {
    Base = "weapon_vj_bmceplus_spas12",
    Name = SWEP.PrintName
})
SWEP.ViewModel = "models/weapons/viewmodel/v_shotgun.mdl"
SWEP.WorldModel = "models/weapons/global/w_shotgun.mdl"
SWEP.Category = "BMCE+ Weapons"


SWEP.NPC_NextPrimaryFire = 0.8 
SWEP.NPC_CustomSpread = 2.5

SWEP.Primary.Damage = 8 
SWEP.Primary.PlayerDamage = 10
SWEP.Primary.ClipSize = 8

SWEP.Primary.NumberOfShots = 7
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Sound = {"vj_bmce/weapons/shotgun/fire/single.wav"}
SWEP.Primary.Delay = 0.8
SWEP.Primary.Cone = 12 

SWEP.NPC_NextPrimaryFire = 0.9
SWEP.NPC_TimeUntilFire = 0.2
SWEP.NPC_CustomSpread = 3
SWEP.NPC_ExtraFireSound = "vj_bmce/weapons/shotgun/fire/pump.wav"
SWEP.NPC_FiringDistanceScale = 0.4

SWEP.Primary.Force = 1 
SWEP.Primary.PlayerDamage = "Double"
SWEP.Primary.PrimaryEffects_ShellAttachment = 2
SWEP.Primary.PrimaryEffects_ShellType = "ShotgunShellEject"
SWEP.Primary.Automatic = true

SWEP.Primary.NumShots = 8 

SWEP.HasReloadSound = true
SWEP.Reload_TimeUntilAmmoIsSet = 0.5
SWEP.NPC_ReloadSound = {
    "vj_bmce/weapons/shotgun/reload/reload1.wav", 
    "vj_bmce/weapons/shotgun/reload/reload2.wav",
    "vj_bmce/weapons/shotgun/reload/reload3.wav"
}

SWEP.Secondary.Sound = {"vj_bmce/weapons/shotgun/fire/double.wav"}
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "Buckshot"

SWEP.Secondary.TakeAmmo = 0

function SWEP:OnPrimaryAttack(Status, Data)
    if Status == "PostFire" then 
        local Owner = self:GetOwner() 

        if IsValid(Owner) and Owner:IsPlayer() then 
            timer.Simple(0.5, function()
                if IsValid(self) and IsValid(Owner) and Owner:IsPlayer() then 
                    self:EmitSound("vj_bmce/weapons/shotgun/fire/pump.wav")
                    local Animation = VJ.AnimDuration(Owner:GetViewModel(), ACT_SHOTGUN_PUMP)
                    self:SendWeaponAnim(ACT_SHOTGUN_PUMP)

                    self.NextIdleAnim = CurTime() + Animation 
                    self.NextReload = CurTime() + Animation
                end
            end)
        end
    end
end

function SWEP:OnSecondaryAttack()
    if self:Clip1() > 1 then    
        self.Primary.Delay = 1 
        self.Primary.Cone = 20 
        self.Primary.NumberOfShots = 14
        self.Primary.TakeAmmo = 2
        self.NextIdle_PrimaryAttack = 1 
        self.AnimTbl_PrimaryFire = ACT_VM_SECONDARYATTACK
    end
    self:PrimaryAttack()

    self.Primary.Delay = 0.8
    self.Primary.Cone = 12
    self.Primary.NumberOfShots = 7
    self.Primary.TakeAmmo = 1 
    self.NextIdle_PrimaryAttack = 0.8
    self.AnimTbl_PrimaryFire = ACT_VM_PRIMARYATTACK
    
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:OnReload(Status) 
    if Status == "Finish" then 
        local Owner = self:GetOwner() 

        if not Owner:IsPlayer() then return true end 
        Owner:RemoveAmmo(1, self.Primary.Ammo)
        self:SetClip1(self:Clip1() + 1) 

        if self.Primary.ClipSize > self:Clip1() then 
            timer.Simple(0.1, function()
                if IsValid(self) and IsValid(Owner) then 
                    self.Reloading = false 
                    self:Reload()
                end
            end)
        end
    end

    return true
end

