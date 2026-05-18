local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ConsumptionList_C = Base:Extend("UMG_ConsumptionList_C")

function UMG_ConsumptionList_C:OnConstruct()
end

function UMG_ConsumptionList_C:OnItemUpdate(data, datalist, index)
  self.data = data
  local itemConf = _G.DataConfigManager:GetBagItemConf(data.id)
  if not itemConf then
    Log.Error("UMG_ConsumptionList_C:SetData \230\137\190\228\184\141\229\136\176itemConf")
    return
  end
  if itemConf.big_icon then
    self.Icon:SetPath(itemConf.big_icon)
  end
  self.CostNum:SetText(itemConf.name)
  self.CostNum_1:SetText("\230\182\136\232\128\151\239\188\154")
  self.CostNum_2:SetText(string.format("%d", data.cur))
  self.CostNum_3:SetText(string.format("/%d", data.need))
  if data.cur < data.need then
    local color = UE4.FSlateColor()
    color.SpecifiedColor = UE4.FColor(255, 0, 0, 255):ToLinearColor()
    self.CostNum_2:SetColorAndOpacity(color)
  end
  local quality = itemConf.item_quality
  if 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_ConsumptionList_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local ret = Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  if self.data then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.data.id, _G.Enum.GoodsType.GT_BAGITEM)
  end
  return ret
end

return UMG_ConsumptionList_C
