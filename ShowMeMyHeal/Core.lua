local AceGUI = LibStub("AceGUI-3.0")

ShowMeMyHeal = LibStub("AceAddon-3.0"):NewAddon("ShowMeMyHeal", "AceConsole-3.0", "AceEvent-3.0")

local defaults = {
    profile = {
        minimap = { 
            hide = false, 
        }, 
        fontSizeNormalHeal = 30,
        fontSizeCriticalHeal = 41,
        animationDuration = 4,
        updateTime = 0.2,
        scrollLength = 480,
        offsetX = 0,
        offsetY = 0,
        showHOTs = true,
        showTargetHealName = true,
        showVampiricEmbracePriest = true,
        showAllPLayersWhoAreHealing = false,
        showOverheal = true,
        overhealShowThreshold = 0,
        showZeroHeal = true,
        showSelfHeal = true,
        colorCrit = "FF0000",
        colorNormal = "0FFF00",
        colorExcess = "EDF404",
        colorName = "FFFFFF",
    },
}

ShowMeMyHealIconDB = LibStub("LibDataBroker-1.1"):NewDataObject("ShowMeMyHealIcon", {
    type = "data source",
    text = "ShowMeMyHeal!",
    icon = "Interface\\Icons\\Spell_Holy_Heal",
    OnClick = function() 
        if ShowMeMyHeal.SettingsUI:IsShown() then
            ShowMeMyHeal.SettingsUI:Hide()
        else
            ShowMeMyHeal.SettingsUI:Show()
        end
    
    end,
	OnTooltipShow = function (tooltip)
		tooltip:AddLine("|cFF0FFF00ShowMeMyHeal|r", 1, 1, 1);
	end
})

function ShowMeMyHealSlashFunction(arg)
    if arg == "show" then
        ShowMeMyHeal.SettingsUI:Show()
    elseif arg == "hide" then
        ShowMeMyHeal.SettingsUI:Hide()
    end
end

function ShowMeMyHeal_Upload()
    if ShowMeMyHeal.texts[1] ~= nil then
        ShowMeMyHeal:DisplayText(ShowMeMyHeal.texts[1].text, ShowMeMyHeal.texts[1].isCrit)
        table.remove(ShowMeMyHeal.texts, 1)
    end
end

function ShowMeMyHeal:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ShowMeMyHealDB", defaults, true)
end

function ShowMeMyHeal:OnEnable()
    ShowMeMyHeal.texts = { };
    ShowMeMyHeal.myName = UnitName("player")
    ShowMeMyHeal.myGUID = UnitGUID("player")

    ShowMeMyHeal:CreateUI()
    ShowMeMyHeal:BinUI()

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")   

    self:RegisterChatCommand("smmh", ShowMeMyHealSlashFunction, true)

    ticker = C_Timer.NewTicker(0.2, ShowMeMyHeal_Upload)

    ShowMeMyHeal:Print("is enabled.") 
end



function ShowMeMyHeal:HexToRGBPerc(hex)
    local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

