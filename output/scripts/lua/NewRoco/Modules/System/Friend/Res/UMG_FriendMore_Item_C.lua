local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_FriendMore_Item_C = Base:Extend("UMG_FriendMore_Item_C")

function UMG_FriendMore_Item_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
end

function UMG_FriendMore_Item_C:OnDestruct()
end

function UMG_FriendMore_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.NRCText_Title:SetText(_data.name)
end

function UMG_FriendMore_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    local Uin = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetCurChatUin)
    local SessionInfo = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetSessionInfo, Uin)
    self.FriendRoleInfo = self:CreateFriendRoleInfo(SessionInfo)
    Log.Debug(Uin, "UMG_FriendMore_Item_C:OnItemSelected")
    Log.Dump(self.FriendRoleInfo, 6, "UMG_FriendMore_Item_C:OnItemSelected")
    if self.data.TabType == FriendEnum.ChatFunctionTabList.CheckCard then
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenStudentCardPanel, self.FriendRoleInfo, FriendEnum.AdminFriendType.Others, FriendEnum.Source.Friend, FriendEnum.SELECT_TAB.Chat)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.Teleport then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OnCmdTeleportToPlayerReq, Uin)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.WorldInformation then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendWold, self.FriendRoleInfo)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.HomeInformation then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_CardInteract_Item_C:SelectInfo")
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdSendZoneHomeQueryFriendHomeInfoReq, Uin)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.ApplicationVisit then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
      if self:IsVisit() then
        _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.Visiting)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      end
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.InviteVisit then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Friend_Report_C:OnConfirm")
      if self:IsVisit() then
        _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.InviteVisiting)
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.ClickMsg)
      end
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.ChangeNickname then
      local ReportData = {}
      ReportData.uin = self.FriendRoleInfo.uin
      ReportData.business_data = {}
      ReportData.business_data.report_scene = ProtoEnum.SafetyBusinessInfo.ReportScense.RPTSS_CONVERSATION_SPEAKING_SCENE
      ReportData.business_data.signature = _G.DataConfigManager:GetLocalizationConf("card_signature_input_empty_text").msg
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendRemark, self.FriendRoleInfo, ReportData)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.BlockFriend then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
      self:OnDeleteFriendOrAddBlack("blacklist_affirm_content", self.OnOnAddBlackListCallback)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.ReportFriend then
      _G.NRCAudioManager:PlaySound2DAuto(40008041, "UMG_Plane_ExchangeVisits_C:OnActive")
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendReport, self.FriendRoleInfo)
    elseif self.data.TabType == FriendEnum.ChatFunctionTabList.RemoveSession then
      self:OnClickDeleteBtn()
    end
    self.module:DispatchEvent(FriendModuleEvent.OnHideChatMenuDropdown)
  end
end

function UMG_FriendMore_Item_C:IsVisit()
  if self.data.TabType == FriendEnum.ChatFunctionTabList.ApplicationVisit or self.data.TabType == FriendEnum.ChatFunctionTabList.InviteVisit then
    local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
    local UnlockLevel = 15
    for i = 1, #OnlineConf do
      if OnlineConf[i].key == "online_unlock_role_level" then
        UnlockLevel = OnlineConf[i].num
        break
      end
    end
    local PlayerLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
    if UnlockLevel > PlayerLevel then
      self.ClickMsg = string.format(_G.DataConfigManager:GetLocalizationConf("cant_online_apply_mine").msg, UnlockLevel)
      return false
    end
    local Level = self.FriendRoleInfo.level or 0
    if UnlockLevel > Level then
      self.ClickMsg = _G.DataConfigManager:GetLocalizationConf("cant_online_apply_other").msg
      return false
    end
  end
  return true
end

function UMG_FriendMore_Item_C:OnDeleteFriendOrAddBlack(_Id, Callback)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local Text = _G.DataConfigManager:GetLocalizationConf(_Id).msg
  local TipsContent = string.format(Text, self.FriendRoleInfo.name)
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, Callback)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_FriendMore_Item_C:OnOnAddBlackListCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddOrRemoveBlackList, self.FriendRoleInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveBlackListReq.TYPE.ADD)
  end
end

function UMG_FriendMore_Item_C:DeleteCallback(_ok)
  if _ok then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.AddFriendApplicationOrRemoveFriend, self.FriendRoleInfo.uin, _G.ProtoEnum.ZoneFriendAddOrRemoveFriendReq.TYPE.REMOVE_FRIEND)
  end
end

function UMG_FriendMore_Item_C:CreateFriendRoleInfo(SessionInfo)
  local FriendRoleInfo = _G.ProtoMessage.newFriendRoleInfo()
  FriendRoleInfo.uin = SessionInfo.basic_info.uin
  if SessionInfo.friend_session_info then
    FriendRoleInfo.gender = SessionInfo.friend_session_info.gende
    FriendRoleInfo.name = SessionInfo.friend_session_info.name
    FriendRoleInfo.note = SessionInfo.friend_session_info.note
    FriendRoleInfo.level = SessionInfo.friend_session_info.level_award_info
    FriendRoleInfo.regist_date = SessionInfo.friend_session_info.regist_date
    FriendRoleInfo.world_level = SessionInfo.friend_session_info.world_level
  end
  FriendRoleInfo.business_data = {}
  FriendRoleInfo.business_data.report_scene = ProtoEnum.SafetyBusinessInfo.ReportScense.RPTSS_CONVERSATION_SPEAKING_SCENE
  FriendRoleInfo.business_data.report_content = self:GetReportChatContent(SessionInfo.basic_info.uin)
  return FriendRoleInfo
end

function UMG_FriendMore_Item_C:GetReportChatContent(uin)
  local Result = ""
  local MaxBytes = 9
  local ChatContentData = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetChatInfoByUin, uin, false)
  if ChatContentData then
    for _, ChatContent in ipairs(ChatContentData) do
      if MaxBytes < #Result then
        break
      end
      Result = Result .. ChatContent.chat_message
    end
  end
  return Result
end

function UMG_FriendMore_Item_C:OnClickDeleteBtn()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401009, "UMG_Friend_Chitchat_C:OnClickBtn_paste")
  local Ctx = DialogContext()
  Ctx:SetTitle(_G.LuaText.TIPS):SetContent(_G.LuaText.online_chat_message_delete_confirm):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnCancel(true):SetClickAnywhereClose(true):SetButtonText(_G.LuaText.umg_dialog_2, _G.LuaText.umg_dialog_1):SetCallback(self, function(caller, isOk)
    if isOk then
      _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.RemoveChatList, self.FriendRoleInfo.uin)
    end
  end)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_FriendMore_Item_C:OnDeactive()
end

return UMG_FriendMore_Item_C
