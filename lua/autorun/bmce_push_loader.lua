BMCE = BMCE or {}
BMCE.TITLE = "[BMCE+]"

BMCE.VERSION = "beta 0.1"
BMCE.WORKSHOP = nil 

BMCE.BUILDERTITLE = "VJ Base" 
BMCE.GLOBALINIT = true
BMCE.ENTITIES = {}

BMCE.GENDERVALUES = {
    INVALID = -1,
    MALE = 0, 
    FEMALE = 1
}


BMCE.CONVARS = {
    ["vj_bmceplus_marineradio_allowchatter"] = {
        FC_VAR_TYPE = {FCVAR_ARCHIVE}, 
        Value = 1,
        Definition = "Allow radio chatter for marines?"
    }
}

BMCE.WEAPONS = {}
BMCE.VALIDAPPEARANCES = {"POST", "BOTH", "PRE"}
BMCE.SOUNDS = {}

local STRIP_PREFIXES = {"grd_bs_","hg_","grd_","hg"}

local function StripPrefix(name)
    name = name:match("(.+)%..+$") or name
    for _, prefix in ipairs(STRIP_PREFIXES) do
        if name:sub(1, #prefix) == prefix then
            return name:sub(#prefix + 1)
        end
    end
    return name
end

local function ExtractCategory(name)
    return name:match("^(%a+)") or "misc"
end

function BMCE.FindDescendants(path, filter, gamepath)
    local results = {}
    local files, folders = file.Find(path .. filter, gamepath)

    for _, f in ipairs(files) do
        table.insert(results, path .. f)
    end
    local _, subfolders = file.Find(path .. "*", gamepath)
    
    for _, folder in ipairs(subfolders) do
        local sub = BMCE.FindDescendants(path .. folder .. "/", filter, gamepath)
        for _, f in ipairs(sub) do
            table.insert(results, f)
        end
    end
    return results
end

function BMCE.PreStoreGenerationSoundTable()
    local PairFind = BMCE.FindDescendants("sound/vj_bmce/npc/", "*.wav", "GAME")

    for _, pairAsset in ipairs(PairFind) do 
        local NPC, Gender, FileName = pairAsset:match("npc/([^/]+)/([^/]+)/(.+)$")
        if not NPC then continue end 

        local PrefixStrip = StripPrefix(FileName)
        local Category = ExtractCategory(PrefixStrip)

        local cleanPath = pairAsset:gsub("^sounds?/", "")
        BMCE.SOUNDS[NPC] = BMCE.SOUNDS[NPC] or {}
        BMCE.SOUNDS[NPC][Gender] = BMCE.SOUNDS[NPC][Gender] or {}
        BMCE.SOUNDS[NPC][Gender][Category] = BMCE.SOUNDS[NPC][Gender][Category] or {}

        table.insert(BMCE.SOUNDS[NPC][Gender][Category], cleanPath)
    end
end

function BMCE.RegisterEntity(class, name, data)
    if not BMCE.ENTITIES[class] then
        BMCE.ENTITIES[class] = {
            Base = class,
            Name = name or class,
            Class = data.Class or "Human",
            UsesWeapon = data.UsesWeapon or {"weapon_vj_bmceplus_glock17"},
            Appearance = data.Appearance or "POST"
        }
    end
end



local titleCol = Color(0, 150, 255)
local textCol = Color(255, 255, 255)

MsgC(titleCol, BMCE.TITLE or "[BMCE+]:", textCol, " loading batch provided sounds... \n")
BMCE.PreStoreGenerationSoundTable()
MsgC(titleCol, BMCE.TITLE or "[BMCE+]:", textCol, " sounds loaded! \n")