local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEnum = reload("NewRoco.Modules.System.Bag.BagModuleEnum")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_Bag_Icon_C = Base:Extend("UMG_Bag_Icon_C")

function UMG_Bag_Icon_C:OnConstruct()
end

function UMG_Bag_Icon_C:OnDestruct()
end

function UMG_Bag_Icon_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.module = NRCModuleManager:GetModule("BagModule")
  self.moduleData = self.module:GetData("BagModuleData")
  if self.uiData.FromBag ~= nil and self.uiData.FromBag == false then
    self.FromBag = false
  else
    self.FromBag = true
  end
  self.showBit = nil
  self:SetInfo()
end

function UMG_Bag_Icon_C:SetInfo()
  if self.FromBag == true and self.FromBag == true then
    if self.moduleData.displayMode == BagModuleEnum.DisplayMode.BattleCatch then
      local catchData = self.moduleData:GetCurSelectedItemDataBattle()
      local curSelectInBattle = catchData and catchData.curUseBallGID == self.uiData.gid
      if curSelectInBattle then
        self.showBit = 9
        self:SetTagOrEquipIcon(true, "")
      elseif 1 == self.uiData.bag_item_flags then
        self.showBit = 8
        self:SetTagOrEquipIcon(true, "")
      elseif 8 == self.uiData.bag_item_flags then
        self.showBit = 8
        self:SetTagOrEquipIcon(true, "")
      elseif 9 == self.uiData.bag_item_flags then
        self.showBit = 8
        self:SetTagOrEquipIcon(true, "")
      else
        self.showBit = 0
        self:SetTagOrEquipIcon(false, "")
      end
    else
      local getEquipMagic = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetEquipMagicInfo)
      self.showBit = self.uiData.bag_item_flags
      if self.uiData.bag_item_flags and 1 == self.uiData.bag_item_flags & 1 or getEquipMagic and self.uiData.gid == getEquipMagic.gid then
        self:SetTagOrEquipIcon(true, "")
      else
        self:SetTagOrEquipIcon(false, "")
      end
    end
  else
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
  self.Image_Icon:SetPath(bagItemConf.icon)
end

function UMG_Bag_Icon_C:SetTagOrEquipIcon(visible, path)
  if visible then
    if 9 == self.showBit then
      self.nrc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.EquippedIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.nrc:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.EquippedIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.nrc:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.EquippedIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Bag_Icon_C:SetSelectedVisible(visible)
  if visible then
    self.NRCImage_1:SetRenderOpacity(1)
    self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.visible)
  else
    self.NRCImage_1:SetRenderOpacity(0)
    self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Bag_Icon_C:OnClick()
  _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ClearSelecteState)
  _G.NRCModuleManager:DoCmd(BagModuleCmd.SetSelectedItem, self.uiData, 0)
end

function UMG_Bag_Icon_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:SetSelectedVisible(true)
    _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_BagItemTemplate_C:OnItemSelected")
    if self.FromBag and self.FromBag == true then
      if self.uiData.IsFirstOpenPanel == false or not self:IsPlayingAnimation() then
        self:PlayAnimation(self.Select)
      end
      self:OnClick()
    else
      if not self:IsPlayingAnimation() then
        self:PlayAnimation(self.Select)
      end
      _G.NRCModuleManager:DoCmd(BagModuleCmd.SetSelectedItem, self.uiData, 1)
    end
  else
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_Bag_Icon_C:OnAnimationFinished(Anim)
end

function UMG_Bag_Icon_C:OnDeactive()
end

return UMG_Bag_Icon_C
