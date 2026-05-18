local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ColorfulColorSchemeItem_C = Base:Extend("UMG_ColorfulColorSchemeItem_C")

function UMG_ColorfulColorSchemeItem_C:OnConstruct()
  self.bSelected = false
end

function UMG_ColorfulColorSchemeItem_C:OnDestruct()
end

function UMG_ColorfulColorSchemeItem_C:OnItemUpdate(_data, datalist, index)
  if self._data == nil then
    return
  end
  self.Data = _data
  self.Index = index
  self.bSelected = false
  self:UpdateView()
end

function UMG_ColorfulColorSchemeItem_C:UpdateView()
  if self.Data == nil then
    return
  end
  if nil == self.Data.conf then
    return
  end
  if nil == self.Data.parentView then
    return
  end
  self.Switcher:SetActiveWidgetIndex(0)
  if self.Data.conf.ui_color_1 then
    local color1 = self.Data.conf.ui_color_1 .. "FF"
    self.NRCImage_A:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
  end
  if self.Data.conf.ui_color_2 then
    local color2 = self.Data.conf.ui_color_2 .. "FF"
    self.NRCImage_B:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
  end
  local particleIconConf = self.Data.parentView:GetCurSelectParticleIconConf()
  if particleIconConf then
    local particleIconRes = particleIconConf.particle_big_icon
    if particleIconRes then
      self.Image_Icon:SetPath(particleIconRes)
    end
  end
  self:StopAllAnimations()
  local SelectItemIndex = self.Data.parentView:GetCurSelectColorItemIndex()
  if SelectItemIndex and SelectItemIndex == self.Index then
    self.bSelected = true
    self:PlayAnimation(self.Select_Loop)
  else
    self:PlayAnimation(self.Normal_Loop)
  end
end

function UMG_ColorfulColorSchemeItem_C:OnItemSelected(_bSelected)
  Log.Debug("UMG_ColorfulColorSchemeItem_C:OnItemSelected")
  if self.bSelected == _bSelected then
    return
  end
  self.bSelected = _bSelected
  self:StopAnimation(self.Selected)
  self:StopAnimation(self.close)
  if self.bSelected then
    self:PlayAnimation(self.Selected)
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ColorfulColorSchemeItem_C:OnItemSelected")
    if self.Data.parentView then
      self.Data.parentView:SetCurSelectColorItemIndex(self.Index)
      self.Data.parentView:OnGlassColorItemSelected()
    end
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_ColorfulColorSchemeItem_C:OnDeactive()
end

return UMG_ColorfulColorSchemeItem_C
