local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ColorfulTabBtn_C = Base:Extend("UMG_ColorfullTabBtn_C")

function UMG_ColorfulTabBtn_C:OnConstruct()
  Log.Debug("UMG_ColorfullTabBtn_C:OnConstruct")
  self.bSelected = false
end

function UMG_ColorfulTabBtn_C:OnDestruct()
end

function UMG_ColorfulTabBtn_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  self.Data = _data
  self.Index = index
  self.bSelected = false
  self:UpdateView()
end

function UMG_ColorfulTabBtn_C:UpdateView()
  if self.Data and self.Data.conf and self.Data.conf.particle_icon then
    self.Tire_Ordinary:SetPath(self.Data.conf.particle_icon)
    self.Tire_Selected:SetPath(self.Data.conf.particle_icon)
  end
  if self.Data.parentView then
    local SelectItemIndex = self.Data.parentView:GetCurSelectParticleIconItemIndex()
    if SelectItemIndex and SelectItemIndex == self.Index then
      self.bSelected = true
      self:PlayAnimation(self.Btn_Hats_A)
    end
  end
end

function UMG_ColorfulTabBtn_C:OnItemSelected(_bSelected)
  Log.Debug("UMG_ColorfulTabBtn_C:OnItemSelected")
  if self.bSelected == _bSelected then
    return
  end
  self.bSelected = _bSelected
  self:StopAnimation(self.Btn_Hats_A)
  self:StopAnimation(self.Btn_Hats_Out)
  if self.bSelected then
    self:PlayAnimation(self.Btn_Hats_A)
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ColorfulTabBtn_C:OnItemSelected")
    if self.Data.parentView then
      self.Data.parentView:SetCurSelectParticleIconItemIndex(self.Index)
      self.Data.parentView:OnGlassParticlesItemSelected()
    end
  else
    self:PlayAnimation(self.Btn_Hats_Out)
  end
end

function UMG_ColorfulTabBtn_C:OnDeactive()
end

return UMG_ColorfulTabBtn_C
