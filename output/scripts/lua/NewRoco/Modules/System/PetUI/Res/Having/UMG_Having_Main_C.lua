local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Having_Main_C = _G.NRCViewBase:Extend("UMG_Having_Main_C")

function UMG_Having_Main_C:OnConstruct()
  self:SetChildViews(self.Having_Equipment, self.Having_Attribute, self.Having_ItemProperties, self.Having_PropertyOfEquipment, self.Having_EquipmentSkills, self.Having_EffectOfResonance)
  self.subPanels = {
    self.Having_Attribute,
    self.Having_ItemProperties,
    self.Having_PropertyOfEquipment,
    self.Having_EquipmentSkills,
    self.Having_EffectOfResonance,
    self.Having_Nothing
  }
  self.curSubPanelIndex = 6
  self.CurrentSelectHavingIndex = 0
  self.uiData = {}
  self.PropertyandEffect = nil
  self:OnAddEventListener()
end

function UMG_Having_Main_C:OnDestruct()
  table.clear(self.uiData)
  self:UnRegisterEvent(self, PetUIModuleEvent.HAVING_EQUIPLEFT)
  self:UnRegisterEvent(self, PetUIModuleEvent.HAVING_EQUIPRIGHT)
end

function UMG_Having_Main_C:OnActive()
end

function UMG_Having_Main_C:OnDeactive()
  self:StopAllAnimations()
end

function UMG_Having_Main_C:OnAddEventListener()
  self:AddButtonListener(self.BtnSwich, self.OnClickBtnSwich)
  self:RegisterEvent(self, PetUIModuleEvent.OnClickSwitchPanelByIndexEvent, self.SetSelectIndexPanel)
  self:RegisterEvent(self, PetUIModuleEvent.UpdateHavingPanelInfoEvent, self.OnHavingChange)
  self:RegisterEvent(self, PetUIModuleEvent.HavingUpdataUpgradeandResonancePanelInfo, self.UpdateChangePanelInfo)
  self:RegisterEvent(self, PetUIModuleEvent.AUTO_SUPPLY_CARRYON, self.OnAutoSupplyChangeSuccess)
  self:RegisterEvent(self, PetUIModuleEvent.HAVING_EQUIPLEFT, self.PLaySetEquipLeft)
  self:RegisterEvent(self, PetUIModuleEvent.HAVING_EQUIPRIGHT, self.PLaySetEquipRight)
end

function UMG_Having_Main_C:PLaySetEquipLeft()
  self:PlayAnimation(self.SetEquipLeft)
end

function UMG_Having_Main_C:PLaySetEquipRight()
  self:PlayAnimationReverse(self.SetEquipLeft)
end

function UMG_Having_Main_C:SetSubPanelVisible(_index, _data)
  for panelIndex, subPanel in pairs(self.subPanels) do
    if subPanel then
      if _index == panelIndex then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
        subPanel:OnActive(_data)
        self:PlayAnimation(self.Chuchang)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
  if 1 == _index then
    self.BtnSwich:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BtnSwich:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:SetThumbDetail(_index)
end

function UMG_Having_Main_C:SetThumbDetail(_index)
  if 6 == _index or 1 == _index then
    self.module:DispatchEvent(PetUIModuleEvent.SetAttributeState, false)
  else
    self.module:DispatchEvent(PetUIModuleEvent.SetAttributeState, true)
  end
end

function UMG_Having_Main_C:OnPanelStateChange(_isShow)
  self.uiData.isPanelShow = _isShow
  if _isShow then
    if self.uiData.petData ~= nil then
      self.uiData.petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.petData.gid)
    end
    self:UpdateRightInfo(self.uiData.petData)
    self.Having_Equipment:SetSelectHaving(0)
    self.Having_Equipment:SetCurrentSelectIndex(self.curSubPanelIndex)
    self.Having_Equipment:SetHavingPosition()
    self:ShowPanel()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetSwich(self.uiData.petData.possession.auto_supply)
    _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
    self:PlayAniEx(self.open)
  else
    self:DispatchEvent(PetUIModuleEvent.Hide_CloseBtn, true)
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Having_Main_C:OnAutoSupplyChangeSuccess(_changes)
  local flag = self.uiData.petData.possession.auto_supply
  self:SetSwich(flag)
end

function UMG_Having_Main_C:SetSwich(flag)
  if true == flag then
    self.NRCSwitcher_p:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_p:SetActiveWidgetIndex(0)
  end
end

