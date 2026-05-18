local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_SystemSettingMain_Item_C = Base:Extend("UMG_SystemSettingMain_Item_C")

function UMG_SystemSettingMain_Item_C:OnConstruct()
end

function UMG_SystemSettingMain_Item_C:OnDestruct()
  self:RemoveAllButtonListener()
  if self.bAddListener then
    _G.NRCEventCenter:UnRegisterEvent(self, SystemSettingModuleEvent.OpenSelectionMenu, self.OpenSelectionMenu)
  end
end

function UMG_SystemSettingMain_Item_C:OnItemUpdate(_data, datalist, index)
  self.caller = _data.caller
  self.NRCText_9:SetText(_data.Name)
  self.CloseAnnotationBtn = _data.CloseAnnotationBtn
  if not self.bAddListener then
    self:AddButtonListener(self.BtnDetails_7.btnLevelUp, self.ShowDetailsText)
    self:AddButtonListener(_data.CloseSelectionBtn, self.CloseSelection)
    self:AddButtonListener(_data.CloseAnnotationBtn, self.CloseDetailsText)
    _G.NRCEventCenter:RegisterEvent("UMG_SystemSettingMain_Item_C", self, SystemSettingModuleEvent.OpenSelectionMenu, self.OpenSelectionMenu)
    self.bAddListener = true
  end
  if _data.Annotation then
    self.BtnDetails_7:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Details_7.Title:SetText(_data.Annotation)
  else
    self.BtnDetails_7:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Details_7:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.DropDownList:InitUI(self)
  self.DropDownList:SetKeyAndOptions(_data.GroupName, _data.Options)
  self.DropDownList:SetSelectedValue(self:GetLegalLevel(_data.GroupName, _data.Level))
end

function UMG_SystemSettingMain_Item_C:OnItemSelected(_bSelected)
end

function UMG_SystemSettingMain_Item_C:OnDeactive()
end

function UMG_SystemSettingMain_Item_C:ShowDetailsText()
  _G.NRCAudioManager:PlaySound2DAuto(41401011, "UMG_SystemSettingMain_Item_C:ShowDetailsText")
  self.CloseAnnotationBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Details_7:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.bShowDetails = true
end

function UMG_SystemSettingMain_Item_C:CloseDetailsText()
  if self.bShowDetails then
    _G.NRCAudioManager:PlaySound2DAuto(41401012, "UMG_SystemSettingMain_Item_C:CloseDetailsText")
    self.CloseAnnotationBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Details_7:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bShowDetails = false
end

function UMG_SystemSettingMain_Item_C:ShowDropDownListCallback(DropDownList)
  self.caller:ShowDropDownListCallback(DropDownList)
end

function UMG_SystemSettingMain_Item_C:DisableClick()
  self.caller:DisableClick()
end

function UMG_SystemSettingMain_Item_C:OpenSelectionMenu(DropDownList)
  if DropDownList and self.DropDownList ~= DropDownList then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_SystemSettingMain_Item_C:CloseSelection()
  if self.DropDownList.IsOpenMenu then
    self.DropDownList:OnShowBtnClick()
  end
end

function UMG_SystemSettingMain_Item_C:GetLegalLevel(Name, Level)
  if not Level then
    return 0
  end
  if "EffectsQuality" == Name then
    if 2 == Level then
      return 1
    end
  elseif "ReflectionQuality" == Name then
    Level = Level >= 2 and 2 or 0
  end
  return Level
end

return UMG_SystemSettingMain_Item_C
