local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Lineup_ShareItem_List1_C = Base:Extend("UMG_Lineup_ShareItem_List1_C")

function UMG_Lineup_ShareItem_List1_C:OnConstruct()
end

function UMG_Lineup_ShareItem_List1_C:OnDestruct()
end

function UMG_Lineup_ShareItem_List1_C:OnItemUpdate(_data, datalist, index)
  self:SetAttrName(self.attributeIcon, _data.attribute)
end

function UMG_Lineup_ShareItem_List1_C:OnItemSelected(_bSelected)
end

function UMG_Lineup_ShareItem_List1_C:OnDeactive()
end

function UMG_Lineup_ShareItem_List1_C:SetAttrName(text, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    text:SetText(LuaText.RADAR_HP_MAX)
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    text:SetText(LuaText.RADAR_AT_PHYATK)
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    text:SetText(LuaText.RADAR_AT_SPEATK)
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    text:SetText(LuaText.RADAR_AT_PHYDEF)
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    text:SetText(LuaText.RADAR_AT_SPEDEF)
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    text:SetText(LuaText.RADAR_AT_SPEED)
  end
end

return UMG_Lineup_ShareItem_List1_C
