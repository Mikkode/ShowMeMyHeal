SLASH_SHOWMEMYHEAL1 = "/smmh"

ShowMeMyHeal = { }; 

function SlashCmdList.SHOWMEMYHEAL(msg) 
    if msg == "hide" then
        ShowMeMyHeal.UIConfig:Hide()
    elseif msg == "show" then
        ShowMeMyHeal.UIConfig:Show()
    end
end




function ShowMeMyHeal:OnLoad(self) 
    
    ShowMeMyHeal.texts = { };
    ShowMeMyHeal.myName = UnitName("player")
    ShowMeMyHeal.myGUID = UnitGUID("player")


    local frame = CreateFrame("FRAME");
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", ShowMeMyHeal_eventAddonLoad);
    

    print("ShowMeMyHeal chargé."); 
end

function ShowMeMyHeal_eventAddonLoad(self, event, arg1)

    if event == "ADDON_LOADED" and arg1 == "ShowMeMyHeal" then
        if ShowMeMyHealParameters == nil then
            ShowMeMyHealParameters = {}
            ShowMeMyHealParameters.fontSizeNormalHeal = 30
            ShowMeMyHealParameters.fontSizeCriticalHeal = 41
            ShowMeMyHealParameters.animationDuration = 4
            ShowMeMyHealParameters.updateTime = 0.2
            ShowMeMyHealParameters.showHOTs = true
            ShowMeMyHealParameters.showTargetHealName = true
        end

        ShowMeMyHeal:BuildUI()
        ShowMeMyHeal:BindUI()
        ticker = C_Timer.NewTicker(0.2, ShowMeMyHeal_Upload)

        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");    
        self:SetScript("OnEvent", ShowMeMyHeal_eventHandler);


    end
end

function ShowMeMyHeal_eventHandler(self, event, arg1)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, heal, excess, A6, isCrit, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()
        if ShowMeMyHeal.myGUID  == who_serial then
            if token == "SPELL_HEAL" or token == "SPELL_PERIODIC_HEAL" then

                if token == "SPELL_PERIODIC_HEAL" and ShowMeMyHealParameters.showHOTs == false then
                    return
                end
                
                local textInfo = {}
                textInfo.isCrit = isCrit

                ShowMeMyHeal:BuildText(textInfo, heal, excess, target_name)

                table.insert(ShowMeMyHeal.texts, textInfo)
            end
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
    
    frame:SetPoint("CENTER")
    frame:SetSize(1, 1)

    frame.text = frame:CreateFontString(nil, "OVERLAY", nil)
    frame.text:SetPoint("CENTER")

    if isCrit then 
        frame.text:SetFont(STANDARD_TEXT_FONT, ShowMeMyHealParameters.fontSizeCriticalHeal, "OUTLINE")
    else
        frame.text:SetFont(STANDARD_TEXT_FONT, ShowMeMyHealParameters.fontSizeNormalHeal, "OUTLINE")
    end

    frame.text:SetText(text)

    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Translation")
    a1:SetOffset(0, 480)    
    a1:SetDuration(ShowMeMyHealParameters.animationDuration)
    a1:SetSmoothing("OUT")
    ag:SetScript("OnFinished", function() frame:Hide() frame:SetParent(nil) end)

    ag:Play()
    
end

function ShowMeMyHeal:BuildText(textInfo, heal, excess, target)

    heal = heal - excess

    if textInfo.isCrit == false then
        textInfo.text = "|cFF0FFF00+"..heal.."|r |cFFEDF404("..excess..")|r"
    else
        textInfo.text = "|cFFFF0000+"..heal.."|r |cFFEDF404("..excess..")|r"
    end

    if ShowMeMyHealParameters.showTargetHealName == true then
        textInfo.text = textInfo.text.." - ["..target.."]"
    end

end

