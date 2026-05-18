local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Battle_SpecificSkills_C = Base:Extend("UMG_Battle_SpecificSkills_C")

function UMG_Battle_SpecificSkills_C:OnConstruct()
end

function UMG_Battle_SpecificSkills_C:OnDestruct()
end

function UMG_Battle_SpecificSkills_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_Battle_SpecificSkills_C:SetInfo()
  local data = self.data
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf(tostring(data.tip_id))
  local tipMsg = LocalizationConf and LocalizationConf.msg or ""
  self.attriNameTxt:SetText(tipMsg)
  local stackString = ""
  if data.stack and data.stack > 1 then
    stackString = tostring(data.stack)
  end
  self.Txt:SetText(stackString)
  local skillDamType = BattleUtils.SkillEnhanceInfoToSkillDamageType(data)
  local typeDic = skillDamType and _G.DataConfigManager:GetTypeDictionary(skillDamType)
  local icon_path = typeDic and typeDic.synchron_petbag_icon
  if icon_path then
    self.Icon:SetPath(icon_path)
    self.Icon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFFFF"))
  end
end

function UMG_Battle_SpecificSkills_C:OnItemSelected(_bSelected)
end

function UMG_Battle_SpecificSkills_C:OnDeactive()
end

return UMG_Battle_SpecificSkills_C
