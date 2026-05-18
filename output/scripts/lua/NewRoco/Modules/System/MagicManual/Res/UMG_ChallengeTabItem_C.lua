local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local ModuleData = require("NewRoco/Modules/System/MagicManual/MagicManualModuleData")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_ChallengeTabItem_C = Base:Extend("UMG_ChallengeTabItem_C")

function UMG_ChallengeTabItem_C:OnConstruct()
end

function UMG_ChallengeTabItem_C:OnDestruct()
  self:CancelAllDelay()
end

function UMG_ChallengeTabItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.IconSelect:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Text:SetVisibility(UE.ESlateVisibility.Visible)
  self.Text:SetText(self.data.TaskTypeName)
  if 1 == self.data.TabType then
    if self.data and self.data.Sort == ModuleData.ChallengeTaskType.XiShou then
      local bEnable = NRCModuleManager:DoCmd(MagicManualModuleCmd.HasDoubleTeamBattleReward)
      self:UpdateDoubleTeamBattleFlag(bEnable)
    end
  elseif 2 == self.data.TabType then
    self.RedDot:SetupKey(self.data.RedPointKey)
  end
  if self.data and self.data.Sort == ModuleData.TeachType.Restraint then
    self.RedPoint_1:SetupKey(456, {
      Enum.TeachingType.TT_TYPE_ADVANTAGE
    })
    if self.RedPoint_1:IsRed() then
      self.RedPoint:SetupKey(0)
    else
      self.RedPoint:SetupKey(436)
    end
  end
  if self.data and self.data.Sort == ModuleData.TeachType.Battle then
    self.RedPoint:SetupKey(0)
    self.RedPoint_1:SetupKey(456, {
      Enum.TeachingType.TT_COMBAT_MECHANISM
    })
  end
  self:PlayAnimation(self.Normal)
end

function UMG_ChallengeTabItem_C:UpdateDoubleTeamBattleFlag(bEnable)
  if bEnable then
    self.DoubleCanvas:SetVisibility(UE.ESlateVisibility.Visible)
    self.Double:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.DoubleCanvas:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Double:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_ChallengeTabItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Press)
    if self.data and self.data.Sort ~= ModuleData.TeachType.Restraint and self.data.Sort ~= ModuleData.TeachType.Battle then
      if 1 == self.data.TabType then
        _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.UpdateChallengeTableView, self.index, self.data.Sort, self.data.TaskTypeName)
      else
        _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.UpdateManualTab, self.index, self.data.Sort)
      end
    else
      _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.UpdateChallengeTableView, self.index, self.data.Sort, self.data.TaskTypeName)
    end
  else
    self:StopAllAnimations()
    self:PlayAnimationReverse(self.Press)
  end
end

function UMG_ChallengeTabItem_C:CancelAllDelay()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

function UMG_ChallengeTabItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self.DelayTabSelect = true
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_ChallengeTabItem_C:OnDeactive()
end

return UMG_ChallengeTabItem_C
