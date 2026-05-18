local UMG_Handbook_Search_C = _G.NRCPanelBase:Extend("UMG_Handbook_Search_C")

function UMG_Handbook_Search_C:OnActive()
  self:SetCommonPopUpInfo(self.PopUp3)
  self:LoadAnimation(0)
end

function UMG_Handbook_Search_C:OnDeactive()
end

function UMG_Handbook_Search_C:OnAddEventListener()
  self:AddDelegateListener(self.UsernameDisplay.OnTextChanged, self.OnTextChanged)
end

function UMG_Handbook_Search_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self:OnAddEventListener()
end

function UMG_Handbook_Search_C:OnDestruct()
end

function UMG_Handbook_Search_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(1) then
    self:DoClose()
  end
end

function UMG_Handbook_Search_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClosePanel
  CommonPopUpData.Btn_RightHandler = self.OnSearch
  CommonPopUpData.ClosePanelHandler = self.OnClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Handbook_Search_C:OnClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_Handbook_Search_C:OnClosePanel")
  self:LoadAnimation(2)
end

function UMG_Handbook_Search_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Handbook_Search_C:OnTextChanged()
  local text = self.UsernameDisplay:GetText()
  text = self:SubStr(text, 30)
  text = string.GetSubStr(text, 30)
  if string.SubStringGetTotalIndex(text) > 30 then
    text = string.GetSubStr(text, 30)
  end
  self.UsernameDisplay:SetText(text)
end

function UMG_Handbook_Search_C:SubStr(str, byte_count)
  local count = 0
  local len = #str
  local index = 1
  while byte_count > count and len >= index do
    local ch = string.byte(str, index)
    local step
    if ch < 128 then
      step = 1
    elseif ch >= 192 and ch < 224 then
      step = 2
    elseif ch >= 224 and ch < 240 then
      step = 3
    elseif ch >= 240 and ch < 248 then
      step = 4
    elseif ch >= 248 and ch < 252 then
      step = 5
    elseif ch >= 252 then
      step = 6
    else
      step = 0
    end
    if byte_count < count + step then
      break
    end
    count = count + step
    index = index + step
  end
  return string.sub(str, 1, index - 1)
end

function UMG_Handbook_Search_C:OnSearch()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Handbook_Search_C:OnSearch")
  local text = self.UsernameDisplay:GetText()
  if nil == text or 0 == #text or nil ~= text:match("^[%s\r\n\t]*$") then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.hb_search_error1)
    return
  end
  _G.NRCModeManager:DoCmd(HandbookModuleCmd.OnSearchHandbook, text)
end

return UMG_Handbook_Search_C