function ShowMeMyHeal:BuildUI()

    -- UI Main panel:
    local FrameBackdrop = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    }
    
    ShowMeMyHeal.UIConfig = CreateFrame("Frame", "ShowMeMyHealFrame", UIParent)
    ShowMeMyHeal.UIConfig:Hide()
    
    ShowMeMyHeal.UIConfig:SetSize(200, 300)
       
    ShowMeMyHeal.UIConfig:EnableMouse(true)
    ShowMeMyHeal.UIConfig:SetMovable(true)
    ShowMeMyHeal.UIConfig:SetFrameStrata("FULLSCREEN_DIALOG")
    ShowMeMyHeal.UIConfig:SetBackdrop(FrameBackdrop)
    ShowMeMyHeal.UIConfig:SetBackdropColor(0, 0, 0, 1)
    ShowMeMyHeal.UIConfig:SetPoint("CENTER", UIParent, "CENTER")

    ShowMeMyHeal.UIConfig:RegisterForDrag("LeftButton")
    ShowMeMyHeal.UIConfig:SetScript("OnDragStart", ShowMeMyHeal.UIConfig.StartMoving)
    ShowMeMyHeal.UIConfig:SetScript("OnDragStop", ShowMeMyHeal.UIConfig.StopMovingOrSizing)
    
    local titlebg = ShowMeMyHeal.UIConfig:CreateTexture(nil, "OVERLAY")
    titlebg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
    titlebg:SetPoint("TOP", 0, 12)
    titlebg:SetWidth(100)
    titlebg:SetHeight(40)
    
    local title = CreateFrame("Frame", nil, frame)
    title:SetAllPoints(titlebg)
    
    local titlebg_l = ShowMeMyHeal.UIConfig:CreateTexture(nil, "OVERLAY")
    titlebg_l:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
    titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
    titlebg_l:SetWidth(30)
    titlebg_l:SetHeight(40)
    
    local titlebg_r = ShowMeMyHeal.UIConfig:CreateTexture(nil, "OVERLAY")
    titlebg_r:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
    titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
    titlebg_r:SetWidth(30)
    titlebg_r:SetHeight(40)
    
    local titletext = ShowMeMyHeal.UIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)
    titletext:SetText("ShowMeMyHeal")
    titlebg:SetWidth((titletext:GetWidth() or 0) + 10)


    --UI Content panel:

    -- UI Slider font size normal heal:
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal = CreateFrame("Slider", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "OptionsSliderTemplate")
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetPoint("TOP", ShowMeMyHeal.UIConfig, "TOP", 0, -50)
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetMinMaxValues(10, 100)
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetValue(ShowMeMyHealParameters.fontSizeNormalHeal)
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetValueStep(1)
    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetObeyStepOnDrag(true)

    -- Slider Descriptif
    local descr = ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descr:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal, "CENTER", 0, 21)
    descr:SetText("Font size normal heal")

    -- UI Slider font size critical heal:
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal = CreateFrame("Slider", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "OptionsSliderTemplate")
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal, "BOTTOM", 0, -30)
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetMinMaxValues(10, 100)
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetValue(ShowMeMyHealParameters.fontSizeCriticalHeal)
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetValueStep(1)
    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetObeyStepOnDrag(true)

    -- Slider Descriptif
    local descr = ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descr:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal, "CENTER", 0, 21)
    descr:SetText("Font size critical heal")

    -- UI Slider Animation duration:
    ShowMeMyHeal.UIConfig.sliderAnimationDuration = CreateFrame("Slider", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "OptionsSliderTemplate")
    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal, "BOTTOM", 0, -30)
    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetMinMaxValues(1, 10)
    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetValue(ShowMeMyHealParameters.animationDuration)
    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetValueStep(1)
    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetObeyStepOnDrag(true)

    -- Slider Button Descriptif
    local descr = ShowMeMyHeal.UIConfig.sliderAnimationDuration:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descr:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderAnimationDuration, "CENTER", 0, 21)
    descr:SetText("Animation duration")

    -- UI Slider Update time:
    --[[
    ShowMeMyHeal.UIConfig.sliderUpdateTime = CreateFrame("Slider", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "OptionsSliderTemplate")
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderAnimationDuration, "BOTTOM", 0, -30)
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetMinMaxValues(0.05, 1)
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetValue(ShowMeMyHeal.updateTime)
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetValueStep(0.01)
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetObeyStepOnDrag(true)

    -- Slider Button Descriptif
    local descr = ShowMeMyHeal.UIConfig.sliderUpdateTime:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descr:SetPoint("TOP", ShowMeMyHeal.UIConfig.sliderUpdateTime, "CENTER", 0, 21)
    descr:SetText("Update time")
    --]]

    -- UI Checkbox HOTs:
    ShowMeMyHeal.UIConfig.checkboxShowHOTs = CreateFrame("CheckButton", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "UICheckButtonTemplate")
    ShowMeMyHeal.UIConfig.checkboxShowHOTs:SetPoint("TOPLEFT", ShowMeMyHeal.UIConfig.sliderAnimationDuration, "BOTTOMLEFT", 0, -20)
    ShowMeMyHeal.UIConfig.checkboxShowHOTs.text:SetText("Show HOTs")
    ShowMeMyHeal.UIConfig.checkboxShowHOTs:SetChecked(ShowMeMyHealParameters.showHOTs)

    -- UI Checkbox target name:
    ShowMeMyHeal.UIConfig.checkboxShowTargetName = CreateFrame("CheckButton", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "UICheckButtonTemplate")
    ShowMeMyHeal.UIConfig.checkboxShowTargetName:SetPoint("TOPLEFT", ShowMeMyHeal.UIConfig.checkboxShowHOTs, "BOTTOMLEFT", 0, 0)
    ShowMeMyHeal.UIConfig.checkboxShowTargetName.text:SetText("Show target heal name")
    ShowMeMyHeal.UIConfig.checkboxShowTargetName:SetChecked(ShowMeMyHealParameters.showTargetHealName)

    -- UI Button Reset:
    ShowMeMyHeal.UIConfig.buttonReset = CreateFrame("Button", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "GameMenuButtonTemplate")
    ShowMeMyHeal.UIConfig.buttonReset:SetPoint("LEFT", ShowMeMyHeal.UIConfig.checkboxShowTargetName, "LEFT", -10, -40)
    ShowMeMyHeal.UIConfig.buttonReset:SetSize(80, 30)
    ShowMeMyHeal.UIConfig.buttonReset:SetText("Reset")
    ShowMeMyHeal.UIConfig.buttonReset:SetNormalFontObject("GameFontNormalLarge")
    ShowMeMyHeal.UIConfig.buttonReset:SetHighlightFontObject("GameFontHighlightLarge")

    -- UI Button Test:
    ShowMeMyHeal.UIConfig.buttonTest = CreateFrame("Button", "ShowMeMyHealFrame", ShowMeMyHeal.UIConfig, "GameMenuButtonTemplate")
    ShowMeMyHeal.UIConfig.buttonTest:SetPoint("LEFT", ShowMeMyHeal.UIConfig.buttonReset, "RIGHT", 4, 0)
    ShowMeMyHeal.UIConfig.buttonTest:SetSize(80, 30)
    ShowMeMyHeal.UIConfig.buttonTest:SetText("Test")
    ShowMeMyHeal.UIConfig.buttonTest:SetNormalFontObject("GameFontNormalLarge")
    ShowMeMyHeal.UIConfig.buttonTest:SetHighlightFontObject("GameFontHighlightLarge")

    
