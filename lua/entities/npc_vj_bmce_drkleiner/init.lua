local MaleModels = {
    "models/humans_sep2025/scientist_kliener.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.kleiner.male
local voiceSet

AddCSLuaFile("shared.lua")
include("shared.lua")

--// We play a sound when Dr. Kleiner is close to Eli Vance
--// Same thing as Dr. Eli Vance
--// D_LI = Friendly, D_NU = neutral. DOES Not trigger when D_HT is here
function ENT:OnMaintainRelationships(Entity, Displacement, Distance)
    if not IsValid(Entity) then return end
    if self.HasGreetWithEli then return end

    if IsValid(self:GetEnemy()) then return end

    if Entity:GetClass() == "npc_vj_bmce_drelivance" and (Displacement == D_LI or Displacement == D_NU) and Distance < 200 then 
        self.HasGreetWithEli = true 
        self:SetTurnTarget(Entity, 3)

        timer.Simple(0.5, function()
            self:PlaySoundSystem("Speech", voiceSet.eligreet)

            if Entity.ReceiveGreeting then
                Entity:ReceiveGreeting(self)
            end
        end)
    end
end

function ENT:CustomOnPreInitialize()
    voiceSet = fetchSoundTableMale 
    self.Model = MaleModels
    self.StartHealth = 50
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 
    self.HasGreetWithEli = false

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

    self.SoundTbl_CallForHelp = voiceSet.alert
    self.SoundTbl_IdleDialogue = voiceSet.talk
end

