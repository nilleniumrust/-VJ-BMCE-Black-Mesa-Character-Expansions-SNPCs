local MaleModels = {
    "models/gman_high.mdl"
}


AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnPreInitialize()
    self.Model = MaleModels
    self.StartHealth = 9e9
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}

    self.Behavior = VJ_BEHAVIOR_PASSIVE

    self.GodMode = true
    self.HasMeleeAttack = false 
    self.HasBloodPool = false
    self.DamageResponse = false 
    self.EnemyDetection = false

    self.YieldToAlliedPlayers = false
    self.HasOnPlayerSight = true

    self.Passive_RunOnTouch = false
    self.AlliedWithPlayerAllies = true 
    self.BloodColor = VJ.BLOOD_COLOR_RED 
    self.Weapon_IgnoreSpawnMenu = true
    self.DropDeathLoot = false

    self.FootstepSoundTimerRun = 0.4 
    self.FootstepSoundTimerWalk = 0.5

    self.SoundTbl_FootStep = {"npc/footsteps/hardboot_generic1.wav", "npc/footsteps/hardboot_generic2.wav", "npc/footsteps/hardboot_generic3.wav", "npc/footsteps/hardboot_generic4.wav", "npc/footsteps/hardboot_generic5.wav", "npc/footsteps/hardboot_generic6.wav"}
end

