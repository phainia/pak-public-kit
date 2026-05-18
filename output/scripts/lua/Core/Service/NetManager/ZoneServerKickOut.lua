local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local GCloudConnEnum = require("Core.Service.NetManager.GCloudConnEnum")
local ZoneServerKickOut = Class()

function ZoneServerKickOut:Ctor()
  self.KickOutType = 0
  self.KickOutSubType = 0
  self.KickOutTxtId = nil
end

function ZoneServerKickOut:Init()
  Log.Debug("ZoneServerKickOut:Init()")
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_KICKOUT_NTY, self.OnKickOutNotify)
  _G.NRCEventCenter:RegisterEvent("ZoneServerKickOut", self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
end

function ZoneServerKickOut:OnShutdown()
  Log.Debug("ZoneServerKickOut:OnShutdown")
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_KICKOUT_NTY, self.OnKickOutNotify)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
end

function ZoneServerKickOut:IsInKickOut()
  return self.KickOutType > 0
end

function ZoneServerKickOut:IsKickOutNeedReconnect()
  Log.Debug("ZoneServer IsKickOutNeedReconnect", self.KickOutType, ProtoEnum.KickoutType.ENUM.ServerRestart)
  return self.KickOutType == ProtoEnum.KickoutType.ENUM.ServerRestart or self.KickOutType == ProtoEnum.KickoutType.ENUM.CSMsgLimitFrequency
end

function ZoneServerKickOut:OnConnected(errorCode)
  if errorCode == GCloudConnEnum.ErrorCode.kSuccess then
    _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_CONNECTED_KICK_OUT_TYPE, self:IsKickOutNeedReconnect())
    self.KickOutType = 0
    self.KickOutSubType = 0
    self.KickOutTxtId = nil
  end
end

function ZoneServerKickOut:ReqGMKickout(kickOutType, kickOutSubType)
  local req = ProtoMessage:newZoneGmKickoutReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.open_id = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.openid
  req.kickout_type = kickOutType
  req.kickout_sub_type = kickOutSubType
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_KICKOUT_REQ, req)
end

function ZoneServerKickOut:OnKickOutNotify(Notify)
  if nil == Notify then
    Log.Error("ZoneServer:OnKickOutNotify Notify is empty!")
    return
  end
  self.KickOutType = Notify.kickout_type
  self.KickOutSubType = Notify.kickout_sub_type or 0
  self.KickOutTxtId = Notify.kickout_txt_id
  local ExtraMsg = self:GetKickOutMsg()
  local debugInfo = "KickOut Type=" .. self.KickOutType .. ",SubType=" .. self.KickOutSubType
  Log.Error("[ZoneServer][NetMsg] OnKickOutNotify debugInfo=", debugInfo)
  _G.ZoneServer:DisConnect(true)
  if self.KickOutType == ProtoEnum.KickoutType.ENUM.InactiveTimeout then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.IllegalPackageSequence then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ServerRestart then
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", "\230\156\141\229\138\161\229\153\168\228\184\187\229\138\168\229\143\145\232\181\183\233\157\153\233\187\152\233\135\141\232\191\158\227\128\130")
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ServerMaintain then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
    _G.NRCNetworkManager:ClearValidServerIdAndTime(_G.ZoneServer.connectID)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ConflictLogin then
    local contentStr = ExtraMsg or LuaText.another_device_login
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.GMKickout then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    if self.KickOutSubType == ProtoEnum.KickoutSubType.ENUM.GMKickout_Ban then
      local GlobalConfig = _G.DataConfigManager:GetGlobalConfig("banned_notice")
      local ZoneHopeInfo = _G.ProtoMessage:newZoneHopeNotify()
      ZoneHopeInfo.instruction.modal = 1
      ZoneHopeInfo.instruction.title = GlobalConfig.title
      local ban_time = os.date("%Y-%m-%d %H:%M:%S", Notify.ban_info.ban_time)
      local Uin = Notify.ban_info.uin
      local Text = string.format(GlobalConfig.str, Uin, ban_time, Notify.ban_info.ban_reason)
      ZoneHopeInfo.instruction.msg = Text
      self:OpenKickOutDialogue(Text, debugInfo)
    elseif self.KickOutSubType == ProtoEnum.KickoutSubType.ENUM.GMKickout_BatchKickout or self.KickOutSubType == ProtoEnum.KickoutSubType.ENUM.GMKickout_PreventAddiction then
      local batchKickOutStr = ExtraMsg or LuaText.onlinemodule_9
      self:OpenKickOutDialogue(batchKickOutStr, debugInfo)
    end
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ServerInternalError then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.VisitTeleportFail then
    local confStr = _G.DataConfigManager:GetLocalizationConf("online_enter_owner_dissolve").msg
    local contentStr = ExtraMsg or confStr
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ClientResVersionTooLow then
    local contentStr = ExtraMsg or LuaText.onlinemodule_7
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.ClientResVersionTooHigh then
    local contentStr = ExtraMsg or LuaText.onlinemodule_9
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", contentStr)
  elseif self.KickOutType == ProtoEnum.KickoutType.ENUM.CSMsgLimitFrequency then
    local contentStr = ExtraMsg or _G.LuaText.Error_Code_1121
    self:OpenKickOutDialogue(contentStr, debugInfo)
    _G.GEMPostManager:GEMPostStepEvent("KickOutNotify", "\230\182\136\230\129\175\233\162\145\231\142\135\232\191\135\229\191\171")
  end
end

function ZoneServerKickOut:OpenKickOutRetryDialogue(contentStr, debugStr)
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(contentStr):SetMode(DialogContext.Mode.OK):SetButtonText(LuaText.RETRY, nil):SetCallback(self, self.OpenKickOutRetryDialogueCallback):SetCloseOnCancel(true):SetDebugInfo(debugStr)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenOnlyForNetworkDialog, Context)
end

function ZoneServerKickOut:OpenKickOutRetryDialogueCallback()
  _G.ZoneServer:ReConnect()
end

function ZoneServerKickOut:OpenKickOutDialogue(contentStr, debugStr)
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(contentStr):SetMode(DialogContext.Mode.OK):SetButtonText(LuaText.onlinemodule_11, nil):SetCallback(self, self.OnKickOutDialogueCallback):SetCloseOnOK(true):SetDebugInfo(debugStr)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenOnlyForNetworkDialog, Context)
end

function ZoneServerKickOut:OnKickOutDialogueCallback()
  _G.AppMain.BackToLogin()
end

function ZoneServerKickOut:OpenKickOutAndRetryDialogue(contentStr, debugStr)
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(contentStr):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.RETRY, LuaText.BACK):SetCallback(self, self.OnKickOutAndRetryDialogueCallback):SetCloseOnCancel(true):SetDebugInfo(debugStr)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenOnlyForNetworkDialog, Context)
end

function ZoneServerKickOut:OnKickOutAndRetryDialogueCallback(result)
  if result then
    _G.ZoneServer:ReConnect()
  else
    _G.AppMain.BackToLogin()
  end
end

function ZoneServerKickOut:GetKickOutMsg(InTextId)
  local textId = InTextId or self.KickOutTxtId
  if textId and not string.IsNilOrEmpty(textId) then
    local ErrText = _G.LuaText[textId]
    if ErrText and string.EndsWith(ErrText, "\230\156\170\233\133\141\231\189\174") then
      ErrText = nil
    end
    return ErrText
  end
  return nil
end

return ZoneServerKickOut
