local UMG_Common_Skill_SpEnergy_C = _G.NRCPanelBase:Extend("UMG_Common_Skill_SpEnergy_C")

function UMG_Common_Skill_SpEnergy_C:InitUI(targetType, damageType, skillId)
  local preText = ""
  local typeDic = _G.DataConfigManager:GetTypeDictionary(damageType)
  self.SkillIcon:SetPath(typeDic.field_res)
  if targetType == Enum.FieldBelongType.FBT_SELF then
    preText = LuaText.umg_common_skill_spenergy_1
    self.TargetIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_lvjiantou_png.img_lvjiantou_png'")
  elseif targetType == Enum.FieldBelongType.FBT_ALL_TARGET then
    preText = LuaText.umg_common_skill_spenergy_2
    self.TargetIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_hongjiantou_png.img_hongjiantou_png'")
  else
    preText = LuaText.umg_common_skill_spenergy_3
    self.TargetIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_lanjiantou_png.img_lanjiantou_png'")
  end
  local skillConf = _G.DataConfigManager:GetSkillConf(skillId)
  self.SkillDes:SetText(preText .. skillConf.desc)
end

return UMG_Common_Skill_SpEnergy_C
