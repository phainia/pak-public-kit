local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LeveASuccessfulChallenge_Item_C = Base:Extend("UMG_LeveASuccessfulChallenge_Item_C")

function UMG_LeveASuccessfulChallenge_Item_C:OnConstruct()
end

function UMG_LeveASuccessfulChallenge_Item_C:OnDestruct()
end

function UMG_LeveASuccessfulChallenge_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local conf = _G.DataConfigManager:GetLegendaryBattleAward(self.data.target_id)
  self.Switcher:SetActiveWidgetIndex(self.data.is_finish and 0 or 1)
  self.TextDescribe:SetText(conf.text)
end

function UMG_LeveASuccessfulChallenge_Item_C:OnItemSelected(_bSelected)
end

function UMG_LeveASuccessfulChallenge_Item_C:OnDeactive()
end

return UMG_LeveASuccessfulChallenge_Item_C
