Log.Debug("NRCDevelopDebugger require")
local UILayerCtrlTest = require("Core.NRCPanelLayer.Test.UILayerCtrlTest")
local NRCDevelopDebugger = NRCClass()

function NRCDevelopDebugger:Ctor()
  Log.Debug("NRCDevelopDebugger Ctor")
  require = HotFix.ReloadFile
end

function NRCDevelopDebugger:Construct()
  Log.Debug("NRCDevelopDebugger Construct")
  if not self.ReloadModuleBtn then
    Log.Debug("self.ReloadModuleBtn not exist")
    return
  end
  self:AddButtonListener(self.ReloadModuleBtn, self.OnClickReload)
  self:AddButtonListener(self.HotfixBtn, self.OnClickHotfix)
  self:AddButtonListener(self.OpenTestPanel, self.OnOpenTestPanel)
  self:AddButtonListener(self.CloseTestPanel, self.OnCloseTestPanel)
  self:AddButtonListener(self.GetValue, self.OnGetValue)
  self:AddButtonListener(self.TestUI, self.OnTestUI)
end

function NRCDevelopDebugger:OnClickReload()
  Log.Debug("NRCDevelop OnClickReload")
  NRCModuleManager:ReloadModule("DebugModule")
end

function NRCDevelopDebugger:OnClickHotfix()
  Log.Debug("NRCDevelop OnClickHotfix")
  _G.HotFix.HotFixModifyFile(false)
end

function NRCDevelopDebugger:OnOpenTestPanel()
  _G.HotFix.HotFixModifyFile(false)
  _G.NRCModeManager:DoCmd(LoginModuleCmd.OpenLoginPanel, 1, 2, 3)
end

function NRCDevelopDebugger:OnCloseTestPanel()
  _G.NRCModuleManager:GetModule("LoginModule"):DoCmdInternal(NRCModuleCmd.ClosePanel, "LoginPanel", 1, 2, 3)
end

function NRCDevelopDebugger:OnGetValue()
  NRCModeManager:ActiveMode("BigWorldMode")
end

function NRCDevelopDebugger:AddButtonListener(btn, handler)
  local handlerWrap = SimpleDelegateFactory:CreateCallback(btn.OnClicked, handler)
  btn.OnClicked:Add(self, handlerWrap)
end

function NRCDevelopDebugger:OnTestUI()
  UILayerCtrlTest.ClickTest()
end

return NRCDevelopDebugger
