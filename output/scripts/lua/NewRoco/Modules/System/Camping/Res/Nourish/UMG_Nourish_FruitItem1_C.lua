local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_FruitItem1_C = Base:Extend("UMG_Nourish_FruitItem1_C")

function UMG_Nourish_FruitItem1_C:OnConstruct()
end

function UMG_Nourish_FruitItem1_C:OnDestruct()
end

function UMG_Nourish_FruitItem1_C:OnItemUpdate(_data, datalist, index)
  self.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  self.petTypeText = {
    self.Text_1,
    self.Text
  }
  self.data = _data
  local modelConf = _G.DataConfigManager:GetModelConf(self.data.model_conf)
  self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
  self.Name:SetText(string.format(LuaText.umg_nourish_fruititem1_1, self.data.name))
  self:SetPetTypeIcon(self.data.unit_type)
end

function UMG_Nourish_FruitItem1_C:SetPetTypeIcon(_dicTypes)
  for i = 1, #self.petTypeIcons do
    local typeText = self.petTypeText[i]
    self.petTypeIcons[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    typeText:SetText("")
    local petType = _dicTypes[#_dicTypes - i + 1]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        self.petTypeIcons[i]:SetPath(typeDic.tips_res)
        typeText:SetText(typeDic.short_name)
        self.petTypeIcons[i]:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_Nourish_FruitItem1_C:OnItemSelected(_bSelected)
end

function UMG_Nourish_FruitItem1_C:OnDeactive()
end

return UMG_Nourish_FruitItem1_C
