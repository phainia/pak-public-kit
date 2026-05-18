local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_LookBack_C = _G.NRCPanelBase:Extend("UMG_Travel_LookBack_C")

function UMG_Travel_LookBack_C:OnActive(campId, campLv, petDatas, rewards)
  self.campLevelConf = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, campId, campLv)
  self.petDatas = petDatas
  for i = 1, #self.petDatas do
    self.petDatas[i].isShowTips = true
  end
  local CampingInfo = _G.DataConfigManager:GetCampConf(self.campLevelConf.content_id)
  local AreaInfo = _G.DataConfigManager:GetAreaFuncConf(CampingInfo.area_id)
  local timeStr = self:FormatTime(self.campLevelConf.travel_time)
  local datas = self:GetRewardDatas(rewards)
  self.Place_Names:SetText(AreaInfo.name)
  self.TimeRemaining:SetText(timeStr)
  self.List:InitGridView(datas)
  self.List_3:InitGridView(self.petDatas)
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
end

function UMG_Travel_LookBack_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
  self.isResetTravel = false
  self.bgProxy = _G.NRCModuleManager:DoCmd(TUIModuleCmd.PushBlackBackgroundWidgets, {
    self.FullStateMask
  })
  self:OnAddEventListener()
end

function UMG_Travel_LookBack_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Desc = _G.DataConfigManager:GetLocalizationConf("pet_remove_text").msg
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCloseBtn
  CommonPopUpData.Btn_RightHandler = self.OnResetBtn
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Travel_LookBack_C:FormatTime(seconds)
  local hours = math.floor(seconds / 3600)
  return string.format(LuaText.umg_travel_lookback_1, hours)
end

function UMG_Travel_LookBack_C:OnDeactive()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.bgProxy)
end

function UMG_Travel_LookBack_C:OnAddEventListener()
end

function UMG_Travel_LookBack_C:OnCloseBtn()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_Travel_LookBack_C:OnCloseBtn")
  self.isResetTravel = false
  self:LoadAnimation(2)
end

function UMG_Travel_LookBack_C:OnResetBtn()
  self.isResetTravel = true
  self:LoadAnimation(2)
end

function UMG_Travel_LookBack_C:GetRewardDatas(rewards)
  local datas = {}
  local levelRewards = self.campLevelConf.reward_item
  if rewards then
    for i, reward in pairs(rewards) do
      local info = {}
      info.reward_item_type = reward.type
      info.reward_item_id = reward.id or 0
      info.reward_item_num = reward.num
      info.isEgg = false
      info.isOther = false
      if info.reward_item_type == _G.Enum.GoodsType.GT_BAGITEM then
        local bagItemConf = _G.DataConfigManager:GetBagItemConf(info.reward_item_id)
        if bagItemConf and bagItemConf.type == _G.Enum.BagItemType.BI_PET_EGG then
          info.isEgg = true
          info.isOther = true
        end
      end
      for j, levelReward in pairs(levelRewards) do
        if levelReward.reward_item_id == reward.id then
          info.reward_item_num = reward.num - levelReward.reward_item_num
          info.isOther = true
        end
      end
      if info.reward_item_num > 0 then
        table.insert(datas, info)
      end
    end
    for _, levelReward in pairs(levelRewards) do
      local info = {}
      info.reward_item_type = levelReward.reward_item_type
      info.reward_item_id = levelReward.reward_item_id or 0
      info.reward_item_num = levelReward.reward_item_num
      table.insert(datas, info)
    end
    table.sort(datas, function(a, b)
      if a.reward_item_id == b.reward_item_id then
        return self:GetSortIndex(a) < self:GetSortIndex(b)
      else
        return a.reward_item_id < b.reward_item_id
      end
    end)
  end
  return datas
end

function UMG_Travel_LookBack_C:GetSortIndex(data)
  if data.isOther and data.isEgg then
    return 2
  elseif data.isOther and data.isEgg == false then
    return 1
  else
    return 0
  end
end

function UMG_Travel_LookBack_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    if self.isResetTravel then
      local key1, key2 = 1, 2
      _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ClearSelectTravelPet)
      for i, v in pairs(self.petDatas) do
        _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTravelPet, i, v.gid, v.baseId, v.level)
      end
      _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.ZoneStartPetTravelReq, self.campLevelConf.content_id, self.campLevelConf.level)
    else
      _G.NRCEventCenter:DispatchEvent(TravelModuleEvent.OnOutTravel, self.campLevelConf.content_id)
    end
    self:DoClose()
  end
end

return UMG_Travel_LookBack_C
