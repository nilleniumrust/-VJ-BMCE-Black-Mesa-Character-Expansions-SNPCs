--// Voices 
--// Here's a fun thing: The female isn't an actual voices pack it's just gasmask voice.
local fetchSoundTableMale = BMCE.SOUNDS.marine.male or {}
local fetchSoundTableFemale = BMCE.SOUNDS.marine.female or {}

local radio = BMCE.SOUNDS.radio.male or {}

--// Bodygroup restrictions 
--// I don't actually know why subgroups begin from 0, while Bodygroups begin from 1. Same issue with perplexed ENT.Model 
local gearBan = {
    [1] = {[0] = true},
    [2] = {[0] = true},
    [3] = {[0] = true, [3] = true, [6] = true},
    [4] = {[0] = true, [3] = true, [5] = true, [6] = true}
}

local medicGear = {
    [1] = {[5] = {[2] = true, [5] = true}},
    [2] = {[5] = {[2] = true}},
    [3] = {[5] = {[2] = true, [5] = true}},
    [4] = {[5] = {[2] = true}}
}

local allowNVGsforHelmets = {
    [1] = {[1] = true, [2] = true, [4] = true, [5] = true},
    [2] = {[1] = true, [2] = true, [4] = true},
    [3] = {[1] = true, [2] = true, [5] = true, [6] = true},
    [4] = {[1] = true, [2] = true, [4] = true}
}

AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
    "models/humans_sep2025/marine.mdl",
    "models/humans_sep2025/marine_02.mdl",
    "models/humans_sep2025/masked_marine.mdl",
    "models/humans_sep2025/masked_marine_02.mdl"
}

--// Config
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.HasGrenadeAttack = true
ENT.GrenadeAttackAttachment = "righthand"
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES"}
ENT.AlliedWithPlayerAllies = false
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.HasMeleeAttack = true
ENT.Weapon_CanSecondaryFire = false

