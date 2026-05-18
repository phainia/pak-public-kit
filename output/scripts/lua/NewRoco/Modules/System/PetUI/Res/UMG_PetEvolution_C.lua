local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local enum = reload("Data.Config.Enum")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local UMG_PetEvolution_C = _G.NRCViewBase:Extend("UMG_PetEvolution_C")

function UMG_PetEvolution_C:Initialize(Initializer)
end

function UMG_PetEvolution_C:OnConstruct()
  self:SetChildViews(self.item1, self.item2, self.item3, self.item4)
  self.uiData = {isPanelShow = false}
  self.uiItem = {}
  self.uiItem.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  local itemPanels = {}
  local itemIcons = {
    self.item1,
    self.item2,
    self.item3,
    self.item4
  }
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    table.insert(itemPanels, self.itemParent:GetChildAt(i))
  end
  self.uiItem.itemIcons = itemIcons
  self.uiItem.itemPanels = itemPanels
  self.uiItem.itemPanelSize = self.itemParent.Slot:GetSize()
  self:AddButtonListener(self.btnEvolution, self.OnBtnEvolutionClick)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_EVOLUTION_INDEX_CHANGE, self.OnEvolutionIndexChange)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_COMMON_TIP_CLOSE, self.OnEventCommonTipClose)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  self.petPropHp:SetTitle(LuaText.umg_petevolution_1)
  self.petPropAttack:SetTitle(LuaText.umg_petevolution_2)
  self.petPropDefence:SetTitle(LuaText.umg_petevolution_3)
  self.petPropSPAttack:SetTitle(LuaText.umg_petevolution_4)
  self.petPropSPDefence:SetTitle(LuaText.umg_petevolution_5)
  self.petPropSpeed:SetTitle(LuaText.umg_petevolution_6)
end

function UMG_PetEvolution_C:OnDestruct()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  table.clear(self.uiItem)
  self.uiData = nil
  self.uiItem = nil
  self.petTypeIcon2:ReleaseForce()
  self.petTypeIcon1:ReleaseForce()
  self.item1:Destruct()
  self.item2:Destruct()
  self.item3:Destruct()
  self.item4:Destruct()
  self.petPropHp:Destruct()
  self.petPropAttack:Destruct()
  self.petPropDefence:Destruct()
  self.petPropSPAttack:Destruct()
  self.petPropSPDefence:Destruct()
  self.petPropSpeed:Destruct()
  self.specialSkillIicon:ReleaseForce()
end

function UMG_PetEvolution_C:OnEnable()
end

function UMG_PetEvolution_C:OnDisable()
end

function UMG_PetEvolution_C:updatePetInfo(_petData, _petBaseConf)
  self.uiData.petData = _petData
  self.uiData.petBaseConf = _petBaseConf
  self.uiData.curEvolutionIndex = 0
  if self.uiData.isPanelShow then
    self:updatePanelInfo()
  end
end

function UMG_PetEvolution_C:updatePetTypeIcon(_dicTypes)
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

function UMG_PetEvolution_C:updatePetSpecialSkill(_skillId)
  local skillCfg = _G.DataConfigManager:GetSkillConf(_skillId)
  if skillCfg then
    self.specialSkillIicon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.specialSkillIicon:SetPath(skillCfg.icon)
    self.textSpecialSkillName:SetText(skillCfg.name)
    self.textSpecialSkillDesc:SetText(skillCfg.desc)
    return
  end
  self:clearPetSpecialSkill()
end

function UMG_PetEvolution_C:clearPetSpecialSkill()
  self.specialSkillIicon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.textSpecialSkillName:SetText("")
  self.textSpecialSkillDesc:SetText("")
end

