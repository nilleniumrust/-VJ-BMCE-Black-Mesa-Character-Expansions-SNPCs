local MaleModels = {
    "models/humans_sep2025/hev_scientist.mdl"
}

local voiceSet = (BMCE.SOUNDS.scientist and BMCE.SOUNDS.scientist.male) or {}
local hevSet = (BMCE.SOUNDS.hev and BMCE.SOUNDS.hev.male) or {}

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            local name = string.lower(self:GetBodygroupName(i))

            if name == "syringe" then 
                self:SetBodygroup(i, 0)
                continue
            end
            self:SetBodygroup(i, math.random(0, Count - 1))
        end 
    end

    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end
end

function ENT:CustomOnPreInitialize()
    self.HEVSet = hevSet

    self.Model = MaleModels
    self.StartHealth = 115
    self.Behavior = VJ_BEHAVIOR_PASSIVE
    self.BloodColor = VJ.BLOOD_COLOR_RED
    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL"}
    self.HasOnPlayerSight = true 
    self.AlliedWithPlayerAllies = true 

    self.Immune_Toxic = true 
    self.Immune_Electricity = true
    self.Immune_Melee = true

    self.SoundTbl_Idle = voiceSet.post
    self.SoundTbl_OnPlayerSight = voiceSet.ahgordon
    self.SoundTbl_Investigate = voiceSet.check
    self.SoundTbl_CallForHelp = voiceSet.help
    self.SoundTbl_Pain = voiceSet.pain
    self.SoundTbl_Death = voiceSet.death
    self.SoundTbl_Alert = voiceSet.heretheycome
    self.SoundTbl_FollowPlayer = voiceSet.leadtheway
    self.SoundTbl_UnFollowPlayer = voiceSet.illstayhere

    self.SoundTbl_IdleDialogue = voiceSet.question
    self.SoundTbl_IdleDialogueAnswer = voiceSet.answer
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
