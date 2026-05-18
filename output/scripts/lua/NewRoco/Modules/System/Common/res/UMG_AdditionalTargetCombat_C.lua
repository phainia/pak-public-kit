local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_AdditionalTargetCombat_C = _G.NRCPanelBase:Extend("UMG_AdditionalTargetCombat_C")

function UMG_AdditionalTargetCombat_C:OnConstruct()
  self.WorldCombatExtraReward = nil
  self.BoxVisible = false
  self.IsReopen = false
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
end

function UMG_AdditionalTargetCombat_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_AdditionalTargetCombat_C:OnActive(_extra_reward_list)
  self.WorldCombatExtraReward = _extra_reward_list
  self.List:InitGridView(self.WorldCombatExtraReward)
  self.NumberOfRounds:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_AdditionalTargetCombat_C:ShowOrHideAdditionalTarget(_IsShow)
  if _IsShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_AdditionalTargetCombat_C:UpdatePanelInfo(_extra_reward_list, BoxVisible)
  self.BoxVisible = BoxVisible
  self.List:InitGridView(self.WorldCombatExtraReward)
  self:OnActive(_extra_reward_list)
  if self:IsAnimationPlaying(self.Out) then
    self.IsReopen = true
    self:StopAllAnimations()
    self:PlayAnimation(self.In)
  end
end

function UMG_AdditionalTargetCombat_C:SetVisibilityInfo()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_AdditionalTargetCombat_C:SetBoxVisible(BoxVisible)
  self.BoxVisible = BoxVisible
end

function UMG_AdditionalTargetCombat_C:OnDeactive()
end

function UMG_AdditionalTargetCombat_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_AdditionalTargetCombat_C", self, MainUIModuleEvent.OnBarrierHidden, self.OnBarrierHidden)
  _G.NRCEventCenter:RegisterEvent("UMG_AdditionalTargetCombat_C", self, MainUIModuleEvent.OnLobbyMainInnerOpened, self.OnLobbyMainInnerOpened)
  _G.NRCEventCenter:RegisterEvent("UMG_AdditionalTargetCombat_C", self, MainUIModuleEvent.OnLobbyMainInnerClosed, self.OnLobbyMainInnerClosed)
end

function UMG_AdditionalTargetCombat_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnBarrierHidden, self.OnBarrierHidden)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnLobbyMainInnerOpened, self.OnLobbyMainInnerOpened)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.OnLobbyMainInnerClosed, self.OnLobbyMainInnerClosed)
end

function UMG_AdditionalTargetCombat_C:OnBarrierHidden()
  if not self.BoxVisible then
    self:PlayAnimation(self.Out)
  end
end

function UMG_AdditionalTargetCombat_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    local rewards = _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetExtraRewardList)
    if not rewards then
      self:SetBoxVisible(false)
      self:OnBarrierHidden()
    end
    Log.Debug("UMG_AdditionalTargetCombat_C:OnAnimationFinished self.In", rewards)
  end
  if Anim == self.Out and not self.IsReopen then
    self:DoClose()
  end
end

function UMG_AdditionalTargetCombat_C:OnLobbyMainInnerOpened()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_AdditionalTargetCombat_C:OnLobbyMainInnerClosed()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_AdditionalTargetCombat_C
