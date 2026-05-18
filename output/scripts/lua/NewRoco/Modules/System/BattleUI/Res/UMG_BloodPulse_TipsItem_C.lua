local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BloodPulse_TipsItem_C = Base:Extend("UMG_BloodPulse_TipsItem_C")

function UMG_BloodPulse_TipsItem_C:OnConstruct()
  if self.Text then
    self.Text.OnRichTextClick:Add(self, self.OnDescTextClicked)
  end
end

function UMG_BloodPulse_TipsItem_C:OnDestruct()
  if self.Text then
    self.Text.OnRichTextClick:Remove(self, self.OnDescTextClicked)
  end
end

function UMG_BloodPulse_TipsItem_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    return
  end
  self.uiData = _data
  local skillConf = _data.conf
  self.NameText:SetText(skillConf.name)
  self.descText = skillConf.desc
  self.Text:SetText(skillConf.desc)
  self.icon:SetPath(skillConf.icon)
  local commonAttrData = {}
  local skillType = skillConf.skill_dam_type
  local typeDic = _G.DataConfigManager:GetTypeDictionary(skillType)
  if typeDic then
    table.insert(commonAttrData, {
      Path = typeDic.tips_res
    })
  end
  if 1 ~= skillConf.damage_type then
    if commonAttrData[1] then
      commonAttrData[1].Name = tostring(skillConf.dam_para[1])
    end
  elseif commonAttrData[1] then
    commonAttrData[1].Name = "-"
  end
  if self.Attr then
    self.Attr:InitGridView(commonAttrData)
  end
  self.TxtPnum:SetText(skillConf.energy_cost[1])
  if _data.textDesc then
    self.NRCText_34:SetText(LuaText[_data.textDesc])
  end
end

function UMG_BloodPulse_TipsItem_C:OnItemSelected(_bSelected)
end

function UMG_BloodPulse_TipsItem_C:OnDescTextClicked(id)
  if self.uiData.parent then
    self.uiData.parent:OnDescTextClicked(self.descText)
  end
end

function UMG_BloodPulse_TipsItem_C:OnDeactive()
end

return UMG_BloodPulse_TipsItem_C
