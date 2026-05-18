local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local SleepingOwlModule = NRCModuleBase:Extend("SleepingOwlModule")
local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local NavigationComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.NavigationComponent")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")

function SleepingOwlModule:OnConstruct()
  _G.SleepingOwlModuleCmd = reload("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleCmd")
  self.data = self:SetData("SleepingOwlModuleData", "NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleData")
  self.fruit_id = nil
  self.last_fruit_id = nil
  self.PetFruitList = nil
  self.SelectedFruitItem = nil
  self.FruitCountDownTime = 0
  self.selectIndex = -1
  self.owlSanctuary = nil
  self.RefreshReason = nil
  self.SelectPetFruitItemData = nil
  self.cacheOpenEquipItemList = {}
  self.NotConfFruit = {}
  self.ItemDeltaTimer = 0
  self.fruitSlotTimerDic = nil
  self.emptySlotTimerDic = nil
  self:RegPanel("SleepingOwlPanel", "UMG_SleepingOwl", _G.Enum.UILayerType.UI_LAYER_POPUP, nil, true, true)
  self:RegPanel("SleepingOwlFruit", "UMG_SleepingOwl_Fruit", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("SleepingOwlHint", "UMG_SleepingOwl_Hint", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("SleepingOwlHint1", "UMG_SleepingOwl_Hint1", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("SleepingOwlTips", "UMG_SleepingOwl_Tips", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("SleepingOwlGoodAndBadiTips", "UMG_SleepingOwl_GoodAndBadi_Tips", _G.Enum.UILayerType.UI_LAYER_POPUP)
  _G.NRCEventCenter:RegisterEvent("SleepingOwlModule", self, SceneEvent.OnPlayerDead, self.DeadClosePanel)
  _G.NRCEventCenter:RegisterEvent("SleepingOwlModule", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  self.OwlRefugeInfo = {}
  self.IsDisabledClose = false
  self.StatusChecker = StatusCheckerGroup({
    StatusCheckerEnum.Scene,
    StatusCheckerEnum.Teleport,
    StatusCheckerEnum.MainPanel,
    StatusCheckerEnum.Battle,
    StatusCheckerEnum.Loading
  }, Log.LOG_LEVEL.ELogDebug)
end

function SleepingOwlModule:RegPanel(name, path, layer, customDisableRendering, isSingleTouchPanel, disablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/SleepingOwl/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customDisableRendering or false
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.enablePcEsc = not disablePcEsc
  self:RegisterPanel(registerData)
end

function SleepingOwlModule:OnOpenOwlLevelUpTips()
  self.StatusChecker:Check(self, self.OnOpenDialogue)
end

function SleepingOwlModule:OnOpenDialogue()
  local Context = DialogContext()
  Context:SetTitle(LuaText.pet_fruit_refresh_title):SetContent(LuaText.pet_fruit_levelup):SetMode(DialogContext.Mode.NotBtn)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog2, Context)
end

function SleepingOwlModule:OnOpenMainPanel(RefugeId, Action)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  NRCModuleManager:DoCmd(FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_OPTION)
  self:OpenPanel("SleepingOwlMainPanel", RefugeId, Action)
end

function SleepingOwlModule:OpenSleepingOwlPanel(Action, NpcData)
  self.Action = Action
  _G.UpdateManager:Register(self)
  if self:HasPanel("SleepingOwlPanel") then
    local Panel = self:GetPanel("SleepingOwlPanel")
    Panel:RefreshPanel(self.RefreshReason)
    self:RefreshPetFruitList()
  else
    self.selectIndex = -1
    self:OpenPanel("SleepingOwlPanel", {action = Action, owlSanctuary = NpcData})
    self:OpenPanel("SleepingOwlFruit")
  end
end

function SleepingOwlModule:OnPreLoadSleepingOwlPanel()
  self:PreLoadPanel("SleepingOwlPanel")
  self:PreLoadPanel("SleepingOwlFruit")
end

function SleepingOwlModule:OpenOwlHintPanel(IsPutIn, index)
  self:OpenPanel("SleepingOwlHint", self.SelectPetFruitItemData, self.SelectedFruitItem, index, IsPutIn)
end

function SleepingOwlModule:GetPetbaseIdByFruitId(FruitId, owlContentId)
  if nil == owlContentId then
    owlContentId = self:GetOwlSanctuaryContentId()
  end
  local owlConf = _G.DataConfigManager:GetOwlSanctuaryConf(owlContentId)
  if not owlConf then
    return nil
  end
  local normalPetBaseId, PetBaseId
  local pet_form_factor_tagList = {}
  local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(FruitId)
  if not owlConf.pet_form_factor_tag then
    pet_form_factor_tagList = {
      Enum.PetFormFacto.PFF_NORMAL
    }
  else
    pet_form_factor_tagList = owlConf.pet_form_factor_tag
  end
  for j = 1, #PetFruitConf.pet_refresh do
    if not PetFruitConf.pet_refresh[j].pet_form_factor_tag or PetFruitConf.pet_refresh[j].pet_form_factor_tag == Enum.PetFormFacto.PFF_NORMAL then
      for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
        local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
        local FirstBaseId = self:GetFirstStageBaseId(BaseId)
        normalPetBaseId = FirstBaseId
      end
    end
    for v = 1, #pet_form_factor_tagList do
      if pet_form_factor_tagList[v] == PetFruitConf.pet_refresh[j].pet_form_factor_tag then
        for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
          local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
          local FirstBaseId = self:GetFirstStageBaseId(BaseId)
          PetBaseId = FirstBaseId
        end
        break
      end
    end
    if PetBaseId then
      break
    end
    if j == #PetFruitConf.pet_refresh then
      PetBaseId = normalPetBaseId
    end
  end
  return PetBaseId
end

function SleepingOwlModule:OpenOwlHint1Panel()
  local dataList = {}
  local leftEquipments = {}
  local joinedEquipments = {}
  local initialEquipments = self.cacheOpenEquipItemList
  local currentEquipments = {}
  local activeDic = {}
  for i = 1, #self.fruit_id do
    activeDic[self.fruit_id[i].BagItemId] = self.fruit_id[i].is_active
    table.insert(currentEquipments, self.fruit_id[i].BagItemId)
  end
  for _, id in ipairs(initialEquipments) do
    if not self:ContainsFruitID(currentEquipments, id) then
      table.insert(leftEquipments, {
        BagItemId = id,
        PetBaseId = self:GetPetbaseIdByFruitId(id)
      })
    end
  end
  for _, id in ipairs(currentEquipments) do
    if not self:ContainsFruitID(initialEquipments, id) and activeDic[id] then
      table.insert(joinedEquipments, {
        BagItemId = id,
        PetBaseId = self:GetPetbaseIdByFruitId(id)
      })
    end
  end
  if #joinedEquipments > 0 then
    table.insert(dataList, {dataList = joinedEquipments, isAdd = true})
  end
  if #dataList > 0 then
    self:OpenPanel("SleepingOwlHint1", dataList)
  end
end

function SleepingOwlModule:OpenOwlFruitTipsPanel(content)
  self:OpenPanel("SleepingOwlTips", content)
end

function SleepingOwlModule:OpenGoodAndBadTips(AdvantageType, DisadvantageType)
  self:OpenPanel("SleepingOwlGoodAndBadiTips", AdvantageType, DisadvantageType)
end

function SleepingOwlModule:OnActive()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    self.OwlRefugeInfo = localPlayer.serverData.owl_refuge_infos
  else
    Log.Error("SleepingOwlModule:OnActive LocalPlayer does not exist")
  end
end

function SleepingOwlModule:CloseUpdate()
  _G.UpdateManager:UnRegister(self)
  self.FruitCountDownTime = 0
end

function SleepingOwlModule:OnTick(deltaTime)
  self.ItemDeltaTimer = self.ItemDeltaTimer + deltaTime
  if self.ItemDeltaTimer >= 0.1 then
    self.ItemDeltaTimer = 0
    if self.emptySlotTimerDic then
      for i, v in pairs(self.emptySlotTimerDic) do
        if self.emptySlotTimerDic[i] > 0 then
          self.emptySlotTimerDic[i] = self.emptySlotTimerDic[i] - 0.1
        end
      end
    end
    if self.fruitSlotTimerDic then
      for i, v in pairs(self.fruitSlotTimerDic) do
        if self.fruitSlotTimerDic[i] > 0 then
          self.fruitSlotTimerDic[i] = self.fruitSlotTimerDic[i] - 0.1
        end
      end
    end
    self:DispatchEvent(SleepingOwlModuleEvent.UpdateTimer, self.fruitSlotTimerDic, self.emptySlotTimerDic)
  end
end

function SleepingOwlModule:GetOwlRefugeInfoByNpcId(NpcId)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.OwlRefugeInfo = localPlayer.serverData.owl_refuge_infos
  for i = 1, #self.OwlRefugeInfo do
    if self.OwlRefugeInfo[i].obj_id == NpcId then
      return self.OwlRefugeInfo[i]
    end
  end
  return nil
end

function SleepingOwlModule:UpdateSleepOwlRefugeInfo(InfoChange)
  for i = 1, #self.OwlRefugeInfo do
    if self.OwlRefugeInfo[i].owl_refuge_cfg_id == InfoChange.refuge_cfg_id then
      local ObtainedIdxs = self.OwlRefugeInfo[i].obtained_reward_idxs
      ObtainedIdxs = InfoChange.obtained_reward_idxs
      return
    end
  end
end

function SleepingOwlModule:OnUnlockSleepOwl(UnlockChange)
  for i = 1, #self.OwlRefugeInfo do
    if self.OwlRefugeInfo[i].owl_refuge_cfg_id == UnlockChange.refuge_cfg_id then
      self.OwlRefugeInfo[i].obtained_owl_time = self.OwlRefugeInfo[i].obtained_owl_time + 1
      return
    end
  end
end

function SleepingOwlModule:OnGetFristCD(timestamp)
  if timestamp and timestamp > 0 then
    local seconds = self:GetActiveCountdown(timestamp)
    if seconds <= 0 then
      return true, nil
    end
    local str = self:GetCdStr(seconds)
    if nil == str then
      return true, nil
    else
      return false, str
    end
  end
  return true, nil
end

function SleepingOwlModule:GetCdStr(seconds)
  local str
  if seconds >= 3600 then
    local hours = math.floor(seconds / 3600)
    local remaining_seconds = seconds % 3600
    local minutes = math.floor(remaining_seconds / 60)
    if 0 == remaining_seconds then
      str = string.format(LuaText.cd_hour, hours, minutes)
    else
      str = string.format(LuaText.cd_hour_minute, hours, minutes)
    end
  elseif seconds >= 60 then
    local minutes = math.floor(seconds / 60)
    str = string.format(LuaText.cd_minute, minutes, seconds % 60)
  else
    str = string.format(LuaText.cd_second, seconds)
  end
  return str
end

function SleepingOwlModule:GetFinishCountdown(timestamp)
  local curTime = _G.ZoneServer:GetServerTime() / 1000
  local remainingTime = curTime - timestamp
  local time = _G.DataConfigManager:GetGlobalConfig("owl_slot_cd") and _G.DataConfigManager:GetGlobalConfig("owl_slot_cd").num * 3600 or 86400
  local countdown = time - remainingTime
  if countdown < 0 then
    countdown = 0
  end
  return countdown
end

function SleepingOwlModule:GetActiveCountdown(timestamp)
  if nil == timestamp then
    return 0
  end
  local curTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local countdown = timestamp - curTime
  if countdown < 0 then
    countdown = 0
  end
  return math.floor(countdown)
end

function SleepingOwlModule:CreatedSlotInfo(owlSanctuaryFruitInfo)
  self.fruitSlotTimerDic = {}
  self.emptySlotTimerDic = {}
  for i = 1, #owlSanctuaryFruitInfo.fruit_data do
    local info = owlSanctuaryFruitInfo.fruit_data[i]
    if info.fruit_active_timestamp and info.fruit_active_timestamp > 0 then
      self.fruitSlotTimerDic[i] = self:GetActiveCountdown(info.fruit_active_timestamp)
    else
      self.fruitSlotTimerDic[i] = 0
    end
    if info.fruit_active_timestamp and info.slot_active_timestamp > 0 then
      self.emptySlotTimerDic[i] = self:GetActiveCountdown(info.slot_active_timestamp)
    else
      self.emptySlotTimerDic[i] = 0
    end
  end
end

function SleepingOwlModule:GetEmptyTimer(key)
  if self.emptySlotTimerDic and self.emptySlotTimerDic[key] then
    return math.floor(self.emptySlotTimerDic[key])
  else
    return 0
  end
end

function SleepingOwlModule:GetFruitTimer(key)
  if self.fruitSlotTimerDic[key] then
    return math.floor(self.fruitSlotTimerDic[key])
  else
    return 0
  end
end

local function SortPetFruitList(a, b)
  return a.sortId > b.sortId
end

local function GetFruitSortId(Type, FactorTag, OwlConf, IsDisabled, isCdFruit)
  local isFactor = false
  local isUnitType = 3 == Type
  if IsDisabled then
    return 0
  end
  if FactorTag then
    for i = 1, #FactorTag do
      if OwlConf.pet_form_factor_tag then
        for j = 1, #OwlConf.pet_form_factor_tag do
          if FactorTag[i] == OwlConf.pet_form_factor_tag[j] then
            isFactor = true
            break
          end
        end
      end
    end
  end
  if isCdFruit then
    if isFactor and isUnitType then
      return 4
    end
    if isUnitType then
      return 3
    end
    if isFactor then
      return 2
    end
    if 2 == Type then
      return 1
    end
  else
    if isFactor and isUnitType then
      return 8
    end
    if isUnitType then
      return 7
    end
    if isFactor then
      return 6
    end
    if 2 == Type then
      return 5
    end
  end
end

function SleepingOwlModule:GetFruitCountDownTime()
  return self.FruitCountDownTime
end

function SleepingOwlModule:GetFruitIdList()
  return self.fruit_id
end

function SleepingOwlModule:RefreshPetFruitList()
  local BagModule = _G.NRCModuleManager:GetModule("BagModule")
  if BagModule then
    local PetFruitList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PET_FRUIT)
    self:SetPetOwlFruitList(PetFruitList)
    if self:HasPanel("SleepingOwlFruit") then
      local Panel = self:GetPanel("SleepingOwlFruit")
      Panel:RefreshPanel(self.SelectPetFruitItemData)
    end
  end
end

function SleepingOwlModule:GetPetFruitList()
  local list = {}
  if self.PetFruitList == nil then
    return list
  end
  local newFruitList = {}
  local timestampDic = {}
  self.PetFruitDic = {}
  for i = 1, #self.PetFruitList do
    local bagId = self.PetFruitList[i].BagItem.id
    local isNotCd = self:OnGetFristCD(self.PetFruitList[i].BagItem.fruit_active_timestamp)
    if isNotCd then
      if nil == self.PetFruitDic[bagId] then
        self.PetFruitDic[bagId] = {}
      end
      table.insert(self.PetFruitDic[bagId], self.PetFruitList[i])
    else
      local timestamp = self.PetFruitList[i].BagItem.fruit_active_timestamp
      if nil == timestampDic[timestamp] then
        timestampDic[timestamp] = {}
      end
      if not timestampDic[timestamp][bagId] then
        timestampDic[timestamp][bagId] = {}
      end
      table.insert(timestampDic[timestamp][bagId], self.PetFruitList[i])
    end
  end
  for bagId, petFruit in pairs(self.PetFruitDic) do
    local fruit = #petFruit > 0 and petFruit[1] or {}
    fruit.BagItem.num = #petFruit
    table.insert(newFruitList, fruit)
  end
  for _, timestampFruits in pairs(timestampDic) do
    for bagId, petFruit in pairs(timestampFruits) do
      local fruit = #petFruit > 0 and petFruit[1] or {}
      fruit.BagItem.num = #petFruit
      table.insert(newFruitList, fruit)
    end
  end
  table.sort(newFruitList, SortPetFruitList)
  for i = 1, #newFruitList do
    if newFruitList[i].BagItem.num > 0 then
      table.insert(list, newFruitList[i])
    end
  end
  return list
end

function SleepingOwlModule:GetPetFruitListItemUpdateData(PetFruitList)
  if nil == PetFruitList then
    return {}
  end
  local list = {}
  for i = 1, #PetFruitList do
    local timestamp = PetFruitList[i].BagItem.fruit_active_timestamp
    if timestamp and timestamp > 0 then
      local seconds = self:GetActiveCountdown(timestamp)
      if seconds > 0 then
        local itemUpdateData = {}
        itemUpdateData.timestamp = timestamp
        itemUpdateData.seconds = seconds
        itemUpdateData.gid = PetFruitList[i].BagItem.gid
        table.insert(list, itemUpdateData)
      end
    end
  end
  return list
end

function SleepingOwlModule:LogNotConfPetFruit()
  local fruitidString = ""
  for i = 1, #self.NotConfFruit do
    fruitidString = fruitidString .. " " .. self.NotConfFruit[i]
  end
  if #self.NotConfFruit > 0 then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("PET_FRUIT_CONF\231\188\186\229\176\145id\228\184\186%s\231\154\132\233\133\141\231\189\174", fruitidString))
  end
end

function SleepingOwlModule:SetOwlSanctuary(npcData)
  self.owlSanctuary = npcData
end

function SleepingOwlModule:GetOwlSanctuary()
  return self.owlSanctuary
end

function SleepingOwlModule:GetOwlSanctuaryContentId()
  if self.owlSanctuary and self.owlSanctuary.sceneCharacter and self.owlSanctuary.sceneCharacter.serverData then
    return self.owlSanctuary.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  end
  return nil
end

function SleepingOwlModule:GetFruitIsDisabled(land, water, pet_refresh)
  if nil == pet_refresh or 0 == #pet_refresh then
    Log.Error("\229\186\135\230\138\164\230\137\128\230\158\156\229\174\158pet_refresh \233\133\141\231\189\174\230\156\137\233\151\174\233\162\152")
    return
  end
  local isDisabled = true
  for h = 1, #pet_refresh do
    local npc_ids = pet_refresh[h].npc_id
    for i = 1, #npc_ids do
      local npc_id = npc_ids[i]
      local owlContentNpcConf = _G.DataConfigManager:GetOwlContentNpcConf(npc_id)
      if not owlContentNpcConf then
        return true
      end
      if owlContentNpcConf.is_land_pet and owlContentNpcConf.is_water_pet then
        if next(land) and next(water) then
          isDisabled = false
        else
          isDisabled = true
          return isDisabled
        end
      elseif owlContentNpcConf.is_land_pet and not owlContentNpcConf.is_water_pet then
        if next(land) then
          isDisabled = false
        else
          isDisabled = true
          return isDisabled
        end
      elseif owlContentNpcConf.is_water_pet and not owlContentNpcConf.is_land_pet then
        if next(water) then
          isDisabled = false
        else
          isDisabled = true
          return isDisabled
        end
      end
    end
  end
  return isDisabled
end

function SleepingOwlModule:SetPetOwlFruitList(PetFruitList)
  if not PetFruitList or not self.owlSanctuary then
    self.PetFruitList = nil
    return
  end
  table.clear(self.PetFruitList)
  table.clear(self.NotConfFruit)
  self.NotConfFruit = {}
  local List = {}
  for i = 1, #PetFruitList do
    local AdvantageType, DisadvantageType
    local IsDisabled = true
    local pet_form_factor_tag = {}
    local pet_form_factor_tagList = {}
    local Type
    local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(PetFruitList[i].id, true)
    if not PetFruitConf then
      table.insert(self.NotConfFruit, PetFruitList[i].id)
    else
      local PetBaseId, normalPetBaseId
      local contentId = self:GetOwlSanctuaryContentId()
      local owlConf = _G.DataConfigManager:GetOwlSanctuaryConf(contentId)
      if not owlConf then
      else
        IsDisabled = self:GetFruitIsDisabled(owlConf.visit_owl_refresh_polygon, owlConf.visit_water_owl_refresh_polygon, PetFruitConf.pet_refresh)
        if not owlConf.pet_form_factor_tag then
          pet_form_factor_tagList = {
            Enum.PetFormFacto.PFF_NORMAL
          }
        else
          pet_form_factor_tagList = owlConf.pet_form_factor_tag
        end
        for j = 1, #PetFruitConf.pet_refresh do
          if not PetFruitConf.pet_refresh[j].pet_form_factor_tag or PetFruitConf.pet_refresh[j].pet_form_factor_tag == Enum.PetFormFacto.PFF_NORMAL then
            for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
              local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
              local FirstBaseId = self:GetFirstStageBaseId(BaseId)
              normalPetBaseId = FirstBaseId
            end
          end
          for v = 1, #pet_form_factor_tagList do
            if pet_form_factor_tagList[v] == PetFruitConf.pet_refresh[j].pet_form_factor_tag then
              table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, pet_form_factor_tagList[v])
              for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
                local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
                local FirstBaseId = self:GetFirstStageBaseId(BaseId)
                PetBaseId = FirstBaseId
              end
              break
            end
          end
          if PetBaseId then
            break
          end
          if j == #PetFruitConf.pet_refresh then
            table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, Enum.PetFormFacto.PFF_NORMAL)
            PetBaseId = normalPetBaseId
          end
        end
        if PetBaseId then
          local petConf = _G.DataConfigManager:GetPetbaseConf(PetBaseId)
          if petConf then
            local PetType = petConf.unit_type
            if PetType then
              for j = 1, #owlConf.advantage_type do
                for k = 1, #PetType do
                  if PetType[k] == owlConf.advantage_type[j] then
                    AdvantageType = true
                    break
                  end
                end
                if AdvantageType then
                  break
                end
              end
            end
          end
        end
        DisadvantageType = false
        if AdvantageType and DisadvantageType then
          Type = 2
        else
          if AdvantageType then
            Type = 3
          end
          if DisadvantageType then
            Type = 1
            PetBaseId = normalPetBaseId
          end
          if not DisadvantageType and not AdvantageType then
            Type = 2
          end
        end
        local isCdFruit = not self:OnGetFristCD(PetFruitList[i].fruit_active_timestamp)
        local SortId = GetFruitSortId(Type, pet_form_factor_tag, owlConf, IsDisabled, isCdFruit)
        table.insert(List, 1, {
          BagItem = PetFruitList[i],
          type = Type,
          PetBaseId = PetBaseId,
          pet_form_factor_tag = pet_form_factor_tag,
          isDisabled = IsDisabled,
          sortId = SortId,
          pos = i - 1
        })
      end
    end
  end
  self.PetFruitList = List
end

function SleepingOwlModule:OnCmdOpenSleepingOwlPanel(Action, NpcData)
  self.fruit_id = {}
  self:SetOwlSanctuary(NpcData)
  self.isFirstOpen = true
  self.cacheOpenEquipItemList = {}
  self:OpenSleepingOwlPanel(Action, NpcData)
end

function SleepingOwlModule:OpenOwlRightFruit(IconData, IconIndex, ContentId)
  self:DispatchEvent(SleepingOwlModuleEvent.ShowCloseOwlBtn, false)
  self.SelectPetFruitItemData = IconData
  self.selectIndex = IconIndex
  local Panel = self:GetPanel("SleepingOwlPanel")
  Panel:RefreshSelectIcon(IconIndex)
  if self:HasPanel("SleepingOwlFruit") then
    local Panel = self:GetPanel("SleepingOwlFruit")
    local PetFruitList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PET_FRUIT)
    self:SetPetOwlFruitList(PetFruitList)
    Panel:RefreshPanel(self.SelectPetFruitItemData, ContentId, IconIndex)
    Panel:PlaySelectInAnimation()
  else
    self:OpenPanel("SleepingOwlFruit", self.SelectPetFruitItemData, self.campfire, ContentId)
  end
end

function SleepingOwlModule:CmdZoneGetOwlSanctuaryFruitInfoReq()
  local owlContentId = self:GetOwlSanctuaryContentId()
  if nil == owlContentId then
    Log.Error("ContenId\230\156\170\230\136\144\229\138\159\232\142\183\229\143\150\229\136\176")
    return
  end
  local playerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local allOwlSanctuaryInfo = _G.DataModelMgr.PlayerDataModel:GetAllPlayerOwlSanctuaryNpcInfo()
  if allOwlSanctuaryInfo then
    for _, actorInfo in ipairs(allOwlSanctuaryInfo) do
      if actorInfo.uin == playerUin then
        if actorInfo.owl_sanctuarys and next(actorInfo.owl_sanctuarys) then
          for _, owlSanctuary in ipairs(actorInfo.owl_sanctuarys) do
            if owlSanctuary.npc_content_id == owlContentId then
              local fruitInfo = {
                fruit_data = {}
              }
              if owlSanctuary.fruit_brief_infos then
                for key, briefInfo in ipairs(owlSanctuary.fruit_brief_infos) do
                  local fruitData = {
                    fruit_id = briefInfo.fruit_id,
                    npc_ids = briefInfo.npc_id,
                    fruit_active_timestamp = briefInfo.fruit_active_timestamp,
                    slot_active_timestamp = briefInfo.slot_active_timestamp,
                    fruit_gid = briefInfo.fruit_gid,
                    is_active = briefInfo.is_active
                  }
                  fruitInfo.fruit_data[key] = fruitData
                end
              end
              self:CmdZoneGetOwlSanctuaryFruitInfoRsp(fruitInfo)
              return
            end
          end
        else
          local fruitInfo = {
            fruit_data = {}
          }
          for i = 1, 2 do
            local fruitData = {
              fruit_id = 0,
              npc_ids = {},
              fruit_active_timestamp = 0,
              slot_active_timestamp = 0,
              fruit_gid = 0,
              is_active = false
            }
            table.insert(fruitInfo.fruit_data, fruitData)
          end
          self:CmdZoneGetOwlSanctuaryFruitInfoRsp(fruitInfo)
          return
        end
      end
    end
  end
end

function SleepingOwlModule:GetFirstStageBaseId(baseId)
  local conf = _G.DataConfigManager:GetPetbaseConf(baseId)
  if conf and conf.stage and conf.stage > 1 then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(conf.degenerate_pet_id, true)
    if nil == petBaseConf then
      return nil
    end
    return self:GetFirstStageBaseId(petBaseConf.id)
  else
    return baseId
  end
end

function SleepingOwlModule:CmdZoneGetOwlSanctuaryFruitInfoRsp(owl_sanctuary_fruit_info)
  self.IsDisabledClose = false
  if owl_sanctuary_fruit_info then
    self:CreatedSlotInfo(owl_sanctuary_fruit_info)
    local fruit_idList = owl_sanctuary_fruit_info.fruit_data
    fruit_idList = fruit_idList or {}
    local List = {}
    for i = 1, #fruit_idList do
      local AdvantageType = false
      local DisadvantageType = false
      local Type = 2
      local pet_form_factor_tag = {}
      local pet_form_factor_tagList = {}
      if 0 == fruit_idList[i].fruit_id then
      else
        local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(fruit_idList[i].fruit_id)
        if self.isFirstOpen then
          table.insert(self.cacheOpenEquipItemList, fruit_idList[i].fruit_id)
        end
        if not PetFruitConf then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("PET_FRUIT_CONF\231\188\186\229\176\145id\228\184\186%d\231\154\132\233\133\141\231\189\174", fruit_idList[i].fruit_id))
        else
          local PetBaseId, normalPetBaseId
          local CampingConf = _G.DataConfigManager:GetOwlSanctuaryConf(self:GetOwlSanctuaryContentId())
          if not CampingConf.pet_form_factor_tag then
            pet_form_factor_tagList = {
              Enum.PetFormFacto.PFF_NORMAL
            }
          else
            pet_form_factor_tagList = CampingConf.pet_form_factor_tag
          end
          for j = 1, #PetFruitConf.pet_refresh do
            if not PetFruitConf.pet_refresh[j].pet_form_factor_tag or PetFruitConf.pet_refresh[j].pet_form_factor_tag == Enum.PetFormFacto.PFF_NORMAL then
              for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
                local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
                local FirstBaseId = self:GetFirstStageBaseId(BaseId)
                normalPetBaseId = FirstBaseId
              end
            end
            for v = 1, #pet_form_factor_tagList do
              if pet_form_factor_tagList[v] == PetFruitConf.pet_refresh[j].pet_form_factor_tag then
                table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, pet_form_factor_tagList[v])
                for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
                  local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
                  local FirstBaseId = self:GetFirstStageBaseId(BaseId)
                  PetBaseId = FirstBaseId
                  DisadvantageType = true
                end
                break
              end
            end
            if PetBaseId then
              break
            end
            if j == #PetFruitConf.pet_refresh then
              table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, Enum.PetFormFacto.PFF_NORMAL)
              PetBaseId = normalPetBaseId
            end
          end
          if PetBaseId and _G.DataConfigManager:GetPetbaseConf(PetBaseId).unit_type then
            local PetType = _G.DataConfigManager:GetPetbaseConf(PetBaseId).unit_type
            for j = 1, #CampingConf.advantage_type do
              for k = 1, #PetType do
                if PetType[k] == CampingConf.advantage_type[j] then
                  AdvantageType = true
                  break
                end
              end
              if AdvantageType then
                break
              end
            end
          end
          if AdvantageType and DisadvantageType then
            Type = 2
          else
            if AdvantageType then
              Type = 3
            end
            if DisadvantageType then
              Type = 1
              PetBaseId = normalPetBaseId
            end
            if not DisadvantageType and not AdvantageType then
              Type = 2
            end
          end
          table.insert(List, 1, {
            gid = fruit_idList[i].fruit_gid,
            BagItemId = fruit_idList[i].fruit_id,
            AdvantageType = Type,
            PetBaseId = PetBaseId,
            pet_form_factor_tag = pet_form_factor_tag,
            active_timestamp = fruit_idList[i].fruit_active_timestamp,
            is_active = fruit_idList[i].is_active,
            pos = i - 1
          })
        end
      end
    end
    self.fruit_id = List
    self.last_fruit_id = {}
    for i = 1, #self.fruit_id do
      table.insert(self.last_fruit_id, self.fruit_id[i])
    end
    self:DispatchEvent(SleepingOwlModuleEvent.AutoSelectItem)
  end
  self.owlSanctuary.fruitInfo = owl_sanctuary_fruit_info
  self.isFirstOpen = false
