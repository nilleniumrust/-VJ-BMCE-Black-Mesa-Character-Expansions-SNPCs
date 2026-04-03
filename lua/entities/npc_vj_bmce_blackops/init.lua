local fetchSoundTableMale = BMCE.SOUNDS.marine.female or {}

AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
    "models/humans_sep2025/blackops.mdl"
}

ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.HasGrenadeAttack = true
ENT.GrenadeAttackAttachment = "righthand"
ENT.VJ_NPC_Class = {"CLASS_BLACKOPS"}
ENT.AlliedWithPlayerAllies = false
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.HasMeleeAttack = true

ENT.Weapon_Accuracy = 0.8
ENT.FootstepSoundLevel = 40

function ENT:CustomOnInitialize()
    local currentVoiceSet = fetchSoundTableMale
    local faceChoice = -1
    if Skincount and Skincount > 1 then
        self:SetSkin(math.random(0, Skincount - 1))
    end

    for i = 0, self:GetNumBodyGroups() - 1 do
        local name = string.lower(self:GetBodygroupName(i))
        local Count = self:GetBodygroupCount(i)
        if name == "face" then
            local randomG = math.random(0, Count - 1)
            self:SetBodygroup(i, randomG)
            faceChoice = randomG

            continue
        end

        self:SetBodygroup(i, math.random(0, Count - 1))
    end

    if faceChoice != -1 then
        print("face choice: " .. faceChoice)
        if faceChoice == 0 then
            local headBone = self:LookupBone("ValveBiped.Bip01_Head1")
            if headBone == -1 then return end

            local GlowSprite = ents.Create("env_sprite")
            local GlowSprite_L = ents.Create("env_sprite")

            GlowSprite:SetKeyValue("model", "vj_base/sprites/glow.vmt")
            GlowSprite:SetKeyValue("scale", "0.05")
            GlowSprite:SetKeyValue("rendermode", "5")
            GlowSprite:SetKeyValue("rendercolor", "255 0 0")
            GlowSprite:SetPos(self:GetPos())
            GlowSprite:SetParent(self)
            GlowSprite:Spawn()

            GlowSprite_L:SetKeyValue("model", "vj_base/sprites/glow.vmt")
            GlowSprite_L:SetKeyValue("scale", "0.05")
            GlowSprite_L:SetKeyValue("rendermode", "5")
            GlowSprite_L:SetKeyValue("rendercolor", "255 0 0")
            GlowSprite_L:SetPos(self:GetPos())
            GlowSprite_L:SetParent(self)
            GlowSprite_L:Spawn()

            timer.Simple(0, function()
                if IsValid(self) then
                    if IsValid(GlowSprite) then
                        GlowSprite:FollowBone(self, headBone)
                        GlowSprite:SetLocalPos(Vector(4.5, -9, -1.5))
                    end

                    if IsValid(GlowSprite_L) then
                        GlowSprite_L:FollowBone(self, headBone)
                        GlowSprite_L:SetLocalPos(Vector(4.5, -9, 1.5))
                    end
                end
            end)

            self:DeleteOnRemove(GlowSprite)
            self:DeleteOnRemove(GlowSprite_L)

            util.SpriteTrail(GlowSprite_L, 0, Color(200, 0, 0), true, 2, 0, 0.2, 0.04167, "VJ_Base/sprites/trail.vmt")
            util.SpriteTrail(GlowSprite, 0, Color(200, 0, 0), true, 2, 0, 0.2, 0.04167, "VJ_Base/sprites/trail.vmt")
        end
    end

    self.SoundTbl_OnPlayerSight = currentVoiceSet.alert
    self.SoundTbl_Investigate = currentVoiceSet.check
    self.SoundTbl_LostEnemy = currentVoiceSet.check
    self.SoundTbl_CallForHelp = currentVoiceSet.charge
    self.SoundTbl_WeaponReload = currentVoiceSet.cover
    self.SoundTbl_GrenadeSight = currentVoiceSet.gren
    self.SoundTbl_AllyDeath = currentVoiceSet.alert
    self.SoundTbl_ChaseEnemy = currentVoiceSet.charge
    self.SoundTbl_Suppressing = currentVoiceSet.charge
    self.SoundTbl_OnFire = currentVoiceSet.onfire
    self.SoundTbl_Pain = currentVoiceSet.pain
    self.SoundTbl_Death = currentVoiceSet.gibdeath
end

function ENT:HandleAnimEvent(event)
    if event == "AE_NPC_RIGHTFOOT" or event == "AE_NPC_BODYDROP_HEAVY" then
        return true
    end
    return true
end
