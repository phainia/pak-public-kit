local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local Base = DebugTabBase
local DebugTabClientRemoteStorage = Base:Extend("DebugTabClientRemoteStorage")

function DebugTabClientRemoteStorage:SetupTabs()
end

function DebugTabClientRemoteStorage:_GetRS(name, panel, InputText)
  local rsReq = ProtoMessage.newZoneClientRemoteStoreReq()
  rsReq.meth = "GET"
  rsReq.cli_stub = 9527
  if panel then
    rsReq.key = panel.inputBox:GetText()
  else
    rsReq.key = InputText
  end
  self:_SendRSReq(rsReq)
  panel:DoClose()
end

function DebugTabClientRemoteStorage:_SetRS(name, panel, InputText)
  local rsReq = ProtoMessage.newZoneClientRemoteStoreReq()
  rsReq.meth = "SET"
  local params
  if panel then
    params = string.split(panel.inputBox:GetText(), " ")
  else
    params = InputText
  end
  rsReq.key = params[1]
  rsReq.value = params[2]
  if #params >= 3 then
    rsReq.live_time = tonumber(params[3])
  else
    rsReq.live_time = -1
  end
  if not rsReq.cli_stub then
    rsReq.cli_stub = 10086
  end
  self:_SendRSReq(rsReq)
end

function DebugTabClientRemoteStorage:_DelRS(name, panel, InputText)
  local rsReq = ProtoMessage.newZoneClientRemoteStoreReq()
  rsReq.meth = "DEL"
  if panel then
    rsReq.key = panel.inputBox.GetText()
  else
    rsReq.key = InputText
  end
  self:_SendRSReq(rsReq)
end

function DebugTabClientRemoteStorage:_DelAllRS(name, panel)
  local rsReq = ProtoMessage.newZoneClientRemoteStoreReq()
  rsReq.meth = "DELALL"
  self:_SendRSReq(rsReq)
end

function DebugTabClientRemoteStorage:_SendRSReq(req)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_REMOTE_STORE_REQ, req, self, self._OnRSRsp, false, true)
end

function DebugTabClientRemoteStorage:_OnRSRsp(rsp)
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.ErrorFormat("Client RS: Op failed, retCode:%s", retCode)
    self:_ShowOKMsgBox(string.format("\229\174\162\230\136\183\231\171\175\232\191\156\231\168\139\230\147\141\228\189\156\229\164\177\232\180\165, \233\148\153\232\175\175\231\160\129:%s", retCode))
    return
  end
  Log.TraceFormat("Client RS: succeed, cliStub:%s", rsp.cli_stub)
  if rsp.cli_stub == 9527 then
    self:_ShowOKMsgBox(string.format("\232\142\183\229\143\150\232\191\156\231\168\139\229\173\152\229\130\168\230\149\176\230\141\174\230\136\144\229\138\159\nvalue:%s\n", rsp.value))
  end
end

function DebugTabClientRemoteStorage:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

return DebugTabClientRemoteStorage
