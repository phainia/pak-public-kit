local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVPASuccessfulChallenge_Item_C = Base:Extend("UMG_PVPASuccessfulChallenge_Item_C")

function UMG_PVPASuccessfulChallenge_Item_C:OnConstruct()
end

function UMG_PVPASuccessfulChallenge_Item_C:OnDestruct()
end

function UMG_PVPASuccessfulChallenge_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  local LegendaryBattleAward = _G.DataConfigManager:GetLegendaryBattleAward(_data.task_id)
  self.TextDescribe:SetText(LegendaryBattleAward.text)
  self.TextDescribe_1:SetText(LegendaryBattleAward.text)
  self.TextDescribe_2:SetText(LegendaryBattleAward.text)
  local taskState = _data.task_state
  self.Switcher:SetActiveWidgetIndex(taskState)
end

function UMG_PVPASuccessfulChallenge_Item_C:OnItemSelected(_bSelected)
end

function UMG_PVPASuccessfulChallenge_Item_C:OnDeactive()
end

return UMG_PVPASuccessfulChallenge_Item_C