function ShowMeMyHeal:RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function ShowMeMyHeal:CreateUI()

    local function CreateMinimapMenu(container)

        ShowMeMyHeal.SettingsUI.checkboxMinimap  = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.checkboxMinimap:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.checkboxMinimap:SetLabel("Hide minimap button")
        ShowMeMyHeal.SettingsUI.checkboxMinimap:SetValue(self.db.profile.minimap.hide)   
        container:AddChild(ShowMeMyHeal.SettingsUI.checkboxMinimap) 
    end

    local function CreateButtonMenu(container)

        local header = AceGUI:Create("Heading")
        header:SetText("")
        header:SetFullWidth(true)
        header:SetHeight(30)
        container:AddChild(header)

        ShowMeMyHeal.SettingsUI.buttonReset = AceGUI:Create("Button")
        ShowMeMyHeal.SettingsUI.buttonReset:SetText("Reset")
        ShowMeMyHeal.SettingsUI.buttonReset:SetWidth(180)
        container:AddChild(ShowMeMyHeal.SettingsUI.buttonReset)

        ShowMeMyHeal.SettingsUI.buttonTest = AceGUI:Create("Button")
        ShowMeMyHeal.SettingsUI.buttonTest:SetText("Test")
        ShowMeMyHeal.SettingsUI.buttonTest:SetWidth(180)
        container:AddChild(ShowMeMyHeal.SettingsUI.buttonTest)
    end

    local function CreateColorMenu(container)

        local header = AceGUI:Create("Heading")
        header:SetText("Fonts color")
        header:SetFullWidth(true)
        header:SetHeight(40)
        container:AddChild(header)

        local r, g, b = ShowMeMyHeal:HexToRGBPerc(self.db.profile.colorNormal)
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetLabel("Normal heal")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetWidth(100)
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(self.db.profile.colorCrit)
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetLabel("Critical heal")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetWidth(100)
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerCritHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(self.db.profile.colorExcess)
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetLabel("Overheal")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetWidth(80)
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(self.db.profile.colorName)
        ShowMeMyHeal.SettingsUI.ColorPickerName = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerName:SetLabel("Name")
        ShowMeMyHeal.SettingsUI.ColorPickerName:SetWidth(80)
        ShowMeMyHeal.SettingsUI.ColorPickerName:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerName)
    end

    local function CreateFontMenu(container)

        local header = AceGUI:Create("Heading")
        header:SetText("Fonts")
        header:SetFullWidth(true)
        header:SetHeight(40)
        container:AddChild(header)
        
        ShowMeMyHeal.SettingsUI.SliderNormalHeal = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetLabel("Font size normal heal")
        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetSliderValues(10, 100, 1)
        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetValue(self.db.profile.fontSizeNormalHeal)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderNormalHeal)

        ShowMeMyHeal.SettingsUI.SliderCritHeal = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetLabel("Font size critical heal")
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetSliderValues(10, 100, 1)
        ShowMeMyHeal.SettingsUI.SliderCritHeal:SetValue(self.db.profile.fontSizeCriticalHeal)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderCritHeal)
    end

    local function createShowMenu(container)

        local header = AceGUI:Create("Heading")
        header:SetText("Heal to display")
        header:SetFullWidth(true)
        header:SetHeight(40)
        container:AddChild(header)

        ShowMeMyHeal.SettingsUI.CheckboxHOTs  = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetLabel("HOTs")
        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetValue(self.db.profile.showHOTs)   
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxHOTs)     

        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetLabel("Target heal name")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetValue(self.db.profile.showTargetHealName)    
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxTargetHealName)    

        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetLabel("(Priest) Vampiric Embrace")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetValue(self.db.profile.showVampiricEmbracePriest)        
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace)

        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetLabel("Show me all heals of all healers (NPC included)")
        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetWidth(320)
        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetValue(self.db.profile.showAllPLayersWhoAreHealing)        
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing)

        local overhealGroup = AceGUI:Create("SimpleGroup")
        overhealGroup:SetWidth(320)
        overhealGroup:SetLayout("Flow")
        container:AddChild(overhealGroup)

        ShowMeMyHeal.SettingsUI.CheckboxOverheal = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetLabel("Overheal, when over:")
        ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetWidth(160)
        ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetValue(self.db.profile.showOverheal)        
        overhealGroup:AddChild(ShowMeMyHeal.SettingsUI.CheckboxOverheal)

        ShowMeMyHeal.SettingsUI.EditboxOverheal = AceGUI:Create("EditBox")
        ShowMeMyHeal.SettingsUI.EditboxOverheal:DisableButton(true)
        ShowMeMyHeal.SettingsUI.EditboxOverheal:SetWidth(40)
        ShowMeMyHeal.SettingsUI.EditboxOverheal:SetText(self.db.profile.overhealShowThreshold)
        overhealGroup:AddChild(ShowMeMyHeal.SettingsUI.EditboxOverheal)

        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetLabel("Show heal when he is equal to 0")
        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetWidth(320)
        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetValue(self.db.profile.showZeroHeal)        
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxZeroHeal)

        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetLabel("Self heal")
        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetWidth(320)
        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetValue(self.db.profile.showSelfHeal)        
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxSelfHeal)
    end

    local function createAnimationMenu(container)
        
        local header = AceGUI:Create("Heading")
        header:SetText("Position / Animation")
        header:SetFullWidth(true)
        header:SetHeight(40)
        container:AddChild(header)

        ShowMeMyHeal.SettingsUI.SliderDuration = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderDuration:SetLabel("Duration")
        ShowMeMyHeal.SettingsUI.SliderDuration:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderDuration:SetHeight(50)
        ShowMeMyHeal.SettingsUI.SliderDuration:SetSliderValues(1, 10, 0.1)
        ShowMeMyHeal.SettingsUI.SliderDuration:SetValue(self.db.profile.animationDuration)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderDuration)

        ShowMeMyHeal.SettingsUI.SliderScrollLength = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetLabel("Scroll length")
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetSliderValues(100, 1000, 1)
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetValue(self.db.profile.scrollLength)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderScrollLength)

        ShowMeMyHeal.SettingsUI.SliderOffsetX = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetLabel("Offset X")
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetSliderValues(-800, 800, 1)
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetValue(self.db.profile.offsetX)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderOffsetX)

        ShowMeMyHeal.SettingsUI.SliderOffsetY = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetLabel("Offset Y")
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetSliderValues(-500, 500, 1)
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetValue(self.db.profile.offsetY)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderOffsetY)
    end

    local function createMinimapIcon()
        ShowMeMyHeal.SettingsUI.icon = LibStub("LibDBIcon-1.0")
        ShowMeMyHeal.SettingsUI.icon:Register("ShowMeMyHealIcon", ShowMeMyHealIconDB, self.db.profile.minimap)
    end
    
    
    -- Create the frame container
    ShowMeMyHeal.SettingsUI = AceGUI:Create("Frame")
    ShowMeMyHeal.SettingsUI:Hide()
    ShowMeMyHeal.SettingsUI:SetTitle("ShowMeMyHeal")
    ShowMeMyHeal.SettingsUI:SetStatusText("Version 0.6.1 by Saveme (Perceval)")

    ShowMeMyHeal.SettingsUI:SetLayout("Flow")
    ShowMeMyHeal.SettingsUI:EnableResize(false)


    ShowMeMyHeal.SettingsUI:SetWidth(400)
    ShowMeMyHeal.SettingsUI:SetHeight(710)

    scrollcontainer = AceGUI:Create("SimpleGroup") 
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) 
    scrollcontainer:SetLayout("Fill")

    ShowMeMyHeal.SettingsUI:AddChild(scrollcontainer)

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") 
    scrollcontainer:AddChild(scroll)

    CreateMinimapMenu(scroll)
    CreateFontMenu(scroll)
    CreateColorMenu(scroll)
    createShowMenu(scroll)
    createAnimationMenu(scroll)
    CreateButtonMenu(scroll)   
    createMinimapIcon(scroll)     