function UMG_Having_Main_C:SetSelectIndexPanel(_data, _Index, _IsOpen, _IsUpdate, _IsFiIterHaving)
  local HavingInfo = {}
  HavingInfo.OldSubPanelIndex = self.curSubPanelIndex
  HavingInfo.IsOpen = _IsOpen
  HavingInfo.IsFiIterHaving = _IsFiIterHaving
  if true == _IsUpdate then
    self:UpdateChangePanelInfo(_data)
  end
  HavingInfo.data = _data
  self.curSubPanelIndex = _Index
  if 6 == self.curSubPanelIndex then
    local IsEquipHavingAward = PetUtils.PetIsEquipmentHaving(_data.petData)
    if true == IsEquipHavingAward then
      self.curSubPanelIndex = 1
    else
      self.Having_Equipment:SetSelectHaving(0)
      self.Having_Equipment:SetCurrentSelectIndex(self.curSubPanelIndex)
      self.Having_Equipment:OnActive(_data.petData)
    end
  end
  self:UpdateMainCloseBtnState()
  if 1 == self.curSubPanelIndex then
    local Info = {}
    Info.petData = self.uiData.petData
    self.Having_Equipment:SetSelectHaving(0)
    self.Having_Equipment:SetCurrentSelectIndex(self.curSubPanelIndex)
    self.Having_Equipment:OnActive(_data.petData)
    self:SetSubPanelVisible(self.curSubPanelIndex, Info)
  else
    self:SetSubPanelVisible(self.curSubPanelIndex, HavingInfo)
    self.Having_Equipment:SetCurrentSelectIndex(self.curSubPanelIndex)
  end
end

function UMG_Having_Main_C:OnHavingChange(_data, _IsUpdata, _Index)
  local data = _data
  if true == _IsUpdata then
    if data.IsSelect == false then
      self.Having_Equipment:SetSelectHaving(data.pos)
      self.Having_Equipment:SetCurrentSelectIndex(_Index)
    else
      self.Having_Equipment:SetSelectHaving(0)
      self.Having_Equipment:SetCurrentSelectIndex(_Index)
    end
  end
  self.Having_Equipment:OnActive(_data.petData)
  self.Having_EquipmentSkills:OnHavingChange(data, _IsUpdata)
  self.Having_PropertyOfEquipment:OnHavingChange(data, _IsUpdata)
  self.Having_ItemProperties:OnHavingChange(data, _IsUpdata)
  self.Having_EffectOfResonance:OnHavingChange(data, _IsUpdata)
  self.CurrentSelectHavingIndex = _data.pos
end

function UMG_Having_Main_C:UpdateChangePanelInfo(_data)
  local data = _data
  self.Having_ItemProperties:OnHavingChange(data)
  self.Having_EffectOfResonance:OnHavingChange(data)
end

function UMG_Having_Main_C:ShowPanel()
  if self.uiData.isPanelShow then
    self.Having_Equipment:OnActive(self.uiData.petData)
  end
end

function UMG_Having_Main_C:UpdateRightInfo(_petData)
  local HavingInfo = {}
  local petData = _petData
  local IsEquipHavingAward = PetUtils.PetIsEquipmentHaving(petData)
  if true == IsEquipHavingAward then
    self.curSubPanelIndex = 1
  else
    self.curSubPanelIndex = 6
    self:UpdateMainCloseBtnState()
  end
  HavingInfo.petData = petData
  self:SetSubPanelVisible(self.curSubPanelIndex, HavingInfo)
end

function UMG_Having_Main_C:UpdateMainCloseBtnState()
  if 1 == self.curSubPanelIndex or 6 == self.curSubPanelIndex then
    self:DispatchEvent(PetUIModuleEvent.Hide_CloseBtn, true)
  end
end

function UMG_Having_Main_C:updatePetInfo(_petData, _petBaseConf)
  local IsEquipHavingAward = PetUtils.PetIsEquipmentHaving(_petData)
  local IsChangeData = true
  if self.uiData.isPanelShow == true and (self.uiData.petData ~= nil and self.uiData.petData.gid ~= _petData.gid or false == IsEquipHavingAward) then
    self:UpdateRightInfo(_petData)
    self.Having_Equipment:SetSelectHaving(0)
    self.Having_Equipment:SetCurrentSelectIndex(self.curSubPanelIndex)
    if self.uiData.petData ~= nil and self.uiData.petData.gid ~= _petData.gid then
      self.Having_Equipment:SetHavingPosition()
      self:PlayAnimation(self.open)
    end
    IsChangeData = false
  else
  end
  self.uiData.petData = _petData
  self.uiData.petBaseConf = _petBaseConf
  self:SetSwich(self.uiData.petData.possession.auto_supply)
  self:ShowPanel()
  if IsChangeData and self.CurrentSelectHavingIndex > 0 and self.CurrentSelectHavingIndex <= 3 then
    local data = self.Having_Equipment:GetDatas()
    self:OnHavingChange(data[self.CurrentSelectHavingIndex], false)
  end
end

function UMG_Having_Main_C:OnClickBtnSwich()
  local flag = self.uiData.petData.possession.auto_supply
  if nil == flag then
    flag = false
  end
  if true == flag then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_HavingAward_C:BtnSwichClick1")
    flag = false
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_HavingAward_C:BtnSwichClick2")
    flag = true
    self:PlayAnimation(self.OpenYinc)
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.AutoSupplyCarryon, self.uiData.petData.gid, flag)
end

function UMG_Having_Main_C:OnAnimationFinished(anim)
  if anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_Having_Main_C:PlayAniEx(_ani)
  if _ani then
    self:PlayAnimation(_ani)
  end
end

return UMG_Having_Main_C
