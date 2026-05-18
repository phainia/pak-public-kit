local UMG_Magic_Details_C = _G.NRCPanelBase:Extend("UMG_Magic_Details_C")

function UMG_Magic_Details_C:OnConstruct()
  self.uiData = {}
  self.uiData.CompleteIconList = {
    self.Complete,
    self.Complete_1,
    self.Complete_2
  }
  self:PlayAnimation(self.open)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_Magic_Details_C:OnConstruct")
end

function UMG_Magic_Details_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Magic_Details_C:OnActive(campfire)
  self.campfire = campfire
  self:OnAddEventListener()
  self:RefreshPanel()
end

function UMG_Magic_Details_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_Magic_Details_C:OnAddEventListener()
  self:AddButtonListener(self.backBtn, self.OnCloseBtnClick)
end

function UMG_Magic_Details_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.backBtn, self.OnCloseBtnClick)
end

function UMG_Magic_Details_C:OnAnimationFinished(anim)
  if anim == self.close then
    self:DoClose()
  end
end

function UMG_Magic_Details_C:OnCloseBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1007, "UMG_Magic_Nourish_C:OnCloseBtnClick")
  if self:IsAnimationPlaying(self.close) then
    return
  end
  self:PlayAnimation(self.close)
end

function UMG_Magic_Details_C:RefreshPanel()
  local campingId = self.campfire.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  local campingLv = self.campfire.sceneCharacter.serverData.base.lv
  local campingCfg = _G.DataConfigManager:GetCampConf(campingId)
  self.TreeTitle:SetText(campingCfg.name)
  local campingIconPath, lvIconPath = self.module:GetCampingIconPathByLv(campingLv)
  self.TreeIcon:SetPath(campingIconPath)
  self.LevelIcon:SetPath(lvIconPath)
  local placeName = _G.DataConfigManager:GetAreaFuncConf(campingCfg.area_id).name
  self.Place_Names:SetText(placeName)
  local listData = self:GetListDataByCampingIdAndLv(campingId, 1)
  self.List:InitGridView(listData)
  self:LogWarningRefreshIds(listData)
  local list1Data = self:GetListDataByCampingIdAndLv(campingId, 2)
  self.List_1:InitGridView(list1Data)
  self:LogWarningRefreshIds(list1Data)
  local list2Data = self:GetListDataByCampingIdAndLv(campingId, 3)
  self.List_2:InitGridView(list2Data)
  self:LogWarningRefreshIds(list2Data)
  local CompleteIconList = self.uiData.CompleteIconList
  for i, icon in ipairs(CompleteIconList) do
    icon:SetVisibility(i <= campingLv and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
  end
  self.Describe:SetText(_G.DataConfigManager:GetLocalizationConf("Camp_LevelUp_Details").msg)
end

function UMG_Magic_Details_C:LogWarningRefreshIds(listData)
  local t = {}
  for _, v in ipairs(listData) do
    table.insert(t, v.refreshId)
  end
  local logStr = table.concat(t, " ")
  Log.Warning(logStr)
end

function UMG_Magic_Details_C:GetListDataByCampingIdAndLv(campingId, campingLv)
  local petbaseList = {}
  local petRefreshConfs = self.module:GetPetRefreshConfsByCampingIdAndLevel(campingId, campingLv, true)
  local petListMap = {}
  local maxStage = 1
  for _, refreshCfg in ipairs(petRefreshConfs) do
    local npcCfg = _G.DataConfigManager:GetNpcConf(refreshCfg.cfg.npc_id)
    local petbase_id = npcCfg.traverse_data_param[1]
    local petbaseCfg = _G.DataConfigManager:GetPetbaseConf(petbase_id)
    table.insert(petbaseList, petbaseCfg)
    petListMap[petbaseCfg.id] = {
      refreshId = refreshCfg.id,
      cfg = petbaseCfg,
      isLvOK = refreshCfg.isLvOK,
      isProcessed = false
    }
    if maxStage < petbaseCfg.stage then
      maxStage = petbaseCfg.stage
    end
  end
  local petListData = {}
  for stage = 1, maxStage do
    for _, petbase in ipairs(petbaseList) do
      if petbase.stage == stage and petListMap[petbase.id].isProcessed == false then
        petListMap[petbase.id].isProcessed = true
        local petSubList = {}
        local petData = {
          cfg = petbase,
          hasLink = false,
          isLvOK = petListMap[petbase.id].isLvOK,
          refreshId = petListMap[petbase.id].refreshId
        }
        table.insert(petSubList, petData)
        local curPet = petData
        while #curPet.cfg.evolution_pet_id > 0 and petListMap[curPet.cfg.evolution_pet_id[1]] and false == petListMap[curPet.cfg.evolution_pet_id[1]].isProcessed do
          local evolutionId = curPet.cfg.evolution_pet_id[1]
          petListMap[evolutionId].isProcessed = true
          curPet.hasLink = true
          local nextPetData = {
            cfg = petListMap[evolutionId].cfg,
            hasLink = false,
            isLvOK = petListMap[evolutionId].isLvOK,
            refreshId = petListMap[petbase.id].refreshId
          }
          table.insert(petSubList, nextPetData)
          curPet = nextPetData
        end
        table.insert(petListData, petSubList)
      end
    end
  end
  local petShowData = {}
  for _, petList in ipairs(petListData) do
    for _, pet in ipairs(petList) do
      petShowData[#petShowData + 1] = pet
    end
  end
  if petShowData[#petShowData] then
    petShowData[#petShowData].hasLink = true
  end
  return petShowData
end

function UMG_Magic_Details_C:SetRedDot(value)
  if self.RedDot then
    self.RedDot:SetupKey(value)
  else
    self:LogError("cannt find reddot")
  end
end

return UMG_Magic_Details_C
