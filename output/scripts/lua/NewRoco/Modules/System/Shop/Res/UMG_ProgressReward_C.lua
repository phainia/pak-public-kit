local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ProgressReward_C = Base:Extend("UMG_ProgressReward_C")

function UMG_ProgressReward_C:OnConstruct()
end

function UMG_ProgressReward_C:OnDestruct()
end

function UMG_ProgressReward_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if _data then
    local itemIcon = ""
    local itemQuality = 0
    local itemNum = 0
    local rewardConf = _G.DataConfigManager:GetRewardConf(_data.rewardId)
    local rewardItem = rewardConf and rewardConf.RewardItem[1]
    if rewardItem then
      itemNum = rewardItem.Count
      itemIcon, itemQuality = self:GetRewardIcon(rewardItem.Type, rewardItem.Id)
    end
    self.Text_Day:SetText(string.format(_G.LuaText.YueKa_Reward_Day, _data.needDays))
    self.ItemIcon.Icon:SetPath(itemIcon)
    self.ItemIcon.Text_Quantity:SetText("x" .. itemNum)
    self.Text_Day:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon.Icon:SetVisibility(UE4.ESlateVisibility.Visible)
    if 1 == itemQuality then
      self.ItemIcon.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
    elseif 2 == itemQuality then
      self.ItemIcon.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
    elseif 3 == itemQuality then
      self.ItemIcon.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
    elseif 4 == itemQuality then
      self.ItemIcon.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
    elseif 5 == itemQuality then
      self.ItemIcon.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
    end
  end
end

function UMG_ProgressReward_C:OnItemSelected(_bSelected)
  if _bSelected then
    local _data = self.data
    if _data then
      local rewardConf = _G.DataConfigManager:GetRewardConf(_data.rewardId)
      local rewardItem = rewardConf and rewardConf.RewardItem[1]
      if rewardItem then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, rewardItem.Id, rewardItem.Type)
      end
    end
  end
end

function UMG_ProgressReward_C:OpItem(_signDays)
  if not _signDays then
    return
  end
  local _data = self.data
  if _data then
    if _signDays >= _data.needDays then
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
      self:PlayAnimation(self.select)
    else
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_ProgressReward_C:GetRewardIcon(itemType, itemId)
  local itemIcon = ""
  local itemQuality = 0
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if vItemsConf then
      itemIcon = _G.NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath)
      itemQuality = vItemsConf.item_quality
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if bagItemConf then
      itemIcon = _G.NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath)
      itemQuality = bagItemConf.item_quality
    end
  end
  return itemIcon, itemQuality
end

function UMG_ProgressReward_C:OnAnimationFinished(anim)
end

return UMG_ProgressReward_C
