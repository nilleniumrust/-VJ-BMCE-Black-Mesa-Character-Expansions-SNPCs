local function Categorize()
    assert(VJ, "[BMCE+]: VJ Base was not found!")
    assert(BMCE and BMCE.ENTITIES, "[BMCE+]: Calhoun? Calhoun! We got a cascade here! BMCE+ global is missing!")
    assert(table.Count(BMCE.ENTITIES) > 0, "[BMCE+]: BMCE+ is missing entities that should've been preloaded") 
    assert(table.Count(BMCE.WEAPONS) > 0, "[BMCE+]: BMCE+ is missing weapons that should've been preloaded")

    VJ.AddPlugin("Black Mesa Character Expansions+", "NPC", BMCE.VERSION)
    VJ.BMCE_VERSION = BMCE.VERSION 

    ---------------------------------------------------------
    ----= CATEGORIES =---------------------------------------
    --------------------------------------------------------
    local PostDisaster_Category = "BMCE+: Incident"
    local PreDisaster_Category = "BMCE+: Pre-Incident"

    local Weapons_Category = "BMCE+: Weapons"

    VJ.AddCategoryInfo(PostDisaster_Category, {Icon = "vj_hl/icons/hl1.png"})
    VJ.AddCategoryInfo(PreDisaster_Category, {Icon = "vj_hl/icons/hl2.png"})
    VJ.AddCategoryInfo(Weapons_Category, {Icon = "vj_hl/icons/hl2.png"})
    ---------------------------------------------------------

    for i, AssetEntity in pairs(BMCE.ENTITIES) do  
        assert(AssetEntity.Base, "Item " .. i .. " is missing the base path!")
        assert(AssetEntity.Appearance, "Item " .. i .. " is missing Appearance (POST/PRE/BOTH)!")

        if SERVER then 
            util.PrecacheModel(AssetEntity.Base)
            print("precache " .. AssetEntity.Base)
        end

        local targetCategory = PostDisaster_Category
        if AssetEntity.Appearance == "PRE" then
            targetCategory = PreDisaster_Category
        end

        if AssetEntity.Class == "Human" then 
            if AssetEntity.Appearance == "BOTH" then
                VJ.AddNPC_HUMAN(AssetEntity.Name, AssetEntity.Base, AssetEntity.UsesWeapon or {}, PostDisaster_Category)
                VJ.AddNPC_HUMAN(AssetEntity.Name, AssetEntity.Base, AssetEntity.UsesWeapon or {}, PreDisaster_Category)
            else
                VJ.AddNPC_HUMAN(AssetEntity.Name, AssetEntity.Base, AssetEntity.UsesWeapon or {}, targetCategory)
            end
        end
    end

    for i, AssetWeapon in ipairs(BMCE.WEAPONS) do 
        assert(AssetWeapon.Name and AssetWeapon.Base, "[BMCE+]: Weapon " .. i .. " is missing it's title information!")
        
        VJ.AddWeapon(AssetWeapon.Name, AssetWeapon.Base, false, Weapons_Category)
        VJ.AddNPCWeapon("VJ_BMCEPLUS" .. string.upper(AssetWeapon.Name), AssetWeapon.Base)
    end

    for i, Convars in ipairs(BMCE.CONVARS) do 
        print("Convar " .. i .. " loading..")
        VJ.AddConVar(i, Convars.Value, Convars.FC_VAR_TYPE)
    end 
end

hook.Add("Initialize", "BMCE_Loader", function() 
    local startTime = os.clock()
    Categorize()
    local duration = math.Round(os.clock() - startTime, 4)

    local titleCol = Color(0, 150, 255)
    local textCol = Color(255, 255, 255)
    
    MsgC(titleCol, BMCE.TITLE or "[BMCE+] ", textCol, " loaded in ", duration, "s\n")
end)

if CLIENT then 
    hook.Add("PopulateToolMenu", "VJ_BMCEPLUS_SETTINGS", function()
        spawnmenu.AddToolMenuOption("DrVrej", "SNPC Configures", "BMCE+: Settings", "BMCE+: Settings", "", "", function(panel) 
            local Player = LocalPlayer()

            if not game.SinglePlayer() and not Player:IsAdmin() then 
                panel:Help("Sorry pal, this panel is for admins only!")
                return
            end

            panel:CheckBox("Allow marines to chatter in radio?", "vj_bmceplus_marineradio_allowchatter")
        end)
    end)
end