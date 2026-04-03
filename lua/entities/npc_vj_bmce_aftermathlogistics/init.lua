local MaleModels = {
    "models/humans_sep2025/logistic.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.scientist.male or {}

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
    voiceSet = fetchSoundTableMale 
    self.Model = MaleModels
    self.StartHealth = 50
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 

    self.Behavior = VJ_BEHAVIOR_PASSIVE

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL"}
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

