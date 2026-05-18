require("UnLuaEx")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_PetCardHp_C = NRCUmgClass:Extend("")

function UMG_Battle_PetCardHp_C:Construct()
  self.CurrentHpBar = self.hpProgressGreen
  self._startModify = 0.01
  self._endModify = 0.99
  self.currentFrozenPercentage = 0
end

function UMG_Battle_PetCardHp_C:Destruct()
  self.CurrentHpBar = nil
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_PetCardHp_C:SetHP(hpPercent)
  self:GetColor(hpPercent)
end

function UMG_Battle_PetCardHp_C:SetFrozenHp(hpPercent)
  if hpPercent > 0 then
    self.Fx_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Fx_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if hpPercent > self.currentFrozenPercentage then
    local TotalTime = self.Frozen:GetEndTime()
    self:PlayAnimationTimeRange(self.Frozen, TotalTime * self.currentFrozenPercentage, TotalTime * hpPercent)
  elseif hpPercent < self.currentFrozenPercentage then
    local TotalTime = self.ReverseFrozen:GetEndTime()
    self:PlayAnimationTimeRange(self.ReverseFrozen, TotalTime * (1 - self.currentFrozenPercentage), TotalTime * (1 - hpPercent))
  end
  self.currentFrozenPercentage = hpPercent
end

function UMG_Battle_PetCardHp_C:OnAnimationFinished(Animation)
  if self.ReverseFrozen == Animation and 0 == self.currentFrozenPercentage then
    self.Fx_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Fx_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_PetCardHp_C:GetColor(hpPercent)
  self.hpProgressRed:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.hpProgressYellow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.hpProgressGreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local hpLevelType = BattleUtils.EvaluateHpLevel(hpPercent)
  if hpLevelType == BattleEnum.HpLevelType.Red then
    self.CurrentHpBar = self.hpProgressRed
  elseif hpLevelType == BattleEnum.HpLevelType.Yellow then
    self.CurrentHpBar = self.hpProgressYellow
  else
    self.CurrentHpBar = self.hpProgressGreen
  end
  self.CurrentHpBar:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CurrentHpBar:SetPercent(hpPercent)
end

return UMG_Battle_PetCardHp_C
