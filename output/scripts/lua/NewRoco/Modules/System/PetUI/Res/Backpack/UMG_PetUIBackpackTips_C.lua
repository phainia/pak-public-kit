local UMG_PetUIBackpackTips_C = _G.NRCPanelBase:Extend("UMG_PetUIBackpackTips_C")

function UMG_PetUIBackpackTips_C:OnConstruct()
  self.uiItem = {}
  self.uiItem.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
end

function UMG_PetUIBackpackTips_C:OnDestruct()
end

function UMG_PetUIBackpackTips_C:OnActive(data)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002013, "UMG_PetUIBackpackTips_C:openTips")
  self:PlayAnimation(self.Appear)
  self.uiData = data
  self:UpdataPetTipsInfo()
  self:OnAddEventListener()
  self:BindInputAction()
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").PETTIPS
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
end

function UMG_PetUIBackpackTips_C:UpdataPetTipsInfo()
  local petData = self.uiData.petData
  local typeList = self.uiData.typeList
  local typeId = self.uiData.typeId
  if typeId then
    self:updatePetTypeIcon({typeId})
    self:ShowPropertyInfoByTypeList({typeId})
  elseif typeList and #typeList > 0 then
    self:updatePetTypeIcon(typeList)
    self:ShowPropertyInfoByTypeList(typeList)
  elseif petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    self:updatePetTypeIcon(petBaseConf.unit_type)
    self:ShowPropertyInfo(petData)
  end
end

function UMG_PetUIBackpackTips_C:updatePetTypeIcon(_dicTypes)
  for i, uiIcon in ipairs(self.uiItem.petTypeIcons) do
    uiIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    local petType = _dicTypes[#_dicTypes - i + 1]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        uiIcon:SetPath(typeDic.type_icon)
        uiIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_PetUIBackpackTips_C:ShowPropertyInfo(petData)
  local RestainTypeList, ResistTypeList = NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetRestrainAndResistType, petData)
  self.NRCGridView_0:InitGridView(ResistTypeList)
  self.NRCGridView:InitGridView(RestainTypeList)
  self:SetBgLength(ResistTypeList, RestainTypeList)
  self:SetTextThintShow(ResistTypeList, RestainTypeList)
end

function UMG_PetUIBackpackTips_C:ShowPropertyInfoByTypeList(typeList)
  local RestainTypeList, ResistTypeList = self:GetRestrainAndResistTypeByTypeList(typeList)
  self.NRCGridView_0:InitGridView(ResistTypeList)
  self.NRCGridView:InitGridView(RestainTypeList)
  self:SetBgLength(ResistTypeList, RestainTypeList)
  self:SetTextThintShow(ResistTypeList, RestainTypeList)
end

