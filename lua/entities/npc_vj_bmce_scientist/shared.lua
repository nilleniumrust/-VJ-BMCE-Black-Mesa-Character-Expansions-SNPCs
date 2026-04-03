ENT.Base = "npc_vj_human_base"
ENT.Type = "ai"
ENT.PrintName = "Scientist"

ENT.Author = "Netberg1"
ENT.Contact = "https://steamcommunity.com/id/typeerrorrust/"
ENT.Category = "Black Mesa Character Expansions+"

-------------------------
local sourcePath = debug.getinfo(1, "S").source
local folderName = string.match(sourcePath, "entities/(.-)/")

if BMCE and BMCE.RegisterEntity then
    BMCE.RegisterEntity(folderName, ENT.PrintName, {
        Class = "Human",
        Appearance = "PRE"
    })
end