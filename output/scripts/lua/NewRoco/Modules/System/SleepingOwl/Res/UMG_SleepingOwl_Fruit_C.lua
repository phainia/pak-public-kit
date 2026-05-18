local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local UMG_SleepingOwl_Fruit_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Fruit_C")

function UMG_SleepingOwl_Fruit_C:OnConstruct()
end

function UMG_SleepingOwl_Fruit_C:OnActive(ItemData, owlSanctuary)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:Disable()
  local OwlNpcData = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.GetOwlSanctuary)
  if OwlNpcData and OwlNpcData.sceneCharacter then
    self.contentId = OwlNpcData.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  end
  local IsVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  if IsVisit then
    self.PanelFlag = false
    self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Sanctuary.btnLevelUp.OnClicked:Add(self, self.OnSanctuaryClick)
  else
    self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.NoFruitText:SetText(_G.DataConfigManager:GetLocalizationConf("have_no_pet_fruit_tips").msg)
  self.owlSanctuary = owlSanctuary
  self.SelectItemIndex = nil
  self.CanDropOff = true
  self:OnAddEventListener()
  if self:IsAnimationPlaying(self.Select_In) or self:IsAnimationPlaying(self.Select_Out) then
    return
  end
end

function UMG_SleepingOwl_Fruit_C:OnSanctuaryClick()
  if self.PanelFlag then
    self.Unfold:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PanelFlag = false
  else
    self.Unfold:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PanelFlag = true
  end
end

function UMG_SleepingOwl_Fruit_C:OnShowFruitPanel()
  if not self.IsShow then
    self:DelaySeconds(1, function()
      self:PlayAnimation(self.Select_In)
      self.IsSelectIn = true
      self.Select:SetShowLockIcon(false)
      self.Time:SetShowLockIcon(false)
      self.Time:SetTitleTextColor("#c7494aFF")
      self:Enable()
      self.IsShow = true
    end, self)
  end
end

function UMG_SleepingOwl_Fruit_C:PlaySelectInAnimation()
  if self.IsSelectIn then
    return
  end
  self.IsSelectIn = true
  if self:IsAnimationPlaying(self.Select_In) or self:IsAnimationPlaying(self.Select_Out) then
    return
  end
  self:PlayAnimation(self.Select_In)
end

function UMG_SleepingOwl_Fruit_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:RemoveEventListener()
  self:CancelDelay()
  _G.NRCEventCenter:DispatchEvent(SleepingOwlModuleEvent.PanelDestroy)
end

