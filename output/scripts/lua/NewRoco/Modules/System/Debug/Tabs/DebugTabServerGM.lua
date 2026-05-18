local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local JsonUtils = require("Common.JsonUtils")
local DebugTabServerGM = Base:Extend("DebugTabServerGM")

function DebugTabServerGM:Ctor()
  Base.Ctor(self)
end

function DebugTabServerGM:SetupTabs()
  self:Add("\229\136\183\230\150\176", self.UpdateInfo, self)
end

function DebugTabServerGM:UpdateInfo(name, panel)
  local Req = _G.ProtoMessage:newZoneGmGetCommGmCmdsReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_COMM_GM_CMDS_REQ, Req, self, self.OnGetCommGmCmdsRsp, false, false)
end

function DebugTabServerGM:OnGetCommGmCmdsRsp(Rsp)
  self:RemoveAll()
  self:Add("\229\136\183\230\150\176", self.UpdateInfo, self)
  local DebugTabServerGmCmds = JsonUtils.LoadSaved("DebugTabServerGmCmds", {})
  DebugTabServerGmCmds.cmds = Rsp.cmds
  JsonUtils.DumpSaved("DebugTabServerGmCmds", DebugTabServerGmCmds)
  for i, _ in ipairs(Rsp.cmds) do
    self:Add(_.cmd_name, self.OpenGmCmdsTips, self)
  end
  self.Rsp = Rsp
  self.Panel:UpdateItemInfo(self.items, 200)
end

function DebugTabServerGM:OpenGmCmdsTips(name)
  for i, CommGm in ipairs(self.Rsp.cmds) do
    if name == CommGm.cmd_name then
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugGmTips, CommGm)
      break
    end
  end
end

return DebugTabServerGM
