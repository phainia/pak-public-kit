local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_UpgradeSkillItem_C = Base:Extend("UMG_UpgradeSkillItem_C")

function UMG_UpgradeSkillItem_C:OnItemUpdate(_data, datalist, index)
  local skillConf = _G.DataConfigManager:GetSkillConf(_data.skillID)
  if skillConf then
    self.SkillName:SetText(skillConf.name)
    self.SkillIcon:SetPath(skillConf.icon)
  end
end

return UMG_UpgradeSkillItem_C
