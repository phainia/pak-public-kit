local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_FriendHome_EntranceItem1_C = Base:Extend("UMG_FriendHome_EntranceItem1_C")

function UMG_FriendHome_EntranceItem1_C:OnConstruct()
end

function UMG_FriendHome_EntranceItem1_C:OnDestruct()
  if self._timer then
    _G.TimerManager:RemoveTimer(self._timer)
    self._timer = nil
  end
end

function UMG_FriendHome_EntranceItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if not self.data then
    Log.Error("UMG_FriendHome_EntranceItem1_C:OnItemUpdate()-->_data is nil")
    return
  end
  if not _data.plantSeedId then
    self:UpdatePet(index)
  else
    self:UpdatePlant()
  end
end

function UMG_FriendHome_EntranceItem1_C:OnTimeUpdate()
  local starTime = self.data.home_pet_info.feed_info.begin_time / 1000000
  local costTime = self.data.home_pet_info.feed_info.time_cost / 1000000
  local curTime = _G.ZoneServer:GetServerTime() / 1000
  local countdownTime = starTime + costTime - curTime
  if countdownTime > 0 then
    self.ProgressBar_76:SetPercent(1 - countdownTime / costTime)
  end
end

function UMG_FriendHome_EntranceItem1_C:OnCountdownOver()
  self.ProgressBar_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RedDot:ShowRedPoint(true)
end

function UMG_FriendHome_EntranceItem1_C:OnItemSelected(_bSelected)
  if not self.data then
    return
  end
  if _bSelected then
    if self.data.plantSeedId then
      local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(self.data.plantSeedId)
      if plantGrowConf and plantGrowConf.plant_harvest then
        _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, plantGrowConf.plant_harvest, Enum.GoodsType.GT_BAGITEM, false)
      end
    else
      if self.petData == nil then
        self.petData = {}
        if self.data and self.data.display_info then
          self.petData.speciality_id = self.data.display_info.speciality_id
          self.petData.base_conf_id = self.data.display_info.base_conf_id
          self.petData.gender = self.data.display_info.gender
          self.petData.name = self.data.display_info.name
          self.petData.level = self.data.display_info.level
          self.petData.mutation_type = self.data.display_info.mutation_type
          self.petData.shine_color_id = self.data.display_info.shine_color_id
          self.petData.energy = self.data.display_info.energy
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.display_info.base_conf_id)
          if petBaseConf then
            self.petData.max_energy = petBaseConf.max_energy
          end
          self.petData.blood_id = self.data.display_info.blood_id
          self.petData.attribute_new_info = self.data.display_info.attribute_new_info
          self.petData.attribute_info = self.data.display_info.attribute_info
          self.petData.skill = self.data.display_info.skill
          self.petData.nature = self.data.display_info.nature
          self.petData.changed_nature_neg_attr_type = self.data.display_info.changed_nature_neg_attr_type
          self.petData.changed_nature_pos_attr_type = self.data.display_info.changed_nature_pos_attr_type
          self.petData.last_breakthrough_lv = self.data.display_info.last_breakthrough_lv or 0
        end
      end
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.petData)
    end
  end
end

function UMG_FriendHome_EntranceItem1_C:UpdatePet(index)
  self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Textclass:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ProgressBar_76:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.data and self.data.display_info then
    self.NRCpetIcon:SetIconPathAndMaterial(self.data.display_info.base_conf_id, self.data.display_info.mutation_type, self.data.display_info.glass_info)
    self.Textclass:SetText(self.data.display_info.level)
  end
  self.RedDot:ShowRedPoint(false)
  self.ProgressBar_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.home_pet_info.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_IN_PRODUCT then
    local starTime = self.data.home_pet_info.feed_info.begin_time / 1000000
    local costTime = self.data.home_pet_info.feed_info.time_cost / 1000000
    local curTime = _G.ZoneServer:GetServerTime() / 1000
    local countdownTime = starTime + costTime - curTime
    if countdownTime > 0 then
      if self._timer then
        _G.TimerManager:RemoveTimer(self._timer)
        self._timer = nil
      end
      self.ProgressBar_76:SetPercent(1 - countdownTime / costTime)
      self.ProgressBar_76:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self._timer = _G.TimerManager:CreateTimer(self, "UMG_FriendHome_EntranceItem1_C-Countdown" .. index, countdownTime, self.OnTimeUpdate, self.OnCountdownOver, 1)
    else
      self.RedDot:ShowRedPoint(true)
    end
  elseif self.data.home_pet_info.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_CAN_STEAL and self.data.can_steal then
    self.RedDot:ShowRedPoint(true)
  end
end

function UMG_FriendHome_EntranceItem1_C:UpdatePlant()
  self.RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Textclass:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ProgressBar_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(self.data.plantSeedId)
  if plantGrowConf and plantGrowConf.plant_harvest then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(plantGrowConf.plant_harvest)
    if bagItemConf then
      self.ItemIcon:SetPath(bagItemConf.big_icon)
    end
  end
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local bShowRedPoint = self.data.bGrowFinish == true
  if self.data.bStealAble ~= nil then
    bShowRedPoint = self.data.bStealAble
  end
  if bShowRedPoint then
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_FriendHome_EntranceItem1_C
