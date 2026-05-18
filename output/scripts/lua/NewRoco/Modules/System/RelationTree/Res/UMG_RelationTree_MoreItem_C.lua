local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_RelationTree_MoreItem_C = Base:Extend("UMG_RelationTree_MoreItem_C")

function UMG_RelationTree_MoreItem_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("RelationTreeModule")
  self.PlayerUin = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetCurPlayerUID)
  self.Button.OnPressed:Add(self, self.OnMoreItemOpation)
end

function UMG_RelationTree_MoreItem_C:OnDestruct()
  self.Button.OnPressed:Remove(self, self.OnMoreItemOpation)
end

function UMG_RelationTree_MoreItem_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    return
  end
  self.Data = _data
  self.NRCText_Title:SetText(self.Data.Name)
end

function UMG_RelationTree_MoreItem_C:OnReadyOpenOpenStudentCardPanel(rsp)
  if 0 == rsp.ret_info.ret_code and rsp.player_info then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenStudentCardPanel, rsp.player_info, FriendEnum.AdminFriendType.Others, rsp.is_friend and FriendEnum.Source.Friend or FriendEnum.Source.Scene, nil)
  end
end

function UMG_RelationTree_MoreItem_C:OnMoreItemOpation()
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_RelationTree_C:ShowMoreClick")
  if self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_OPEN_CARD then
    local PlayerUid = self.PlayerUin
    local req = _G.ProtoMessage:newZoneFriendSearchPlayerReq()
    req.uin = PlayerUid
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_FRIEND_SEARCH_PLAYER_REQ, req, self, self.OnReadyOpenOpenStudentCardPanel, false, true)
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_WORLD_INF then
    local PlayerInfo = {}
    PlayerInfo.uin = self.PlayerUin
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendWold, PlayerInfo)
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_HOME_INF then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdSendZoneHomeQueryFriendHomeInfoReq, self.PlayerUin)
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_BLACK_PLAYER then
    self:OnDeleteFriendOrAddBlack("blacklist_affirm_content", self.OnOnAddBlackListCallback)
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_REPORT_PLAYER then
    self:OnReport()
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_NICKNAME then
    local playerInfo = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetOpenPlayerInfo)
    if playerInfo then
      _G.NRCModeManager:DoCmd(FriendModuleCmd.OpenFriendRemark, playerInfo)
    end
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_SP_ATTENTION then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OnModifyFriendTopReq, self.PlayerUin, true)
  elseif self.Data.RelationTreeBasic == Enum.RelationTreeBasic.RLTB_DELETE_FRIEND then
    self:OnDeleteFriendOrAddBlack("delete_friend_affirm_content", self.DeleteCallback)
  end
end

function UMG_RelationTree_MoreItem_C:OnReport()
  local ReportData = {}
  ReportData.uin = self.PlayerUin
  ReportData.business_data = {}
  ReportData.business_data.report_scene = ProtoEnum.SafetyBusinessInfo.ReportScense.RPTSS_PERSONAL_INFORMATION_SCENE
  local playerInfo = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetOpenPlayerInfo)
  if playerInfo then
    if playerInfo.signature == nil or playerInfo.signature == "" then
      ReportData.business_data.signature = _G.DataConfigManager:GetLocalizationConf("card_signature_input_empty_text").msg
    else
      ReportData.business_data.signature = playerInfo.signature
    end
    _G.NRCAudioManager:PlaySound2DAuto(1010, "UMG_Friend_Chitchat_C:OnReportBtn")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendReport, ReportData)
  end
end

function UMG_RelationTree_MoreItem_C:OnDeleteFriendOrAddBlack(_Id, Callback)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local playerInfo = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetOpenPlayerInfo)
  if playerInfo then
    local Text = _G.DataConfigManager:GetLocalizationConf(_Id).msg
    local name = playerInfo.name
    if name then
      local TipsContent = string.format(Text, name)
      dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetClickAnywhereClose(true):SetCallback(self, Callback)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
    end
  end
end

function UMG_RelationTree_MoreItem_C:OnOnAddBlackListCallback(_ok)
  if _ok then
    local PlayerUin = self.PlayerUin
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddOrRemoveBlackList, PlayerUin, _G.ProtoEnum.ZoneFriendAddOrRemoveBlackListReq.TYPE.ADD)
  end
end

function UMG_RelationTree_MoreItem_C:DeleteCallback(_ok)
  if _ok then
    local PlayerUin = self.PlayerUin
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, PlayerUin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.REMOVE_FRIEND)
  end
end

function UMG_RelationTree_MoreItem_C:OnItemSelected(_bSelected)
end

function UMG_RelationTree_MoreItem_C:OnDeactive()
end

return UMG_RelationTree_MoreItem_C
