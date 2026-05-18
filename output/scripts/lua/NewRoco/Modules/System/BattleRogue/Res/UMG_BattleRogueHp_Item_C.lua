local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BattleRogueHp_Item_C = Base:Extend("UMG_BattleRogueHp_Item_C")

function UMG_BattleRogueHp_Item_C:OnConstruct()
end

function UMG_BattleRogueHp_Item_C:OnDestruct()
end

function UMG_BattleRogueHp_Item_C:OnItemUpdate(_data, datalist, index)
  if _data.IsShowHP then
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BattleRogueHp_Item_C:OnItemSelected(_bSelected)
end

function UMG_BattleRogueHp_Item_C:OnDeactive()
end

return UMG_BattleRogueHp_Item_C