end

function ShowMeMyHeal:BindUI()

    ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetScript("OnValueChanged", function(self, value)
        ShowMeMyHealParameters.fontSizeNormalHeal = value
    end)

    ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetScript("OnValueChanged", function(self, value)
        ShowMeMyHealParameters.fontSizeCriticalHeal = value
    end)

    ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetScript("OnValueChanged", function(self, value)
        ShowMeMyHealParameters.animationDuration = value
    end)

    --[[
    ShowMeMyHeal.UIConfig.sliderUpdateTime:SetScript("OnValueChanged", function(self, value)
        print("sliderUpdateTime:"..value)
        ShowMeMyHeal.updateTime = value
    end)
    --]]

    ShowMeMyHeal.UIConfig.checkboxShowHOTs:SetScript("OnClick", function(self, button)
        ShowMeMyHealParameters.showHOTs = ShowMeMyHeal.UIConfig.checkboxShowHOTs:GetChecked()
    end)

    ShowMeMyHeal.UIConfig.checkboxShowTargetName:SetScript("OnClick", function(self, button)
        ShowMeMyHealParameters.showTargetHealName = ShowMeMyHeal.UIConfig.checkboxShowTargetName:GetChecked()
    end)

    ShowMeMyHeal.UIConfig.buttonTest:SetScript("OnClick", function(self, button, down)

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
    
    ShowMeMyHeal.UIConfig.buttonReset:SetScript("OnClick", function(self, button, down)
        ShowMeMyHeal.UIConfig.sliderFontSizeNormalHeal:SetValue(30)
        ShowMeMyHeal.UIConfig.sliderFontSizeCriticallHeal:SetValue(50)
        ShowMeMyHeal.UIConfig.sliderAnimationDuration:SetValue(4)
        --ShowMeMyHeal.UIConfig.sliderUpdateTime:SetValue(0.2)
        ShowMeMyHeal.UIConfig.checkboxShowHOTs:SetChecked(true)
        ShowMeMyHeal.UIConfig.checkboxShowTargetName:SetChecked(true)
    end)

end

