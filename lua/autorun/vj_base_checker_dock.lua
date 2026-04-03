if VJBASE_INSTALLED_CHECK then return end
VJBASE_INSTALLED_CHECK = true

local VJ_TITLE_MISSING_FORMAT = "Your game is missing %s! Please install it from the links provided below. \n After installing %s please enable it and restart the game."
local VJ_LABEL_MISSING = "%s: %s is missing!"
local VJ_BUILDER_MISSING = "Missing dependency for addon: %s using %s"

local function dockOutdatedFix()
    if VJF and type(VJF) == "Panel" then VJF:Close() end; VJF = true 
    return
end

local function dockAddWidget() 
    local VFrame = vgui.Create("DFrame")
    local Panel = vgui.Create("Panel", VFrame)

    local Label = vgui.Create("DLabel", Panel)
    local Body = vgui.Create("DLabel", Panel)
    local ButtonWS = vgui.Create("DButton", Panel)
    local ButtonClose = vgui.Create("DButton", Panel)

    VFrame:SetSize(320,160)
    VFrame:Center()
    VFrame:SetTitle(string.format(VJ_BUILDER_MISSING, BMCE.TITLE, BMCE.BUILDERTITLE))
    VFrame:SetBackgroundBlur(true)
    VFrame:DockPadding(12,34,12,12)

    VFrame:MakePopup()

    Panel:Dock(FILL)
    Panel:SetPaintBackground(false)

    Label:Dock(TOP)
    Label:SetText(string.format(VJ_LABEL_MISSING, BMCE.TITLE, BMCE.BUILDERTITLE))
    Label:SetContentAlignment(5)
    Label:SetTextColor(Color(255,128,120))
    Label:SetFont("DermaLarge")
    Label:SetTall(30)

    Body:Dock(TOP)
    Body:SetContentAlignment(5)
    Body:SetText(string.format(VJ_TITLE_MISSING_FORMAT, BMCE.BUILDERTITLE, BMCE.BUILDERTITLE))
    Body:SetAutoStretchVertical(true)

    ButtonWS:Dock(LEFT)
    ButtonWS:DockMargin(10, 8, 10, 0)
    ButtonWS:SetFont("DermaFontBold")
    ButtonWS:SetText("WORKSHOP - " .. BMCE.BUILDERTITLE)

    ButtonWS:SetTall(35)
    ButtonWS.DoClick = function() 
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
    end

    ButtonClose:Dock(RIGHT)
	ButtonClose:DockMargin(10, 8, 10, 0)
	ButtonClose:SetFont("DermaDefaultBold")
	ButtonClose:SetText("CLOSE")
	ButtonClose:SetWide(120)
	ButtonClose:SetTall(35)
    ButtonClose.DoClick = function() 
        VFrame:Close()
    end
end 

hook.Add("InitPostEntity", "VJBASE_INSTALLED_CHECK", function() 
    timer.Simple(1, function()
        if VJ_BASE_INSTALLED and not VJ_BASE_MISSING then return end
        VJBASE_ERROR_MISSING = true

        if CLIENT then 
            dockOutdatedFix()
            dockAddWidget()
        else 
            timer.Remove("VJBASEMissing"); VJF = true
            MsgC(Color(255, 165, 0), "Missing dependency: VJ Base. ", Color(255, 255, 255), "Install it from the Steam Workshop: ", Color(100, 200, 255), "https://steamcommunity.com/sharedfiles/filedetails/?id=131759821\n")
        end
    end)
end)
