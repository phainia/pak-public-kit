local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Activity_ServerActivationOutfit_Item_C = Base:Extend("UMG_Activity_ServerActivationOutfit_Item_C")

function UMG_Activity_ServerActivationOutfit_Item_C:OnConstruct()
  self.SearchButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_ServerActivationOutfit_Item_C:OnDestruct()
end

function UMG_Activity_ServerActivationOutfit_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if not _data then
    Log.Error("UMG_Activity_FashionAward_Item_C:OnItemUpdate _data is nil")
    return
  end
  self.rewardInfo = nil
  if _data.conf and _data.conf.condition_group and _data.conf.condition_group[1] then
    self.ProgressText:SetText(_data.conf.condition_group[1].condition_param or index)
  end
  local rewards = _data:GetRewardGroup()
  if rewards and #rewards > 0 then
    self.rewardInfo = rewards[1]
    UIUtils.SetItemIcon(rewards[1].goods_id, rewards[1].goods_type, rewards[1].goods_count, self.ImageIcon)
  end
  self.TitleText:SetText(_data:GetRewardItemName() or "")
  self.Completed:SetVisibility(2 == _data.status and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.redPointNew:SetVisibility(1 == _data.status and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.redPointNew.RedPointNode:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:TryPlayAnimation()
  self.lastState = self.data and self.data.status or 0
end

function UMG_Activity_ServerActivationOutfit_Item_C:TryPlayAnimation()
  if self.data and self.data.status then
    if 1 == self.data.status then
      self:PlayAnimation(self.Reward_ready_loop)
    elseif 2 == self.data.status then
      if 1 == self.lastState then
        _G.NRCAudioManager:PlaySound2DAuto(40006010, "UMG_Activity_ServerActivationOutfit_Item_C:TryPlayAnimation")
        self:PlayAnimation(self.Reward_get)
      else
        self:PlayAnimation(self.Get)
      end
    elseif 0 == self.data.status then
      self:PlayAnimation(self.Reward_normal)
    end
  end
end

function UMG_Activity_ServerActivationOutfit_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self._data then
      local rewardStatus = self.data:GetRewardStatus()
      if rewardStatus == ActivityEnum.RewardStatus.Available then
        _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_ServerActivationOutfit_Item_C:OnItemSelected")
        local parentCustomData = self:GetParentCustomData()
        if parentCustomData then
          parentCustomData:OnTryGetLoginPartReward(self.data)
        end
      else
        _G.NRCAudioManager:PlaySound2DAuto(40001002, "UMG_Activity_ServerActivationOutfit_Item_C:OnItemSelected")
        if self.rewardInfo then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.rewardInfo.goods_id, self.rewardInfo.goods_type)
        end
      end
    end
  else
    self:StopAllAnimations()
    self:TryPlayAnimation()
  end
end

function UMG_Activity_ServerActivationOutfit_Item_C:OnAnimationFinished(Anim)
  if Anim == self.Reward_ready_loop then
    self:PlayAnimation(self.Reward_ready_loop)
  end
end

function UMG_Activity_ServerActivationOutfit_Item_C:OnDeactive()
end

return UMG_Activity_ServerActivationOutfit_Item_C
