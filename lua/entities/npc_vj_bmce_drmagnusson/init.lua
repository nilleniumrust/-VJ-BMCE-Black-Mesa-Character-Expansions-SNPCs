local MaleModels = {
    "models/humans_sep2025/scientist_magnusson.mdl"
}

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnPreInitialize()
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
end

