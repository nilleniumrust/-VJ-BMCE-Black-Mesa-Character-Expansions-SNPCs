local MaleModels = {
    "models/humans_sep2025/guard_first_response.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.guard.male or {}

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    local bgHelmet, bgVest = -1, -1
    local bodyIndex = -1

    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            local name = string.lower(self:GetBodygroupName(i))

            if name == "helmet" then
                bgHelmet = i
                continue
            elseif name == "chest" then 
                bgVest = i
                continue
            elseif name == "body" then 
                local t = math.random(0, Count - 1)
                self:SetBodygroup(i, t)
                bodyIndex = t

                continue
            elseif name == "pda" then 
                continue
            elseif name == "walkietalkie" then 
                continue
            end

            self:SetBodygroup(i, math.random(0, Count - 1))
        end 
    end


    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end

    if bgVest != -1 and bodyIndex != -1 then 
        
        local noVest = false
        if bodyIndex > 1 then 
            noVest = true
        end
        if not noVest and math.random(1, 2) == 2 then 
            local pdarandom = math.random(1, 3) 
            if pdarandom then 
                self:SetBodygroup(BodyGroupCount - 1, pdarandom)
            end

            self:SetBodygroup(BodyGroupCount - 2, 0)
            
            local Count = self:GetBodygroupCount(bgVest)
            self:SetBodygroup(bgVest, math.random(1, Count - 1))
        else 
            self:SetMaxHealth(60)
            self:SetBodygroup(bgVest, 4)
        end
    end

    if bgHelmet != -1 then 
            if math.random(1, 10) <= 7 then
                local Count = self:GetBodygroupCount(bgHelmet)
                self:SetBodygroup(bgHelmet, math.random(1, Count - 1))
            else
                self:SetBodygroup(bgHelmet, 0)
            end
    end

end

function ENT:CustomOnPreInitialize()
    voiceSet = fetchSoundTableMale 
    self.Model = MaleModels

    self.StartHealth = 90
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = true 
    self.HasOnPlayerSight = true 

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL"}
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

