local JsonUtils = require("Common.JsonUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabAccounts = Base:Extend("DebugTabAccounts")

function DebugTabAccounts:Ctor()
  self.AccountInfos = JsonUtils.LoadSaved("DebugTabAccounts", {})
  Base.Ctor(self)
end

function DebugTabAccounts:SetupTabs()
  for k, v in pairs(self.AccountInfos) do
    self:Add(k, function(caller, Name, Panel)
      self:QuickLoginSkip(Name, Panel, k)
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  end
end

function DebugTabAccounts:Klear()
  OpenMessageBoxWthCaller("", "\232\180\166\229\143\183\228\187\172\230\176\184\229\136\171\228\186\134\227\128\130\227\128\130\227\128\130\227\128\130\227\128\130", "\231\161\174\229\174\154", "\229\143\150\230\182\136", DialogContext.Mode.OK_CANCEL, self.KlearInner, self)
end

function DebugTabAccounts:KlearInner(ok)
  if ok then
    self.AccountInfos = {}
    JsonUtils.DumpSaved("DebugTabAccounts", self.AccountInfos)
    self.items = {}
    self:SetupTabs()
  end
end

function DebugTabAccounts:DelayedTruth()
  if NRCModuleManager:GetModule("CinematicModule") then
    NRCModuleManager:GetModule("CinematicModule").Skip = true
  else
    _G.DelayManager:DelaySeconds(0.1, self.DelayedTruth, self)
  end
end

function DebugTabAccounts:QuickLoginSkip(name, panel, final)
  self:DelayedTruth()
  local data = NRCModuleManager:GetModule("LoginModule").data
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserAccountInfo, final, "53535353535")
  NRCModuleManager:DoCmd(OnlineModuleCmd.ConnectAndLogin, data.selectedServer.key, 0, 0, data.selectedServer.ip, data.selectedServer.port, final)
  _G.DelayManager:DelaySeconds(1, self.Luck, self, name, panel)
end

function DebugTabAccounts:Luck(name, panel)
  local namegen = require("NewRoco.Modules.System.Debug.Res.RandomName.namegen2")
  GlobalConfig.EnableDeahTeleport = not GlobalConfig.EnableDeahTeleport
  Log.Debug("EnableDeathTeleport=", GlobalConfig.EnableDeahTeleport)
  local _PlayerBriefInfo = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info
  local Gender = _PlayerBriefInfo.sex or ProtoEnum.ESexValue.SEX_NOT_SEL
  if Gender == ProtoEnum.ESexValue.SEX_MALE or Gender == ProtoEnum.ESexValue.SEX_FEMALE then
    _G.NRCModuleManager:GetModule("LoginModule"):ReqEnter()
    return
  end
  local GenderPicker = math.random(0, 1)
  local nomen = namegen:generate(GenderPicker)
  if 1 == GenderPicker then
    Gender = ProtoEnum.ESexValue.SEX_MALE
  else
    Gender = ProtoEnum.ESexValue.SEX_FEMALE
  end
  local roleAttrReq = ProtoMessage:newZoneRoleAttrReq()
  roleAttrReq.image = Gender
  roleAttrReq.sex = Gender
  roleAttrReq.name = nomen
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex = Gender
  _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.name = nomen
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_ROLE_ATTR_REQ, roleAttrReq, self, self.CheckRoleValid)
end

function DebugTabAccounts:CheckRoleValid(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ErrorCode.SUCCESS then
    _G.NRCModuleManager:GetModule("LoginModule"):ReqEnter()
  end
end

return DebugTabAccounts
