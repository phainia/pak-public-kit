local UMG_UIBattleSkillItem_Tips_C = NRCUmgClass:Extend("")

function UMG_UIBattleSkillItem_Tips_C:Construct()
  _G.Log.Debug("UMG_UIBattleSkillItem_Tips_C::Construct")
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_UIBattleSkillItem_Tips_C:SetSkillName(skillName)
  self.TxtSkillName:SetText(skillName)
end

function UMG_UIBattleSkillItem_Tips_C:SetPower(skillPower)
  self.TxtPower:SetText(tostring(skillPower))
end

function UMG_UIBattleSkillItem_Tips_C:SetPPValue(ppValue)
  self.TxtPP:SetText(tostring(ppValue))
end

function UMG_UIBattleSkillItem_Tips_C:SetDesc(desc)
  self.txtDesc:SetText(desc)
end

function UMG_UIBattleSkillItem_Tips_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_UIBattleSkillItem_Tips_C:Hide()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

return UMG_UIBattleSkillItem_Tips_C
