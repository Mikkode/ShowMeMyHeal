local ShowMeMyHeal = {}

local AceGUI = LibStub("AceGUI-3.0")
local ShowMeMyHeal = LibStub("AceAddon-3.0"):NewAddon("ShowMeMyHeal", "AceConsole-3.0", "AceEvent-3.0")

ShowMeMyHealParameters = {

    display = {
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
        colorCrit = "FF0000",
        colorNormal = "0FFF00",
        colorExcess = "EDF404",
        colorName = "FFFFFF"
    },
    profile = { 
        minimap = { 
            hide = false, 
        }, 
    }, 
}

function ShowMeMyHealSlashFunction(arg)
    if arg == "show" then
        ShowMeMyHeal.SettingsUI:Show()
    elseif arg == "hide" then
        ShowMeMyHeal.SettingsUI:Hide()
    end
end

ShowMeMyHealParametersIconDB = LibStub("LibDataBroker-1.1"):NewDataObject("ShowMeMyHealIcon", {
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

function ShowMeMyHeal:OnInitialize()

    self.db = LibStub("AceDB-3.0"):New("ShowMeMyHealParameters", { profile = { minimap = { hide = false, }, }, })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register("ShowMeMyHealIcon", ShowMeMyHealParametersIconDB, self.db.profile.minimap)
end

function ShowMeMyHeal:OnEnable()

    ShowMeMyHeal.texts = { };
    ShowMeMyHeal.myName = UnitName("player")
    ShowMeMyHeal.myGUID = UnitGUID("player")

    ShowMeMyHeal:CreateUI()
    ShowMeMyHeal:BinUI()

    ShowMeMyHeal:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ShowMeMyHeal_eventHandler);    

    ShowMeMyHeal:RegisterChatCommand("smmh", ShowMeMyHealSlashFunction, true)

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

        local r, g, b = ShowMeMyHeal:HexToRGBPerc(ShowMeMyHealParameters.display.colorNormal)
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetLabel("Normal heal")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetWidth(100)
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(ShowMeMyHealParameters.display.colorCrit)
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetLabel("Critical heal")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetWidth(100)
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerCritHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(ShowMeMyHealParameters.display.colorExcess)
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal = AceGUI:Create("ColorPicker")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetLabel("Excess")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetWidth(80)
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetColor(r, g, b, 1)
        container:AddChild(ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal)

        r, g, b = ShowMeMyHeal:HexToRGBPerc(ShowMeMyHealParameters.display.colorName)
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
        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetValue(ShowMeMyHealParameters.display.fontSizeNormalHeal)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderNormalHeal)

        ShowMeMyHeal.SettingsUI.SliderCritHeal = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetLabel("Font size critical heal")
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderCritHeal :SetSliderValues(10, 100, 1)
        ShowMeMyHeal.SettingsUI.SliderCritHeal:SetValue(ShowMeMyHealParameters.display.fontSizeCriticalHeal)
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
        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetValue(ShowMeMyHealParameters.display.showHOTs)   
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxHOTs)     


        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetLabel("Target heal name")
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetValue(ShowMeMyHealParameters.display.showTargetHealName)    
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxTargetHealName)    

        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace = AceGUI:Create("CheckBox")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetType("checkbox")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetLabel("(Priest) Vampiric Embrace")
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetValue(ShowMeMyHealParameters.display.showVampiricEmbracePriest)        
        container:AddChild(ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace)
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
        ShowMeMyHeal.SettingsUI.SliderDuration:SetValue(ShowMeMyHealParameters.display.animationDuration)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderDuration)

        ShowMeMyHeal.SettingsUI.SliderScrollLength = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetLabel("Scroll length")
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetSliderValues(100, 1000, 1)
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetValue(ShowMeMyHealParameters.display.scrollLength)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderScrollLength)

        ShowMeMyHeal.SettingsUI.SliderOffsetX = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetLabel("Offset X")
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetSliderValues(-800, 800, 1)
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetValue(ShowMeMyHealParameters.display.offsetX)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderOffsetX)

        ShowMeMyHeal.SettingsUI.SliderOffsetY = AceGUI:Create("Slider")
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetLabel("Offset Y")
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetWidth(182)
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetSliderValues(-500, 500, 1)
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetValue(ShowMeMyHealParameters.display.offsetY)
        container:AddChild(ShowMeMyHeal.SettingsUI.SliderOffsetY)
    end
    
    -- Create the frame container
    ShowMeMyHeal.SettingsUI = AceGUI:Create("Frame")
    ShowMeMyHeal.SettingsUI:Hide()
    ShowMeMyHeal.SettingsUI:SetTitle("ShowMeMyHeal")
    ShowMeMyHeal.SettingsUI:SetStatusText("Version 0.4.0 by Saveme (Perceval)")

    ShowMeMyHeal.SettingsUI:SetLayout("Flow")
    ShowMeMyHeal.SettingsUI:EnableResize(false)


    ShowMeMyHeal.SettingsUI:SetWidth(400)
    ShowMeMyHeal.SettingsUI:SetHeight(570)



    scrollcontainer = AceGUI:Create("SimpleGroup") 
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) 
    scrollcontainer:SetLayout("Fill")

    ShowMeMyHeal.SettingsUI:AddChild(scrollcontainer)

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") 
    scrollcontainer:AddChild(scroll)

    CreateFontMenu(scroll)
    CreateColorMenu(scroll)
    createShowMenu(scroll)
    createAnimationMenu(scroll)
    CreateButtonMenu(scroll)   
