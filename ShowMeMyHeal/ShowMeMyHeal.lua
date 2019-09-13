ShowMeMyHeal = { }; 

ShowMeMyHeal.myGUID = nil
ShowMeMyHeal.myName = nil

function ShowMeMyHeal:OnLoad(self) 
    
    ShowMeMyHeal.myName = UnitName("player")
    ShowMeMyHeal.myGUID = UnitGUID("player")

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:SetScript("OnEvent", ShowMeMyHeal_eventHandler);

    print("ShowMeMyHeal chargé."); 
end

function ShowMeMyHeal_eventHandler(self, event, ...)
    local time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CombatLogGetCurrentEventInfo()
    if ShowMeMyHeal.myGUID  == who_serial then
        if token == "SPELL_HEAL" or token == "SPELL_PERIODIC_HEAL" then
            --d = who_name.."("..A2..") heal "..target_name.." for "..A4.." exces:"..A5.." crit:"..tostring(A7)
            t = A4.." - ["..target_name.."]"
            ShowMeMyHeal:DisplayText(t, A7)
        end
    end    
end

function ShowMeMyHeal:DisplayText(text, isCrit)
    local frame = CreateFrame("Frame", "FloatingText", UIParent)
    
    frame:SetPoint("CENTER")
    frame:SetSize(1, 1)

    ---frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    --frame.texture:SetAllPoints(true)
    --frame.texture:SetTexture(0, 0, 0, 0.0)    
    
    frame.text = frame:CreateFontString(nil, "ARTWORK", nil)
    frame.text:SetPoint("CENTER")

    if isCrit then 
        frame.text:SetFont([=[Fonts\FRIZQT__.TTF]=], 50, "OUTLINE")
        frame.text:SetTextColor(1, 0, 0, 1.0)
    else
        frame.text:SetFont([=[Fonts\FRIZQT__.TTF]=], 30, "OUTLINE")
        frame.text:SetTextColor(0, 1, 0, 1.0)
    end

    frame.text:SetText(text)

    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Translation")
    a1:SetOffset(0, 400)    
    a1:SetDuration(4)
    a1:SetSmoothing("OUT")
    ag:SetScript("OnFinished", function() frame:Hide() end)

    ag:Play()
end

