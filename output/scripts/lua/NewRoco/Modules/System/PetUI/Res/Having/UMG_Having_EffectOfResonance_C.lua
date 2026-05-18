local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Having_EffectOfResonance_C = _G.NRCViewBase:Extend("UMG_Having_EffectOfResonance_C")

function UMG_Having_EffectOfResonance_C:OnConstruct()
  self:PlayAnimation(self.GongmingLoop)
  self.SelectResonanceItem = nil
  self:SetBtnInfo()
  self:OnAddEventListener()
end

function UMG_Having_EffectOfResonance_C:OnAddEventListener()
  self:AddButtonListener(self.backBtn.btnClose, self.OnClickDescend)
  self:AddButtonListener(self.NRCButton_72, self.AddHavingResonanceItem)
  self:AddButtonListener(self.Btn_0.btnLevelUp, self.ResonanceSucceed)
  self:RegisterEvent(self, PetUIModuleEvent.HavingUpgradeAndResonanceUpdateEvent, self.HavingUpgradeAndResonanceUpdate)
end

function UMG_Having_EffectOfResonance_C:OnDestruct()
end

function UMG_Having_EffectOfResonance_C:HavingUpgradeAndResonanceUpdate(_res_carryon)
  local res_carryon = _res_carryon
  if self.data then
    self.data.possessionItem.conf_id = res_carryon.conf_id
    self.data.possessionItem.level = res_carryon.level
    self.data.possessionItem.stage = res_carryon.stage
  end
  self:SetBasicInfo()
  self:SetAddItemInfo()
end

function UMG_Having_EffectOfResonance_C:OnActive(_PanelInfo)
  local PanelInfo = _PanelInfo
  if PanelInfo.IsOpen == true then
    self.OldSubPanelIndex = PanelInfo.OldSubPanelIndex
  end
  if true == PanelInfo.IsFiIterHaving then
    self.SelectResonanceItem = _PanelInfo.data
  else
    self.SelectResonanceItem = nil
  end
  self.ConsumeMoney = nil
  self:SetBasicInfo()
  self:SetAddItemInfo()
end

function UMG_Having_EffectOfResonance_C:OnHavingChange(_data)
  self.data = _data
end

function UMG_Having_EffectOfResonance_C:SetBasicInfo()
  local data = self.data
  local OldResonance = PetUtils.GetHavingSkillPropertyByPossession(data.possessionItem)
  local NewOldResonance
  if self.SelectResonanceItem then
    local NewAddStage = self.SelectResonanceItem.selectData.bagItem.stage or 0
    NewOldResonance = PetUtils.GetHavingSkillPropertyByPossession(data.possessionItem, NewAddStage + 1, true)
  else
    NewOldResonance = PetUtils.GetHavingSkillPropertyByPossession(data.possessionItem, 1)
    if nil ~= NewOldResonance and NewOldResonance.SkillConf then
      self.Prompt:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Btn_0:SetVisibility(UE4.ESlateVisibility.Visible)
      self.UpperLimit:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasAfterResonance:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Title_1:SetText(LuaText.umg_having_effectofresonance_1)
    else
      self.Prompt:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.Btn_0:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.UpperLimit:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CanvasAfterResonance:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Title_1:SetText(LuaText.umg_having_effectofresonance_2)
    end
  end
  self.Having_EffectOfResonance_List:SetInfo(OldResonance)
  self.UMG_Having_EffectOfResonance_List_1:SetInfo(NewOldResonance)
end

function UMG_Having_EffectOfResonance_C:SetAddItemInfo()
  if self.SelectResonanceItem then
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    local bagItemConf = self.SelectResonanceItem.selectData.bagItemConf
    local stage = self.SelectResonanceItem.selectData.bagItem.stage
    if stage and stage > 0 then
      self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NumText:SetText(stage)
    end
    self.Plus:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ItemIcon:SetPath(bagItemConf.icon)
    self:SetQuality(bagItemConf.item_quality)
  else
    self:SetQuality(1)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Plus:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Having_EffectOfResonance_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_Having_EffectOfResonance_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_Having_EffectOfResonance_C:AddHavingResonanceItem()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, 3, true, false, true)
end

function UMG_Having_EffectOfResonance_C:OnClickDescend()
  if self.OldSubPanelIndex then
    self.SelectResonanceItem = nil
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, self.OldSubPanelIndex, false, false)
  end
end

function UMG_Having_EffectOfResonance_C:ResonanceSucceed()
  local data = self.data
  if self.SelectResonanceItem then
    local PetIsEquipmentHaving
    if data.possessionItem.gid then
      PetIsEquipmentHaving = false
    else
      PetIsEquipmentHaving = true
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.HavingResonance, data.petData.gid, data.pos - 1, PetIsEquipmentHaving, data.possessionItem.gid, self.SelectResonanceItem.selectData.bagItem.gid, data.possessionItem.conf_id, self.SelectResonanceItem.selectData.bagItem.id)
    self.SelectResonanceItem = nil
    self.module:DispatchEvent(PetUIModuleEvent.PET_ResonanceSucceed)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_having_effectofresonance_3)
  end
end

function UMG_Having_EffectOfResonance_C:OnAnimationFinished(Animation)
  if Animation == self.GongmingLoop then
    self:PlayAnimation(self.GongmingLoop)
  end
end

function UMG_Having_EffectOfResonance_C:SetBtnInfo()
  self.Btn_0:SetBtnText(LuaText.umg_having_effectofresonance_4)
end

return UMG_Having_EffectOfResonance_C