end

function ShowMeMyHeal:BinUI()


    ShowMeMyHeal.SettingsUI.buttonTest:SetCallback("OnClick", function()
        for i=0, 20, 1 do
            local textInfo = {}
            textInfo.isCrit = math.random(0, 1)

            if textInfo.isCrit == 0 then
                textInfo.isCrit = false
            else
                textInfo.isCrit = true
            end

            ShowMeMyHeal:BuildText(textInfo, math.random(50, 1500), math.random(50, 1500), "TestName")

            table.insert(ShowMeMyHeal.texts, textInfo)
        end
    end)

    ShowMeMyHeal.SettingsUI.buttonReset:SetCallback("OnClick", function()

        local r, g, b = ShowMeMyHeal:HexToRGBPerc("0FFF00")
        ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetColor(r, g, b, 1)   
        ShowMeMyHealParameters.display.colorNormal = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("FF0000")
        ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetColor(r, g, b, 1)
        ShowMeMyHealParameters.display.colorCrit = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("EDF404")
        ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetColor(r, g, b, 1)
        ShowMeMyHealParameters.display.colorExcess = ShowMeMyHeal:RGBPercToHex(r, g, b)

        r, g, b = ShowMeMyHeal:HexToRGBPerc("FFFFFF")
        ShowMeMyHeal.SettingsUI.ColorPickerName:SetColor(r, g, b, 1)
        ShowMeMyHealParameters.display.colorName = ShowMeMyHeal:RGBPercToHex(r, g, b)

        ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetValue(30)
        ShowMeMyHealParameters.display.fontSizeNormalHeal = 30
        ShowMeMyHeal.SettingsUI.SliderCritHeal:SetValue(41)
        ShowMeMyHealParameters.display.fontSizeCriticalHeal = 41

        ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetValue(true)   
        ShowMeMyHealParameters.display.showHOTs = true
        ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetValue(true)  
        ShowMeMyHealParameters.display.showTargetHealName = true  
        ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetValue(true) 
        ShowMeMyHealParameters.display.showVampiricEmbracePriest = true     

        ShowMeMyHeal.SettingsUI.SliderDuration:SetValue(4)
        ShowMeMyHealParameters.display.animationDuration = 4
        ShowMeMyHeal.SettingsUI.SliderScrollLength:SetValue(500)
        ShowMeMyHealParameters.display.scrollLength = 500
        ShowMeMyHeal.SettingsUI.SliderOffsetX:SetValue(0)
        ShowMeMyHealParameters.display.offsetX = 0
        ShowMeMyHeal.SettingsUI.SliderOffsetY:SetValue(0)
        ShowMeMyHealParameters.display.offsetY = 0
    end)
   

    ShowMeMyHeal.SettingsUI.ColorPickerNormalHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        ShowMeMyHealParameters.display.colorNormal = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)
    ShowMeMyHeal.SettingsUI.ColorPickerCritHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        ShowMeMyHealParameters.display.colorCrit = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)
    ShowMeMyHeal.SettingsUI.ColorPickerExcessHeal:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        ShowMeMyHealParameters.display.colorExcess = ShowMeMyHeal:RGBPercToHex(r, g, b)
    end)

    ShowMeMyHeal.SettingsUI.SliderNormalHeal:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.fontSizeNormalHeal = value
    end)
    ShowMeMyHeal.SettingsUI.SliderCritHeal:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.fontSizeCriticalHeal = value
    end)

    ShowMeMyHeal.SettingsUI.CheckboxHOTs:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.showHOTs = value 
    end)
    ShowMeMyHeal.SettingsUI.CheckboxTargetHealName:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.showTargetHealName = value
    end)
    ShowMeMyHeal.SettingsUI.CheckboxVampiricEmbrace:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.showVampiricEmbracePriest = value
    end)

    ShowMeMyHeal.SettingsUI.SliderDuration:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.animationDuration = value
    end)
    ShowMeMyHeal.SettingsUI.SliderScrollLength:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.scrollLength = value
    end)
    ShowMeMyHeal.SettingsUI.SliderOffsetX:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.offsetX = value
    end)
    ShowMeMyHeal.SettingsUI.SliderOffsetY:SetCallback("OnValueChanged", function(widget, event, value)
        ShowMeMyHealParameters.display.offsetY = value
    end)

