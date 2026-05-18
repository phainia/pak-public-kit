local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Travel_Begin_List_C = Base:Extend("UMG_Travel_Begin_List_C")

function UMG_Travel_Begin_List_C:OnConstruct()
end

function UMG_Travel_Begin_List_C:OnDestruct()
end

function UMG_Travel_Begin_List_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local petList = self:GetPetDatas(self.data)
  local conf = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetCampLevelConf, self.data.camp_content_id, self.data.camp_lv)
  local campConf = _G.DataConfigManager:GetCampConf(self.data.camp_content_id)
  local campName = campConf.camp_name
  local hours = self:SecondsToTime(conf.travel_time)
  if self.data.isAward then
    self.Rewards:SetVisibility(UE4.ESlateVisibility.Visible)
    local datas = self:AddEggRewardItem(conf.reward_item)
    self.List:InitGridView(datas)
    self.Countdown:SetText(string.format(LuaText.umg_travel_1, hours))
  else
    self.Countdown:SetText(string.format(LuaText.umg_travel_begin_1, hours))
    self.Rewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Place:SetText(campName)
  self.List_3:InitGridView(petList)
end

function UMG_Travel_Begin_List_C:SecondsToTime(seconds)
  local hours = math.floor(seconds / 3600)
  seconds = seconds % 3600
  return hours
end

function UMG_Travel_Begin_List_C:SetTalentEffectReward(petData)
  local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
  if PetTalentConf and PetTalentConf.effect_group and #PetTalentConf.effect_group then
    for _, effect in ipairs(PetTalentConf.effect_group) do
      if effect.effect == Enum.PetTalentEffect.PTE_TRAVEL_REWARD then
        table.insert(self.TalentEffectReward, effect.effect_param / 10000)
      end
    end
  end
end

function UMG_Travel_Begin_List_C:GetRealNum(_num)
  local num
  if self.TalentEffectReward and #self.TalentEffectReward > 0 then
    for _, EffectPercent in ipairs(self.TalentEffectReward) do
      if EffectPercent then
        if num then
          num = num + math.ceil(EffectPercent * _num)
        else
          num = _num + math.ceil(EffectPercent * _num)
        end
      end
    end
  end
  return num or _num
end

function UMG_Travel_Begin_List_C:AddEggRewardItem(rewards)
  local datas = {}
  for i = 1, #rewards do
    local data = {}
    data.reward_item_type = rewards[i].reward_item_type
    data.reward_item_id = rewards[i].reward_item_id
    data.reward_item_num = rewards[i].reward_item_num
    data.isEgg = false
    data.isOther = false
    table.insert(datas, data)
    if self.TalentEffectReward and #self.TalentEffectReward > 0 then
      local talentData = {}
      talentData.reward_item_type = rewards[i].reward_item_type
      talentData.reward_item_id = rewards[i].reward_item_id
      talentData.reward_item_num = self:GetRealNum(data.reward_item_num) - data.reward_item_num
      talentData.isEgg = false
      talentData.isOther = true
      table.insert(datas, talentData)
    end
  end
  local eggData = {}
  local petDataDic = self:GetAllPetDataDic()
  if self.data and self.data.will_lay_egg then
    local eggId = 0
    for i, gid in pairs(self.data.pet_gid) do
      if petDataDic[gid] then
        local petData = petDataDic[gid]
        if 2 == petData.gender then
          local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
          if petbaseConf then
            eggId = petbaseConf.pet_egg
          end
        end
      end
    end
    if 0 ~= eggId then
      eggData.reward_item_type = _G.Enum.GoodsType.GT_BAGITEM
      eggData.reward_item_id = eggId
      eggData.reward_item_num = 1
      eggData.isEgg = true
      eggData.isOther = true
      table.insert(datas, eggData)
    end
  end
  return datas
end

function UMG_Travel_Begin_List_C:GetPetDatas(travelInfo)
  local gids = travelInfo.pet_gid
  local petDataDic = self:GetAllPetDataDic()
  self.TalentEffectReward = {}
  local datas = {}
  for i = 1, #gids do
    local gid = gids[i]
    if petDataDic[gid] then
      local petData = petDataDic[gid]
      self:SetTalentEffectReward(petData)
      if petData.gid == gid then
        local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
        local types = petbaseConf.unit_type
        local info = {}
        info.gid = petData.gid
        info.baseId = petData.base_conf_id
        info.isShowTips = true
        table.insert(datas, info)
      end
    end
  end
  return datas
end

function UMG_Travel_Begin_List_C:GetAllPetDataDic()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data
  local petDataDic = {}
  for i, petData in pairs(battlePetList) do
    petDataDic[petData.gid] = petData
  end
  for i, petData in pairs(bagPetList) do
    petDataDic[petData.gid] = petData
  end
  for i, petData in pairs(petList) do
    petDataDic[petData.gid] = petData
  end
  return petDataDic
end

function UMG_Travel_Begin_List_C:OnItemSelected(_bSelected)
end

function UMG_Travel_Begin_List_C:OnDeactive()
end

return UMG_Travel_Begin_List_C
