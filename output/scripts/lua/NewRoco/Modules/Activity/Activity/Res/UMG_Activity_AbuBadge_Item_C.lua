local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_AbuBadge_Item_C = Base:Extend("UMG_Activity_AbuBadge_Item_C")

function UMG_Activity_AbuBadge_Item_C:OnConstruct()
  Base.OnConstruct(self)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AddButtonListener(self.ButtonClick, self.OnChildItemClick)
end

function UMG_Activity_AbuBadge_Item_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
end

function UMG_Activity_AbuBadge_Item_C:OnEnter()
  self:EnableAnimations(true)
end

function UMG_Activity_AbuBadge_Item_C:OnLeave()
  self:DisableAnimations()
end

function UMG_Activity_AbuBadge_Item_C:OnItemUpdate(_data, datalist, index)
  Base.OnItemUpdate(self, _data, datalist, index)
  local itemData = _data.customData
  if not itemData then
    return
  end
  itemData:UpdateProgress()
  self:RefreshUI(itemData)
end

function UMG_Activity_AbuBadge_Item_C:RefreshUI(itemData)
  local cur, total, taskType = itemData:GetProgress()
  local taskState = itemData:GetRewardStatus()
  local playAnim = 1
  if taskType == ProtoEnum.RequiredType.ACTRT_TASK then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.Switcher:SetActiveWidgetIndex((taskState == ActivityEnum.RewardStatus.UnAvailable and 1 or 2) - 1)
    self.ListItemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ButtonClick:SetVisibility(UE4.ESlateVisibility.Collapsed)
    playAnim = taskState == ActivityEnum.RewardStatus.UnAvailable and 1 or 2
  elseif taskType == ProtoEnum.RequiredType.ACTRT_ACTIVITY_LOGIN_DAY then
    if taskState == ActivityEnum.RewardStatus.Received then
      self.Switcher:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Switcher:SetActiveWidgetIndex(2)
    else
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    playAnim = taskState == ActivityEnum.RewardStatus.Available and 2 or 1
    self.ListItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ButtonClick:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.NRCImage_0:SetVisibility(taskState == ActivityEnum.RewardStatus.UnAvailable and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.NRCImage:SetVisibility(taskState == ActivityEnum.RewardStatus.UnAvailable and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  self.Desc:SetText(string.format("%s(%d/%d)", itemData:GetRewardItemName(), cur or 0, total))
  self.QuantityText:SetText(itemData:GetRewardItemDesc())
  if 2 == playAnim then
    self:DelayPlayAnimation(self.Available, false)
  end
  local rewardGroup = itemData:GetRewardGroup()
  if rewardGroup and #rewardGroup > 0 then
    local goodsData = rewardGroup[1]
    local redKye, redExtraKey = itemData:GetRewardRedPointData()
    local Item = {
      itemId = goodsData.goods_id,
      itemType = goodsData.goods_type,
      bShowTip = true,
      itemNum = goodsData.goods_count,
      bShowNum = true,
      IsCanClick = true
    }
    self.ListItemIcon:OnItemUpdate(Item, nil, 0)
    self.redPointNew:SetupKey(redKye, redExtraKey)
  else
    self.redPointNew:SetupKey(0)
  end
end

function UMG_Activity_AbuBadge_Item_C:OnChildItemClick()
  local _itemObject = self.itemData.customData
  local status = _itemObject:GetRewardStatus()
  if status == ActivityEnum.RewardStatus.Available then
    _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_Activity_AbuBadge_Item_C:OnChildItemClick")
    if _itemObject:GetOwner():PerformActivityInteraction(ActivityEnum.ActivityInteractionType.GetReward, _itemObject) then
      self.Switcher:SetActiveWidgetIndex(2)
      self:PlayAnimationImmediately(self.Stamp, false)
    end
  else
    local rewardGroup = _itemObject:GetRewardGroup()
    if rewardGroup and #rewardGroup > 0 then
      local goodsData = rewardGroup[1]
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, goodsData.goods_id, goodsData.goods_type)
    end
  end
end

function UMG_Activity_AbuBadge_Item_C:OpItem(OpType, _rewardItemObj)
  self:RefreshUI(_rewardItemObj)
end

return UMG_Activity_AbuBadge_Item_C
