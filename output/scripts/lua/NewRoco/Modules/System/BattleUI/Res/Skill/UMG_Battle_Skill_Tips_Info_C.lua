require("UnLuaEx")
local UMG_Battle_Skill_Tips_Info_C = NRCUmgClass:Extend("")

function UMG_Battle_Skill_Tips_Info_C:UpdateInfo(skillData)
  local skillConf = _G.DataConfigManager:GetSkillConf(skillData.skill_id)
  self.TxtPower:SetText(skillConf.dam_para[1])
  if 1 == skillConf.damage_type then
    self.TxtDamageType:SetText(_G.LuaText.DAMAGETYPE_NONE)
  elseif 2 == skillConf.damage_type then
    self.TxtDamageType:SetText(_G.LuaText.DAMAGETYPE_PHYSICAL)
  elseif 3 == skillConf.damage_type then
    self.TxtDamageType:SetText(_G.LuaText.DAMAGETYPE_MAGICAL)
  end
  self.TxtCDInit:SetText(skillConf.cd_round[2])
  self.TxtCDRound:SetText(skillConf.cd_round[1])
  self.TxtSpeed:SetText("0")
end

return UMG_Battle_Skill_Tips_Info_C
