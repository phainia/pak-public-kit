local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Share_SkillIcon_C = Base:Extend("UMG_Share_SkillIcon_C")

function UMG_Share_SkillIcon_C:OnConstruct()
end

function UMG_Share_SkillIcon_C:OnDestruct()
end

function UMG_Share_SkillIcon_C:OnItemUpdate(_data, datalist, index)
  local skillConf = _G.DataConfigManager:GetSkillConf(_data.id)
  self.SkillNameTxt:SetText(skillConf.name)
  self.SkillIcon:SetPath(skillConf.icon)
end

function UMG_Share_SkillIcon_C:OnItemSelected(_bSelected)
end

function UMG_Share_SkillIcon_C:OnDeactive()
end

return UMG_Share_SkillIcon_C