end

function SleepingOwlModule:SetSelectedFruitItem(index, ItemData)
  self.SelectedFruitItem = ItemData
  if self:HasPanel("SleepingOwlFruit") then
    local Panel = self:GetPanel("SleepingOwlFruit")
    Panel:SetSelectFruitItemIndex(index, ItemData)
  end
end

function SleepingOwlModule:ContainsFruitID(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function SleepingOwlModule:OnSetSendFruitData(isAdd, itemData)
  local contentId = self:GetOwlSanctuaryContentId()
  local OwlConf = _G.DataConfigManager:GetOwlSanctuaryConf(contentId)
  local isBigOwl = OwlConf and OwlConf.owl_sanctuary_type == _G.Enum.OwlSanctuaryType.OST_BIG
  local listCount = isBigOwl and 2 or 1
  local fruitDatas = {}
  local fruitPos
  for i = 1, listCount do
    if self.fruit_id[i] then
      fruitPos = self.fruit_id[i].pos
      table.insert(fruitDatas, {
        fruit_id = self.fruit_id[i].BagItemId,
        fruit_gid = self.fruit_id[i].gid,
        pos = self.fruit_id[i].pos
      })
    else
      fruitPos = 0 == fruitPos and 1 or 0
      table.insert(fruitDatas, {
        fruit_id = 0,
        fruit_gid = 0,
        pos = fruitPos
      })
    end
  end
  if false == isAdd then
    for i = 1, #fruitDatas do
      local fruitData = fruitDatas[i]
      if fruitData.fruit_gid == itemData.gid then
        fruitData.fruit_id = 0
        fruitData.fruit_gid = 0
        break
      end
    end
  else
    for i = 1, #fruitDatas do
      local fruitData = fruitDatas[i]
      if fruitData.pos == itemData.pos then
        fruitData.fruit_id = itemData.BagItemId
        fruitData.fruit_gid = itemData.gid
        break
      end
    end
  end
  table.sort(fruitDatas, function(a, b)
    return a.pos < b.pos
  end)
  return fruitDatas
end

function SleepingOwlModule:CmdZoneSceneSetOwlSanctuaryFruitReq(isAdd, itemData)
  self.IsDisabledClose = true
  if self.lastReqTime and os.time() - self.lastReqTime < 1 then
    return
  end
  self.lastReqTime = os.time()
  local req = ProtoMessage:newZoneSceneSetOwlSanctuaryFruitReq()
  local content_id = self:GetOwlSanctuaryContentId()
  req.content_id = content_id and content_id or 0
  req.fruit_data = {}
  req.fruit_data = self:OnSetSendFruitData(isAdd, itemData)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_SET_OWL_SANCTUARY_FRUIT_REQ, req, self, self.CmdZoneSceneSetOwlSanctuaryFruitRsp, true, false)
