local UMG_Home_Feed_C = _G.NRCPanelBase:Extend("UMG_Home_Feed_C")

function UMG_Home_Feed_C:OnConstruct()
end

function UMG_Home_Feed_C:OnActive()
  local currentActiveNest
  self.currentFurnitureId = nil
  if not self.currentFurnitureId then
    Log.Error("UMG_Home_Feed_C OnActive currentFurnitureId nil")
    return
  end
  local petDataTable = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPairNestAndPet, self.currentFurnitureId)
  self.currentPetHomeData = petDataTable[2]
  if not self.currentPetHomeData or not self.currentPetHomeData.gid then
    Log.Error("UMG_Home_Feed_C OnActive currentPetHomeData nil")
    return
  end
  self.currentPetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.currentPetHomeData.gid)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.currentPetData.conf_id)
  local evoId = petBaseConf.pet_evolution_id[1]
  local evoConf = _G.DataConfigManager:GetPetEvolutionConf(evoId)
  if not evoConf then
    return
  end
  self.consumeItemId = evoConf.home_feed_bagitem_id
  self:SetCommonTitle()
  self:ShowPetPreview()
  self:AddButtonListener(self.BtnFeed.bLevelUp, self.OnConfirmFeed)
  self:AddButtonListener(self.BtnStopFeeding.bLevelUp, self.OnStopFeed)
  self:AddButtonListener(self.Btn_Close, self.OnClosePanel)
end

function UMG_Home_Feed_C:InitFeedList()
  local feedConf = _G.DataConfigManager:GetHomePetFeedConf()
  local feedConfigData = {}
  for _, v in feedConf, nil, nil, nil do
    local needTime = feedConf.need_Time
    if not needTime or #needTime <= 0 then
      return
    end
    table.insert({
      minTime = needTime[1],
      maxTime = needTime[#needTime],
      remainTime = -1,
      consumeItemId = self.consumeItemId,
      needCount = feedConf.needNum
    })
  end
  self.ItemList_4:InitList(feedConfigData)
end

function UMG_Home_Feed_C:InitShowReward()
end

function UMG_Home_Feed_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if self.titleConf.title then
    self.Title1:Set_MainTitle(self.titleConf.title)
  end
  if self.titleConf.head_icon then
    self.Title1:SetBg(self.titleConf.head_icon)
  end
  if self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
end

function UMG_Home_Feed_C:ShowPetPreview()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.currentPetData.conf_id)
  if not petBaseConf then
    return
  end
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  local modelPath = modelConf.path
  self:LoadPanelRes(modelPath, 255, self.LoadPetModelSucceed, nil, nil)
end

function UMG_Home_Feed_C:LoadPetModelSucceed(resRequest, petModel)
  if not petModel then
    Log.Error("UMG_HomePetChoose_C OnScrollPetItemSelected load model failed ", resRequest or "")
    return
  end
  self.homePetPreviewPanel:SetPetPreview(self, self.currentSelectPet.base_conf_id)
end

function UMG_Home_Feed_C:OnConfirmFeed()
end

function UMG_Home_Feed_C:OnStopFeed()
end

function UMG_Home_Feed_C:OnClosePanel()
  self:DoClose()
end

return UMG_Home_Feed_C
