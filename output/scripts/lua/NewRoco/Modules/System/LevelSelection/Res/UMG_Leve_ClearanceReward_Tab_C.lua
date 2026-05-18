local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_ClearanceReward_Tab_C = Base:Extend("UMG_Leve_ClearanceReward_Tab_C")

function UMG_Leve_ClearanceReward_Tab_C:OnConstruct()
end

function UMG_Leve_ClearanceReward_Tab_C:OnDestruct()
end

function UMG_Leve_ClearanceReward_Tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.NRCText_35:SetText(_data.Text)
  if self.data and self.data.TabType == LevelSelectionEnum.RewardTab.StarReward then
    self.redPointReward:SetupKey(372, self.data.ActivityId)
  end
end

function UMG_Leve_ClearanceReward_Tab_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.select1)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.SelectTab, self.data)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_Leve_ClearanceReward_Tab_C:OnDeactive()
end

return UMG_Leve_ClearanceReward_Tab_C
