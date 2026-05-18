local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_DuringJourney_C = _G.NRCPanelBase:Extend("UMG_Travel_DuringJourney_C")

function UMG_Travel_DuringJourney_C:OnActive(npcInfo)
  self.travelInfo = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfo, npcInfo.npc_refresh_id)
  self.CheckMark_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Egg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CheckMark:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Egg_1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.npcInfo = npcInfo
  if self.travelInfo then
    self:PlayInAnim()
    local CampingInfo = _G.DataConfigManager:GetCampConf(self.travelInfo.camp_content_id)
    local CampLevelInfo = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, self.travelInfo.camp_content_id, self.travelInfo.camp_lv)
    if nil == CampLevelInfo then
      Log.Error("\233\133\141\231\189\174\229\143\175\232\131\189\230\156\137\232\175\175 camp_content_id", self.travelInfo.camp_content_id)
      return
    end
    local svr_time = math.floor(_G.ZoneServer:GetServerTime() / 1000)
    local finishTime = self.travelInfo.start_travel_sec + CampLevelInfo.travel_time
    self.cacheFinishTime = finishTime
    if self.travelInfo.travel_complete then
      self.downTime = 0
    else
      self.downTime = math.clamp(finishTime - svr_time, 0, finishTime)
    end
    self.advantage_type = CampingInfo.advantage_type
    self.disadvantage_type = CampingInfo.disadvantage_type
    self.NRCSwitcher_70:SetActiveWidgetIndex(not self.travelInfo.travel_complete and 0 or 1)
    local petList = self:GetPetDatas(self.travelInfo)
    self.List_3:InitGridView(petList)
    if self.travelInfo.travel_complete then
      if self.DelayId then
        _G.DelayManager:CancelDelayById(self.DelayId)
        self.DelayId = nil
      end
      self.NRCSwitcher_70:SetActiveWidgetIndex(self.travelInfo.will_lay_egg and 1 or 2)
    else
      if self.DelayId then
        _G.DelayManager:CancelDelayById(self.DelayId)
        self.DelayId = nil
      end
      self:OnDownTime()
    end
  end
end

function UMG_Travel_DuringJourney_C:PlayCloseAnim()
  self:PlayAnimation(self.Out)
  self.bIsPlayIn = false
end

function UMG_Travel_DuringJourney_C:PlayInAnim()
  if not self.bIsPlayIn and not self:IsAnimationPlaying(self.In) then
    self.bIsPlayIn = true
    self:PlayAnimation(self.In)
  end
end

function UMG_Travel_DuringJourney_C:OnAnimationFinished(anim)
  if anim == self.Out then
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.UpdateTravelInfos)
  elseif anim == self.In then
  end
end

function UMG_Travel_DuringJourney_C:FormatTime(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor(seconds % 3600 / 60)
  local s = seconds % 60
  return string.format(LuaText.umg_travel_duringjourney_1, hours, minutes, s)
end

function UMG_Travel_DuringJourney_C:GetPetDatas(travelInfo)
  local gids = travelInfo.pet_gid
  local petDataDic = self:GetAllPetDataDic()
  local datas = {}
  for i = 1, #gids do
    local gid = gids[i]
    if petDataDic[gid] then
      local petData = petDataDic[gid]
      if petData.gid == gid then
        local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
        local types = petbaseConf.unit_type
        local info = {}
        info.gid = petData.gid
        info.baseId = petData.base_conf_id
        info.advantage = self:GetAdvantageNumber(types)
        table.insert(datas, info)
      end
    end
  end
  return datas
end

function UMG_Travel_DuringJourney_C:GetAllPetDataDic()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local petDataDic = {}
  for i, petData in pairs(battlePetList) do
    if nil ~= petData and nil ~= petData.gid then
      petDataDic[petData.gid] = petData
    end
  end
  for i, petData in pairs(bagPetList) do
    if nil ~= petData and nil ~= petData.gid then
      petDataDic[petData.gid] = petData
    end
  end
  for i, petData in pairs(petList) do
    if nil ~= petData and nil ~= petData.gid then
      petDataDic[petData.gid] = petData
    end
  end
  return petDataDic
end

function UMG_Travel_DuringJourney_C:GetAdvantageNumber(types)
  local advantage = 0
  if self.advantage_type and self.disadvantage_type then
    for i = 1, #types do
      local petType = types[i]
      for j = 1, #self.advantage_type do
        local goodType = self.advantage_type[j]
        if petType == goodType then
          advantage = advantage + 1
        end
      end
      for k = 1, #self.disadvantage_type do
        local badType = self.disadvantage_type[k]
        if petType == badType then
          advantage = advantage - 1
        end
      end
    end
  end
  return advantage
end

function UMG_Travel_DuringJourney_C:SetParent(parent)
  self.parent = parent
end

function UMG_Travel_DuringJourney_C:OnDownTime()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  local str = self:FormatTime(self.downTime)
  self.Text_Time:SetText(str)
  if self.downTime <= 0 then
    self.downTime = 0
    _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.UpdateTravelInfos)
    if self.DelayId then
      _G.DelayManager:CancelDelayById(self.DelayId)
      self.DelayId = nil
    end
    NRCEventCenter:DispatchEvent(TravelModuleEvent.OnUpdateTravelCountdown, self.travelInfo.camp_content_id, self.downTime)
    return
  end
  NRCEventCenter:DispatchEvent(TravelModuleEvent.OnUpdateTravelCountdown, self.travelInfo.camp_content_id, self.downTime)
  self.downTime = self.downTime - 1
  self.DelayId = _G.DelayManager:DelaySeconds(1, self.OnDownTime, self)
end

function UMG_Travel_DuringJourney_C:GetTravelDownTime()
  return self.downTime
end

function UMG_Travel_DuringJourney_C:OnDeactive()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_Travel_DuringJourney_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
  self.cacheFinishTime = nil
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnServerTimeUpdate, self.OnServerTimeUpdate)
end

function UMG_Travel_DuringJourney_C:OnConstruct()
  self.cacheFinishTime = nil
  self:OnAddEventListener()
end

function UMG_Travel_DuringJourney_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_57, self.ClickPanel)
  _G.NRCEventCenter:RegisterEvent("UMG_Travel_DuringJourney_C", self, _G.NRCGlobalEvent.OnServerTimeUpdate, self.OnServerTimeUpdate)
end

function UMG_Travel_DuringJourney_C:OnServerTimeUpdate()
  if self.cacheFinishTime and self.travelInfo then
    local svr_time = math.floor(_G.ZoneServer:GetServerTime() / 1000)
    local finishTime = self.cacheFinishTime
    if finishTime then
      if self.travelInfo.travel_complete then
        self.downTime = 0
      else
        self.downTime = math.clamp(finishTime - svr_time, 0, finishTime)
        if self.DelayId then
          _G.DelayManager:CancelDelayById(self.DelayId)
          self.DelayId = nil
        end
        self:OnDownTime()
      end
    end
  end
end

function UMG_Travel_DuringJourney_C:ClickPanel()
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.OpenTravelPanel, self.npcInfo, self.downTime, false)
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OnTravelShowMouseIcon, self.npcInfo)
end

return UMG_Travel_DuringJourney_C
