local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_WebSitesTemplate_C = Base:Extend("UMG_Activity_WebSitesTemplate_C")

function UMG_Activity_WebSitesTemplate_C:OnConstruct()
  Base.OnConstruct(self)
  if not self.uiElements.itemList then
    self:LogError("itemList cannot be nil!")
  end
  self:RegisterEvent(self, ActivityModuleEvent.RefreshActiveWebSiteItems, self.RefreshWebSiteItems)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshWebSiteItemLeftTime, self.OnWebSiteItemLeftTimeChange)
  self:RegisterEvent(self, ActivityModuleEvent.WebSiteItemStatusChange, self.OnWebSiteItemStatusChange)
  self:RefreshWebSiteItems(self.activityInst)
end

function UMG_Activity_WebSitesTemplate_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshActiveWebSiteItems)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshWebSiteItemLeftTime)
  self:UnRegisterEvent(self, ActivityModuleEvent.WebSiteItemStatusChange)
end

function UMG_Activity_WebSitesTemplate_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if self.activeItems then
    for _index, _ in ipairs(self.activeItems) do
      local itemInst = self:GetItemByIndex(_index)
      if itemInst then
        itemInst:OnEnable(firstLoad)
      end
    end
  end
end

function UMG_Activity_WebSitesTemplate_C:OnDisable()
  Base.OnDisable(self)
  if self.activeItems then
    for _index, _ in ipairs(self.activeItems) do
      local itemInst = self:GetItemByIndex(_index)
      if itemInst then
        itemInst:OnDisable()
      end
    end
  end
end

function UMG_Activity_WebSitesTemplate_C:GetItemByIndex(itemIndex)
  if itemIndex and itemIndex > 0 then
    if self.itemCaches == nil then
      self.itemCaches = _G.MakeWeakTable({}, "v")
    end
    if not self.itemCaches[itemIndex] then
      self.itemCaches[itemIndex] = self.uiElements.itemList:GetItemByIndex(itemIndex - 1)
    end
    return self.itemCaches[itemIndex]
  end
end

function UMG_Activity_WebSitesTemplate_C:GetItemByObj(_webSiteItemObj)
  local itemIndex = self.uiElements.itemList:GetIndexByData(_webSiteItemObj, function(_data, _valueInList)
    return _valueInList and _valueInList.customData == _data
  end)
  return self:GetItemByIndex(itemIndex)
end

function UMG_Activity_WebSitesTemplate_C:RefreshWebSiteItems(_activityInst)
  if _activityInst and _activityInst == self.activityInst then
    self.itemCaches = {}
    self.activeItems = _activityInst:GetActiveWebSiteItems(true)
    local itemList = self.uiElements.itemList
    ActivityUtils.AdjustCtrlAutoSize(itemList, #self.activeItems < 4)
    if itemList.InitList then
      itemList:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, self.activeItems))
    elseif itemList.InitGridView then
      itemList:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, self.activeItems))
    end
  end
end

function UMG_Activity_WebSitesTemplate_C:OnWebSiteItemLeftTimeChange(_activityInst, _webSiteItemObj, _leftSeconds)
  if _activityInst and _activityInst == self.activityInst then
    local itemInst = self:GetItemByObj(_webSiteItemObj)
    if itemInst then
      itemInst:RefreshView()
    end
  end
end

function UMG_Activity_WebSitesTemplate_C:OnWebSiteItemStatusChange(_activityInst, _webSiteItemObj, _userOperation)
  if _activityInst and _activityInst == self.activityInst then
    local itemInst = self:GetItemByObj(_webSiteItemObj)
    if itemInst then
      itemInst:RefreshView()
    end
    if _userOperation and _webSiteItemObj:GetRewardStatus() == ActivityEnum.RewardStatus.Received then
      ActivityUtils.ShowRewardGetTips(_webSiteItemObj:GetRewardID())
      if itemInst and itemInst.PlayRewardGetAnimation then
        itemInst:PlayRewardGetAnimation()
      end
    end
  end
end

function UMG_Activity_WebSitesTemplate_C:OnItemSelected(_itemInst, _index, _itemObject, _bSelected)
  if _bSelected and _itemObject then
    ActivityUtils.ShowRewardTips(_itemObject:GetRewardID())
  end
end

function UMG_Activity_WebSitesTemplate_C:DoJoinActivityOrClaimReward(_itemInst, _index, _itemObject)
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_WebSitesTemplate_C:DoJoinActivityOrClaimReward")
  if _itemObject then
    local _activityInst = self.activityInst
    if _activityInst then
      if _itemObject:GetRewardStatus() == ActivityEnum.RewardStatus.Received and _itemObject:RecoverOptionIfRewardGet() then
        return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Join, _itemObject)
      end
      return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Auto, _itemObject)
    end
  end
  return false
end

return UMG_Activity_WebSitesTemplate_C