end

function SleepingOwlModule:CmdZoneSceneSetOwlSanctuaryFruitRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:RefreshPetFruitList()
    self:CmdZoneGetOwlSanctuaryFruitInfoReq()
    self.owlSanctuary:OnFruitDataUpdate()
  end
end

function SleepingOwlModule:EquipPutFruitInOwlSanctuary()
  if self.SelectedFruitItem then
    local gid = self.SelectedFruitItem.BagItem.gid
    local selectItem = {}
    for i = 1, #self.PetFruitList do
      local fruitItem = self.PetFruitList[i]
      if fruitItem and fruitItem.BagItem.gid == gid then
        selectItem.gid = fruitItem.BagItem.gid
        selectItem.BagItemId = fruitItem.BagItem.id
        selectItem.AdvantageType = fruitItem.type
        selectItem.PetBaseId = fruitItem.PetBaseId
        selectItem.fruitIimes = fruitItem.BagItem.fruit_active_timestamp or 0
        selectItem.pet_form_factor_tag = fruitItem.pet_form_factor_tag
        table.remove(self.PetFruitList, i)
        break
      end
    end
    selectItem.pos = self.selectIndex
    local addItem = {
      gid = selectItem.gid,
      BagItemId = selectItem.BagItemId,
      pos = self.selectIndex
    }
    if not _G.GlobalConfig.DebugOpenUI then
      self:CmdZoneSceneSetOwlSanctuaryFruitReq(true, addItem)
    end
  end
