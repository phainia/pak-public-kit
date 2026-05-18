local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ProgressReward_C = Base:Extend("UMG_ProgressReward_C")

function UMG_ProgressReward_C:OnConstruct()
end

function UMG_ProgressReward_C:OnDestruct()
end

function UMG_ProgressReward_C:OnItemUpdate(data, datalist, index)
  self.Index = index
  local averageValue = _G.DataConfigManager:GetTaskGlobalConfig("gp_rank_list_average").num
  self.GradePoint = index * averageValue
  self.Parent = data.parent
  self.RewardId = data.rewardId
  local rewardList = _G.DataConfigManager:GetRewardConf(self.RewardId).RewardItem
  self.ItemId = rewardList[1].Id
  self.ItemType = rewardList[1].Type
  self.ItemCount = rewardList[1].Count
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.ItemId)
  self.Item:SetPath(bagItemConf.icon)
  self.Text_Day:SetText(tostring(self.GradePoint))
  if 1 == self.ItemCount then
    self.Text_Day_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Text_Day_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Text_Day_1:SetText(tostring(self.ItemCount))
  end
  self:SetItemQuality()
  local getRewardList = self.Parent.data.reward_taken
  self.IsGetReward = false
  if getRewardList and self.Index <= #getRewardList and getRewardList[self.Index] then
    self.IsGetReward = true
  end
  if self.IsGetReward then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Text_Day_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#7a7770ff"))
  else
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Day_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#f4eee1ff"))
  end
  self.CanGetReward = false
  local curGrade = 0
  if self.Parent.data.gp_num_add then
    curGrade = self.Parent.data.gp_num_add
  end
  if curGrade >= self.GradePoint then
    self.CanGetReward = true
  end
  if self.CanGetReward then
    self.Dot:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffc65fff"))
  else
    self.Dot:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#030303ff"))
  end
  self.RedDot:SetupKey(389, {
    _G.Enum.ItemLableType.ILT_TASK,
    290025,
    self.Index
  })
end

function UMG_ProgressReward_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.IsGetReward and self.CanGetReward and self.Parent.CanSelectItem then
      self.Parent:GetAddGradeReward(self.Index)
    else
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.ItemId, self.ItemType)
    end
  end
end

function UMG_ProgressReward_C:UpdateRewardState()
  self.IsGetReward = true
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_ProgressReward_C:SetItemQuality()
  if self.ItemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.ItemId)
    if vItemConf then
      self:SetQualityOpen(vItemConf.item_quality)
    end
  elseif self.ItemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.ItemId)
    if bagItemConf then
      self:SetQualityOpen(bagItemConf.item_quality)
    end
  elseif self.FinalItemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(self.ItemId)
    if cardSkinConf then
      self:SetQualityOpen(cardSkinConf.card_quality)
    end
  else
    self.QualityColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ProgressReward_C:SetQualityOpen(quality)
  self.QualityColor:SetVisibility(UE4.ESlateVisibility.Visible)
  if 1 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_ProgressReward_C
