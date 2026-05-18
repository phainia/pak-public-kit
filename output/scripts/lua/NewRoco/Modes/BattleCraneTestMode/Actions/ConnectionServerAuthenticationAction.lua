local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local NRCBattleTestMapDefine = require("NewRoco.Modes.BattleCraneTestMode.NRCBattleTestMapDefine")
local ConnectionServerAuthenticationAction = NRCModeAction:Extend("ConnectionServerAuthenticationAction")

function ConnectionServerAuthenticationAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
end

function ConnectionServerAuthenticationAction:OnLoadLoginNoticeDataCallback(noticeList)
  if UE4.UNoticeStatics.IsLoginNotice() then
    _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.OpenAnnouncementPanel, noticeList)
  end
end

function ConnectionServerAuthenticationAction:OnEnter()
  Log.Debug("yukaheTestMap ConnectionServerAuthenticationAction.OnEnter")
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.maintenance_tips, 0)
  _G.GEMPostManager:GEMPostStepEvent("OpenAnnouncement")
  _G.NRCModuleManager:DoCmd(_G.LoginModuleCmd.LoadLoginNoticeData, self, self.OnLoadLoginNoticeDataCallback)
  self.data = _G.NRCModuleManager:GetModule("LoginModule"):GetData("LoginData")
  local userId = NRCBattleTestMapDefine.userId or "yuka3"
  local key = NRCBattleTestMapDefine.key or "QA\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149\230\156\141"
  local port = NRCBattleTestMapDefine.port or 8099
  Log.Debug("yukaheTestMap ConnectionServerAuthenticationAction.OnEnter, userId=", userId, "key=", key, "port=", port)
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserAccountInfo, userId, "53535353535", nil)
  self.data.selectedServer.key = key
  self.data.selectedServer.port = port
  NRCModuleManager:DoCmd(OnlineModuleCmd.ConnectAndLogin, self.data.selectedServer.key, self.data.selectedServer.typeid, self.data.selectedServer.zoneid, self.data.selectedServer.ip, self.data.selectedServer.port, self.data:GetOpenID(), self.data.selectedServer.encryptMethod or 0, self.data.selectedServer.keyMakingMethod or 0, 0, 0, self.data.selectedServer.clb)
  Log.Debug("yukaheTestMap", self.data.selectedServer.key, self.data.selectedServer.typeid, self.data.selectedServer.zoneid, self.data.selectedServer.ip, self.data.selectedServer.port)
  self:Finish()
end

function ConnectionServerAuthenticationAction:OnExit()
end

return ConnectionServerAuthenticationAction
