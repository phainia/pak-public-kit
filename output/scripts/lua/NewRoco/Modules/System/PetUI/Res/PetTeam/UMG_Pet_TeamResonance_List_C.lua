local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pet_TeamResonance_List_C = Base:Extend("UMG_Pet_TeamResonance_List_C")

function UMG_Pet_TeamResonance_List_C:OnConstruct()
end

function UMG_Pet_TeamResonance_List_C:OnDestruct()
end

function UMG_Pet_TeamResonance_List_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetData()
end

function UMG_Pet_TeamResonance_List_C:OnItemSelected(_bSelected)
end

function UMG_Pet_TeamResonance_List_C:OnDeactive()
end

function UMG_Pet_TeamResonance_List_C:SetData()
  local data = self.data
  self.Text:SetText(data.cfg.name .. LuaText.umg_pet_teamresonance_list_1)
  self.PetList:InitGridView(data.pets)
  local typeCfg = _G.DataConfigManager:GetTypeDictionary(data.cfg.unit_type)
  local iconPath = typeCfg.type_icon
  local bannerPath = typeCfg.synchron_banner_res
  self.ShiNeng:SetPath(iconPath)
  self.Departmen_Bg:SetPath(bannerPath)
  local skillListData = {}
  local cfg = data.cfg
  local petNum = #data.pets
  local maxActiveNum = 0
  for i, type_synchron in ipairs(cfg.type_synchron) do
    local isActive = petNum >= type_synchron.synchron_number
    if isActive and maxActiveNum < type_synchron.synchron_number then
      maxActiveNum = type_synchron.synchron_number
      if skillListData[i - 1] and skillListData[i - 1].isActive then
        skillListData[i - 1].isActive = false
      end
    end
    local t = {
      isActive = isActive,
      number = type_synchron.synchron_number,
      skillText = type_synchron.synchron_text,
      attrData = type_synchron.attribute_data
    }
    table.insert(skillListData, t)
  end
  self.SkillList:InitGridView(skillListData)
end

return UMG_Pet_TeamResonance_List_C
