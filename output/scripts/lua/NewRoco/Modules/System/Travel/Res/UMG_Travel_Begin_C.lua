local UMG_Travel_Begin_C = _G.NRCPanelBase:Extend("UMG_Travel_Begin_C")

function UMG_Travel_Begin_C:OnActive(petDatas, conf)
  self:LoadAnimation(0)
  local timeStr = self:FormatTime(conf.travel_time)
  self:SetCommonPopUpInfo(self.PopUp1)
  self.PopUp1:SetDescInfo(timeStr)
  for _, data in pairs(petDatas or {}) do
    data.bShowLevel = true
  end
  self.List_3:InitGridView(petDatas)
end

function UMG_Travel_Begin_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  self:OnAddEventListener()
end

function UMG_Travel_Begin_C:OnDeactive()
  if self.bgProxy then
    _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
  end
end

function UMG_Travel_Begin_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Travel_Begin_C:FormatTime(seconds)
  local hours = math.floor(seconds / 3600)
  return string.format(LuaText.umg_travel_begin_1, hours)
end

function UMG_Travel_Begin_C:OnAddEventListener()
end

function UMG_Travel_Begin_C:OnPcClose()
  if self:IsAnimationPlaying() then
    return
  end
  self:OnCloseBtn()
end

function UMG_Travel_Begin_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Travel_C:OnDepartBtn")
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.UpdateTravelInfos)
  self:LoadAnimation(2)
end

function UMG_Travel_Begin_C:OnAnimationFinished(anim)
  if self:GetAnimByIndex(2) == anim then
    self:DoClose()
  end
end

return UMG_Travel_Begin_C
