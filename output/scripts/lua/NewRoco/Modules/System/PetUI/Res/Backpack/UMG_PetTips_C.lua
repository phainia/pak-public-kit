local UMG_PetTips_C = _G.NRCPanelBase:Extend("UMG_Tips_C")

function UMG_PetTips_C:OnConstruct()
  self.uiItem = {}
  self.uiItem.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
end

function UMG_PetTips_C:OnDestruct()
end

function UMG_PetTips_C:OnActive(data)
  self.uiData = data
  self:UpdataPetTipsInfo()
  self:OnAddEventListener()
end

function UMG_PetTips_C:UpdataPetTipsInfo()
  local petData = self.uiData.petData
  if petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    self:updatePetTypeIcon(petBaseConf.unit_type)
    self:UpdataPetDepartment(petBaseConf.unit_type)
  end
end

function UMG_PetTips_C:updatePetTypeIcon(_dicTypes)
  for i, uiIcon in ipairs(self.uiItem.petTypeIcons) do
    uiIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    local petType = _dicTypes[i]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        uiIcon:SetPath(typeDic.type_icon)
        uiIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_PetTips_C:UpdataPetDepartment(_dicTypes)
  self.NRCGridView_0:Clear()
  self.NRCGridView:Clear()
  self.NRCGridView_1:Clear()
  local petType, typeDic
  local Pinned = {}
  local resist = {}
  local rests = {}
  for i, uiIcon in ipairs(self.uiItem.petTypeIcons) do
    uiIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    if _dicTypes[i] then
      petType = _dicTypes[i]
    end
  end
  typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
  for j, v in pairs(typeDic) do
    for k = 1, 20 do
      if "type_restraint" .. k == j then
        local typeDicinfo = _G.DataConfigManager:GetTypeDictionary(k)
        if v > 0 then
          table.insert(Pinned, {
            v,
            typeDicinfo.type_icon
          })
          break
        elseif v < 0 then
          table.insert(resist, {
            v,
            typeDicinfo.type_icon
          })
        else
          table.insert(rests, {
            v,
            typeDicinfo.type_icon
          })
        end
      end
    end
  end
  self.NRCGridView_0:InitGridView(Pinned)
  self.NRCGridView:InitGridView(resist)
  self.NRCGridView_1:InitGridView(rests)
end

function UMG_PetTips_C:OnDeactive()
end

function UMG_PetTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnbtnCloseTipsClick)
end

function UMG_PetTips_C:OnbtnCloseTipsClick()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_ClosePetTips)
end

return UMG_PetTips_C