function ENT:CustomOnThink()
    if self.Dead or self.VJ_IsBeingControlled then return end
    if IsValid(self:GetEnemy()) then return end
    if self:IsBusy() then return end

    -- Slightly decrease time since it's during incident, and many things can happen here.
    if not self.NextRadioChatterT then
        self.NextRadioChatterT = CurTime() + math.random(15, 40)
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
    local LeaderChance = math.random(1, 4)

    local modelIndex = table.KeyFromValue(self.Model, modelName)
    local IsRedBeret = false

    if LeaderChance == 1 then
        IsRedBeret = true
    end

    if Skincount and Skincount > 1 then
        self:SetSkin(math.random(0, Skincount - 1))
    end

    --// Sort out garbage and stuff
    --// Very useful mate
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
    
    --// Again, we sort out stuff that is needed for us
    for i = 0, self:GetNumBodyGroups() - 1 do
        if i == 0 then continue end
        if isMedic then continue end
        if i == bgNV or i == bgMask or i == bgHeadset or i == bgPack or i == bgHelmet then continue end

        local Count = self:GetBodygroupCount(i)
        self:SetBodygroup(i, math.random(0, Count - 1))
    end

    --// Rucksack randomization so we don't always spawn with rucksacks
    if bgPack != -1 then
        local rucksackCount = self:GetBodygroupCount(bgPack)
        local spawnWithBg = math.random(1, 2)
        if isMedic then
            if spawnWithBg == 2 then 
                self:SetBodygroup(bgPack, math.random(0, rucksackCount - 1))
            end
        else
            if spawnWithBg == 2 then 
                self:SetBodygroup(bgPack, math.random(0, rucksackCount - 2))
            end
        end

        if spawnWithBg == 1 then 
            self:SetBodygroup(bgPack, 1)
        end
    end

    local emptyHelmets = gearBan[1]
    local currentVoiceSet = fetchSoundTableMale

    if modelIndex then
        local helm_category_medic = medicGear[modelIndex][bgHelmet]
        local HelmetCount = self:GetBodygroupCount(bgHelmet)
        local allowedHelmets = {}

        for i = 0, HelmetCount - 1 do
            if not isMedic and helm_category_medic[i] then continue end
            table.insert(allowedHelmets, i)
        end

        --// Red berets choicing (Squad Leader)
        --// Red berets have also a very accurate spread in which other marines do not have 
        --// Red berets have increased health, whilst not having a Helmet, but since they are extreme prepared vets, they are very experienced.
        if modelIndex > 2 then
            currentVoiceSet = fetchSoundTableFemale
        else
            if IsRedBeret then
                local Beret = ents.Create("prop_physics")
                
                --// Keep the old choice, for 25% chance of appearing with the old beret which means they were part of Black Mesa compounds, not the exterior HECU soldiers.
                local BeretOld = math.random(1,4) 

                
                if BeretOld == 3 then 
                    Beret:SetModel("models/humans_sep2025/props/marine_beret.mdl")
                    self.Beret = {
                        Model = "models/humans_sep2025/props/marine_beret.mdl"
                    }
                else 
                    Beret:SetModel("models/humans_sep2025/props/marine_beret_02.mdl")
                    self.Beret = {
                        Model = "models/humans_sep2025/props/marine_beret_02.mdl"
                    }
                end

                Beret:SetLocalPos(self:GetPos())
                Beret:SetOwner(self)
                Beret:SetParent(self)
                Beret:Fire("SetParentAttachment", "eyes")
                Beret:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                Beret:Spawn()
                Beret:Activate()
                Beret:SetSolid(SOLID_NONE)
                Beret:AddEffects(EF_BONEMERGE)
               
                self:SetHealth(100)

                self.NextSecondaryFire = VJ.SET(4, 8)
                self.MinSecondaryFireDistance = 150
                self.Weapon_CanSecondaryFire = true
                self.Weapon_Accuracy = 0.8
            end
        end

        --// Medic equipment & Helmet randomization stuff
        if isMedic and helm_category_medic and not IsRedBeret then
            local keys_medic = table.GetKeys(helm_category_medic)
            if #keys_medic > 0 then
                local randomHelm = keys_medic[math.random(1, #keys_medic)]
                if randomHelm then
                    self:SetBodygroup(bgHelmet, randomHelm)
                end
            end
            self:SetBodygroup(6, 3)
            self:SetBodygroup(7, 3)
        else
            if #allowedHelmets > 0 and not IsRedBeret then
                local randomSelection = math.random(1, #allowedHelmets)
                local finalHelmetIndex = allowedHelmets[randomSelection]
                self:SetBodygroup(bgHelmet, finalHelmetIndex)
            end
        end

        emptyHelmets = gearBan[modelIndex]
    end

    self.VoiceSetExterior = currentVoiceSet
    self.SoundTbl_Idle = currentVoiceSet.idle
    self.SoundTbl_MedicBeforeHeal = currentVoiceSet.medic
    self.SoundTbl_Alert = currentVoiceSet.alert
    self.SoundTbl_OnPlayerSight = currentVoiceSet.alert
    self.SoundTbl_Investigate = currentVoiceSet.check
    self.SoundTbl_LostEnemy = currentVoiceSet.clear

    self.SoundTbl_WeaponReload = currentVoiceSet.cover
    self.SoundTbl_GrenadeSight = currentVoiceSet.gren

    self.SoundTbl_ChaseEnemy = currentVoiceSet.charge
    self.SoundTbl_Suppressing = currentVoiceSet.charge
    self.SoundTbl_IdleDialogueAnswer = currentVoiceSet.answer
    self.SoundTbl_OnFire = currentVoiceSet.onfire
    self.SoundTbl_IdleDialogue = currentVoiceSet.question

    self.SoundTbl_KilledEnemy = currentVoiceSet.enemydown 
    self.SoundTbl_CombatIdle = currentVoiceSet.taunt
    self.SoundTbl_Pain = currentVoiceSet.pain
    self.SoundTbl_Death = currentVoiceSet.gibdeath

    --// We do not allow red berets to be medics in this case. I don't know why, but why not.
    if not IsRedBeret and isMedic then
        self.IsMedic = true
        self.Medic_CheckDistance = 600
        self.Medic_HealDistance = 100
        self.Medic_HealthAmount = 25
        self.Medic_SpawnPropOnHeal = true
        self.Medic_SpawnPropOnHealModel = "models/items/healthkit.mdl"
    end

    local curHelmet = (bgHelmet != -1) and self:GetBodygroup(bgHelmet) or 0

    if emptyHelmets[curHelmet] and not IsRedBeret then
        if bgNV != -1 then self:SetBodygroup(bgNV, 0) end
        if bgHeadset != -1 then self:SetBodygroup(bgHeadset, 0) end
        self:SetHealth(self.StartHealth - 20)
    end

    --// NVG Section
    --// Look, nobody wants floating NVGs for marines. 
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

--// convar [developer 1] anti-spam event handler
--// or generally console anti-spam protection
function ENT:HandleAnimEvent(event)
    if event == "AE_NPC_RIGHTFOOT" or event == "AE_NPC_BODYDROP_HEAVY" then
        return true
    end
end

function ENT:OnCreateDeathCorpse()
    if self.Beret then 
        self:CreateExtraDeathCorpse("prop_physics", self.Beret.Model, {Pos = self:LocalToWorld(Vector(0,0,-2))})
    end
end