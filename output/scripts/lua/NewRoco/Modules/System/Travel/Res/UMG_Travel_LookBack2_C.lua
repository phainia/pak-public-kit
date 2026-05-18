local UMG_Travel_LookBack2_C = _G.NRCPanelBase:Extend("UMG_Travel_LookBack2_C")

function UMG_Travel_LookBack2_C:OnActive(panelType, arg)
  self:OnUpdatePanel(panelType, arg)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "MainBigMap").GETALL
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BigMapModule", "MainBigMap", touchReasonType)
end

function UMG_Travel_LookBack2_C:OnUpdatePanel(panelType, arg)
  self:LoadAnimation(0)
  self.TravelInfos = self:CreateListDatas(panelType, arg)
  self.NRCScrollView_44:InitList(self.TravelInfos)
  local position = self.TheStars.Slot:GetPosition()
  local TitleText
  local hideBtn = false
  if 1 == panelType then
    TitleText = LuaText.pet_travel_review
    self.TheStars.Slot:SetPosition(UE4.FVector2D(position.X, -39))
    self:OnShowAllReward(arg)
  else
    TitleText = LuaText.pet_travel_start
    self.TheStars.Slot:SetPosition(UE4.FVector2D(position.X, 0))
    self:OnShowAllStart(arg)
    hideBtn = true
  end
  self:SetCommonPopUpInfo(TitleText, hideBtn)
end

function UMG_Travel_LookBack2_C:SetCommonPopUpInfo(TitleText, hideBtn)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = TitleText
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnBtnCloseClick2
  if hideBtn then
    CommonPopUpData.HideBtn = true
  else
    CommonPopUpData.Btn_RightHandler = self.OnBtnGetAllRewardClick
    CommonPopUpData.Btn_LeftHandler = self.OnBtnCloseClick
  end
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Travel_LookBack2_C:OnConstruct()
  self.TravelInfos = {}
  self.bgProxy = _G.NRCModuleManager:DoCmd(TUIModuleCmd.PushBlackBackgroundWidgets, {
    self.FullStateMask
  })
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
end

function UMG_Travel_LookBack2_C:OnDeactive()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
end

function UMG_Travel_LookBack2_C:OnShowAllReward()
  self.PopUp2:ShowOrHideBtnLeft(true)
  self.PopUp2:ShowOrHideBtnRight(true)
end

function UMG_Travel_LookBack2_C:OnShowAllStart()
  self.PopUp2:ShowOrHideBtnLeft(false)
  self.PopUp2:ShowOrHideBtnRight(false)
end

function UMG_Travel_LookBack2_C:CreateListDatas(type, arg)
  local travelInfos = {}
  local lst = {}
  table.deepCopy(arg, travelInfos, false)
  for i = 1, #travelInfos do
    local travelInfo = travelInfos[i]
    travelInfo.isAward = 1 == type
    table.insert(lst, travelInfo)
  end
  return lst
end

function UMG_Travel_LookBack2_C:OnAddEventListener()
end

function UMG_Travel_LookBack2_C:OnBtnCloseClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_MainMap_C:OnBtnCloseClick")
  self:LoadAnimation(2)
end

function UMG_Travel_LookBack2_C:OnBtnCloseClick2()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1061, "UMG_MainMap_C:OnBtnCloseClick2")
  self:LoadAnimation(2)
end

function UMG_Travel_LookBack2_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Travel_LookBack2_C:OnBtnGetAllRewardClick()
  local reqData = {}
  for i = 1, #self.TravelInfos do
    local travelInfo = self.TravelInfos[i]
    local petTravelInfo = _G.ProtoMessage:newPetTravelInfo()
    petTravelInfo.camp_content_id = travelInfo.camp_content_id
    petTravelInfo.camp_lv = travelInfo.camp_lv
    petTravelInfo.pet_gid = travelInfo.pet_gid
    table.insert(reqData, petTravelInfo)
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_MainMap_C:OnBtnGetAllRewardClick")
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.OnCmdZoneStartAllPetTravelAgainReq, reqData)
end

return UMG_Travel_LookBack2_C