end

function ShowMeMyHeal_eventHandler(self, event, arg1)

    local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, spellName, A3, heal, excess, A6, isCrit, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()
    if ShowMeMyHeal.myGUID  == who_serial then
        
        if token == "SPELL_HEAL" or token == "SPELL_PERIODIC_HEAL" then

            if token == "SPELL_PERIODIC_HEAL" and ShowMeMyHealParameters.display.showHOTs == false then
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
                spellName == "吸血鬼的拥抱") and ShowMeMyHealParameters.display.showVampiricEmbracePriest == false then
                return
            end             

            local textInfo = {}
            textInfo.isCrit = isCrit

            ShowMeMyHeal:BuildText(textInfo, heal, excess, target_name)

            table.insert(ShowMeMyHeal.texts, textInfo)
        end
    end   
end

function ShowMeMyHeal_Upload()
    if ShowMeMyHeal.texts[1] ~= nil then
        ShowMeMyHeal:DisplayText(ShowMeMyHeal.texts[1].text, ShowMeMyHeal.texts[1].isCrit)
        table.remove(ShowMeMyHeal.texts, 1)
    end
end

function ShowMeMyHeal:DisplayText(text, isCrit)
    local frame = CreateFrame("Frame", "FloatingText", UIParent)
    
    frame:SetPoint("CENTER", ShowMeMyHealParameters.display.offsetX, ShowMeMyHealParameters.display.offsetY)
    frame:SetSize(1, 1)

    frame.text = frame:CreateFontString(nil, "OVERLAY", nil)
    frame.text:SetPoint("CENTER")

    if isCrit then 
        frame.text:SetFont(STANDARD_TEXT_FONT, ShowMeMyHealParameters.display.fontSizeCriticalHeal, "OUTLINE")
    else
        frame.text:SetFont(STANDARD_TEXT_FONT, ShowMeMyHealParameters.display.fontSizeNormalHeal, "OUTLINE")
    end

    frame.text:SetText(text)

    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Translation")

    a1:SetOffset(0, ShowMeMyHealParameters.display.scrollLength)    
    a1:SetDuration(ShowMeMyHealParameters.display.animationDuration)
    a1:SetSmoothing("OUT")
    ag:SetScript("OnFinished", function() frame:Hide() frame:SetParent(nil) end)

    ag:Play()    
end

function ShowMeMyHeal:BuildText(textInfo, heal, excess, target)

    heal = heal - excess

    if textInfo.isCrit == false then
        textInfo.text = "|cFF"..ShowMeMyHealParameters.display.colorNormal.."+"..heal.."|r |cFF"..ShowMeMyHealParameters.display.colorExcess.."("..excess..")|r"
    else
        textInfo.text = "|cFF"..ShowMeMyHealParameters.display.colorCrit.."+"..heal.."|r |cFF"..ShowMeMyHealParameters.display.colorExcess.."("..excess..")|r"
    end

    if ShowMeMyHealParameters.display.showTargetHealName == true then
        textInfo.text = textInfo.text.."|cFF"..ShowMeMyHealParameters.display.colorName.." - ["..target.."]|r"
    end

end

