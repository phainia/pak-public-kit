local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AltarModuleEvent = require("NewRoco.Modules.System.AltarModule.AltarModuleEvent")
local UMG_ItemAltarItem1_C = Base:Extend("UMG_ItemAltarItem1_C")

function UMG_ItemAltarItem1_C:OnConstruct()
  self.bSelected = false
  self.bTip = false
  _G.NRCEventCenter:RegisterEvent("UMG_ItemAltarItem1_C", self, AltarModuleEvent.FreeAltarItemSelect, self.ItemSelected)
end

function UMG_ItemAltarItem1_C:OnDestruct()
end

function UMG_ItemAltarItem1_C:OnItemUpdate(data, datalist, index)
  self._data = data
  local itemConf = _G.DataConfigManager:GetBagItemConf(data.id)
  if not itemConf then
    Log.Error("UMG_PetAltarItem_C:SetData \230\137\190\228\184\141\229\136\176itemConf")
    return
  end
  if itemConf.big_icon then
    self.ICON_2:SetPath(itemConf.big_icon)
  end
  self.IconText:SetText(string.format("%d", data.cur))
  self.IconText_2:SetText(string.format("/%d", data.need))
  local color = UE4.FSlateColor()
  if data.cur >= data.need then
    color.SpecifiedColor = UE4.UNRCStatics.HexToLinearColor("#8B8975FF")
  else
    color.SpecifiedColor = UE4.UNRCStatics.HexToLinearColor("#AF3D3EFF")
  end
  self.IconText:SetColorAndOpacity(color)
  local quality = itemConf.item_quality
  if 1 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
  if data.bCommit then
    self.Obturation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Extra:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Submit)
  else
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Extra:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.bSelected then
      self:PlayAnimation(self.Select)
    else
      self:PlayAnimation(self.Normal)
    end
  end
end

function UMG_ItemAltarItem1_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local ret = Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  if self.bTip then
    _G.DelayManager:CancelDelay(self.OpenTip)
    self.bTip = false
    if not self._data.bCommit then
      if self.bSelected then
        self:StopAllAnimations()
        _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_ItemAltarItem1_C:OnTouchEnded")
        self:PlayAnimation(self.Change2)
        self.bSelected = false
        _G.NRCEventCenter:DispatchEvent(AltarModuleEvent.FreeAltarItemUnSelect)
      else
        self:StopAllAnimations()
        _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_ItemAltarItem1_C:OnTouchEnded")
        self:PlayAnimation(self.Change1)
        self.bSelected = true
        _G.NRCEventCenter:DispatchEvent(AltarModuleEvent.FreeAltarItemSelect, self._data)
      end
    end
  end
  return ret
end

function UMG_ItemAltarItem1_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self.bTip = true
  _G.DelayManager:DelaySeconds(0.8, self.OpenTip, self)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_ItemAltarItem1_C:OpenTip()
  if self.bTip then
    self.bTip = false
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self._data.id, _G.Enum.GoodsType.GT_BAGITEM)
  end
end

function UMG_ItemAltarItem1_C:ItemSelected(data)
  if self._data and self.bSelected and self._data ~= data then
    self.bSelected = false
    self:StopAllAnimations()
    self:PlayAnimation(self.Change2)
  end
end

function UMG_ItemAltarItem1_C:OnAnimationFinished(Anim)
  if Anim == self.Change1 then
    self:PlayAnimation(self.Select)
  elseif Anim == self.Change2 then
    self:PlayAnimation(self.Normal)
  end
end

function UMG_ItemAltarItem1_C:OnMouseLeave(MouseEvent)
  if self.bTip then
    self.bTip = false
    _G.DelayManager:CancelDelay(self.OpenTip)
  end
end

function UMG_ItemAltarItem1_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, AltarModuleEvent.FreeAltarItemSelect, self.ItemSelected)
end

return UMG_ItemAltarItem1_C