end

function ShowMeMyHeal:BinUI()


    ShowMeMyHeal.SettingsUI.checkboxMinimap:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.minimap.hide = value
        if self.db.profile.minimap.hide == false then
            ShowMeMyHeal.SettingsUI.icon:Show("ShowMeMyHealIcon")
        else
            ShowMeMyHeal.SettingsUI.icon:Hide("ShowMeMyHealIcon")
        end
    end)

    ShowMeMyHeal.SettingsUI.buttonTest:SetCallback("OnClick", function()
        for i=0, 20, 1 do
            local textInfo = {}
            textInfo.isCrit = math.random(0, 1)

            if textInfo.isCrit == 0 then
                textInfo.isCrit = false
            else
                textInfo.isCrit = true
            end

            ShowMeMyHeal:BuildText(textInfo, math.random(50, 1500), math.random(50, 1500), "TestNameTarget", "TestNameFrom")

            table.insert(ShowMeMyHeal.texts, textInfo)
        end
    end)

    ShowMeMyHeal.SettingsUI.buttonReset:SetCallback("OnClick", function()

        local r, g, b = ShowMeMyHeal:HexToRGBPerc("0FFF00")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetColor(r, g, b, 1)   
        self.db.profile.colorNormal = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("FF0000")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetColor(r, g, b, 1)
        self.db.profile.colorCrit = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("EDF404")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetColor(r, g, b, 1)
        self.db.profile.colorExcess = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("FFFFFF")
        ShowMeMyHeal.SettingsUI.ColorPickerName:SetColor(r, g, b, 1)
        self.db.profile.colorName = ShowMeMyHeal:RGBPercToHex(r, g, b)

        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetValue(30)
        self.db.profile.fontSizeNormalHeal = 30
        ShowMeMyHeal.SettingsUI.SliderCritHeal:SetValue(41)
        self.db.profile.fontSizeCriticalHeal = 41

        ShowMeMyHeal.SettingsUI.checkboxMinimap:SetValue(false) 
        self.db.profile.minimap.hide = false 

        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetValue(true)   
        self.db.profile.showHOTs = true
        
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetValue(true)  
        self.db.profile.showTargetHealName = true  
        
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetValue(true) 
        self.db.profile.showVampiricEmbracePriest = true     
        
        ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetValue(false) 
        self.db.profile.showAllPLayersWhoAreHealing = false 

        ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetValue(true) 
        self.db.profile.showOverheal = true

        ShowMeMyHeal.SettingsUI.EditboxOverheal:SetText("0")
        self.db.profile.overhealShowThreshold = 0

        ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetValue(true) 
        self.db.profile.showZeroHeal = true

        ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetValue(true) 
        self.db.profile.showSelfHeal = true

  
        ShowMeMyHeal.SettingsUI.SliderDuration:SetValue(4)
        self.db.profile.animationDuration = 4
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetValue(480)
        self.db.profile.scrollLength = 480
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetValue(0)
        self.db.profile.offsetX = 0
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetValue(0)
        self.db.profile.offsetY = 0
    end)
   

    ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        self.db.profile.colorNormal = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)
    ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        self.db.profile.colorCrit = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)
    ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        self.db.profile.colorExcess = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)

    ShowMeMyHeal.SettingsUI.ColorPickerName:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        self.db.profile.colorName = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)

    ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.fontSizeNormalHeal = value
    end)
    ShowMeMyHeal.SettingsUI.SliderCritHeal:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.fontSizeCriticalHeal = value
    end)

    ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showHOTs = value 
    end)
    ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showTargetHealName = value
    end)
    ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showVampiricEmbracePriest = value
    end)
    ShowMeMyHeal.SettingsUI.CheckboxShowAllPLayersWhoAreHealing:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showAllPLayersWhoAreHealing = value
    end)


    ShowMeMyHeal.SettingsUI.CheckboxOverheal:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showOverheal = value
    end)
    ShowMeMyHeal.SettingsUI.EditboxOverheal:SetCallback("OnTextChanged", function(widget, event, value)
        number = tonumber(value)
        if not number then
            ShowMeMyHeal.SettingsUI.EditboxOverheal:SetText(self.db.profile.overhealShowThreshold)
            return
        end
        self.db.profile.overhealShowThreshold = number
    end)
    ShowMeMyHeal.SettingsUI.CheckboxZeroHeal:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showZeroHeal = value
    end)
    ShowMeMyHeal.SettingsUI.CheckboxSelfHeal:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.showSelfHeal = value
    end)

    ShowMeMyHeal.SettingsUI.SliderDuration:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.animationDuration = value
    end)
    ShowMeMyHeal.SettingsUI.SliderScrollLength:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.scrollLength = value
    end)
    ShowMeMyHeal.SettingsUI.SliderOffsetX:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.offsetX = value
    end)
    ShowMeMyHeal.SettingsUI.SliderOffsetY:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.offsetY = value
    end)

