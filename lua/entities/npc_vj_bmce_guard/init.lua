local FemaleModels = {
    "models/humans_sep2025/guard_female.mdl"
}

local MaleModels = {
    "models/humans_sep2025/guard.mdl",
    "models/humans_sep2025/guard_02.mdl",
    "models/humans_sep2025/guard_03.mdl",
    "models/humans_sep2025/guard_04.mdl",
    "models/humans_sep2025/guard_jacket.mdl",
    "models/humans_sep2025/guard_jacket_02.mdl",
    "models/humans_sep2025/guard_jacket_03.mdl",
    "models/humans_sep2025/guard_jacket_04.mdl"
}

local fetchSoundTableMale = BMCE.SOUNDS.guard.male or {}
local fetchSoundTableFemale = BMCE.SOUNDS.guard.female or {}

local voiceSet 
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CustomOnInitialize()
    local BodyGroupCount = self:GetNumBodyGroups()
    local SkinCount = self:SkinCount()

    local bgHelmet = -1
    local bgHardhat = -1

    local _leaderChance = math.random(1,8)
    local IsLeader = (_leaderChance == 8)


    if BodyGroupCount then 
        for i = 1, BodyGroupCount - 1 do 
            local Count = self:GetBodygroupCount(i) 
            local name = string.lower(self:GetBodygroupName(i))

            if name == "helmet" then
                bgHelmet = i
                continue
            elseif name == "hardhat" then 
                bgHardhat = i
                continue
            end

            self:SetBodygroup(i, math.random(0, Count - 1))
        end 
    end

    if SkinCount and SkinCount > 1 then 
        self:SetSkin(math.random(0, SkinCount - 1))
    end

    local hasHardHat = false 

    if not IsLeader then 
        if bgHardhat != -1 then 
        if math.random(1,4) == 4 then 
            local Count = self:GetBodygroupCount(bgHardhat)
            self:SetBodygroup(Count, math.random(1, Count - 1))
        else 
            self:SetBodygroup(bgHardhat, 0)
        end
        end

        if bgHelmet != -1 then
            if hasHardhat then 
                self:SetBodyGroup(bgHelmet, 0)
            else 
            if math.random(1, 10) <= 7 then
                local Count = self:GetBodygroupCount(bgHelmet)
                self:SetBodygroup(bgHelmet, math.random(1, Count - 1))
            else
                self:SetBodygroup(bgHelmet, 0)
            end
          end
        end
    else 
        local Beret = ents.Create("prop_physics")
        if self.Human_Gender == BMCE.GENDERVALUES.MALE then 
            Beret:SetModel("models/humans_sep2025/props/guard_beret.mdl")
        else 
            Beret:SetModel("models/humans_sep2025/props/guard_beret_fem.mdl")
        end

        self:SetBodygroup(bgHelmet, 1) -- Sets to empty, because for some reason our zero is the "guard helmet"
        
        Beret:SetPos(self:GetLocalPos())
        Beret:SetOwner(self)
        Beret:SetParent(self)
        Beret:Fire("SetParentAttachment", "eyes")

        Beret:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        Beret:Spawn()
        Beret:Activate()
        Beret:AddEffects(EF_BONEMERGE)

        self:SetHealth(85)
    end

end

--// We detect the red beret marines and yell out a voiceline for this guard
function ENT:OnAlert(Entity)
    if not IsValid(Entity) then return end 
    if Entity:IsPlayer() then return end 
    if not IsValid(self:GetEnemy()) then return end
    if not Entity:GetClass() == "npc_vj_bmce_marine" or not Entity:GetClass() == "npc_vj_bmce_aftermathmarine" then return end

    if Entity.Beret then 
        self:PlaySoundSystem("Alert", voiceSet.lookout)
    end
end

function ENT:OnMaintainRelationships(Entity, Displacement, Distance)
    if not IsValid(Entity) then return end 
    if Displacement == D_NU or Displacement == D_HT then return end 
    if IsValid(self:GetEnemy()) then return end
    if CurTime() < self.ReloadTrigger then return end

    if Distance > 200 then return end

    self.ReloadTrigger = CurTime() + math.random(10, 60)
    if Entity:IsPlayer()  then 
        local CurrentWeapon = Entity:GetActiveWeapon()
        local Random = math.random(1,2)

        if IsValid(CurrentWeapon) and Random == 2 then 
            local AmmoType = CurrentWeapon:GetPrimaryAmmoType()

            if AmmoType and AmmoType > -1 then 
                if Entity:GetAmmoCount(AmmoType) <= 255 and IsValid(self:GetActiveWeapon()) and not self:IsBusy() then 
                    if Distance > 100 then 
                        self.ReloadTrigger = 0 
                    else 
                        local t, AnimTime = self:PlayAnim("heal", true, false, false, 0, { 
                            OnFinish = function(Interrupted, Anim)
                                if not Interrupted then 
                                    Entity:GiveAmmo(10, AmmoType)
                                end
                            end
                        })

                        self:SetTurnTarget(Entity, AnimTime)
                        self:PlaySoundSystem("Speech", voiceSet.ammo)
                    end
                elseif CurrentWeapon:Clip1() < CurrentWeapon:GetMaxClip1() and Entity:GetAmmoCount(AmmoType) > 0 then 
                    self:PlaySoundSystem("Speech", voiceSet.reloadfm)
                end
            end
        end
    end
end

function ENT:CustomOnPreInitialize()
    if self.Human_Gender == nil or self.Human_Gender == BMCE.GENDERVALUES.INVALID then
        self.Human_Gender = (math.random(1, 2) == 1) and BMCE.GENDERVALUES.MALE or BMCE.GENDERVALUES.FEMALE
    end

    voiceSet = fetchSoundTableMale
    if self.Human_Gender == BMCE.GENDERVALUES.FEMALE then
        self.Model = FemaleModels
        voiceSet = fetchSoundTableFemale
    else
        self.Model = MaleModels
        voiceSet = fetchSoundTableMale
    end

    self.StartHealth = 70 
    self.HullType = HULL_HUMAN 
    self.HasGrenadeAttack = false 
    self.HasOnPlayerSight = true 

    self.ReloadTrigger = 0

    self.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_BLACK_MESA_PERSONNEL"}
    self.AlliedWithPlayerAllies = true 
    self.BloodColor = VJ.BLOOD_COLOR_RED 

    self.HasMeleeAttack = true 
    self.MeleeAttackDamage = 8 
    self.TimeUntilMeleeAttackDamage = 0.5

   if self.Human_Gender == BMCE.GENDERVALUES.FEMALE then 
        self.SoundTbl_Idle = voiceSet.statement
        self.SoundTbl_OnPlayerSight = voiceSet.abouttime
    
        self.SoundTbl_GrenadeSight = voiceSet.lookoutfm
        self.SoundTbl_Pain = voiceSet.scream
        self.SoundTbl_Death = voiceSet.ow
    
        self.SoundTbl_Alert = voiceSet.heretheycome
        self.SoundTbl_FollowPlayer = voiceSet.leadtheway 
        self.SoundTbl_UnFollowPlayer = voiceSet.illstayhere
        self.SoundTbl_DamagePlayer = voiceSet.stopitfm or voiceSet.annoyance

        self.SoundTbl_IdleDialogueAnswer = voiceSet.answer
        self.SoundTbl_IdleDialogue = voiceSet.question
        self.SoundTbl_YieldToPlayer = voiceSet.sorry
    else 
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

    self:SetAnimationTranslations(VJ.ANIM_SET_REBEL)
end

