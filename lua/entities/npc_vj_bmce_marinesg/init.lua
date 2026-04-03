local fetchSoundTableMale = BMCE.SOUNDS.marine.male or {}
local fetchSoundTableFemale = BMCE.SOUNDS.marine.female or {}

local radio = BMCE.SOUNDS.radio.male or {}

local gearBan = {
    [1] = {
        [0] = true,
        [3] = true,
        [6] = true
    },
    [2] = {
        [0] = true,
        [3] = true, 
        [6] = true
    },
    [3] = {
        [0] = true,
        [3] = true,
        [6] = true
    },
    [4] = {
        [0] = true, 
        [3] = true, 
        [5] = true, 
        [6] = true
    }
}

local medicGear = {
    [1] = {
        [5] = {
            [3] = true, 
            [5] = true
        }
    },
    [2] = {
        [5] = {
            [2] = true
        }
    },
    [3] = {
        [5] = {
            [3] = true, 
            [6] = true
        }
    },
    [4] = {
        [5] = {
            [2] = true
        }
    }
}

local allowNVGsforHelmets = {
    [1] = {
        [1] = true,
        [2] = true,
        [4] = true,
        [5] = true
    },
    [2] = {
        [1] = true,
        [2] = true,
        [4] = true
    },
    [3] = {
        [1] = true,
        [2] = true,
        [5] = true,
        [6] = true
    },
    [4] = {
        [1] = true,
        [2] = true,
        [4] = true
    }
}

AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
    "models/humans_sep2025/marine_sg.mdl",
    "models/humans_sep2025/marine_02_sg.mdl",
    "models/humans_sep2025/masked_marine_sg.mdl",
    "models/humans_sep2025/masked_marine_02_sg.mdl"
}

ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.HasGrenadeAttack = true
ENT.GrenadeAttackAttachment = "righthand"
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES", "CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.HasMeleeAttack = true

function ENT:CustomOnThink()
    if self.Dead or self.VJ_IsBeingControlled then return end
    if IsValid(self:GetEnemy()) then return end
    if self:IsBusy() then return end

    if not self.NextRadioChatterT then
        self.NextRadioChatterT = CurTime() + math.random(25, 60)
    end
    
    if self.NextRadioChatterT < CurTime() then
        if IsValid(self:GetEnemy()) then return end

        local random = VJ.PICK(radio.radio)
        local duration = SoundDuration(random)
        local random_chatter = math.random(1, 2)

        VJ.EmitSound(self, random, 75, 100)
        self.NextRadioChatterT = CurTime() + math.random(30, 140)

        if random_chatter == 2 then 
            timer.Simple(duration, function()
                if IsValid(self) and not self.Dead then
                    timer.Simple(0.1, function()
                        self:PlaySoundSystem("Speech", radio.beep)
                    end)
                    
                    timer.Simple(0.3, function()
                        self:PlaySoundSystem("Speech", self.VoiceSetExterior.answer)
                    end)
                end
            end)
        end
    end
end

