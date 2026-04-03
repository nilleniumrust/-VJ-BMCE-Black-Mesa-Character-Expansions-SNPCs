local MaleModels = {
    "models/humans_sep2025/scientist_eli.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.eli.male or {}
local voiceSet

AddCSLuaFile("shared.lua")
include("shared.lua")

--// Respond to KLEINER, when he greets ELI. interest 100%%%
--// We do not trigger the greeting response when he's under attack
function ENT:ReceiveGreeting(Talker)
    if IsValid(self:GetEnemy()) then return end

    if not IsValid(Talker) then return end
    if not Talker:GetClass() == "npc_vj_bmce_drkleiner" then return end
    if self.HasRepliedToKleiner then return end

    self:SetTurnTarget(Talker, 3)
    timer.Simple(1.5, function()
        self.HasRepliedToKleiner = true 
        self:PlaySoundSystem("Speech", voiceSet.izzygreet)
    end)
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

    self.SoundTbl_OnPlayerSight = voiceSet.greet
    self.SoundTbl_Alert = voiceSet.alert
    self.SoundTbl_IdleDialogue = voiceSet.talk
    self.SoundTbl_IdleDialogueAnswer = voiceSet.answer
end

