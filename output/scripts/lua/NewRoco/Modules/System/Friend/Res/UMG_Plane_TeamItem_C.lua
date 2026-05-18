local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Plane_TeamItem_C = Base:Extend("UMG_Plane_TeamItem_C")

function UMG_Plane_TeamItem_C:OnConstruct()
  _G.NRCModuleManager:GetModule("FriendModule"):RegisterEvent(self, FriendModuleEvent.OnPlaneItemSetNetWork, self.SetNetWork)
end

function UMG_Plane_TeamItem_C:OnDestruct()
  _G.NRCModuleManager:GetModule("FriendModule"):UnRegisterEvent(self, FriendModuleEvent.OnPlaneItemSetNetWork)
end

function UMG_Plane_TeamItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if _data.card_info and _data.card_info.card_icon_selected and 0 ~= _data.card_info.card_icon_selected then
    local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
    local CardIconConf = _G.DataConfigManager:GetCardIconConf(_data.card_info.card_icon_selected)
    local AvatarPath = CardIconConf.icon_resource_path
    AvatarPath = string.format("%s%s.%s'", path, AvatarPath, AvatarPath)
    self.HeadItem:SetPath(AvatarPath)
  end
  UIUtils.SetTextPlayerNameByCheckFriendNote(self.RemarkName, self.data.uin, self.data.name, "F4EEE1FF")
  self.SerialNumber:SetText(tostring(self.index))
  self.SerialNumber_1:SetText(tostring(self.index))
  if not self.data.level then
    Log.Error("UMG_Plane_TeamItem_C:OnItemUpdate Player level is nil")
  end
  local lvText = string.format(LuaText.umg_petskilltemple2_1, self.data.level or 0)
  self.TextClass:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
    if self.data.uin == _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
      self.Switcher_127:SetActiveWidgetIndex(1)
    else
      self.Switcher_127:SetActiveWidgetIndex(0)
    end
  elseif self.data.uin == _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
    self.Switcher_127:SetActiveWidgetIndex(1)
    self.Switcher_127:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Switcher_127:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.data.uin == _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
  if _G.DataModelMgr.PlayerDataModel:IsVisitState() then
    if self.data.bInDoubleRide then
    elseif self.data.IsInVisitHAND then
    end
  else
    if self.data.IsHomeItem then
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.data.bInDoubleRide then
    elseif self.data.IsInVisitHAND then
    elseif self.data.isMaster then
      self.Switcher_127:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif not HomeIndoorSandbox:InHomeIndoor() and (not (_G.FarmModuleCmd and _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.OnCmdGetIsInFarm)) or not not FarmUtils.IsCurrentHomeOwner()) then
      self.Switcher_127:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif self.data.IsHomeItem then
      self.Switcher_127:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Switcher_127:SetActiveWidgetIndex(0)
    end
  end
  local isBlack = _G.DataModelMgr.PlayerDataModel:CheckHasBlackByPlayerUin(self.data.uin)
  if isBlack then
    UIUtils.SafeSetVisibility(self.Icon_Blacklist, UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    UIUtils.SafeSetVisibility(self.Icon_Blacklist, UE4.ESlateVisibility.Collapsed)
  end
  if self.data.uin == _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
    self.data.is_friend = nil
  else
    self:OnVisitSearchPlayer()
  end
  self:OnAddEventListener()
end

function UMG_Plane_TeamItem_C:OnVisitSearchPlayer()
  local req = _G.ProtoMessage:newZoneFriendSearchPlayerReq()
  req.uin = self.data.uin
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_FRIEND_SEARCH_PLAYER_REQ, req, self, self.OnVisitSearchPlayerRsp, false, true)
end

function UMG_Plane_TeamItem_C:OnVisitSearchPlayerRsp(Rsp)
  if 0 == Rsp.ret_info.ret_code then
    self.data.is_friend = Rsp.is_friend
    self.data.is_black_role = Rsp.is_black_role
  end
end

function UMG_Plane_TeamItem_C:OnItemSelected(_bSelected)
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_Plane_TeamItem_C:OnItemSelected")
  if _bSelected then
  end
end

function UMG_Plane_TeamItem_C:OnDeactive()
end

function UMG_Plane_TeamItem_C:SetNetWork(index, ColorState)
  if index == self.index then
    self.Signal:SetActiveWidgetIndex(ColorState)
  end
end

function UMG_Plane_TeamItem_C:OnAddEventListener()
  self.PleaseLeave.btnLevelUp.OnClicked:Add(self, self.PleaseLeaveBtn)
  self.Dissolve.btnLevelUp.OnClicked:Add(self, self.OwnerDissolveOrExitBtn)
  self.CancelRide.btnLevelUp.OnClicked:Add(self, self.CancelRideBtn)
  self.CancelHandshake.btnLevelUp.OnClicked:Add(self, self.CancelHandshakeBtn)
end

function UMG_Plane_TeamItem_C:CancelRideBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Plane_TeamItem_C:OnItemSelected")
  if self.data.IsHomeItem then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.InviteComponent then
    player.InviteComponent:InteractCancel()
  end
end

function UMG_Plane_TeamItem_C:CancelHandshakeBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Plane_TeamItem_C:OnItemSelected")
  if self.data.IsHomeItem then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.InviteComponent then
    player.InviteComponent:InteractCancel()
  end
end

function UMG_Plane_TeamItem_C:PleaseLeaveBtn()
  if HomeIndoorSandbox:InOtherHomeIndoor() or _G.FarmModuleCmd and _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.OnCmdGetIsInFarm) and not FarmUtils.IsCurrentHomeOwner() then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1192, "UMG_LobbyMain_C:OnBtnExitDungeon")
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    HomeIndoorSandbox.Module:ReqLeavePlayerHomeIndoor()
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_Plane_TeamItem_C:OnItemSelected")
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local ContentText = string.format(_G.DataConfigManager:GetLocalizationConf("online_kick_affirm_text").msg, self.data.name)
  Context:SetTitle(LuaText.umg_plane_teamitem_1):SetContent(ContentText):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, self.OwnerPleaseLeave):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_plane_teamitem_2, LuaText.umg_plane_teamitem_3)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_Plane_TeamItem_C:OwnerPleaseLeave()
  if self.data then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdZoneKick0utVisitReq, self.data.uin)
    NRCEventCenter:DispatchEvent(FriendModuleEvent.OnVisitorLeaved, self.data.uin)
  end
end

function UMG_Plane_TeamItem_C:OwnerDissolveOrExitBtn()
  _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_Plane_TeamItem_C:OnItemSelected")
  if _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    local ContentText = _G.DataConfigManager:GetLocalizationConf("online_breakup_affirm_text").msg
    Context:SetTitle(LuaText.umg_plane_teamitem_1):SetContent(ContentText):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, self.OwnerDissolveOrExit):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_plane_teamitem_2, LuaText.umg_plane_teamitem_3)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  else
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdZoneExitVisitReq)
  end
end

function UMG_Plane_TeamItem_C:OwnerDissolveOrExit()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdZoneDisbandVisitReq)
end

function UMG_Plane_TeamItem_C:OnAnimationFinished(anim)
end

return UMG_Plane_TeamItem_C
