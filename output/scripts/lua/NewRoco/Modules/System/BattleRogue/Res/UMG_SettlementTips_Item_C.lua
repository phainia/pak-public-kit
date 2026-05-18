local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SettlementTips_Item_C = Base:Extend("UMG_SettlementTips_Item_C")

function UMG_SettlementTips_Item_C:OnConstruct()
end

function UMG_SettlementTips_Item_C:OnDestruct()
end

function UMG_SettlementTips_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.Icon:SetPath(_data.Icon)
  self.Title:SetText(_data.topic)
  self.Description:SetText(_data.Description)
end

function UMG_SettlementTips_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    local Add
    if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
      Add = false
    else
      self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      Add = true
    end
    _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SelectBuffInfo, Add, self.index)
  end
end

function UMG_SettlementTips_Item_C:OnDeactive()
end

return UMG_SettlementTips_Item_C
