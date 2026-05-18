local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChallengePlayTabItem_C = Base:Extend("UMG_ChallengePlayTabItem_C")

function UMG_ChallengePlayTabItem_C:OnConstruct()
end

function UMG_ChallengePlayTabItem_C:OnDestruct()
end

function UMG_ChallengePlayTabItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_ChallengePlayTabItem_C:SetInfo()
  self.IconSelect:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Ordinary:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Text:SetVisibility(UE.ESlateVisibility.Visible)
  self.Text:SetText(self.data.TaskTypeName)
  if 1 == self.data.TabType then
    self.RedDot:SetupKey(368, self.data.activityId)
  elseif 2 == self.data.TabType then
    self.RedDot:SetupKey(368, self.data.activityId)
  end
  self:IsShowSandClock(false)
end

function UMG_ChallengePlayTabItem_C:IsShowSandClock(_IsShow)
  if _IsShow then
    self.SandClock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.SandClock_1 then
      self.SandClock_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.SandClock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.SandClock_1 then
      self.SandClock_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_ChallengePlayTabItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Press)
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.SelectGamePlayTabType, self.data)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_ChallengePlayTabItem_C:OnDeactive()
end

return UMG_ChallengePlayTabItem_C
