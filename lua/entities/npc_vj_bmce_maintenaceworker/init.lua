local MaleModels = {
    "models/humans_sep2025/cwork.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.scientist.male or {}

local AllowWieldingMaskGears = {
    [2] = {
        [1] = true,
        [4] = true
    }
}

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    local bgFace, bgHelmet = -1, -1

    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            local name = string.lower(self:GetBodygroupName(i))

            if name == "syringe" then 
                self:SetBodygroup(i, 0)
            elseif name == "face" then 
                bgFace = i
            elseif name == "helmet" then 
                bgHelmet = i
            else 
                self:SetBodygroup(i, math.random(0, Count - 1))
            end
        end 
    end

    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end
    if bgFace == -1 or bgHelmet == -1 then return end

    local randomWielding = math.random(1,4)
    --// probably... probability... 
    --// do not allow wielding gear to fit onto other garbage
    if randomWielding == 4 then 
        if bgFace != -1 and bgHelmet != -1 then 
            local Keys = table.GetKeys(AllowWieldingMaskGears[bgHelmet])

            if Keys and #Keys > 0 then 
                self:SetBodygroup(bgFace, 2)
                self:SetBodygroup(bgHelmet, Keys[math.random(1, #Keys)])
            end
        end
    else 
        local Count = self:GetBodygroupCount(bgHelmet) 
        self:SetBodygroup(bgHelmet, math.random(1, Count - 1))
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
    self.SoundTbl_OnPlayerSight = voiceSet.freeman
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

