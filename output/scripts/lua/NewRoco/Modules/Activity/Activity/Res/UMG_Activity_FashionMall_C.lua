local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_FashionMall_C = Base:Extend("UMG_Activity_FashionMall_C")

function UMG_Activity_FashionMall_C:OnConstruct()
  Base.OnConstruct(self)
  self.uiData = {}
  self.ShowingFashionPackageIndex = 0
  self:AddButtonListener(self.ViewBtn.btnLevelUp, self.OnPressViewButton)
  self:AddButtonListener(self.GorgeousMagicBtn, self.OnClickedGorgeousMagicBtn)
end

function UMG_Activity_FashionMall_C:OnDestruct()
  Base.OnDestruct(self)
  self.NRCGridView_46:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_FashionMall_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:OnAddEventListener()
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.EraseFashionPackageShopRedPoint)
  self:UpdateUI()
end

function UMG_Activity_FashionMall_C:OnDisable()
  self.NeeItemSelectedAudio = false
  self:OnRemoveEventListener()
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SwitchGorgeousMagicUMG, false)
end

function UMG_Activity_FashionMall_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_FashionMall_C:OnAddEventListener()
  self:RegisterEvent(self, ActivityModuleEvent.UpdateShowingFashionPackage, self.OnShowingFashionPackageUpdated)
end

function UMG_Activity_FashionMall_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.UpdateShowingFashionPackage)
end

function UMG_Activity_FashionMall_C:OnShowingFashionPackageUpdated(Index)
  if self.NeeItemSelectedAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagItemTemplate_C:OnItemSelected")
  else
    self.NeeItemSelectedAudio = true
  end
  self.ShowingFashionPackageIndex = Index
  self:UpdateShowingInfo()
end

function UMG_Activity_FashionMall_C:OnPressViewButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_FashionMall_C:OnPressViewButton")
  local _activityInst = self.activityInst
  if nil == _activityInst then
    return
  end
  if nil == self.ShowingFashionPackageIndex or nil == self.itemDataArray then
    return
  end
  local itemData = self.itemDataArray[self.ShowingFashionPackageIndex]
  if nil == itemData then
    return
  end
  local handled = _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Auto, _G.AppearanceModuleEnum.FashionMallShopId.SEASONAL_COMBINATION_BAG, itemData.FashionPackageId)
end

function UMG_Activity_FashionMall_C:OnClickedGorgeousMagicBtn()
  local fashionPackageId = self:GetFashionPackageId()
  if fashionPackageId then
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenMagicVideoDetailsPanel, Enum.GoodsType.GT_FASHION_PACKAGE, fashionPackageId)
  end
end

function UMG_Activity_FashionMall_C:GetFashionPackageId()
  local itemData = self.ShowingFashionPackageIndex and self.itemDataArray and self.itemDataArray[self.ShowingFashionPackageIndex]
  if itemData then
    return itemData.FashionPackageId
  end
end

function UMG_Activity_FashionMall_C:FindMinSGSuitId()
  local itemData = self.ShowingFashionPackageIndex and self.itemDataArray and self.itemDataArray[self.ShowingFashionPackageIndex]
  if itemData then
    local minSGSutiId = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.FindMinSGSuitId, itemData.FashionPackageId)
    return minSGSutiId
  end
end

function UMG_Activity_FashionMall_C:UpdateGorgeousMagicBtnVisible()
  self.GorgeousMagicBtn:SetVisibility(self:FindMinSGSuitId() and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_FashionMall_C:RefreshPanel()
  self:UpdateShowingInfo()
end

function UMG_Activity_FashionMall_C:UpdateShowingInfo()
  if self.ShowingFashionPackageIndex == nil or nil == self.itemDataArray then
    return
  end
  local itemData = self.itemDataArray[self.ShowingFashionPackageIndex]
  if nil == itemData then
    return
  end
  local fashionPackageConf = _G.DataConfigManager:GetFashionPackageConf(itemData.FashionPackageId, true)
  if fashionPackageConf then
    self.Bg:SetPath(fashionPackageConf.kv_activity)
    if self.TitleImage and fashionPackageConf.kv_activity_title then
      self.TitleImage:SetPath(fashionPackageConf.kv_activity_title)
    end
  end
  self:UpdateGorgeousMagicBtnVisible()
end

function UMG_Activity_FashionMall_C:UpdateUI()
  if self.activityInst == nil then
    return
  end
  local activityId = self.activityInst:GetActivityId()
  local baseId = self.activityInst:GetPartIds()
  local activityPikaConf = DataConfigManager:GetActivityPikaConf(baseId[1])
  if nil == activityPikaConf then
    return
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil == localPlayer then
    return
  end
  local playerGender = localPlayer.gender
  local itemDataArray = {}
  for idx, genderPackage in ipairs(activityPikaConf.kv_path) do
    if playerGender == genderPackage.gender then
      for idx1, packageId in ipairs(genderPackage.package_id1) do
        local fashionPackageConf = _G.DataConfigManager:GetFashionPackageConf(packageId, true)
        if fashionPackageConf and fashionPackageConf.gender == playerGender then
          table.insert(itemDataArray, {ActivityId = activityId, FashionPackageId = packageId})
        end
      end
    end
  end
  self.NRCGridView_46:InitGridView(itemDataArray)
  self.itemDataArray = itemDataArray
  if #itemDataArray > 0 then
    self.NRCGridView_46:SelectItemByIndex(0)
    if 1 == #itemDataArray then
      self.NRCGridView_46:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.NRCGridView_46:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

return UMG_Activity_FashionMall_C
