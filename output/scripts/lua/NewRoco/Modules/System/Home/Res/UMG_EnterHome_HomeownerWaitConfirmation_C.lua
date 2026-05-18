local UMG_EnterHome_HomeownerWaitConfirmation_C = _G.NRCPanelBase:Extend("UMG_EnterHome_HomeownerWaitConfirmation_C")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
  local _waitTime = (_G.DataConfigManager:GetHomeGlobalConfig("invite_home_owner_timeout") or {}).num
  if _waitTime and _waitTime > 0 then
    self:DelaySeconds(_waitTime, self.TimeoutHandle, self)
  end
  self:RegisterEvent(self, HomeModuleEvent.OnTeamEnterHomeRefresh, self.OnHomeTeamUpdateNotify)
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnDestruct()
  if self.funBan then
    _G.FunctionBanManager:RemovePlayerConditionType(self.funBan)
  end
  self:CancelDelay()
  self:UnRegisterEvent(self, HomeModuleEvent.OnTeamEnterHomeRefresh)
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnActive(teamInfo)
  self:LoadAnimation(0)
  if not teamInfo then
    Log.Error("teamInfo is nil")
    return
  end
  local _waitConFirmType
  local selfUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  if teamInfo.team_leader_uin == selfUin then
    _waitConFirmType = teamInfo.team_type == ProtoEnum.HomeTeamType.HOME_TEAM_TYPE_VISIT and HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome or HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome
  else
    _waitConFirmType = teamInfo.team_type == ProtoEnum.HomeTeamType.HOME_TEAM_TYPE_VISIT and HomeEnum.HomeownerWaitConfirmation.VisitorLeaveHome or HomeEnum.HomeownerWaitConfirmation.VisitorEnterHome
  end
  self.funBan = nil
  self.waitConFirmType = _waitConFirmType
  self.ownerUin = teamInfo.team_leader_uin
  self.teamType = teamInfo.team_type
  self.playerList = {}
  if _waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome then
    self.funBan = Enum.PlayerConditionType.PCT_INVITE_VISIT_HOME
    self.Title = LuaText.online_visit_home_waiting_title
    self.Desc = LuaText.online_visit_home_waiting_button_CD
    self.RightBtnText = LuaText.online_visit_home_waiting_button_yes
    self.RightBtnTitle = LuaText.online_visit_home_bottom_text
    self.RightBtnCD = (_G.DataConfigManager:GetGlobalConfig("online_visit_home_enter_CD") or {}).num or 5
  elseif _waitConFirmType == HomeEnum.HomeownerWaitConfirmation.VisitorEnterHome then
    self.funBan = Enum.PlayerConditionType.PCT_INVITE_VISIT_HOME
    self.Title = LuaText.online_visit_home_waiting_title
    self.Desc = LuaText.online_visit_home_waiting_button_CD
  elseif _waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome then
    self.funBan = Enum.PlayerConditionType.PCT_INVITE_LEAVE_HOME
    self.Title = LuaText.online_leave_home_waiting_title
    self.Desc = LuaText.online_leave_home_bottom_text
    self.RightBtnText = LuaText.online_leave_home_waiting_button_yes
    self.RightBtnTitle = LuaText.online_leave_home_waiting_button_CD
    self.RightBtnCD = (_G.DataConfigManager:GetGlobalConfig("online_visit_home_enter_CD") or {}).num or 5
  elseif _waitConFirmType == HomeEnum.HomeownerWaitConfirmation.VisitorLeaveHome then
    self.funBan = Enum.PlayerConditionType.PCT_INVITE_LEAVE_HOME
    self.Title = LuaText.online_leave_home_waiting_title
    self.Desc = LuaText.online_leave_home_bottom_text
  end
  if self.funBan then
    _G.FunctionBanManager:AddPlayerConditionType(self.funBan)
  end
  self:RefreshPlayerList(teamInfo.members)
  self:SetCommonPopUpInfo()
  self:RefreshConfirmCountdown()
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:RefreshConfirmCountdown()
  if self.RightBtnCD and self.RightBtnCD > 0 then
    self.PopUp4.Btn_Right_GrayState2:SetTitleTextAndIcon(nil, nil, nil, nil, string.format(self.RightBtnTitle, self.RightBtnCD))
    self.PopUp4.Btn_Right_GrayState2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.RightBtnCD = self.RightBtnCD - 1
    self:DelaySeconds(1, self.RefreshConfirmCountdown, self)
  else
    self.PopUp4.Btn_Right_GrayState2:SetTitleTextAndIcon()
    self.PopUp4.Btn_Right_GrayState2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PopUp4.Btn_Right:SetIsEnabled(true)
  end
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:RefreshPlayerList(_playerList)
  local playerList = _playerList or {}
  if not _playerList then
    playerList[1] = self:GetOwnerInfo()
    playerList[2] = nil
    playerList[3] = nil
    playerList[4] = nil
  end
  if #playerList > 1 then
    table.sort(playerList, function(a, b)
      return a.uin == self.ownerUin
    end)
  end
  self.List:InitGridView(playerList)
  self.playerList = playerList
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:GetOwnerInfo()
  local ownerInfo = {}
  ownerInfo.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  ownerInfo.name = _G.DataModelMgr.PlayerDataModel:GetPlayerName()
  ownerInfo.status = ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_ACCEPT
  ownerInfo.card_icon = _G.DataModelMgr.PlayerDataModel:GetPlayerHeadIcon()
  return ownerInfo
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnHomeTeamUpdateNotify(teamInfo)
  if teamInfo then
    if #teamInfo.members < 2 then
      self:OnClose()
      return
    end
    if teamInfo.team_leader_uin == _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
    elseif teamInfo.status == ProtoEnum.HomeTeamStatus.HOME_TEAM_STATUS_DISBAND then
      self:OnClose()
      return
    end
    self:RefreshPlayerList(teamInfo.members)
  end
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  if self.Title and self.playerList and self.playerList[1] and self.playerList[1].name then
    CommonPopUpData.TitleText = string.format(self.Title, self.playerList[1].name)
  end
  CommonPopUpData.Desc = self.Desc
  CommonPopUpData.Btn_RightText = self.RightBtnText
  if self.RightBtnTitle and self.RightBtnCD then
    CommonPopUpData.Btn_RightTitle = string.format(self.RightBtnTitle, self.RightBtnCD)
  end
  CommonPopUpData.ClosePanelHandler = self.OnBtnClose
  CommonPopUpData.FullScreen_Close = false
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnConFirm
  CommonPopUpData.HideBtn = self.waitConFirmType ~= HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome and self.waitConFirmType ~= HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp4.Btn_Right:SetIsEnabled(false)
  self.PopUp4.Btn_Right_GrayState2:SetIsEnabled(false)
  self.PopUp4.Btn_Right_GrayState2.Title_1:SetText(self.RightBtnText)
  self.PopUp4.Btn_Right_GrayState2.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PopUp4:SetPanelInfo(CommonPopUpData)
  self.PopUp4:SetRightBtnIconInfo()
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnClose()
  if self:IsAnimationPlaying(self:GetAnimByIndex(2)) then
    return
  end
  self.PopUp4:LoadAnimation(2)
  self:LoadAnimation(2)
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:TimeoutHandle()
  if self.waitConFirmType and (self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome or self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.invite_home_owner_timeout)
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamDisbandReq)
    self:OnClose()
  end
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnBtnClose()
  if self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome or self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamDisbandReq)
  elseif self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.VisitorEnterHome or self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.VisitorLeaveHome then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamRespondInviteReq, self.ownerUin, self.teamType, ProtoEnum.HomeTeamRespondType.HOME_TEAM_RESPOND_TYPE_REJECT)
  end
  self:OnClose()
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnCancel()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_EnterHome_HomeownerWaitConfirmation_C:OnConFirm")
  if self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome or self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdZoneSceneHomeTeamDisbandReq)
  end
  self:OnClose()
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnConFirm()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_EnterHome_HomeownerWaitConfirmation_C:OnConFirm")
  if self:IsAllPlayerAccept() then
    self:OnExecuteHandle()
    return
  end
  local Title, Tips
  if self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome then
    Title = LuaText.online_visit_home_enter_tips_title
    Tips = LuaText.online_visit_home_enter_tips_text
  elseif self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome then
    Title = LuaText.online_leave_home_tips_title
    Tips = LuaText.online_leave_home_tips_text
  end
  local Ctx = _G.DialogContext()
  Ctx:SetTitle(Title)
  Ctx:SetContent(Tips)
  Ctx:SetMode(_G.DialogContext.Mode.OK_CANCEL)
  Ctx:SetButtonText(LuaText.YES, LuaText.NO)
  Ctx:SetForceEnableFullScreenBtn()
  Ctx:SetCallback(self, function(_, IsOK, CancelType)
    if IsOK then
      self:OnExecuteHandle()
    end
  end)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnExecuteHandle()
  if self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerEnterHome then
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdZoneSceneHomeTeamEnterHomeReq)
  elseif self.waitConFirmType == HomeEnum.HomeownerWaitConfirmation.OwnerLeaveHome then
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdZoneSceneHomeTeamLeaveHomeReq)
  end
  self:OnClose()
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:IsAllPlayerAccept()
  if self.playerList then
    for i, v in pairs(self.playerList) do
      if not v or v.status ~= ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_ACCEPT then
        return false
      end
    end
  end
  return true
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:GetRefusalInvitationPlayerName(newPlayerList)
  if not self.playerList or not newPlayerList then
    return nil
  end
  local oldPlayerMap = {}
  for _, player in ipairs(self.playerList) do
    oldPlayerMap[player.uin] = player
  end
  for _, newPlayer in ipairs(newPlayerList) do
    local oldPlayer = oldPlayerMap[newPlayer.uin]
    if oldPlayer and newPlayer.status == ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_DECLINED and oldPlayer.status ~= ProtoEnum.HomeTeamMemberStatus.HOME_TEAM_MEMBER_STATUS_DECLINED then
      return newPlayer.name
    end
  end
  return nil
end

function UMG_EnterHome_HomeownerWaitConfirmation_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_EnterHome_HomeownerWaitConfirmation_C
