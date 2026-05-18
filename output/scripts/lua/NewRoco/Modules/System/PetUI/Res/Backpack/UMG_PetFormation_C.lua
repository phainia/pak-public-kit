local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetFormation_C = Base:Extend("UMG_PetFormation_C")

function UMG_PetFormation_C:OnConstruct()
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.PetList = nil
end

function UMG_PetFormation_C:OnDestruct()
end

function UMG_PetFormation_C:OnActive()
end

function UMG_PetFormation_C:OnItemUpdate(_Petdata)
  self.PetList = _Petdata
  self:SetData()
end

function UMG_PetFormation_C:SetData()
  local petList = self.PetList
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.plus:SetVisibility(UE4.ESlateVisibility.Visible)
  self.plus:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Unlocked:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  if petList and petList.IsHasPet then
    if petList.IsOnClick then
      self:SetClickable(true)
    else
      self:SetClickable(false)
    end
    self.NumText:SetText(petList.IconListInfo)
    self.ItemIcon:SetPath(petList.PetIcon.icon)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.plus:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Unlocked:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PetLevel_1:SetText(petList.energy)
  else
    self:SetClickable(false)
    self.plus:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if petList and petList.EnableChange == false then
    self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
    self.Unlocked:SetRenderOpacity(0.5)
    self.HorizontalBox_46:SetRenderOpacity(0.5)
  else
    self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
    self.Unlocked:SetRenderOpacity(1)
    self.HorizontalBox_46:SetRenderOpacity(1)
  end
end

function UMG_PetFormation_C:SetSelect(_flag)
  self:StopAllAnimations()
  if _flag then
    self:PlayAnimation(self.change1)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1225, "UMG_PetFormation_C:SetSelect ")
  else
    self:PlayAnimation(self.change2)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetFormation_C:OnItemSelected(_bSelected)
  Log.Trace("UMG_PetFormation_C:OnItemSelected", self._index)
  if _bSelected and self.PetList.IsHasPet then
    _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.ChangePetTeams, self._index)
  end
  self:SetSelect(_bSelected)
end

function UMG_PetFormation_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    Log.Trace("UMG_PetItemTemplate_C:OnAnimationFinished")
    self:PlayAnimation(self.select, 0, 9999)
  end
end

function UMG_PetFormation_C:OnDeactive()
end

return UMG_PetFormation_C