function UMG_SleepingOwl_Fruit_C:RefreshPanel(ItemData, ContentId, index)
  self.ItemData = ItemData
  self.ItemIndex = index
  self.CDprompt:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnShowFruitPanel()
  local OwlNpcData = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.GetOwlSanctuary)
  if OwlNpcData and OwlNpcData.sceneCharacter then
    self.contentId = OwlNpcData.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  end
  if self.contentId then
    local conf = _G.DataConfigManager:GetOwlSanctuaryConf(self.contentId)
    if conf.advantage_type and #conf.advantage_type > 0 then
      self.GoodAndBad:OnActive(conf.advantage_type)
      self.GoodAndBad:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.GoodAndBad:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if conf.owl_sanctuary_type == _G.Enum.OwlSanctuaryType.OST_BIG then
      self.Title:SetText(_G.DataConfigManager:GetLocalizationConf("sanctuary_title_big").msg)
    else
      self.Title:SetText(_G.DataConfigManager:GetLocalizationConf("sanctuary_title_small").msg)
    end
  end
  local PetFruitList = self.module:GetPetFruitList()
  if nil == PetFruitList then
    PetFruitList = {}
  end
  self.List:Clear()
  if PetFruitList and #PetFruitList >= 1 then
    self.List:ClearSelection()
    self.List:InitGridView(PetFruitList)
    self:TimingUpdateListItem(PetFruitList)
  end
  local IsVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  if IsVisit then
    local tempInfo = {}
    local OnlinetempInfo = _G.DataModelMgr.PlayerDataModel:GetAllPlayerOwlSanctuaryNpcInfo()
    if nil ~= OnlinetempInfo and nil ~= next(OnlinetempInfo) then
      for _, OwlSanctuary in pairs(OnlinetempInfo) do
        local uin = OwlSanctuary.uin
        for _, OwlSanctuaryInfo in pairs(OwlSanctuary.owl_sanctuarys) do
          local FruitInfo = ProtoMessage:newSpaceAct_OwlSanctuaryFruitInfoUpdate()
          FruitInfo.owl_content_id = OwlSanctuaryInfo.npc_content_id
          FruitInfo.fruit_infos = {}
          if nil ~= next(OwlSanctuaryInfo.fruit_brief_infos) then
            for key, value in ipairs(OwlSanctuaryInfo.fruit_brief_infos) do
              FruitInfo.fruit_infos[key] = value
            end
          end
          FruitInfo.uin = uin
          tempInfo[OwlSanctuaryInfo.npc_content_id] = tempInfo[OwlSanctuaryInfo.npc_content_id] or {}
          tempInfo[OwlSanctuaryInfo.npc_content_id][uin] = FruitInfo
        end
      end
    end
    local TargetOwlInfo = tempInfo[self.contentId] or {}
    local FriendFruitList = {}
    local playerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
    for uin, info in pairs(TargetOwlInfo) do
      if uin and uin ~= playerUin then
        local temp = {}
        temp.uin = uin
        temp.FruitInfo = {}
        for _, v in pairs(info.fruit_infos) do
          table.insert(temp.FruitInfo, v)
        end
        local visitIndex = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorIndex, uin) or nil
        temp.visitindex = visitIndex
        table.insert(FriendFruitList, temp)
      end
    end
    if nil ~= FriendFruitList and nil ~= next(FriendFruitList) then
      table.sort(FriendFruitList, function(a, b)
        local index_a = a.visitindex or 999999
        local index_b = b.visitindex or 999999
        return index_a < index_b
      end)
      self.FriendFruit:InitGridView(FriendFruitList)
    end
  end
  if self.ItemData then
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local Time = self.module:GetFruitTimer(index and index + 1 or nil)
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.ItemData.BagItemId)
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.ItemData.PetBaseId)
    local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(self.ItemData.BagItemId)
    self:OnShowFruitTime(Time)
    self.BtnSwitcher:SetActiveWidgetByWidgetName("Dropoff")
    if 2 ~= self.ItemData.AdvantageType then
      self.Switcher_175:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if 3 ~= self.ItemData.AdvantageType then
        self.Switcher_175:SetActiveWidgetIndex(1)
      else
        self.Switcher_175:SetActiveWidgetIndex(0)
      end
    else
      self.Switcher_175:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local isHaveBook, itemName, itemDesc = _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdCheckItemInHandbook, BagItemConf.id)
    self.NRCImage_101:SetPath(BagItemConf.big_icon)
    if isHaveBook then
      self.Describe:SetText(itemDesc)
    else
      self.Describe:SetText(BagItemConf.description)
    end
    for i = 1, #self.ItemData.pet_form_factor_tag do
      if self.ItemData.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
        self.Factor:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local factor_desc
        for j = 1, #PetFruitConf.pet_refresh do
          if PetFruitConf.pet_refresh[j].pet_form_factor_tag == self.ItemData.pet_form_factor_tag[i] then
            factor_desc = PetFruitConf.pet_refresh[j].factor_desc
          end
        end
        self.MaxLevelHint1:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_change_preview").msg, factor_desc, PetBaseConf.form))
        break
      end
      if i == #self.ItemData.pet_form_factor_tag then
        self.Factor:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.PanelSwitcher:SetActiveWidgetByWidgetName("Property")
  elseif PetFruitList and #PetFruitList >= 1 then
    self.BtnSwitcher:SetActiveWidgetByWidgetName("Select")
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.PanelSwitcher:SetActiveWidgetByWidgetName("FruitList")
  else
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PanelSwitcher:SetActiveWidgetByWidgetName("ForOwning")
  end
  self:ShowEmptySlotTimeDownText(index)
end

function UMG_SleepingOwl_Fruit_C:ShowEmptySlotTimeDownText(index)
  if nil == index then
    return
  end
  local timer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetEmptyTimer, index + 1)
  if timer > 0 then
    self.CDprompt:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local timeStr = self.module:GetCdStr(timer)
    local des = string.format(LuaText.owl_slot_cd_tip, timeStr)
    self.Title_1:SetText(des)
  else
    self.CDprompt:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SleepingOwl_Fruit_C:OnShowFruitTime(timer)
  if timer and timer > 0 then
    local timeStr = self.module:GetCdStr(timer)
    self.FruitCoolingTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_UsageCount_1:SetText(string.format(LuaText.fruit_CD, timeStr))
  else
    self.FruitCoolingTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SleepingOwl_Fruit_C:SortFruitData()
