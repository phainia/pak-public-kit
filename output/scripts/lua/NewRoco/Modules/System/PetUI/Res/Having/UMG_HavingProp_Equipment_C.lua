local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local UMG_HavingProp_Equipment_C = _G.NRCViewBase:Extend("UMG_HavingProp_Equipment_C")

function UMG_HavingProp_Equipment_C:OnConstruct()
  self.CurrentSelectIndex = nil
  self.IsCanScale = nil
  self.IsChangeColor = nil
  self.time = 0
  self.data = nil
  self:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.PET_ResonanceSucceed, self.ResonanceSucceedAnimation)
end

function UMG_HavingProp_Equipment_C:OnDestruct()
  self:UnRegisterEvent(self, PetUIModuleEvent.PET_ResonanceSucceed)
end

function UMG_HavingProp_Equipment_C:OnActive()
end

function UMG_HavingProp_Equipment_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_HavingProp_Equipment_C:OnAddEventListener()
  self:AddButtonListener(self.ClickButton, self.OnClickClickButton)
end

function UMG_HavingProp_Equipment_C:ResonanceSucceedAnimation()
  if self.data and self.data.IsSelect == true then
    self:PlayAnimation(self.Change)
  end
end

function UMG_HavingProp_Equipment_C:SetHavingEquipInfo(_data, CurrentSelectIndex, _IsCanScale)
  self.CurrentSelectIndex = CurrentSelectIndex
  self.data = _data
  self.IsChangeColor = _IsCanScale
  if self.data.open then
    self.IsCanScale = _IsCanScale
    self:ShowOpenInfo()
  else
    self:NotOpen()
  end
end

function UMG_HavingProp_Equipment_C:SetHavingPoSitionInfo(position)
  local pos = UE4.FVector2D(position.X, position.Y)
  self.Slot:SetPosition(pos)
end

function UMG_HavingProp_Equipment_C:IsNeedMovePosition(position)
  local CurrentPos = self.Slot:GetPosition()
  if CurrentPos.X == position.X and CurrentPos.Y == position.Y then
    return false
  end
end

function UMG_HavingProp_Equipment_C:GetCurrentPosition()
  return self.Slot:GetPosition()
end

function UMG_HavingProp_Equipment_C:ShowOpenInfo()
  if self.IsCanScale == false then
    self:SetRenderScale(UE4.FVector2D(1, 1))
  end
  self.State:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.data.possessionItem ~= nil and nil ~= self.data.possessionItem.conf_id then
    self.State:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasGood:SetVisibility(UE4.ESlateVisibility.Visible)
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.possessionItem.conf_id)
    local PetCarryonItem = _G.DataConfigManager:GetPetCarryonItem(self.data.possessionItem.conf_id)
    if bagItemConf then
      self.Icon:SetPath(bagItemConf.big_icon)
      if self.data.IsSelect == true then
        self:PlayAnimation(self.loop)
        self.Quality:SetPath(self.data.checkbgIcon[bagItemConf.item_quality])
      else
        self:StopAllAnimations()
        self.Quality:SetPath(self.data.bgIcon[bagItemConf.item_quality])
      end
      self.NameTxt:SetText(bagItemConf.name)
    end
    if 1 == PetCarryonItem.can_cost then
      self.Resonance:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.Resonance:SetVisibility(UE4.ESlateVisibility.Visible)
      if 0 == self.data.possessionItem.stage then
        self.Resonance:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.Resonance:SetVisibility(UE4.ESlateVisibility.Visible)
        local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("Pet_carryon_resonance_string")
        self.Resonance:SetText(string.format("%s%s", LocalizationConf.msg, self.data.possessionItem.stage))
      end
    end
  else
    if self.data.IsSelect == true then
      self:PlayAnimation(self.loop)
      self.Quality:SetPath(self.data.checkbgIcon[1])
    else
      self.Quality:SetPath(self.data.bgIcon[1])
      self:StopAllAnimations()
    end
    self.CanvasGood:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.State:SetActiveWidgetIndex(0)
  end
end

function UMG_HavingProp_Equipment_C:NotOpen()
  self.Quality:SetPath(self.data.bgIcon[1])
  self.CanvasGood:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.State:SetVisibility(UE4.ESlateVisibility.Visible)
  self.State:SetActiveWidgetIndex(1)
end

function UMG_HavingProp_Equipment_C:OnAnimationFinished(Animation)
  if Animation == self.loop then
    self:PlayAnimation(self.loop)
  end
end

function UMG_HavingProp_Equipment_C:OnClickClickButton()
  local data = self.data
  if data.open == true then
    self:DispatchEvent(PetUIModuleEvent.Hide_CloseBtn, false)
    local index
    if data.IsSelect == false then
      if data.possessionItem ~= nil and nil ~= data.possessionItem.conf_id then
        index = 4
      else
        index = 3
      end
    elseif data.possessionItem ~= nil and nil ~= data.possessionItem.conf_id then
      index = 1
    else
      index = 6
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.UpdateHavingPanelInfo, data, true, index)
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, data, index, true, false)
  end
end

return UMG_HavingProp_Equipment_C