end

function SleepingOwlModule:UnEquipPutFruitInOwlSanctuary(id, gid)
  local removeItem = {}
  for i = 1, #self.fruit_id do
    if self.fruit_id[i] and self.fruit_id[i].BagItemId == id and self.fruit_id[i].gid == gid then
      removeItem.gid = self.fruit_id[i].gid
      removeItem.BagItemId = self.fruit_id[i].BagItemId
      removeItem.pos = self.fruit_id[i].pos
      break
    end
  end
  local bagItem = {}
  bagItem.gid = gid
  bagItem.id = id
  bagItem.num = 1
  bagItem.type = _G.Enum.BagItemType.BI_PET_FRUIT
  local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(id)
  local contentId = self:GetOwlSanctuaryContentId()
  local OwlConf = _G.DataConfigManager:GetOwlSanctuaryConf(contentId)
  if nil == PetFruitConf or nil == OwlConf then
    return
  end
  local IsDisabled = self:GetFruitIsDisabled(OwlConf.visit_owl_refresh_polygon, OwlConf.visit_water_owl_refresh_polygon, PetFruitConf.pet_refresh)
  local PetBaseId, normalPetBaseId
  local pet_form_factor_tagList = {}
  local pet_form_factor_tag = {}
  if not OwlConf.pet_form_factor_tag then
    pet_form_factor_tagList = {
      Enum.PetFormFacto.PFF_NORMAL
    }
  else
    pet_form_factor_tagList = OwlConf.pet_form_factor_tag
  end
  for j = 1, #PetFruitConf.pet_refresh do
    if not PetFruitConf.pet_refresh[j].pet_form_factor_tag or PetFruitConf.pet_refresh[j].pet_form_factor_tag == Enum.PetFormFacto.PFF_NORMAL then
      for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
        local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
        local FirstBaseId = self:GetFirstStageBaseId(BaseId)
        normalPetBaseId = FirstBaseId
      end
    end
    for v = 1, #pet_form_factor_tagList do
      if pet_form_factor_tagList[v] == PetFruitConf.pet_refresh[j].pet_form_factor_tag then
        table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, pet_form_factor_tagList[v])
        for k = 1, #PetFruitConf.pet_refresh[j].npc_id do
          local BaseId = _G.DataConfigManager:GetNpcConf(PetFruitConf.pet_refresh[j].npc_id[k]).traverse_data_param[1]
          local FirstBaseId = self:GetFirstStageBaseId(BaseId)
          PetBaseId = FirstBaseId
        end
        break
      end
    end
    if PetBaseId then
      break
    end
    if j == #PetFruitConf.pet_refresh then
      table.insert(pet_form_factor_tag, #pet_form_factor_tag + 1, Enum.PetFormFacto.PFF_NORMAL)
      PetBaseId = normalPetBaseId
    end
  end
  local isCdFruit = not self:OnGetFristCD(bagItem.fruit_active_timestamp)
  local SortId = GetFruitSortId(2, pet_form_factor_tag, OwlConf, IsDisabled, isCdFruit)
  table.insert(self.PetFruitList, {
    BagItem = bagItem,
    type = 2,
    PetBaseId = PetBaseId,
    pet_form_factor_tag = pet_form_factor_tag,
    isDisabled = IsDisabled,
    sortId = SortId
  })
  if not _G.GlobalConfig.DebugOpenUI then
    self:CmdZoneSceneSetOwlSanctuaryFruitReq(false, removeItem)
  end
end

function SleepingOwlModule:OnLogin(isRelogin)
  if isRelogin then
    self:DeadClosePanel()
  end
end

function SleepingOwlModule:OnDialogueEnded()
  self:DeadClosePanel()
end

function SleepingOwlModule:DeadClosePanel()
  if self:HasPanel("SleepingOwlFruit") then
    self:ClosePanel("SleepingOwlFruit")
  end
  if self:HasPanel("SleepingOwlPanel") then
    self:ClosePanel("SleepingOwlPanel")
  end
  self.IsDisabledClose = false
end

function SleepingOwlModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnPlayerDead, self.DeadClosePanel)
  if self.DelayID then
    _G.DelayManager:CancelDelayById(self.DelayID)
    self.DelayID = nil
  end
