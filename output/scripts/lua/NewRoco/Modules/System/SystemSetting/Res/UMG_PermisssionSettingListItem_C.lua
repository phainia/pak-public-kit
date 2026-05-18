local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_PermissionSettingListItem_C = Base:Extend("UMG_PermissionSettingListItem_C")

function UMG_PermissionSettingListItem_C:OnConstruct()
  local singleCheckData = {}
  singleCheckData.Name = LuaText.privacy_setting_40
  singleCheckData.Value = 0
  singleCheckData.OnItemSelectedCallbackOwner = self
  singleCheckData.OnItemSelectedCallback = self.OnItemClickChecked
  singleCheckData.OnClickAnimationStartCallbackOwner = self
  singleCheckData.OnClickAnimationStartCallback = self.OnClickAnimationStartCallback
  singleCheckData.OnClickAnimationFinishCallbackOwner = self
  singleCheckData.OnClickAnimationFinishCallback = self.OnClickAnimationFinishCallback
  self.singleCheckData = singleCheckData
  self.Allow:InitGridView({singleCheckData})
  self:AddButtonListener(self.BtnDetails.btnLevelUp, self.OnBtnDetailClick)
end

function UMG_PermissionSettingListItem_C:OnDestruct()
  self:RemoveButtonListener(self.BtnDetails)
end

function UMG_PermissionSettingListItem_C:CloseDetailTips()
  _G.NRCAudioManager:PlaySound2DAuto(41401012, "UMG_PermissionSettingListItem_C:CloseDetailTips")
  if self.data then
    if self.data.DetailTipsContent then
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
      self.DetailTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.DetailTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DetailTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PermissionSettingListItem_C:OnClickAnimationStartCallback()
  Log.Info("UMG_PermissionSettingList_C:OnClickAnimationStartCallback")
  self.Allow:SetItemClickAble(false)
end

function UMG_PermissionSettingListItem_C:OnClickAnimationFinishCallback()
  Log.Info("UMG_PermissionSettingList_C:OnClickAnimationFinishCallback")
  self.Allow:SetItemClickAble(true)
end

function UMG_PermissionSettingListItem_C:OnItemClickChecked(checkData, bChecked)
  self.data.IsToggled = bChecked
  if self.data and self.data.OnItemClickChecked then
    self.data.OnItemClickChecked(self.data.OnItemClickCheckedOwner, self.data, bChecked)
  end
end

function UMG_PermissionSettingListItem_C:OnItemUpdate(data, dataList, index)
  self.data = data
  if self.data.DetailTipsContent then
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DetailTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DetailTips.Title:SetText(self.data.DetailTipsContent)
  else
    self.BtnDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DetailTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Function:SetText(self.data.Name)
  self.singleCheckData.Value = self.data.IsToggled and 1 or 0
  self.Allow:InitGridView({
    self.singleCheckData
  })
end

function UMG_PermissionSettingListItem_C:OnBtnDetailClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401011, "UMG_PermissionSettingListItem_C:OnBtnDetailClick")
  self.BtnDetails:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.DetailTips:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if self.data.OnBtnDetailClicked then
    if self.data.OnBtnDetailClickedOwner then
      self.data.OnBtnDetailClicked(self.data.OnBtnDetailClickedOwner)
    else
      self.data.OnBtnDetailClicked()
    end
  end
end

return UMG_PermissionSettingListItem_C