function ENT:CustomOnInitialize()
    local modelName = self:GetModel()
    local bgHelmet, bgNV, bgMask, bgHeadset, bgPack = -1, -1, -1, -1, -1

    local Medic_random = math.random(1, 3)
    local isMedic = (Medic_random == 3)

    local Skincount = self:SkinCount()

    if Skincount and Skincount > 1 then
        self:SetSkin(math.random(0, Skincount - 1))
    end

    --// Categorize the bodygroups and see if they exist, put their IDs into static vars
    for i = 0, self:GetNumBodyGroups() - 1 do
        local name = string.lower(self:GetBodygroupName(i))
        if name == "helmet" then
            bgHelmet = i
        elseif name == "nv" then
            bgNV = i
        elseif name == "gasmask" or name == "mask" then
            bgMask = i
        elseif name == "headset" then
            bgHeadset = i
        elseif name == "rucksack" then
            bgPack = i
        end
    end

    --// We randomize and ditch something I guess........
    for i = 0, self:GetNumBodyGroups() - 1 do
        if i == 0 then continue end
        if isMedic then continue end
        if i == bgNV or i == bgMask or i == bgHeadset or i == bgPack or i == bgHelmet then continue end 

        local Count = self:GetBodygroupCount(i)
        self:SetBodygroup(i, math.random(0, Count - 1))
    end
    
    --// randomize rucksack to make it look different and not ALWAYS spawn with rucksack
    if bgPack != -1 then 
        local rucksackCount = self:GetBodygroupCount(bgPack)
    
        if isMedic then 
         self:SetBodygroup(bgPack, (math.random(1, 3) == 3) and 1 or 3)
        else 
            local safeMax = math.max(0, rucksackCount - 2) 
            self:SetBodygroup(bgPack, math.random(0, safeMax))
        end
    end

    local currentVoiceSet = fetchSoundTableMale
    local emptyHelmets = gearBan[1]


    local modelIndex = table.KeyFromValue(self.Model, modelName)

    --// I wondered why Black Mesa uses female for marines even though they don't exist, then I knew.
    --// Gasmask voice and gearbans
    if modelIndex then 
        local modelRules = medicGear[modelIndex]
        local helm_category_medic = modelRules and modelRules[bgHelmet] or nil

        local HelmetCount = self:GetBodygroupCount(bgHelmet)
        local allowedHelmets = {}

        for i = 0, HelmetCount - 1 do 
            if not isMedic and helm_category_medic and helm_category_medic[i] then
                continue 
            end
            table.insert(allowedHelmets, i)
        end

        if modelIndex > 2 then
            currentVoiceSet = fetchSoundTableFemale
        end

        if isMedic and helm_category_medic then 
            local keys_medic = table.GetKeys(helm_category_medic)
            if #keys_medic > 0 then
                local randomHelm = keys_medic[math.random(1, #keys_medic)]
                self:SetBodygroup(bgHelmet, randomHelm)
            end

            if self:GetNumBodyGroups() > 7 then
                self:SetBodygroup(6, 3)
                self:SetBodygroup(7, 3)
            end
        else 
            if #allowedHelmets > 0 then
                local randomSelection = math.random(1, #allowedHelmets)
                self:SetBodygroup(bgHelmet, allowedHelmets[randomSelection])
            end
        end

        emptyHelmets = gearBan[modelIndex] or gearBan[1]
    end

    self.VoiceSetExterior = currentVoiceSet
    self.SoundTbl_Idle = currentVoiceSet.idle
    self.SoundTbl_MedicBeforeHeal = currentVoiceSet.medic
    self.SoundTbl_OnPlayerSight = currentVoiceSet.alert
    self.SoundTbl_Investigate = currentVoiceSet.check
    self.SoundTbl_LostEnemy = currentVoiceSet.check
    self.SoundTbl_CallForHelp = currentVoiceSet.charge
    self.SoundTbl_WeaponReload = currentVoiceSet.cover
    self.SoundTbl_GrenadeSight = currentVoiceSet.gren
    self.SoundTbl_AllyDeath = currentVoiceSet.alert
    self.SoundTbl_ChaseEnemy = currentVoiceSet.charge
    self.SoundTbl_Suppressing = currentVoiceSet.charge
    self.SoundTbl_IdleDialogueAnswer = currentVoiceSet.answer
    self.SoundTbl_OnFire = currentVoiceSet.onfire
    self.SoundTbl_IdleDialogue = currentVoiceSet.question
    self.SoundTbl_DangerSight = currentVoiceSet.question
    self.SoundTbl_KilledEnemy = currentVoiceSet.taunt
    self.SoundTbl_Pain = currentVoiceSet.pain
    self.SoundTbl_Death = currentVoiceSet.gibdeath

    local curHelmet = (bgHelmet != -1) and self:GetBodygroup(bgHelmet) or 0

    --// if the marine has no helmet, we deduct 20 health from health because he can get wounds (shrapnel, bullets)
    if emptyHelmets[curHelmet] then
        if bgNV != -1 then self:SetBodygroup(bgNV, 0) end
        if bgHeadset != -1 then self:SetBodygroup(bgHeadset, 0) end

        self:SetHealth(self.StartHealth - 20)
    end

    --// NVG section
    if modelIndex and allowNVGsforHelmets[modelIndex] then
        local indexp_Parent = allowNVGsforHelmets[modelIndex]
        local indexp_Helmet = indexp_Parent[curHelmet]

        if indexp_Helmet then
            local addNVG = math.random(1, 4)
            if addNVG == 4 then
                local choiceCount = self:GetBodygroupCount(bgNV)
                self:SetBodygroup(bgNV, math.random(0, choiceCount - 1))
            end
        else
            self:SetBodygroup(bgNV, 0)
        end
    end
end

function ENT:HandleAnimEvent(event)
    if event == "AE_NPC_RIGHTFOOT" or event == "AE_NPC_BODYDROP_HEAVY" then
        return true
    end
    return true
end
