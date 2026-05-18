local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local M = Base:Extend("NPCActionHomeIndoorOpenLevelReward")

function M:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function M:Execute()
  Base.Execute(self)
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeLevelRewardPanel)
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeIndoorOpenLevelReward", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
end

function M:OnClosePanel(PanelData)
  local Name = PanelData.panelName
  if "HomeLevelRewardPanel" == Name then
    self:Finish(true)
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  end
end

return M
