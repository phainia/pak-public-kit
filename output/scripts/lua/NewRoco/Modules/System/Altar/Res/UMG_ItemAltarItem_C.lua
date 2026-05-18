local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ItemAltarItem_C = Base:Extend("UMG_ItemAltarItem_C")

function UMG_ItemAltarItem_C:OnConstruct()
end

function UMG_ItemAltarItem_C:OnItemUpdate(data, datalist, index)
  self._data = data
  local itemConf = _G.DataConfigManager:GetBagItemConf(data.id)
  if not itemConf then
    Log.Error("UMG_PetAltarItem_C:SetData \230\137\190\228\184\141\229\136\176itemConf")
    return
  end
  if itemConf.big_icon then
    self.Icon_1:SetPath(itemConf.big_icon)
  end
  self.Name:SetText(itemConf.name)
  self.txtCur:SetText(string.format("%d", data.cur))
  self.txtNeed:SetText(string.format("/%d", data.need))
  local color = UE4.FSlateColor()
  if data.cur >= data.need then
    color.SpecifiedColor = UE4.UNRCStatics.HexToLinearColor("1F1F1FFF")
  else
    color.SpecifiedColor = UE4.UNRCStatics.HexToLinearColor("AF3D3EFF")
  end
  self.txtCur:SetColorAndOpacity(color)
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

function UMG_ItemAltarItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local ret = Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self._data.id, _G.Enum.GoodsType.GT_BAGITEM)
  return ret
end

function UMG_ItemAltarItem_C:OnDestruct()
end

function UMG_ItemAltarItem_C:OnActive()
end

function UMG_ItemAltarItem_C:OnDeactive()
end

return UMG_ItemAltarItem_C
