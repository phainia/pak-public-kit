local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Level_Tab1_C = Base:Extend("UMG_Level_Tab1_C")

function UMG_Level_Tab1_C:OnConstruct()
end

function UMG_Level_Tab1_C:OnDestruct()
end

function UMG_Level_Tab1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.TextTab:SetText(_data.ChallengeText)
  self:SetClickable(true)
  self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if _data.UnlockedState == LevelSelectionEnum.UnlockedState.locked then
    if _data.is_readed then
      self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Lock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Level_Tab1_C:PlayUnlockReadEd()
  if self.data.UnlockedState == LevelSelectionEnum.UnlockedState.locked and not self.data.is_readed then
    self:PlayAnimation(self.Unlock)
    self.data.is_readed = true
  end
end

function UMG_Level_Tab1_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.SelectLevelTab, self.data, self.index)
    if self.data.UnlockedState == LevelSelectionEnum.UnlockedState.locked then
      self:PlayAnimation(self.select)
    end
  elseif self.data.UnlockedState == LevelSelectionEnum.UnlockedState.locked then
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_Level_Tab1_C:OnAnimationFinished(Anim)
  if Anim == self.Unlock then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.ChallengeSetModuleUnlock, self.data.ActivityId, self.data.module_id)
  end
end

function UMG_Level_Tab1_C:OnDeactive()
end

return UMG_Level_Tab1_C