function UMG_PetUIBackpackTips_C:GetRestrainAndResistTypeByTypeList(typeList)
  local petType = {}
  local ResistTypeList = {}
  local RestainTypeList = {}
  for i = 1, 2 do
    if typeList[i] then
      table.insert(petType, typeList[i])
    end
  end
  local AbandonType = {7}
  local firstTypeRestraints = {}
  local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[1])
  if typeDic then
    for k = 2, 20 do
      if not table.contains(AbandonType, k) then
        local key = "type_restraint" .. typeDic.id
        local typeDicinfo = _G.DataConfigManager:GetTypeDictionary(k)
        if typeDicinfo then
          local v = typeDicinfo[key]
          firstTypeRestraints[k] = v
          if v then
            if v < 0 then
              table.insert(ResistTypeList, {
                id = 2,
                icon = typeDicinfo.type_icon,
                num = k,
                Phase = false,
                isDouble = false,
                typeID = typeDicinfo.id
              })
            elseif v > 0 then
              table.insert(RestainTypeList, {
                id = 2,
                icon = typeDicinfo.type_icon,
                num = k,
                Phase = true,
                isDouble = false,
                typeID = typeDicinfo.id
              })
            end
          end
        end
      end
    end
  end
  if 2 == #petType then
    typeDic = _G.DataConfigManager:GetTypeDictionary(petType[2])
    if typeDic then
      local secondTypeRestraints = {}
      for k = 2, 20 do
        if not table.contains(AbandonType, k) then
          local typeDicinfo = _G.DataConfigManager:GetTypeDictionary(k)
          if typeDicinfo then
            local key = "type_restraint" .. typeDic.id
            local v = typeDicinfo[key]
            secondTypeRestraints[k] = v
          end
        end
      end
      for k = 2, 20 do
        if not table.contains(AbandonType, k) then
          local v1 = firstTypeRestraints[k]
          local v2 = secondTypeRestraints[k]
          local typeDicinfo = _G.DataConfigManager:GetTypeDictionary(k)
          local isDouble = false
          if v1 and v2 and (v1 > 0 and v2 > 0 or v1 < 0 and v2 < 0) then
            isDouble = true
          end
          if v2 and typeDicinfo then
            if v2 < 0 then
              local found = false
              for n, m in ipairs(ResistTypeList) do
                if k == m.num then
                  found = true
                  ResistTypeList[n].id = 4
                  ResistTypeList[n].isDouble = isDouble
                end
              end
              if not found then
                table.insert(ResistTypeList, {
                  id = 2,
                  icon = typeDicinfo.type_icon,
                  num = k,
                  Phase = false,
                  isDouble = isDouble,
                  typeID = typeDicinfo.id
                })
              end
            elseif v2 > 0 then
              local found = false
              for n, m in ipairs(RestainTypeList) do
                if k == m.num then
                  found = true
                  RestainTypeList[n].id = 4
                  RestainTypeList[n].isDouble = isDouble
                end
              end
              if not found then
                table.insert(RestainTypeList, {
                  id = 2,
                  icon = typeDicinfo.type_icon,
                  num = k,
                  Phase = true,
                  isDouble = isDouble,
                  typeID = typeDicinfo.id
                })
              end
            end
          end
        end
      end
      local needRemoveResist = {}
      local needRemoveRestain = {}
      for _, resistItem in ipairs(ResistTypeList) do
        for _, restainItem in ipairs(RestainTypeList) do
          if resistItem.num == restainItem.num then
            table.insert(needRemoveResist, resistItem.num)
            table.insert(needRemoveRestain, restainItem.num)
          end
        end
      end
      for _, v in ipairs(needRemoveResist) do
        for i = #ResistTypeList, 1, -1 do
          if ResistTypeList[i] and ResistTypeList[i].num == v then
            table.remove(ResistTypeList, i)
          end
        end
      end
      for _, v in ipairs(needRemoveRestain) do
        for i = #RestainTypeList, 1, -1 do
          if RestainTypeList[i] and RestainTypeList[i].num == v then
            table.remove(RestainTypeList, i)
          end
        end
      end
    end
  end
  return RestainTypeList, ResistTypeList
end

function UMG_PetUIBackpackTips_C:SetTextThintShow(_Pinned, _resist, _rests)
  if 0 == #_resist then
  end
  if 0 == #_Pinned then
  end
end

function UMG_PetUIBackpackTips_C:SetBgLength(_Pinned, _resist, _rests)
  if self.uiData.is_not_set_bg then
    return
  end
  local rests = _rests
  local Size = self.Bg.Slot:GetSize()
  local bglength = 204.0
  if 0 == #_Pinned then
    self.PinnedPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCGridView_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 == #_resist then
    self.resistPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCGridView:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 == #_resist and 0 == #_Pinned then
    self.TexThint:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 0 ~= #_resist and 0 ~= #_Pinned then
    self.TexThint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    bglength = 469.5
  else
    self.TexThint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    bglength = 291.0
  end
  local bglengthAdd = (#_Pinned // 7 + #_resist // 7) * 90
  Size.y = bglength + bglengthAdd
  self.Bg.Slot:SetSize(Size)
end

function UMG_PetUIBackpackTips_C:OnDeactive()
end

function UMG_PetUIBackpackTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnbtnCloseTipsClick)
end

function UMG_PetUIBackpackTips_C:OnbtnCloseTipsClick()
  self.btnCloseTips:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002014, "UMG_Bag_C:OnBtnLeft1Clicked")
  self:PlayAnimation(self.Disappear)
end

function UMG_PetUIBackpackTips_C:OnAnimationFinished(Animation)
  if Animation == self.Disappear then
    self.btnCloseTips:SetIsEnabled(true)
    self:DoClose()
  end
end

function UMG_PetUIBackpackTips_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_PetUIBackpackTips")
  if mappingContext then
    mappingContext:BindAction("IA_ClosePetUIBackpackTips", self, "OnPcClose2")
  end
end

function UMG_PetUIBackpackTips_C:OnPcClose2()
  self:OnbtnCloseTipsClick()
end

return UMG_PetUIBackpackTips_C
