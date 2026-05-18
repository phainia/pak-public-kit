local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CharacterSkillItem_C = Base:Extend("UMG_CharacterSkillItem_C")

function UMG_CharacterSkillItem_C:OnConstruct()
end

function UMG_CharacterSkillItem_C:OnDestruct()
end

function UMG_CharacterSkillItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local BattleRuleConf = _G.DataConfigManager:GetBattleRuleConf(self.data)
  self.SkillIcon:SetPath(BattleRuleConf.icon)
end

function UMG_CharacterSkillItem_C:OnItemSelected(_bSelected)
end

function UMG_CharacterSkillItem_C:OnDeactive()
end

return UMG_CharacterSkillItem_C