end

function ShowMeMyHeal:COMBAT_LOG_EVENT_UNFILTERED(event)

    local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, spellName, spellSchool, heal, excess, absorbed, isCrit, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()
    if token == "SPELL_HEAL" or token == "SPELL_PERIODIC_HEAL" then

        if ShowMeMyHeal.myGUID  == who_serial or self.db.profile.showAllPLayersWhoAreHealing == true then
           
            --a = string.format("%s %q", "Hello", "Lua user!")

            if token == "SPELL_PERIODIC_HEAL" and self.db.profile.showHOTs == false then
                return
            end

            
            if self.db.profile.showZeroHeal == false and (heal - excess) == 0 then
                return
            end

  
            if self.db.profile.showSelfHeal == false and ShowMeMyHeal.myGUID  == target_serial then
                return
            end


            if (spellName == "Vampirumarmung" or 
                spellName == "Vampiric Embrace" or 
                spellName == "Unirse a vampírica" or 
                spellName == "Etreinte vampirique" or 
                spellName == "Vampiric Embrace" or 
                spellName == "Abraço Vampírico" or 
                spellName == "Объятия вампира" or 
                spellName == "흡혈의 선물" or 
                spellName == "吸血鬼的拥抱") and self.db.profile.showVampiricEmbracePriest == false then
                return
            end        
            
            local textInfo = {}
            textInfo.isCrit = isCrit

            ShowMeMyHeal:BuildText(textInfo, heal, excess, target_name, who_name)

            table.insert(ShowMeMyHeal.texts, textInfo)
        end
    end   
