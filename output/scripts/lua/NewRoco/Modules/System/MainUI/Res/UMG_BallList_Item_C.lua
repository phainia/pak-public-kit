local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local UMG_BallList_Item_C = Base:Extend("UMG_BallList_Item_C")

function UMG_BallList_Item_C:OnConstruct()
  self:AddEventListener()
end

function UMG_BallList_Item_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_BallList_Item_C:AddEventListener()
  _G.NRCEventCenter:RegisterEvent(self.name, self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_BallList_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self.datalist = datalist
  self:UpdateItemInfo()
end

function UMG_BallList_Item_C:UpdateItemInfo()
  if self.uiData and self.uiData.isEmpty then
    self.CanvasPanel_41:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.CanvasPanel_41:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCImage_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SelectedAnim_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.uiData then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
    if bagItemConf and bagItemConf.type == _G.Enum.BagItemType.BI_PET_BALL then
      self.NRCImage_0:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCImage_0:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    end
    self.PetLevel:SetText(tostring(self.uiData.num))
  end
end

function UMG_BallList_Item_C:PCKeySetting(pcIndex)
  if SystemSettingModuleCmd then
    local InputAction = string.format("IA_SelectPetStart_%s", pcIndex)
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, InputAction)
    if "" ~= image then
      self.Text_PCKey:SetImageMode(image)
    else
      self.Text_PCKey:SetText(text)
    end
    self.Text_PCKey:SetKeyVisibility(true)
  end
end

function UMG_BallList_Item_C:OnItemSelected(_bSelected)
  local equipItem = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
  if self.uiData and self.uiData.gid then
    if equipItem and equipItem.gid == self.uiData.gid then
      if not _bSelected then
        if self and self.SelectedAnim_bg then
          self.SelectedAnim_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self:PlayAnimation(self.Select_out)
        end
      elseif self.SelectedAnim_bg:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        self:DealSelectItem()
      end
    elseif _bSelected then
      self:DealSelectItem()
    end
  end
end

function UMG_BallList_Item_C:DealSelectItem()
  self:StopAllAnimations()
  local itemConf = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
  if itemConf.type == _G.Enum.BagItemType.BI_PET_BALL then
    _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_BallList_Item_C:DealSelectItem")
    self.SelectedAnim_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select_In)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.SetCurEquipItemInfo, self.uiData)
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.UI_SetSimpleUseListVisible, false)
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    player:SendEvent(PlayerModuleEvent.ON_THROW_INFO_CHANGE, _G.MainUIModuleEnum.MainUIChooseType.ITEM, self.uiData)
  end
end

function UMG_BallList_Item_C:CheckIsEquipItem()
  local equipItem = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
  if equipItem and equipItem.gid == self.uiData.gid then
    return true
  end
  return false
end

function UMG_BallList_Item_C:OnAnimationFinished(Anim)
  if Anim == self.Select_In then
    self:PlayAnimation(self.Select_loop)
  elseif Anim == self.Select_loop then
    self:PlayAnimation(self.Select_loop)
  elseif Anim == self.Select_out then
    self.SelectedAnim_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_BallList_Item_C
