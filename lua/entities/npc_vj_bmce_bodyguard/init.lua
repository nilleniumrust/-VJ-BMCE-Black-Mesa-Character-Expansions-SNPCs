local MaleModels = {
    "models/humans_sep2025/guard_bodyguard.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.guard.male or {}

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            self:SetBodygroup(i, math.random(0, Count - 1))
        end 
    end

    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end
end

function ENT:CustomOnPreInitialize()
    voiceSet = fetchSoundTableMale 
    self.Model = MaleModels

    self.StartHealth = 85
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = true 
    self.HasOnPlayerSight = true 

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL", "CLASS_UNITED_STATES"}
    self.AlliedWithPlayerAllies = true 
    self.BloodColor = VJ.BLOOD_COLOR_RED 

    self.HasMeleeAttack = true 
    self.MeleeAttackDamage = 8 
    self.TimeUntilMeleeAttackDamage = 0.5

    self.SoundTbl_Idle = voiceSet.statement
    self.SoundTbl_OnPlayerSight = voiceSet.abouttime
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

