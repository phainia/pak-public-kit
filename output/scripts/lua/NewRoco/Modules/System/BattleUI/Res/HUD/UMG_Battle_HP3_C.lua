local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_Battle_HP_C = require("NewRoco.Modules.System.BattleUI.Res.HUD.UMG_Battle_HP_C")
local UMG_Battle_HP3_C = _G.NRCPanelBase:Extend("UMG_Battle_HP3_C")
local EHPLevel = {
  Red = 1,
  Yellow = 2,
  Green = 3
}

function UMG_Battle_HP3_C:SetHP(percent, current, max)
  self.HPBar:SetPercent(percent)
  local hpText
  if current and max then
    hpText = string.format("%d/%d", current, max)
  else
    local value = UMG_Battle_HP_C.GetPercentForShow(percent)
    hpText = string.format("%d%%", value)
  end
  self.TxtHp:SetText(hpText)
  self.HPBar.WidgetStyle.FillImage.TintColor = UE4.UNRCStatics.HexToSlateColor(self:_EvaluateHpColor(self:_EvaluateHpLevel(percent)))
end

function UMG_Battle_HP3_C:SetFrozenPercent(percent)
  local bVisible = percent > 0
  self.HpBarFrozen:SetVisibility(bVisible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.HpBarFrozen_1:SetVisibility(bVisible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if bVisible then
    self.HpBarFrozen:SetPercent(percent)
    self.HpBarFrozen_1:SetPercent(percent)
  end
end

function UMG_Battle_HP3_C:_EvaluateHpLevel(percent)
  local lowConf = _G.DataConfigManager:GetBattleGlobalConfig("blood_pr_low")
  local redLimt = lowConf.numList and lowConf.numList[2] / 10000 or 0.2
  local midConf = _G.DataConfigManager:GetBattleGlobalConfig("blood_pr_middle")
  local yellowLimt = midConf.numList and midConf.numList[2] / 10000 or 0.5
  if percent <= redLimt then
    return EHPLevel.Red
  elseif percent <= yellowLimt then
    return EHPLevel.Yellow
  end
  return EHPLevel.Green
end

function UMG_Battle_HP3_C:_EvaluateHpColor(hpLevel)
  if hpLevel == EHPLevel.Red then
    return BattleConst.HpBarColor.Normal.Red
  elseif hpLevel == EHPLevel.Yellow then
    return BattleConst.HpBarColor.Normal.Yellow
  end
  return BattleConst.HpBarColor.Normal.Green
end

return UMG_Battle_HP3_C
