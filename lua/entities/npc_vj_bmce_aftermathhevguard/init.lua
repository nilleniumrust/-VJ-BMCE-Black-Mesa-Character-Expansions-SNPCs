local MaleModels = {
    "models/humans_sep2025/hev_guard.mdl",
    "models/humans_sep2025/hev_guard_02.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.guard.male or {}
local hevSet = (BMCE.SOUNDS.hev and BMCE.SOUNDS.hev.male) or {}
local voiceSet 


AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    local bgHelmet = -1
    local bgHardhat = -1

    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            local name = string.lower(self:GetBodygroupName(i))

            if name == "helmet" then
                bgHelmet = i
            elseif name == "hardhat" then 
                bgHardhat = i
            end

            self:SetBodygroup(i, math.random(0, Count - 1))
        end 
    end

    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end

    local hasHardHat = false 
    if bgHardhat != -1 then 
        if math.random(1,4) == 4 then 
            local Count = self:GetBodygroupCount(bgHardhat)
            self:SetBodygroup(Count, math.random(1, Count - 1))
        else 
            self:SetBodygroup(bgHardhat, 0)
        end
    end

    if bgHelmet != -1 then 
        if hasHardhat then 
            self:SetBodyGroup(bgHelmet, 0)
        else 
            if math.random(1, 10) <= 7 then
                local Count = self:GetBodygroupCount(bgHelmet)
                self:SetBodygroup(bgHelmet, math.random(1, Count - 1))
            else
                self:SetBodygroup(bgHelmet, 0)
            end
        end
    end

end
function ENT:OnMaintainRelationships(Entity, Displacement, Distance)
    if not IsValid(Entity) then return end 
    if Displacement == D_NU or Displacement == D_HT then return end 
    if IsValid(self:GetEnemy()) then return end
    if CurTime() < self.ReloadTrigger then return end

    if Distance > 200 then return end

    self.ReloadTrigger = CurTime() + math.random(10, 60)
    if Entity:IsPlayer()  then 
        local CurrentWeapon = Entity:GetActiveWeapon()
        local Random = math.random(1,2)

        print(Random, CurrentWeapon)
        if IsValid(CurrentWeapon) and Random == 2 then 
            local AmmoType = CurrentWeapon:GetPrimaryAmmoType()

            if AmmoType and AmmoType > -1 then 
                print(AmmoType)
                if Entity:GetAmmoCount(AmmoType) <= 255 and IsValid(self:GetActiveWeapon()) and not self:IsBusy() then 
                    if Distance > 100 then 
                        self.ReloadTrigger = 0 
                    else 
                        local t, AnimTime = self:PlayAnim("heal", true, false, false, 0, { 
                            OnFinish = function(Interrupted, Anim)
                                if not Interrupted then 
                                    Entity:GiveAmmo(10, AmmoType)
                                end
                            end
                        })

                        self:SetTurnTarget(Entity, AnimTime)
                        self:PlaySoundSystem("Speech", voiceSet.ammo)
                    end
                elseif CurrentWeapon:Clip1() < CurrentWeapon:GetMaxClip1() and Entity:GetAmmoCount(AmmoType) > 0 then 
                    self:PlaySoundSystem("Speech", voiceSet.reloadfm)
                end
            end

        end
    end
end

function ENT:CustomOnPreInitialize()
    voiceSet = fetchSoundTableMale
    self.Model = MaleModels

    self.StartHealth = 115
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 
    self.HasOnPlayerSight = true 

    self.ReloadTrigger = 0

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL"}
    self.AlliedWithPlayerAllies = true 
    self.BloodColor = VJ.BLOOD_COLOR_RED 
    self.HEVSet = hevSet

    self.HasMeleeAttack = true 
    self.MeleeAttackDamage = 8 
    self.TimeUntilMeleeAttackDamage = 0.5

    self.Immune_Toxic = true 
    self.Immune_Electricity = true
    self.Immune_Melee = true

    self.SoundTbl_Idle = voiceSet.statement
    self.SoundTbl_OnPlayerSight = voiceSet.freeman
    self.SoundTbl_Investigate = voiceSet.check
    self.SoundTbl_CallForHelp = voiceSet.charge 
    self.SoundTbl_WeaponReload = voiceSet.coverwhilereload
    
    self.SoundTbl_GrenadeSight = voiceSet.lookout
    self.SoundTbl_KilledEnemy = voiceSet.taunt
    self.SoundTbl_Pain = voiceSet.pain
    self.SoundTbl_Death = voiceSet.death
    
    self.SoundTbl_Alert = voiceSet.heretheycome
    self.SoundTbl_FollowPlayer = voiceSet.leadtheway 
    self.SoundTbl_UnFollowPlayer = voiceSet.illstayhere
    self.SoundTbl_DamagePlayer = voiceSet.stopitfm or voiceSet.annoyance

    self.SoundTbl_IdleDialogueAnswer = voiceSet.answer
    self.SoundTbl_IdleDialogue = voiceSet.question
    self.SoundTbl_YieldToPlayer = voiceSet.sorry
end

function ENT:OnDamaged(DmgInfo, HitGroup, Status)
    if Status == "PreDamage" and DmgInfo:IsBulletDamage() then 
        if self.HasSounds and self.HasImpactSounds then 
            VJ.EmitSound(self, "VJ.Impact.Armor")
        end

        if math.random(1, 2) == 1 then 
            DmgInfo:ScaleDamage(0.5)
            local Position = DmgInfo:GetDamagePosition()
            local DmgForce_Normalized = DmgInfo:GetDamageForce():GetNormalized()
            local effectData = EffectData()
            effectData:SetOrigin(Position)
            effectData:SetNormal(DmgForce_Normalized)
            effectData:SetMagnitude(3)
            effectData:SetScale(1)
            util.Effect("ElectricSpark", effectData)
        else 
            DmgInfo:ScaleDamage(0.8)
        end
        
        if self.NextHEVSound and CurTime() < self.NextHEVSound then return end
        if math.random(1, 5) == 1 and self.HEVSet and self.HEVSet.health then
            self:EmitSound(table.Random(self.HEVSet.health), 70, 100)
            self.NextHEVSound = CurTime() + 5

            timer.Simple(4, function()
                if IsValid(self) then
                    local sound = table.Random(self.HEVSet.seek or self.HEVSet.medic or {})
                    if sound then self:EmitSound(sound) end
                end
            end)
        end

        if self:Health() < (self:GetMaxHealth() * 0.25) and not self.DoneCritBeep then
            if self.HEVSet.fuzz then self:EmitSound(table.Random(self.HEVSet.fuzz)) end
            if self.HEVSet.warning then self:EmitSound(table.Random(self.HEVSet.warning)) end

            local lowHealthSound = table.Random(self.HEVSet.death or {})
            if lowHealthSound then self:EmitSound(lowHealthSound, 80, 100) end

            self.DoneCritBeep = true
        end
    end
end


function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo, hitgroup, corpse)
    if IsValid(corpse) and self.HEVSet and self.HEVSet.flatline then
        local Sound = table.Random(self.HEVSet.flatline)
        corpse:EmitSound(Sound, 75, 100)
    end
end