function UMG_PetEvolution_C:updatePanelInfo()
  local uiData = self.uiData
  local petData = uiData.petData
  local petBaseConf = uiData.petBaseConf
  if nil == petData or nil == petBaseConf then
    return
  end
  local isAcceptTask = petData.evolution_task and petData.evolution_task > 0
  local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  self.curMoney:SetText(curMoney)
  if not petBaseConf.evolution_pet_id or not (#petBaseConf.evolution_pet_id > 0) then
    self.mainPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.messagePanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self:updateMaxEvolutionLevelInfo()
    return
  end
  if isAcceptTask then
    uiData.curEvolutionIndex = petData.evolution_chosen_idx and petData.evolution_chosen_idx + 1 or 1
  end
  local evolutionListCount = #petBaseConf.evolution_pet_id
  local curEvolutionIndex = uiData.curEvolutionIndex
  if curEvolutionIndex <= 0 or evolutionListCount < curEvolutionIndex then
    curEvolutionIndex = 1
    uiData.curEvolutionIndex = 1
  end
  self.mainPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.messagePanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:updateEvolutionInfo()
end

function UMG_PetEvolution_C:updateEvolutionInfo()
  local uiData = self.uiData
  local petData = uiData.petData
  local curPetBaseConf = uiData.petBaseConf
  local curEvolutionIndex = uiData.curEvolutionIndex
  local isAcceptTask = petData.evolution_task and petData.evolution_task > 0
  if not (curPetBaseConf and curPetBaseConf.evolution_pet_id) or not curEvolutionIndex then
    return
  end
  local evolutionPetId = curPetBaseConf.evolution_pet_id[curEvolutionIndex]
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(evolutionPetId)
  if not petBaseConf then
    return
  end
  self.textPetName:SetText(petBaseConf.name)
  self:updateMoneyInfo(petBaseConf.evolution_need_money, isAcceptTask)
  self:updatePetTypeIcon(petBaseConf.unit_type)
  self:updatePetSpecialSkill(petBaseConf.pet_feature)
  self:updatePetPropInfo(curPetBaseConf, petBaseConf)
  local itemEnough = self:updateItemInfo(petBaseConf.evolution_need_items, isAcceptTask)
  self.maxEvolutionFlag:SetVisibility(UE4.ESlateVisibility.Hidden)
  if petData.level < petBaseConf.evolution_need_level or not itemEnough then
    self.canEvolutionFlag:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.canEvolutionFlag:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PetEvolution_C:updateMaxEvolutionLevelInfo()
  local uiData = self.uiData
  local petData = uiData.petData
  local petBaseConf = uiData.petBaseConf
  self.canEvolutionFlag:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.maxEvolutionFlag:SetVisibility(UE4.ESlateVisibility.Visible)
  self.textPetName:SetText(petBaseConf.name)
  self:updatePetTypeIcon(petBaseConf.unit_type)
  self:updatePetSpecialSkill(petBaseConf.pet_feature)
  self:updatePetPropInfo(petBaseConf, nil)
end

function UMG_PetEvolution_C:updatePetPropInfo(_petBaseConf, _dstPetBaseConf)
  self.petPropHp:SetProp(_petBaseConf and _petBaseConf.hp_max_race, _dstPetBaseConf and _dstPetBaseConf.hp_max_race)
  self.petPropAttack:SetProp(_petBaseConf and _petBaseConf.phy_attack_race, _dstPetBaseConf and _dstPetBaseConf.phy_attack_race)
  self.petPropDefence:SetProp(_petBaseConf and _petBaseConf.phy_defence_race, _dstPetBaseConf and _dstPetBaseConf.phy_defence_race)
  self.petPropSPAttack:SetProp(_petBaseConf and _petBaseConf.spe_attack_race, _dstPetBaseConf and _dstPetBaseConf.spe_attack_race)
  self.petPropSPDefence:SetProp(_petBaseConf and _petBaseConf.spe_defence_race, _dstPetBaseConf and _dstPetBaseConf.spe_defence_race)
  self.petPropSpeed:SetProp(_petBaseConf and _petBaseConf.speed_race, _dstPetBaseConf and _dstPetBaseConf.speed_race)
end

function UMG_PetEvolution_C:updateItemInfo(_evolutionItems, _isAcceptTask)
  local itemEnough = true
  local itemTypeCount = _evolutionItems and #_evolutionItems or 0
  local itemPanels = self.uiItem.itemPanels
  local itemPanelCount = #itemPanels
  local itemPanelSize = self.uiItem.itemPanelSize
  local itemIcons = self.uiItem.itemIcons
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    local index = i + 1
    local childItem = self.itemParent:GetChildAt(i)
    if i < itemTypeCount then
      local itemData = _evolutionItems[index]
      local itemId = itemData.evolution_need_item
      local itemCfg = itemId > 0 and _G.DataConfigManager:GetBagItemConf(itemId) or nil
      local itemCount = self:getItemCount(itemId)
      itemIcons[index]:SetData({
        itemId = itemId,
        itemCfg = itemCfg,
        needCount = itemData.number,
        itemCount = itemCount,
        isShowFinish = _isAcceptTask
      })
      if itemCount < itemData.number then
        itemEnough = false
      end
    else
      itemIcons[index]:SetData(nil)
    end
  end
  return itemEnough
end

function UMG_PetEvolution_C:updateMoneyInfo(_needMoney, _isAcceptTask)
  local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  self.curMoney:SetText(curMoney)
  if _isAcceptTask then
    self.moneyFinish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.needMoney:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.moneyFinish:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.needMoney:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local moneyInfo
    if _needMoney > curMoney then
      moneyInfo = string.format("<evomoney2>%d</>", _needMoney)
    else
      moneyInfo = string.format("<evomoney1>%d</>", _needMoney)
    end
    self.needMoney:SetText(moneyInfo)
  end
end

function UMG_PetEvolution_C:getItemCount(_itemId)
  local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
  if itemData then
    return itemData.num or 0
  end
  return 0
end

function UMG_PetEvolution_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetEvolution_C:OnEvolutionIndexChange(_index)
  local uiData = self.uiData
  local petBaseCfg = uiData.petBaseConf
  local evolutionCount = 0
  local evolutionPetIdList = petBaseCfg.evolution_pet_id
  if evolutionPetIdList then
    evolutionCount = #evolutionPetIdList
  end
  if evolutionCount < 1 then
    return
  end
  if _index > evolutionCount then
    _index = evolutionCount
  end
  if _index < 1 then
    _index = 1
  end
  self.uiData.curEvolutionIndex = _index
  self:updateEvolutionInfo()
end

function UMG_PetEvolution_C:OnPlayerDataUpdate()
  if not self.uiData.isPanelShow then
    return
  end
  local uiData = self.uiData
  local petData = uiData.petData
  local curPetBaseConf = uiData.petBaseConf
  local curEvolutionIndex = uiData.curEvolutionIndex
  if not (curPetBaseConf and curPetBaseConf.evolution_pet_id) or not curEvolutionIndex then
    return
  end
  local evolutionPetId = curPetBaseConf.evolution_pet_id[curEvolutionIndex]
  if evolutionPetId and evolutionPetId > 0 then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(evolutionPetId)
    local isAcceptTask = petData.evolution_task and petData.evolution_task > 0
    if petBaseConf then
      self:updateMoneyInfo(petBaseConf.evolution_need_money, isAcceptTask)
    end
  end
end

function UMG_PetEvolution_C:OnPanelStateChange(_isShow)
  self.uiData.isPanelShow = _isShow
  if _isShow then
    self:updatePanelInfo()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAniEx(self.OpenAnim)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetEvolution_C:OnBtnEvolutionClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_PetEvolution_C:OnBtnEvolutionClick")
  local petData = self.uiData.petData
  if petData.evolution_task and petData.evolution_task > 0 then
    self:showEvolutionTaskPanel()
  else
    self:showEvolutionItemPanel()
  end
end

function UMG_PetEvolution_C:OnEventCommonTipClose()
  for _, itemIcon in ipairs(self.uiItem.itemIcons) do
    itemIcon:ClearSelectAnim()
  end
end

function UMG_PetEvolution_C:showEvolutionItemPanel()
  local uiData = self.uiData
  local petData = uiData.petData
  local curPetBaseConf = uiData.petBaseConf
  local curEvolutionIndex = uiData.curEvolutionIndex
  if not (curPetBaseConf and curPetBaseConf.evolution_pet_id) or not curEvolutionIndex then
    return
  end
  local evolutionPetId = curPetBaseConf.evolution_pet_id[curEvolutionIndex]
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(evolutionPetId)
  if not petBaseConf then
    return
  end
  if petData.level < petBaseConf.evolution_need_level then
    Log.Debug("UMG_PetEvolution_C:showEvolutionItemPanel | need level=", petBaseConf.evolution_need_level)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.pet_evo_level_not_enough or "", petBaseConf.evolution_need_level))
    return
  end
  local taskId = petBaseConf.evolution_task_id
  if not taskId or taskId <= 0 then
    Log.ErrorFormat("\229\174\160\231\137\169\232\191\155\229\140\150\233\133\141\231\189\174 \228\187\187\229\138\161id\233\148\153\232\175\175, petBaseConf.id=[%d]", petBaseConf.id or 0)
    return
  end
  local checkRet = _G.NRCModuleManager:DoCmd(TaskModuleCmd.checkEvolutionTask, taskId)
  if checkRet then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petevolution_7)
    return
  end
  for _, itemData in ipairs(petBaseConf.evolution_need_items) do
    local itemId = itemData.evolution_need_item
    local needCount = itemData.number
    local itemCount = self:getItemCount(itemId)
    if needCount > itemCount then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petevolution_8)
      return
    end
  end
  local curMoney = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_COIN) or 0
  if curMoney < petBaseConf.evolution_need_money then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petevolution_9)
    return
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetEvolutionItemPanel, {
    petData = petData,
    petBaseConf = petBaseConf,
    curEvolutionIndex = curEvolutionIndex
  })
end

function UMG_PetEvolution_C:showEvolutionTaskPanel()
  local uiData = self.uiData
  local petData = uiData.petData
  local petBaseConf = uiData.petBaseConf
  local curEvolutionIndex = uiData.curEvolutionIndex
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetEvolutionTaskPanel, {
    petData = petData,
    petBaseConf = petBaseConf,
    curEvolutionIndex = curEvolutionIndex
  })
end

function UMG_PetEvolution_C:PlayAniEx(_ani)
  Log.Debug("[UMG_PetEvolution_C:PlayAniEx]:", _ani)
  if _ani then
    if self:IsAnimationPlaying(_ani) then
      self:StopAnimation(_ani)
    end
    self:PlayAnimation(_ani)
  end
end

return UMG_PetEvolution_C
