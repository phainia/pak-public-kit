local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_CommonMagic_C = Base:Extend("UMG_CommonMagic_C")

function UMG_CommonMagic_C:OnConstruct()
end

function UMG_CommonMagic_C:OnDestruct()
end

function UMG_CommonMagic_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  local skill_conf = _G.SkillUtils.GetSkillConf(self.data.player_skill_id)
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(skill_conf.icon, _G.UIIconPath.SkillIconPath))
end

return UMG_CommonMagic_C