end

function ShowMeMyHeal:DisplayText(text, isCrit)
    local frame = CreateFrame("Frame", "FloatingText", UIParent)
    
    frame:SetPoint("CENTER", self.db.profile.offsetX, self.db.profile.offsetY)
    frame:SetSize(1, 1)

    frame.text = frame:CreateFontString(nil, "OVERLAY", nil)
    frame.text:SetPoint("CENTER")

    if isCrit then 
        frame.text:SetFont(STANDARD_TEXT_FONT, self.db.profile.fontSizeCriticalHeal, "OUTLINE")
    else
        frame.text:SetFont(STANDARD_TEXT_FONT, self.db.profile.fontSizeNormalHeal, "OUTLINE")
    end

    frame.text:SetText(text)

    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Translation")

    a1:SetOffset(0, self.db.profile.scrollLength)    
    a1:SetDuration(self.db.profile.animationDuration)
    a1:SetSmoothing("OUT")
    ag:SetScript("OnFinished", function() frame:Hide() frame:SetParent(nil) end)

    ag:Play()    
end

function ShowMeMyHeal:BuildText(textInfo, heal, excess, target, who)

    heal = heal - excess

    textInfo.text = ""

    if self.db.profile.showAllPLayersWhoAreHealing == true then
        textInfo.text = "|cFF"..self.db.profile.colorName.."["..who.."] -> |r"
    end

    if textInfo.isCrit == false then
        textInfo.text = textInfo.text.."|cFF"..self.db.profile.colorNormal.."+"..heal.."|r"
    else
        textInfo.text = textInfo.text.."|cFF"..self.db.profile.colorCrit.."+"..heal.."|r"
    end

    if self.db.profile.showOverheal == true and excess > self.db.profile.overhealShowThreshold then
        textInfo.text = textInfo.text.."|cFF"..self.db.profile.colorExcess.." ("..excess..")|r"
    end

    if self.db.profile.showTargetHealName == true then

        textInfo.text = textInfo.text.."|cFF"..self.db.profile.colorName
        
        if self.db.profile.showAllPLayersWhoAreHealing == true then 
            textInfo.text = textInfo.text.." -> "
        else
            textInfo.text = textInfo.text.." - "
        end

        textInfo.text = textInfo.text.."["..target.."]|r"

    end

end

