local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Tips_StrongPoint_Item_C = Base:Extend("UMG_Tips_StrongPoint_Item_C")

function UMG_Tips_StrongPoint_Item_C:OnConstruct()
end

function UMG_Tips_StrongPoint_Item_C:OnDestruct()
end

function UMG_Tips_StrongPoint_Item_C:OnItemUpdate(_data, datalist, index)
  if _data then
    local PetTalentConf = _data
    self.SkillNameTxt:SetText(string.format(LuaText.pet_talent_tips_title, PetTalentConf.name))
    self.ChangeText:SetText(PetTalentConf.desc)
  end
end

function UMG_Tips_StrongPoint_Item_C:OnItemSelected(_bSelected)
end

function UMG_Tips_StrongPoint_Item_C:OnDeactive()
end

return UMG_Tips_StrongPoint_Item_C
