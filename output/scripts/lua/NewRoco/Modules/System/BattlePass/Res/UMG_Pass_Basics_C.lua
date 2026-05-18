local UMG_Pass_Basics_C = _G.NRCPanelBase:Extend("UMG_Pass_Basics_C")

function UMG_Pass_Basics_C:OnActive()
end

function UMG_Pass_Basics_C:PlayInAnimation()
  self:PlayAnimation(self.In)
end

function UMG_Pass_Basics_C:PlayOutAnimation()
  self:PlayAnimation(self.Out)
end

function UMG_Pass_Basics_C:UpdatePanel(petBaseId)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  self.textPetName:SetText(petBaseConf.name)
  self.NRCText_100:SetText(petBaseConf.description)
  self:ShowTypeIcons(petBaseConf)
  self:SetWeigthAndStature(petBaseId)
end

function UMG_Pass_Basics_C:ShowTypeIcons(petBaseConf)
  self.typeIcon = {}
  table.insert(self.typeIcon, {
    icon = self.petTypeIcon1,
    text = self.Text_1
  })
  table.insert(self.typeIcon, {
    icon = self.petTypeIcon2,
    text = self.Text
  })
  local unit_type = petBaseConf.unit_type
  for i, typeIcon in ipairs(self.typeIcon) do
    typeIcon.icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    typeIcon.text:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local uiIcon = typeIcon.icon
    local typeText = typeIcon.text
    typeText:SetText("")
    local petType = unit_type[#unit_type - i + 1]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        uiIcon:SetPath(typeDic.tips_res)
        typeText:SetText(typeDic.short_name)
        typeText:SetVisibility(UE4.ESlateVisibility.Visible)
        uiIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_Pass_Basics_C:SetWeigthAndStature(petBaseId)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  local WeightData = petBaseConf.weight_high * 0.001
  local WeightDataLow = petBaseConf.weight_low * 0.001
  local num = self:GetPreciseDecimal(WeightData, 2)
  local numLow = self:GetPreciseDecimal(WeightDataLow, 2)
  self.TextWeight:SetText(string.format(LuaText.umg_pass_basics_1, numLow, num))
  self.TextStature:SetText(string.format(LuaText.umg_pass_basics_2, petBaseConf.height_low * 0.01, petBaseConf.height_high * 0.01))
end

function UMG_Pass_Basics_C:GetPreciseDecimal(num, n)
  if type(num) ~= "number" then
    return num
  end
  n = n or 0
  n = math.floor(n)
  if n < 0 then
    n = 0
  end
  local decimal = 10 ^ n
  local temp = math.floor(num * decimal)
  return temp / decimal
end

function UMG_Pass_Basics_C:ShowMobility(petBaseConf)
  local id = petBaseConf.scene_ability
  local name = ""
  local iconPath = ""
  if 0 == id then
    name = _G.DataConfigManager:GetSceneAbilityConf(1300056).ability_name
    iconPath = _G.DataConfigManager:GetPetSceneAbilityGanzhi(petBaseConf.id).ability_icon
  else
    local conf = _G.DataConfigManager:GetSceneAbilityConf(id)
    name = conf.ability_name
    iconPath = conf.ability_icon
  end
  self.textPetNature:SetText(name)
  self.NRCImage_55:SetPath(iconPath)
end

return UMG_Pass_Basics_C
