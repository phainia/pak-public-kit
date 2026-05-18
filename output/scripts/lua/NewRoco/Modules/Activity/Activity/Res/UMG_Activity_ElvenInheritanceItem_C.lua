local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_ElvenInheritanceItem_C = Base:Extend("UMG_Activity_ElvenInheritanceItem_C")

function UMG_Activity_ElvenInheritanceItem_C:OnConstruct()
  Base.OnConstruct(self)
  self.SearchButton.OnClicked:Add(self, self.OnClickSearchButton)
end

function UMG_Activity_ElvenInheritanceItem_C:OnDestruct()
  Base.OnDestruct(self)
  self.SearchButton.OnClicked:Clear()
end

function UMG_Activity_ElvenInheritanceItem_C:OnEnter()
  self:EnableAnimations(true)
  self:PlayInAnimation()
end

function UMG_Activity_ElvenInheritanceItem_C:OnLeave()
  self:DisableAnimations()
end

function UMG_Activity_ElvenInheritanceItem_C:OnClickSearchButton()
  self:InvokeParentFunc("OnClickSearchButton")
end

function UMG_Activity_ElvenInheritanceItem_C:SetTitle(titleText)
  self.TitleText:SetText(titleText)
end

function UMG_Activity_ElvenInheritanceItem_C:SetDescribe(describeText)
  self.Text_Describe:SetText(describeText)
  if self.Text_Describe_Select then
    self.Text_Describe_Select:SetText(describeText)
  end
end

function UMG_Activity_ElvenInheritanceItem_C:SetProgress(cur, max)
  self.ProgressText:SetText(string.format("%d/%d", cur, max))
  if 0 ~= max then
    self.TaskProgress:SetPercent(cur / max)
  else
    self.TaskProgress:SetPercent(0)
  end
end

function UMG_Activity_ElvenInheritanceItem_C:SetButtonState(index, btnText)
  self.BtnSwitcher:SetActiveWidgetIndex(index)
  if 0 == index then
    self.UnderwayText:SetText(btnText)
  elseif 1 == index then
    self.SelectText:SetText(btnText)
  elseif 2 == index then
    self.ChangeText:SetText(btnText)
  end
end

function UMG_Activity_ElvenInheritanceItem_C:SetPetIcon(PetBaseId, mutation_type, glass_info)
  if not PetBaseId then
    self.UnderwayImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SearchButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.UnderwayImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_5:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SearchButton:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon_5:SetIconPathAndMaterial(PetBaseId, mutation_type, glass_info, true)
  end
end

function UMG_Activity_ElvenInheritanceItem_C:SetupRedPoint(key, extraKey)
  self.redPointNew:SetupKey(key, extraKey)
end

function UMG_Activity_ElvenInheritanceItem_C:PlayInAnimation()
  self:DelayPlayAnimation(self.In, false)
end

function UMG_Activity_ElvenInheritanceItem_C:PlayRewardGetAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Reward_get, false, 10)
end

function UMG_Activity_ElvenInheritanceItem_C:PlayRewardUnAvailableAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Reward_normal, false, 0)
end

function UMG_Activity_ElvenInheritanceItem_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Reward_ready_loop, false, 0, true)
end

function UMG_Activity_ElvenInheritanceItem_C:PlayRewardReceivedAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Get)
end

function UMG_Activity_ElvenInheritanceItem_C:PlaySelectAnimation(_bSelected)
  self:TryPlayAnimation(self.select, not _bSelected, 0)
end

return UMG_Activity_ElvenInheritanceItem_C