end

function UMG_SleepingOwl_Fruit_C:SetSelectFruitItemIndex(Index, ItemData)
  if 1 == ItemData.type then
    self.Btn_PutIn:SetClickAble(false)
  else
    self.Btn_PutIn:SetClickAble(true)
  end
  self.SelectItemIndex = Index
  self.BtnSwitcher:SetActiveWidgetByWidgetName("Fruit")
  self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_SleepingOwl_Fruit_C:SetTimeDownText()
  if self.ItemData and self.ItemIndex then
    local Timer = self.module:GetFruitTimer(self.ItemIndex + 1)
    self:OnShowFruitTime(Timer)
    self.BtnSwitcher:SetActiveWidgetByWidgetName("Dropoff")
  end
  if self.ItemIndex then
    self:ShowEmptySlotTimeDownText(self.ItemIndex)
  end
end

function UMG_SleepingOwl_Fruit_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.Select.btnLevelUp, self.ShowTips)
  self:AddButtonListener(self.Btn_PutIn.btnLevelUp, self.OnPutInBtnClick)
  self:AddButtonListener(self.Btn_Dropoff.btnLevelUp, self.OnDropOffBtnClick)
  self:RegisterEvent(self, SleepingOwlModuleEvent.UpdateTimer, self.SetTimeDownText)
end

function UMG_SleepingOwl_Fruit_C:RemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:RemoveButtonListener(self.Select.btnLevelUp, self.ShowTips)
  self:RemoveButtonListener(self.Btn_PutIn.btnLevelUp, self.OnPutInBtnClick)
  self:RemoveButtonListener(self.Btn_Dropoff.btnLevelUp, self.OnDropOffBtnClick)
  self:UnRegisterEvent(self, SleepingOwlModuleEvent.UpdateTimer)
end

function UMG_SleepingOwl_Fruit_C:OnPutInBtnClick()
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlHintPanel, true, self.ItemIndex)
end

function UMG_SleepingOwl_Fruit_C:OnDropOffBtnClick()
  if not self.ItemIndex then
    Log.Warning("OnDropOffBtnClick index is nil")
    return
  end
  local slotTimer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetEmptyTimer, self.ItemIndex + 1)
  local fruitTimer = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetFruitTimer, self.ItemIndex + 1)
  if slotTimer > 0 or fruitTimer > 0 then
    if self.ItemData then
      self.module:UnEquipPutFruitInOwlSanctuary(self.ItemData.BagItemId, self.ItemData.gid)
    end
  else
    _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlHintPanel, false, self.ItemIndex)
  end
end

function UMG_SleepingOwl_Fruit_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1007, "CampingModule:OpenNourishRightFruit")
  if self:IsAnimationPlaying(self.Select_In) or self:IsAnimationPlaying(self.Select_Out) then
    return
  end
  if self.module.IsDisabledClose then
    return
  end
  self.IsSelectIn = false
  self:DispatchEvent(SleepingOwlModuleEvent.ShowCloseOwlBtn, true)
  self:PlayAnimation(self.Select_Out)
end

function UMG_SleepingOwl_Fruit_C:ShowTips()
  if self.clickCd ~= nil and os.time() - self.clickCd < 2 then
    return
  end
  self.clickCd = os.time()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.pet_fruit_use_tips_no_fruit)
end

function UMG_SleepingOwl_Fruit_C:TimingUpdateListItem(PetFruitList)
  local timingDatas = _G.NRCModuleManager:DoCmd(SleepingOwlModuleCmd.GetPetFruitListItemUpdateData, PetFruitList)
  if nil == timingDatas then
    return
  end
  if self.IsShow then
    self:CancelDelay()
  end
  for i = 1, #timingDatas do
    local data = timingDatas[i]
    self:DelaySeconds(data.seconds, function()
      for j = 1, #PetFruitList do
        if PetFruitList[j].BagItem.gid == data.gid then
          local item = self.List:GetItemByIndex(j - 1)
          item:OnUpdateTime()
          break
        end
      end
    end, self)
  end
end

function UMG_SleepingOwl_Fruit_C:OnAnimationFinished(anim)
  if anim == self.Select_Out then
    self:DoClose()
  end
  if anim == self.Select_In and 0 == self.PanelSwitcher:GetActiveWidgetIndex() and self.module then
    self.module:LogNotConfPetFruit()
  end
end

return UMG_SleepingOwl_Fruit_C
