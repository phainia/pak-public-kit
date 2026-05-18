local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_KeySettingList_C = Base:Extend("UMG_KeySettingList_C")

function UMG_KeySettingList_C:OnConstruct()
  self.uiData = {}
  self:AddButtonListener(self.NRCButton_0, self.OnBtnClicked)
  self.NRCButton_0.OnHovered:Add(self, self._OnItemHovered)
  self.NRCButton_0.OnUnhovered:Add(self, self._OnItemUnHovered)
end

function UMG_KeySettingList_C:OnDestruct()
  self.NRCButton_0.OnHovered:Add(self, self._OnItemHovered)
  self.NRCButton_0.OnUnhovered:Add(self, self._OnItemUnHovered)
end

function UMG_KeySettingList_C:OnItemUpdate(_data, datalist, index)
  self.uiData.ButtonSettingConf = _data
  self.Index = index
  self:UpdateUI()
end

function UMG_KeySettingList_C:UpdateUI()
  if self.uiData.ButtonSettingConf == nil then
    return
  end
  if self.uiData.ButtonSettingConf.button_ischangeable then
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.clickable = true
  else
    self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.clickable = false
  end
  self.NRCText_111:SetText(self.uiData.ButtonSettingConf.button_action_name)
  local keyName, keyUIName, keyUIImage = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetButtonSettingMappingKey, self.uiData.ButtonSettingConf.id, true)
  if not string.IsNilOrEmpty(keyUIImage) then
    self.Text_Key:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.KeyBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.KeyBg:SetPath(keyUIImage)
  else
    self.Text_Key:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.KeyBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Key:SetText(keyUIName)
  end
end

function UMG_KeySettingList_C:OnBtnClicked()
  if not self.clickable then
    return
  end
  local systemSettingModule = NRCModuleManager:GetModule("SystemSettingModule")
  if systemSettingModule then
    systemSettingModule:DispatchEvent(SystemSettingModuleEvent.ClickButtonSettingListItem, self.uiData.ButtonSettingConf, self.Index)
  end
end

function UMG_KeySettingList_C:_OnItemHovered()
end

function UMG_KeySettingList_C:_OnItemUnHovered()
end

function UMG_KeySettingList_C:GetButtonSettingId()
  if self.uiData and self.uiData.ButtonSettingConf then
    return self.uiData.ButtonSettingConf.id
  end
end

function UMG_KeySettingList_C:PlayResetAnim()
  self:PlayAnimation(self.Flicker)
end

return UMG_KeySettingList_C