end

function SleepingOwlModule:OnDestruct()
end

function SleepingOwlModule:OnCmdReceiveSanctuaryDetected(OwlSanctuaryDetected)
  if nil == OwlSanctuaryDetected then
    return
  end
  local newDetectedSanctuaryInfo = OwlSanctuaryDetected.owl_sanctuary_info
  if newDetectedSanctuaryInfo then
    _G.DataModelMgr.PlayerDataModel:UpdateOwlSanctuaryNpcInfo(newDetectedSanctuaryInfo)
    _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.UpdateOwlSanctuaryNpcData, newDetectedSanctuaryInfo)
    local owlSceneNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, newDetectedSanctuaryInfo.npc_obj_id)
    if owlSceneNPC and owlSceneNPC.MarkHadDetected then
      owlSceneNPC:MarkHadDetected()
    end
  end
end

function SleepingOwlModule:OnCmdReceiveUpdateOwlSanctuaryFruit(OwlSanctuaryFruitInfoUpdate)
  if nil == OwlSanctuaryFruitInfoUpdate or nil == OwlSanctuaryFruitInfoUpdate.owl_sanctuary_infos then
    Log.Debug("SleepingOwlModule:OnCmdReceiveUpdateOwlSanctuaryFruit owl_sanctuary_infos is nil")
    return
  end
  for _, owl_sanctuary_info in pairs(OwlSanctuaryFruitInfoUpdate.owl_sanctuary_infos) do
    local TempInfoUpdate = ProtoMessage:newSpaceAct_OwlSanctuaryFruitInfoUpdate()
    TempInfoUpdate.owl_content_id = owl_sanctuary_info.npc_content_id
    for _, data in pairs(owl_sanctuary_info.fruit_info.fruit_data) do
      local TempFruitInfo = ProtoMessage:newOwlSanctuaryFruitBriefInfo()
      TempFruitInfo.fruit_id = data.fruit_id
      TempFruitInfo.fruit_active_timestamp = data.fruit_active_timestamp
      TempFruitInfo.npc_id = data.npc_ids
      TempFruitInfo.slot_active_timestamp = data.slot_active_timestamp
      TempFruitInfo.fruit_gid = data.fruit_gid
      TempFruitInfo.is_active = data.is_active
      table.insert(TempInfoUpdate.fruit_infos, TempFruitInfo)
    end
    local avatarOwlSanctuaryInfo = _G.DataModelMgr.PlayerDataModel:UpdateOwlSanctuaryFruitInfo(owl_sanctuary_info.npc_content_id, TempInfoUpdate.fruit_infos, OwlSanctuaryFruitInfoUpdate.uin, owl_sanctuary_info.is_upgrade, owl_sanctuary_info.detect_info)
    local PlayerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
    if OwlSanctuaryFruitInfoUpdate.uin == PlayerUin and avatarOwlSanctuaryInfo then
      _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.UpdateOwlSanctuaryNpcData, avatarOwlSanctuaryInfo)
    end
  end
end

return SleepingOwlModule
