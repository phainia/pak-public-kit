local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local TowerMode = Base:Extend("TowerMode")

function TowerMode:Ctor()
  Base.Ctor(self)
end

function TowerMode:SetupTabs()
end

function TowerMode:ShowReadMe(name, panel)
  UE4.UKismetSystemLibrary.LaunchURL("https://iwiki.woa.com/pages/viewpage.action?pageId=827460344")
end

function TowerMode:OnPanelTest()
  NRCModuleManager:DoCmd(TowerModeCmd.OpenMainPanel)
end

return TowerMode
