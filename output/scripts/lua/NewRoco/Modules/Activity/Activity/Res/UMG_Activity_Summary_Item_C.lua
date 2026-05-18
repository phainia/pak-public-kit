local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_Summary_Item_C = Base:Extend("UMG_Activity_Summary_Item_C")

function UMG_Activity_Summary_Item_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_Activity_Summary_Item_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_Summary_Item_C:SetSignStage(stage)
  local signStageText = stage
  if stage < 10 then
    signStageText = string.format("0%d", stage)
  end
  if self.SignStage_1 then
    self.SignStage_1:SetText(signStageText)
  end
  if self.SignStage then
    self.SignStage:SetText(signStageText)
  end
end

function UMG_Activity_Summary_Item_C:SetSignStageColor(color)
  if self.SignStage then
    self.SignStage:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
  end
end

function UMG_Activity_Summary_Item_C:SetRewardNum(num)
  if num then
    self:SetNumSize(num)
    self.RewardNum:SetText("x" .. num)
  else
    self.RewardNum:SetText("")
  end
end

function UMG_Activity_Summary_Item_C:SetRewardNumColor(color)
  self.RewardNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
end

function UMG_Activity_Summary_Item_C:SetReceiveState()
  if self.Maskkjk then
    self.Maskkjk:SetRenderOpacity(1)
  end
  if self.Mask then
    self.Mask:SetRenderOpacity(1)
  end
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.AlreadyReceived:SetRenderOpacity(1)
end

function UMG_Activity_Summary_Item_C:SetRewardIcon(iconPath, itemType, itemId)
  if itemType and itemType == _G.Enum.GoodsType.GT_BAGITEM and itemId then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if bagItemConf and bagItemConf.type == _G.Enum.BagItemType.BI_PET_EGG and bagItemConf.item_behavior and bagItemConf.item_behavior[1] and bagItemConf.item_behavior[1].ratio2 and bagItemConf.item_behavior[1].ratio2[1] then
      local eggInfo = {}
      eggInfo.random_egg_conf = bagItemConf.item_behavior[1].ratio2[1]
      self.IconSwitcher:SetActiveWidgetIndex(1)
      self.PetEggIcon:SetEggIcon(eggInfo, iconPath)
      return
    end
  end
  self.IconSwitcher:SetActiveWidgetIndex(0)
  self.Icon:SetPath(iconPath)
end

function UMG_Activity_Summary_Item_C:SetupRedPoint(key, extraKey)
  self.redPointReward:EnableAnimation()
  self.redPointReward:SetupKey(key, extraKey)
end

function UMG_Activity_Summary_Item_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Activity_Summary_Item_C:SetNumSize(Count)
  local number = Count
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local Font = self.RewardNum.Font
  if length > 5 then
    Font.Size = 22
    self.RewardNum:SetFont(Font)
  end
end

function UMG_Activity_Summary_Item_C:OnAnimationFinished(anim)
  Base.OnAnimationFinished(self, anim)
  if anim == self.Reward_get or anim == self.Get_loop then
    self:SetReceiveState()
  end
end

function UMG_Activity_Summary_Item_C:PlayRewardGetAnimation()
  _G.NRCAudioManager:PlaySound2DAuto(40008022, "UMG_Activity_SevenDay_C:OnItemSelected")
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Reward_get, false, 10)
end

function UMG_Activity_Summary_Item_C:PlayRewardUnAvailableAnimation()
  self:TryPlayAnimation(self.Reward_normal, false, 0)
end

function UMG_Activity_Summary_Item_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Reward_ready_loop, false, 0, true)
end

function UMG_Activity_Summary_Item_C:PlayRewardReceivedAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Get_loop)
end

return UMG_Activity_Summary_Item_C
