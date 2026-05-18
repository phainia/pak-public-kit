local UMG_OrdinaryReward_C = _G.NRCPanelBase:Extend("UMG_OrdinaryReward_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_OrdinaryReward_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  self:RegisterEvent(self, ActivityModuleEvent.OnSelectedActivityByOpenCmd, self.ClosePanel)
end

function UMG_OrdinaryReward_C:OnActive(rewardData)
  self:LoadAnimation(0)
  self.GridView:InitGridView(rewardData)
  local data = _G.NRCCommonPopUpData()
  data.Call = self
  data.ClosePanelHandler = self.ClosePanel
  self.PopUp1:SetPanelInfo(data)
end

function UMG_OrdinaryReward_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_OrdinaryReward_C:ClosePanel")
  self:LoadAnimation(2)
  self:OnClose()
end

function UMG_OrdinaryReward_C:OnDeactive()
  self:UnRegisterEvent(self, ActivityModuleEvent.OnSelectedActivityByOpenCmd)
end

function UMG_OrdinaryReward_C:OnPcClose()
  self:ClosePanel()
end

return UMG_OrdinaryReward_C
