local UMG_Pass_Property_C = _G.NRCPanelBase:Extend("UMG_Pass_Property_C")

function UMG_Pass_Property_C:OnActive()
end

function UMG_Pass_Property_C:OnConstruct()
  self:OnAddEventListener()
  self.textRace:SetText(LuaText.race_qualify_text)
end

function UMG_Pass_Property_C:OnDeactive()
end

function UMG_Pass_Property_C:OnAddEventListener()
  self:AddButtonListener(self.PetTypeIcon, self.OnPetTypeIconClick)
end

function UMG_Pass_Property_C:PlayInAnimation()
  self:PlayAnimation(self.In)
end

function UMG_Pass_Property_C:PlayOutAnimation()
  self:PlayAnimation(self.Out)
end

function UMG_Pass_Property_C:UpdatePanel(petBaseId)
  if petBaseId then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
    local list = self:GetAttrDatas(petBaseConf)
    self.NRCGridView_41:InitGridView(list)
    self.textPetName:SetText(petBaseConf.name)
    self.NRCText_100:SetText(petBaseConf.description)
    self:ShowTypeIcons(petBaseConf)
    self:SetWeigthAndStature(petBaseId)
    self.uiData = {}
    local petData = {}
    petData.base_conf_id = petBaseId
    self.uiData.petData = petData
  end
end

function UMG_Pass_Property_C:ShowTypeIcons(petBaseConf)
  local unit_type = petBaseConf.unit_type
  local attrDatas = {}
  for i = 1, #unit_type do
    local petType = unit_type[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    if typeDic then
      table.insert(attrDatas, {
        Name = typeDic.short_name,
        Path = typeDic.type_icon
      })
    end
  end
  self.Attr:InitGridView(attrDatas)
end

function UMG_Pass_Property_C:SetWeigthAndStature(petBaseId)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  local WeightData = petBaseConf.weight_high * 0.001
  local WeightDataLow = petBaseConf.weight_low * 0.001
  local num = self:GetPreciseDecimal(WeightData, 2)
  local numLow = self:GetPreciseDecimal(WeightDataLow, 2)
  self.TextWeight:SetText(string.format(LuaText.umg_pass_basics_1, numLow, num))
  self.TextStature:SetText(string.format(LuaText.umg_pass_basics_2, petBaseConf.height_low * 0.01, petBaseConf.height_high * 0.01))
end

function UMG_Pass_Property_C:GetPreciseDecimal(num, n)
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

function UMG_Pass_Property_C:GetAttrDatas(petBaseConf)
  local hp = petBaseConf.hp_max_race
  local attack = petBaseConf.phy_attack_race
  local spe_attack = petBaseConf.spe_attack_race
  local defence = petBaseConf.phy_defence_race
  local spe_defence = petBaseConf.spe_defence_race
  local speed = petBaseConf.speed_race
  local hp_max = _G.DataConfigManager:GetAttrGlobalConfig("race_hp_maximum").num
  local attack_max = _G.DataConfigManager:GetAttrGlobalConfig("race_attack_maximum").num
  local spe_attack_max = _G.DataConfigManager:GetAttrGlobalConfig("race_special_attack_maximum").num
  local defence_max = _G.DataConfigManager:GetAttrGlobalConfig("race_defense_maximium").num
  local spe_defence_max = _G.DataConfigManager:GetAttrGlobalConfig("race_special_defense_maximum").num
  local speed_max = _G.DataConfigManager:GetAttrGlobalConfig("race_speed_maximum").num
  local hpData = {
    id = 1,
    value = hp,
    value_max = hp_max
  }
  local attackData = {
    id = 2,
    value = attack,
    value_max = attack_max
  }
  local speAttackData = {
    id = 3,
    value = spe_attack,
    value_max = spe_attack_max
  }
  local defenceData = {
    id = 4,
    value = defence,
    value_max = defence_max
  }
  local speDefenceData = {
    id = 5,
    value = spe_defence,
    value_max = spe_defence_max
  }
  local speedData = {
    id = 6,
    value = speed,
    value_max = speed_max
  }
  local max = hp + attack + spe_attack + spe_defence + defence + speed
  self.NRC_Change:SetText(tostring(max))
  local dataList = {}
  table.insert(dataList, hpData)
  table.insert(dataList, attackData)
  table.insert(dataList, speAttackData)
  table.insert(dataList, defenceData)
  table.insert(dataList, speDefenceData)
  table.insert(dataList, speedData)
  return dataList
end

function UMG_Pass_Property_C:OnPetTypeIconClick()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, self.uiData, _G.Enum.GoodsType.GT_PET)
end

return UMG_Pass_Property_C
