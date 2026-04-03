local FemaleModels = {
    "models/humans_sep2025/admin_female.mdl"
}

local MaleModels = {
    "models/humans_sep2025/admin_male.mdl",
    "models/humans_sep2025/admin_male02.mdl",
    "models/humans_sep2025/admin_male_casual.mdl",
    "models/humans_sep2025/admin_male_cl.mdl",
    "models/humans_sep2025/admin_female.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.scientist.male or {}
local fetchSoundTableFemale = BMCE.SOUNDS.scientist.female or {}

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
    if self.Human_Gender == nil or self.Human_Gender == BMCE.GENDERVALUES.INVALID then
        self.Human_Gender = (math.random(1, 2) == 1) and BMCE.GENDERVALUES.MALE or BMCE.GENDERVALUES.FEMALE
    end

    local voiceSet = fetchSoundTableMale
    if self.Human_Gender == BMCE.GENDERVALUES.FEMALE then
        self.Model = FemaleModels
        voiceSet = fetchSoundTableFemale
    else
        self.Model = MaleModels
        voiceSet = fetchSoundTableMale
    end

    self.StartHealth = 50
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 

    self.Behavior = VJ_BEHAVIOR_PASSIVE

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL", "CLASS_UNITED_STATES"}
    self.AlliedWithPlayerAllies = true 
    self.BloodColor = VJ.BLOOD_COLOR_RED 
    self.Weapon_IgnoreSpawnMenu = true
    self.DropDeathLoot = false

    self.BecomeEnemyToPlayer = 2
    self.HasOnPlayerSight = true 

    self.FootstepSoundTimerRun = 0.4 
    self.FootstepSoundTimerWalk = 0.5

    self.SoundTbl_FootStep = {"npc/footsteps/hardboot_generic1.wav", "npc/footsteps/hardboot_generic2.wav", "npc/footsteps/hardboot_generic3.wav", "npc/footsteps/hardboot_generic4.wav", "npc/footsteps/hardboot_generic5.wav", "npc/footsteps/hardboot_generic6.wav"}

    self.SoundTbl_Idle = voiceSet.post
    self.SoundTbl_OnPlayerSight = voiceSet.abouttime
    self.SoundTbl_Investigate = voiceSet.check
    self.SoundTbl_CallForHelp = voiceSet.help
    self.SoundTbl_GrenadeSight = voiceSet.lookoutfm
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

