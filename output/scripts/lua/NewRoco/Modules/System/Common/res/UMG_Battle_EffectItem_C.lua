local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Battle_EffectItem_C = _G.NRCPanelBase:Extend("UMG_Battle_EffectItem_C")

function UMG_Battle_EffectItem_C:Show(skill, enemyPet)
  local restraintResult = skill:GetRestraintByPetId(enemyPet.guid)
  local damageText = skill:GetDamageByPetId(enemyPet.guid)
  if damageText > skill.config.dam_para[1] then
    damageText = "<green>" .. tostring(damageText) .. "</>"
  elseif damageText < skill.config.dam_para[1] then
    damageText = "<red>" .. tostring(damageText) .. "</>"
  else
    damageText = "<normal_0>" .. tostring(damageText) .. "</>"
  end
  if restraintResult == BattleEnum.TypeRestraint.ENUM_NORMAL then
    self.EffectSwitcher:SetActiveWidgetIndex(1)
    self.EffectCommonText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectCommon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectCommon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_RESTRAINT then
    self.EffectSwitcher:SetActiveWidgetIndex(0)
    self.EffectGodText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectGod:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectGod:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_RESTRAINT_DOUBLE then
    self.EffectSwitcher:SetActiveWidgetIndex(3)
    self.EffectGodText_1:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectGod_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectGod_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_WEAK then
    self.EffectSwitcher:SetActiveWidgetIndex(2)
    self.EffectBadText:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectBad:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectBad:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif restraintResult == BattleEnum.TypeRestraint.ENUM_WEAK_DOUBLE then
    self.EffectSwitcher:SetActiveWidgetIndex(4)
    self.EffectBadText_1:SetText(damageText)
    if BattleUtils.IsPartialShow(enemyPet.card) then
      self.Img_EffectBad_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Img_EffectBad_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

return UMG_Battle_EffectItem_C
