local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ModifySkillsItem_C = Base:Extend("UMG_ModifySkillsItem_C")

function UMG_ModifySkillsItem_C:OnConstruct()
end

function UMG_ModifySkillsItem_C:OnDestruct()
end

function UMG_ModifySkillsItem_C:UpdateInfo(skillID)
  if not skillID then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  else
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local skillConf = _G.DataConfigManager:GetSkillConf(skillID)
  if skillConf then
    self.skillConf = skillConf
    self.SkillIcon:SetPath(skillConf.icon)
    self.SkillNameTxt:SetText(skillConf.name)
  else
    Log.Debug("\230\138\128\232\131\189id\230\178\146\230\156\137\230\137\190\229\136\176", skillID)
  end
end

function UMG_ModifySkillsItem_C:OnItemUpdate(_data, datalist, index)
  self.skillID = _data
  self:UpdateInfo(self.skillID)
end

function UMG_ModifySkillsItem_C:OnItemSelected(_bSelected)
end

function UMG_ModifySkillsItem_C:OnDeactive()
end

return UMG_ModifySkillsItem_C
