local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChallengeItem_C = Base:Extend("UMG_ChallengeItem_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
UMG_ChallengeItem_C.ChallengeType = {
  None = 0,
  FlowerData = 1,
  BossData = 2,
  LegendData = 3
}
UMG_ChallengeItem_C.LockType = {
  None = 0,
  CampLock = 1,
  TaskLock = 2
}

function UMG_ChallengeItem_C:OnConstruct()
  self.TheShinyFlowerDescField = MagicManualUtils.InitFlowerCueBubble(self.CueBubble, self, self.OnGetFlowerData)
  self.Btn2:SetBtnText(LuaText.umg_npcinfo_2)
  self.Btn2:SetClickAble(false)
  self.Btn2:SetShowLockIcon(false)
  self.Text_Time_2:SetText(LuaText.umg_petleftpanel_8)
  self.NotCollectedText:SetText(string.format("(%s)", LuaText.pet_not_collected))
  self:AddButtonListener(self.DepartmentBtn, self.OnOpenPetTips)
  self:AddButtonListener(self.FlowerBloodBtn, self.OnOpenBloodTips)
  if self.BossDepartmentBtn then
    self:AddButtonListener(self.BossDepartmentBtn, self.OnOpenPetTips)
  end
  self:AddButtonListener(self.UMG_Details.btnLevelUp, self.OnOpenPetInfoPanel)
  self.DistanceText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.ItemRequired then
    self.ItemRequired:SetText(_G.LuaText.worldmap_tips_reward_text)
  end
end

function UMG_ChallengeItem_C:OnDestruct()
  self:RemoveButtonListener(self.DepartmentBtn, self.OnOpenPetTips)
  self:RemoveButtonListener(self.FlowerBloodBtn, self.OnOpenBloodTips)
  self:RemoveButtonListener(self.BossDepartmentBtn, self.OnOpenPetTips)
  self:RemoveButtonListener(self.UMG_Details.btnLevelUp, self.OnOpenPetInfoPanel)
end

function UMG_ChallengeItem_C:OnItemUpdate(_data, datalist, index)
  self.FlowerData = _data
  self.BossData = _data.data
  self.LegendData = _data
  self.index = index
  self.DataType = _data.dataType
  self.lockState = _data.LockType
  self.WorldCombatConf = _data.WorldCombatConf
  self.needTick = false
  if self.Boss_Right then
    self.Boss_Right:EndInertialScrolling()
    self.Boss_Right:ScrollToStart()
  end
  self.FlowerSeed_Right:EndInertialScrolling()
  self.FlowerSeed_Right:ScrollToStart()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Btn1.btnLevelUp.OnClicked:Add(self, self.NotFoundClick)
  if self.Btn and self.Btn.btnLevelUp and self.Btn.btnLevelUp.OnClicked then
    self.Btn.btnLevelUp.OnClicked:Add(self, self.TraceBtnClick)
  else
    Log.Error("self.Btn or self.Btn.btnLevelUp or self.Btn.btnLevelUp.OnClicked Not Found")
  end
end

function UMG_ChallengeItem_C:OnSpawn()
  if self.DataType == self.ChallengeType.FlowerData then
    if self.Switcher then
      self.Switcher:SetActiveWidgetIndex(0)
    end
    self:SetFlowerDataInfo()
  elseif self.DataType == self.ChallengeType.BossData then
    if self.Switcher then
      self.Switcher:SetActiveWidgetIndex(1)
    end
    self:SetBossDataInfo()
  elseif self.DataType == self.ChallengeType.LegendData then
    if self.Switcher then
      self.Switcher:SetActiveWidgetIndex(1)
    end
    self:SetLegendDataInfo()
  end
end

function UMG_ChallengeItem_C:OnUpdateStarNum()
  if self.DataType == self.ChallengeType.FlowerData then
    local useStarNum = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_starlink", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
    local costNum2 = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_starlink", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
    self.StarEnergy_5:SetText(useStarNum)
    self.StarEnergy_3:SetText(costNum2)
    local colorEnough = "#F4EEE1FF"
    local colorRed = "#AF3A3DFF"
    local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    if costNum2 > StarDebrisNum and useStarNum > StarNum then
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    else
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    end
  elseif self.DataType == self.ChallengeType.BossData then
    local StarAwardConf = _G.DataConfigManager:GetStarAwardConf(self.WorldCombatConf.trophy_id)
    local useStarNum = StarAwardConf and StarAwardConf.star_amount or 0
    local costNum2 = StarAwardConf and StarAwardConf.star_amount or 0
    self.StarEnergy_3:SetText(useStarNum)
    self.StarEnergy_5:SetText(costNum2)
    local colorEnough = "#F4EEE1FF"
    local colorRed = "#AF3A3DFF"
    local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    if costNum2 > StarDebrisNum and useStarNum > StarNum then
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    else
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    end
  elseif self.DataType == self.ChallengeType.LegendData then
    local useStarNum = _G.DataConfigManager:GetLegendaryGlobalConfig("star_consume").num
    local costItemId1, costNum2 = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetLegendaryTicketIDAndNum)
    self.StarEnergy_3:SetText(useStarNum)
    self.StarEnergy_5:SetText(costNum2)
    local colorEnough = "#F4EEE1FF"
    local colorRed = "#AF3A3DFF"
    local StarDebrisNum = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId1)
    if nil == StarDebrisNum then
      StarDebrisNum = 0
    else
      StarDebrisNum = StarDebrisNum.num
    end
    local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
    if costNum2 > StarDebrisNum and useStarNum > StarNum then
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    else
      self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
      self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    end
  end
end

function UMG_ChallengeItem_C:SetActivityFlowerUpDateTime()
  if self.FlowerData and self.FlowerData.end_timestamp then
    local refreshTime = self.FlowerData.end_timestamp - _G.ZoneServer:GetServerTime() / 1000
    if refreshTime > 0 then
      local day = math.floor(refreshTime / 86400)
      local hour = math.floor((refreshTime - day * 86400) / 3600)
      local min = math.floor((refreshTime - day * 86400 - hour * 3600) / 60)
      local btnText = 0
      if day > 0 then
        btnText = string.format(LuaText.magicmanual_challenge_countdown05, day, hour)
      else
        btnText = string.format(LuaText.magicmanual_challenge_countdown01, hour, min)
      end
      self.Text_Time:SetText(btnText)
      self.Text_Time2:SetText(btnText)
      self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChallengeItem_C:SetBtnBgByUnitType(UnitType, seasonLegendaryID)
  if seasonLegendaryID then
    local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
    if seasonLegendaryDataConf then
      local bgPath = seasonLegendaryDataConf.frame_1
      if nil ~= bgPath and "" ~= bgPath then
        self.Department_5:SetPath(bgPath)
        return
      end
    end
  end
  if UnitType == Enum.SkillDamType.SDT_COMMON then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Normal.img_Normal'")
  elseif UnitType == Enum.SkillDamType.SDT_GRASS then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_cao.img_cao'")
  elseif UnitType == Enum.SkillDamType.SDT_FIRE then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_fire.img_fire'")
  elseif UnitType == Enum.SkillDamType.SDT_WATER then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_water.img_water'")
  elseif UnitType == Enum.SkillDamType.SDT_LIGHT then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Light.img_Light'")
  elseif UnitType == Enum.SkillDamType.SDT_STONE then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Ground.img_Ground'")
  elseif UnitType == Enum.SkillDamType.SDT_ICE then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_lce.img_lce'")
  elseif UnitType == Enum.SkillDamType.SDT_DRAGON then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Loong.img_Loong'")
  elseif UnitType == Enum.SkillDamType.SDT_ELECTRIC then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Electric.img_Electric'")
  elseif UnitType == Enum.SkillDamType.SDT_TOXIC then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Poison.img_Poison'")
  elseif UnitType == Enum.SkillDamType.SDT_INSECT then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Bug.img_Bug'")
  elseif UnitType == Enum.SkillDamType.SDT_FIGHT then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Fighting.img_Fighting'")
  elseif UnitType == Enum.SkillDamType.SDT_WING then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Flying.img_Flying'")
  elseif UnitType == Enum.SkillDamType.SDT_MOE then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Moe.img_Moe'")
  elseif UnitType == Enum.SkillDamType.SDT_GHOST then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Ghost.img_Ghost'")
  elseif UnitType == Enum.SkillDamType.SDT_DEMON then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Demon.img_Demon'")
  elseif UnitType == Enum.SkillDamType.SDT_MECHANIC then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Steel.img_Steel'")
  elseif UnitType == Enum.SkillDamType.SDT_PHANTOM then
    self.Department_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/TitleBg/img_Phantom.img_Phantom'")
  end
end

function UMG_ChallengeItem_C:SetFlowerDataInfo(IsMapToMagicManual)
  if not self.FlowerData then
    return
  end
  self.DataType = self.ChallengeType.FlowerData
  if IsMapToMagicManual then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  if vItemsConf then
    self.img_star_3:SetPath(vItemsConf.iconPath)
  end
  self.TimeSwitcher_0:SetActiveWidgetIndex(0)
  if self.FlowerData.BookState == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
    self.NotCollectedText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NotCollectedText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local AwardList = _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.GetTeamBattleAwards, self.FlowerData.star, self.FlowerData.blood)
  if not AwardList then
    self:LogError("invalid flower data, star|blood", self.FlowerData.star, self.FlowerData.blood)
    AwardList = {}
  end
  local rewardsTable = {}
  local dropReward = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetSpecificTimeActivityReward, ProtoEnum.ActivityDropShowArea.ADSA_FLOWER)
  if dropReward then
    for i, v in ipairs(dropReward) do
      v.tag = Enum.RewardTag.RTA_ACTIVITY
      v.reward_reason = ProtoEnum.FlowReason.FLOW_REASON_ACTIVITY_DROP
      table.insert(rewardsTable, v)
    end
  end
  for k, v in ipairs(AwardList) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    if rewards.itemNum > 0 then
      rewards.bShowNum = true
    else
      rewards.bShowNum = false
    end
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.FlowerData.battle_petbase_id)
  self.Text_Name_Flower:SetText(petBaseConf.name)
  self.StarNumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local levelText = self.FlowerData.level
  if self.FlowerData.IsReCom then
    self.StarNumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.StarNumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.IsReCom = self.FlowerData.IsReCom
  self.StarNumText:SetText(string.format(LuaText.umg_petskilltemple2_1, levelText))
  self.img_star_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/17.17'")
  local useStarNum = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_starlink", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
  local costNum2 = _G.DataConfigManager:GetGlobalConfigByKeyType("team_battle_starlink", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num
  self.StarEnergy_5:SetText(useStarNum)
  self.StarEnergy_3:SetText(costNum2)
  local colorEnough = "#F4EEE1FF"
  local colorRed = "#AF3A3DFF"
  local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
  if costNum2 > StarDebrisNum and useStarNum > StarNum then
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
  else
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
  end
  local bloodConf = _G.DataConfigManager:GetPetBloodConf(self.FlowerData.blood)
  self.Icon_Flower:SetPath(bloodConf.icon_flower)
  local bloodAttrData = {}
  table.insert(bloodAttrData, {
    Name = bloodConf.blood_name,
    Path = bloodConf.icon
  })
  self.Attr_Blood:InitGridView(bloodAttrData)
  self:SetBgColor(bloodConf.blood_type)
  self:SetBtnBgByUnitType(bloodConf.blood_type)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.FlowerData.battle_petbase_id)
  local petAttrData = {}
  local unit_type = petBaseConf.unit_type
  for i = 1, #unit_type do
    local petType = petBaseConf.unit_type[i]
    table.insert(petAttrData, {Type = petType})
  end
  _G.DelayManager:DelayFrames(1, function()
    self.Attr_Pet:InitGridView(petAttrData)
    self.FlowerSeed_ItemIist:InitGridView(rewardsTable)
  end)
  if not petBaseConf then
    self:LogError("invalid flower data, petbase_id", self.FlowerData.battle_petbase_id)
  else
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.PetHeadIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
  end
  self.BtnSwitch:SetActiveWidgetIndex(0)
  self.is_camp_unlock = self.FlowerData.is_camp_unlock
  if self.is_camp_unlock then
    self.Btn:SetBtnText(LuaText.umg_npcinfo_2)
  else
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if NpcRefreshID and NpcRefreshID > 0 then
      local NPCId = NpcRefreshID
      if self.FlowerData.content_cfg_id then
        if self.FlowerData.content_cfg_id == NPCId then
          self.Btn:SetBtnText(LuaText.head_to_cancel)
        else
          self.Btn:SetBtnText(LuaText.head_to)
        end
      else
        self.Btn:SetBtnText(LuaText.head_to)
      end
    else
      self.Btn:SetBtnText(LuaText.head_to)
    end
    self.Distance = self.FlowerData.Distance
    self.isBigMapScene = self.FlowerData.isBigMapScene
    if self.isBigMapScene then
      self.Text_Time_1:SetText(self.Distance)
      self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Text_Time_1:SetText(LuaText.magic_manual_distance_invalid)
      self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:SetActivityFlowerUpDateTime()
  self:UpdateShinyFlowerInfo()
  self:SetFlowerSeedFusionInfo()
end

function UMG_ChallengeItem_C:SetFlowerSeedFusionInfo()
  if self.FlowerData.visit_flower_seed_boss_datas and self.FlowerSeedSharingOnline then
    self.FlowerSeedSharingOnline:SetVisibility(UE.ESlateVisibility.Visible)
    local visit_flower_seed_boss_datas = {}
    for k, v in ipairs(self.FlowerData.visit_flower_seed_boss_datas) do
      table.insert(visit_flower_seed_boss_datas, {data = v, isTip = true})
    end
    
    local function SortVisitFlowerData(a, b)
      local A_owner_id = a.data and a.data.owner_id
      local B_owner_id = b.data and b.data.owner_id
      local aIndex = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorIndex, A_owner_id) or 99
      local bIndex = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorIndex, B_owner_id) or 99
      return aIndex < bIndex
    end
    
    table.sort(visit_flower_seed_boss_datas, SortVisitFlowerData)
    self.SharedFriendsHeadItem:InitGridView(visit_flower_seed_boss_datas)
    self.SharedFriendsHeadItem:SetItemClickAble(false)
  elseif self.FlowerSeedSharingOnline then
    self.FlowerSeedSharingOnline:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function UMG_ChallengeItem_C:OnGetFlowerData()
  return self.FlowerData
end

function UMG_ChallengeItem_C:UpdateShinyFlowerInfo()
  local TypeWrap = NRCModuleManager:GetModule("MagicManualModule"):GetFlowerType(self.FlowerData)
  if TypeWrap.IsShinyFlower then
    self.SwitcherBG:SetActiveWidgetIndex(1)
    self.Switcher_Star:SetActiveWidgetIndex(1)
    MagicManualUtils.RefreshCurBubbleText(self.TheShinyFlowerDescField, self.FlowerData.content_cfg_id)
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Visible)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.FlowerData.battle_petbase_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self.PetHeadIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.shiny_icon, _G.UIIconPath.HeadIconPath))
    end
  elseif TypeWrap.Is7StarHardFlower then
    self.TimeSwitcher_0:SetActiveWidgetIndex(1)
    self.SwitcherBG:SetActiveWidgetIndex(3)
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Visible)
    MagicManualUtils.RefreshCueBubbleNature(self.CueBubble, self.FlowerData)
  else
    self.SwitcherBG:SetActiveWidgetIndex(0)
    self.PatternSwitcher:SetActiveWidgetIndex(1)
    self.Switcher_Star:SetActiveWidgetIndex(0)
    if self.FlowerData.spec_flower_seed_id and self.FlowerData.activity_id then
      local activityConf = _G.DataConfigManager:GetActivityConf(self.FlowerData.activity_id)
      if activityConf and activityConf.activity_type == Enum.ActivityType.ATP_LIMITED_FLOWER_SEED then
        self.SwitcherBG:SetActiveWidgetIndex(2)
        self.Switcher_Star:SetActiveWidgetIndex(2)
      end
    else
      self.Img_di:SetPath("Texture2D'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Textures/img_di_bg1.img_di_bg1'")
    end
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_ChallengeItem_C:SetLegendDataInfo(IsMapToMagicManual)
  self.TimeSwitcher_0:SetActiveWidgetIndex(0)
  self.SwitcherBG:SetActiveWidgetIndex(0)
  self.PatternSwitcher:SetActiveWidgetIndex(0)
  self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CueBubble:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.NRCImage_52:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Icon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if IsMapToMagicManual then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.NotCollectedText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.is_camp_unlock = self.LegendData.is_camp_unlock
  if self.is_camp_unlock then
    self.Btn:SetBtnText(LuaText.umg_npcinfo_2)
  else
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if NpcRefreshID and NpcRefreshID > 0 then
      local NPCId = NpcRefreshID
      if self.LegendData.content_cfg_id then
        if self.LegendData.content_cfg_id == NPCId then
          self.Btn:SetBtnText(LuaText.head_to_cancel)
        else
          self.Btn:SetBtnText(LuaText.head_to)
        end
      else
        self.Btn:SetBtnText(LuaText.head_to)
      end
    else
      self.Btn:SetBtnText(LuaText.head_to)
    end
  end
  self.DataType = self.ChallengeType.LegendData
  self.unLockLevel = 0
  self.StarList = {}
  self.startStarNum = 0
  local seasonLegendaryID
  if self.LegendData and self.LegendData.content_cfg_id then
    seasonLegendaryID = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetSeasonLegendaryID, self.LegendData.content_cfg_id)
    if seasonLegendaryID then
      local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
      if seasonLegendaryDataConf then
        self.StarList = seasonLegendaryDataConf.battle_id
        self.unLockLevel = seasonLegendaryDataConf.world_level
        self.startStarNum = seasonLegendaryDataConf.start_difficulty
        if seasonLegendaryDataConf.start_time and seasonLegendaryDataConf.duration then
          local start_time = ActivityUtils.ToTimestamp(seasonLegendaryDataConf.start_time)
          local end_time = start_time + seasonLegendaryDataConf.duration
          local refreshTime = end_time - _G.ZoneServer:GetServerTime() / 1000
          if refreshTime >= 0 then
            self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            local day = math.floor(refreshTime / 86400)
            local hour = math.floor((refreshTime - day * 86400) / 3600)
            local min = math.floor((refreshTime - day * 86400 - hour * 3600) / 60)
            local sec = math.floor(refreshTime % 60)
            local btnText = ""
            if day > 0 then
              btnText = string.format(LuaText.activity_RTS1, day, hour)
            elseif hour > 0 then
              btnText = string.format(LuaText.activity_RTS2, hour, min)
            else
              btnText = string.format(LuaText.magicmanual_challenge_countdown03, min, sec)
            end
            self.Text_Time:SetText(btnText)
          end
        end
        if seasonLegendaryDataConf.frame_1 ~= nil and "" ~= seasonLegendaryDataConf.frame_1 and nil ~= seasonLegendaryDataConf.frame_2 and "" ~= seasonLegendaryDataConf.frame_2 then
          self.SwitcherBG:SetActiveWidgetIndex(4)
        end
      end
    else
      local LegendaryBattleEventConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.LEGENDARY_BATTLE_EVENT):GetAllDatas()
      for k, v in pairs(LegendaryBattleEventConf or {}) do
        if v.refresh_content_id_2 == self.LegendData.content_cfg_id then
          self.StarList = v.battle_id
          local ActivityConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ACTIVITY_CONF):GetAllDatas()
          for _, value in pairs(ActivityConf) do
            if value.base_id and #value.base_id > 0 and value.base_id[1] == k then
              self.unLockLevel = value.world_level_required or 0
              break
            end
          end
          self.unLockLevel = v.world_level
          self.startStarNum = v.start_difficulty
        end
      end
    end
  end
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  local playerWorldLv = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if visitorList and #visitorList > 0 then
    playerWorldLv = visitorList[1].world_lv
  end
  local maxLevel = self.unLockLevel + #self.StarList
  local curChooseStarNum = 0
  if playerWorldLv >= maxLevel then
    curChooseStarNum = self.startStarNum + #self.StarList - 1
  else
    curChooseStarNum = self.startStarNum + (playerWorldLv - self.unLockLevel)
  end
  local index = curChooseStarNum - self.startStarNum + 1
  self.BattleId = 0
  if index > 0 and index <= #self.StarList then
    self.BattleId = self.StarList[index]
  else
    self.BattleId = self.StarList[#self.StarList]
  end
  if nil == self.BattleId or nil == _G.DataConfigManager:GetBattleConf(self.BattleId) or nil == _G.DataConfigManager:GetBattleConf(self.BattleId).npc_battle_list then
    Log.Error("npc_battle_list is nil")
    return
  end
  local monsterConfId = _G.DataConfigManager:GetBattleConf(self.BattleId).npc_battle_list[1].pos1_1st[1]
  local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(monsterConf.base_id)
  self.Text_Name:SetText(petBaseConf.name)
  local commonAttrData = {}
  local unit_type = petBaseConf.unit_type
  for i = 1, #unit_type do
    local petType = unit_type[i]
    table.insert(commonAttrData, {Type = petType})
  end
  local level = 0
  if monsterConf.new_level and #monsterConf.new_level > 0 then
    level = monsterConf.new_level[1]
  end
  local lvText = string.format(LuaText.umg_petskilltemple2_1, level)
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  local pet_top_level = 0
  local WORLD_LEVEL_CONF = _G.DataConfigManager:GetAllByName("WORLD_LEVEL_CONF")
  for _, item in ipairs(WORLD_LEVEL_CONF) do
    if item.world_level == worldLevel then
      pet_top_level = item.pet_top_level
      break
    end
  end
  local IsReCom = level <= pet_top_level
  if level <= pet_top_level then
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.IsReCom = IsReCom
  self.Text_Grade:SetText(lvText)
  local rewardsTable = {}
  local dropReward = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetSpecificTimeActivityReward, ProtoEnum.ActivityDropShowArea.ADSA_LEGENDARY)
  if dropReward then
    for i, v in ipairs(dropReward) do
      v.tag = Enum.RewardTag.RTA_ACTIVITY
      v.reward_reason = ProtoEnum.FlowReason.FLOW_REASON_ACTIVITY_DROP
      table.insert(rewardsTable, v)
    end
  end
  local showRewards
  local TeamBattleAwardTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TEAM_BATTLE_AWARD)
  local TeamBattleAwardDatas = TeamBattleAwardTable:GetAllDatas()
  for k, v in pairs(TeamBattleAwardDatas) do
    if v.star == curChooseStarNum and v.is_legendary_reward == monsterConf.base_id then
      showRewards = v.show_award
      break
    end
  end
  if showRewards then
    for k, v in ipairs(showRewards) do
      local rewards = _G.NRCCommonItemIconData()
      rewards.itemType = v.Type
      rewards.itemId = v.Id
      rewards.itemNum = v.Count
      if v.Count > 0 then
        rewards.bShowNum = true
      else
        rewards.bShowNum = false
      end
      rewards.bShowTip = true
      table.insert(rewardsTable, rewards)
    end
  end
  _G.DelayManager:DelayFrames(1, function()
    self.Boss_ItemIist:InitGridView(rewardsTable)
    self.Attr:InitGridView(commonAttrData)
  end)
  local content_id
  if self.LegendData and self.LegendData.content_cfg_id then
    content_id = self.LegendData.content_cfg_id
  end
  local costItemId1, costNum2 = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetLegendaryTicketIDAndNum, content_id)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(costItemId1)
  self.img_star_3:SetPath(bagItemConf.icon)
  local useStarNum = _G.DataConfigManager:GetLegendaryGlobalConfig("star_consume").num
  self.StarEnergy_3:SetText(useStarNum)
  self.StarEnergy_5:SetText(costNum2)
  local colorEnough = "#F4EEE1FF"
  local colorRed = "#AF3A3DFF"
  local StarDebrisNum = NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, costItemId1)
  if nil == StarDebrisNum then
    StarDebrisNum = 0
  else
    StarDebrisNum = StarDebrisNum.num
  end
  local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
  if costNum2 > StarDebrisNum and useStarNum > StarNum then
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
  else
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
  end
  self.Icon:SetPath(petBaseConf.JL_small_res)
  self.Icon_2:SetPath(petBaseConf.JL_small_res)
  self.BtnSwitch:SetActiveWidgetIndex(0)
  self:SetBgColor(unit_type[1], seasonLegendaryID)
  self:SetBtnBgByUnitType(unit_type[1], seasonLegendaryID)
end

function UMG_ChallengeItem_C:SetBossDataInfo(IsMapToMagicManual)
  self.TimeSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SwitcherBG:SetActiveWidgetIndex(0)
  self.PatternSwitcher:SetActiveWidgetIndex(0)
  self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CueBubble:SetVisibility(UE.ESlateVisibility.Collapsed)
  if IsMapToMagicManual then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  if vItemsConf then
    self.img_star_3:SetPath(vItemsConf.iconPath)
  end
  self.DataType = self.ChallengeType.BossData
  local content_cfg_id = self.BossData.content_cfg_id
  if not content_cfg_id then
    local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
    if worldMapConf and worldMapConf.npc_refresh_ids then
      content_cfg_id = worldMapConf.npc_refresh_ids[1]
    end
  end
  local levelText = self.BossData.level
  if self.BossData.IsReCom then
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.IsReCom = self.BossData.IsReCom
  self.Text_Grade:SetText(string.format(LuaText.umg_petskilltemple2_1, levelText))
  if self.BossData.next_refresh_time and self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000 >= 0 then
    self.is_camp_unlock = false
  else
    self.is_camp_unlock = self.BossData.is_camp_unlock
  end
  self.Distance = self.BossData.Distance
  self.isBigMapScene = self.BossData.isBigMapScene
  if self.BossData.is_world_boss_defeated then
    self.NotDefeatedText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NotDefeatedText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotDefeatedText:SetText(LuaText.boss_not_defeated)
  end
  if self.BossData.npc_cfg_id then
    self.npcCfg = _G.DataConfigManager:GetNpcConf(self.BossData.npc_cfg_id)
  else
    local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
    if worldMapConf and worldMapConf.npc_refresh_ids then
      local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(worldMapConf.npc_refresh_ids[1])
      if refreshConf then
        self.npcCfg = _G.DataConfigManager:GetNpcConf(refreshConf.npc_id)
      end
    end
  end
  local starRewards
  self.img_star_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/17.17'")
  if not (self.WorldCombatConf and self.WorldCombatConf.trophy_id) or not self.WorldCombatConf.world_boss_refer then
    return
  end
  local StarAwardConf = _G.DataConfigManager:GetStarAwardConf(self.WorldCombatConf.trophy_id)
  starRewards = StarAwardConf and StarAwardConf.show_award or {}
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.WorldCombatConf.world_boss_refer)
  local useStarNum = StarAwardConf and StarAwardConf.star_amount or 0
  local costNum2 = StarAwardConf and StarAwardConf.star_amount or 0
  self.StarEnergy_3:SetText(useStarNum)
  self.StarEnergy_5:SetText(costNum2)
  local colorEnough = "#F4EEE1FF"
  local colorRed = "#AF3A3DFF"
  local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  local StarNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR)
  if costNum2 > StarDebrisNum and useStarNum > StarNum then
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorRed))
  else
    self.StarEnergy_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
    self.StarEnergy_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(colorEnough))
  end
  self.Icon:SetPath(PetBaseConf.JL_small_res)
  self.Icon_2:SetPath(PetBaseConf.JL_small_res)
  local commonAttrData = {}
  local unit_type = PetBaseConf.unit_type
  for i = 1, #unit_type do
    local petType = unit_type[i]
    table.insert(commonAttrData, {Type = petType})
  end
  self:SetLockState()
  self:SetBtnBgByUnitType(unit_type[1])
  self:SetBgColor(self.WorldCombatConf.background_color and self.WorldCombatConf.background_color ~= Enum.SkillDamType.SDT_NONE and self.WorldCombatConf.background_color ~= Enum.SkillDamType.SDT_INVALID and self.WorldCombatConf.background_color or unit_type[1])
  local rewardsTable = {}
  local dropReward = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetSpecificTimeActivityReward, ProtoEnum.ActivityDropShowArea.ADSA_BOSS)
  if dropReward then
    for i, v in ipairs(dropReward) do
      v.tag = Enum.RewardTag.RTA_ACTIVITY
      v.reward_reason = ProtoEnum.FlowReason.FLOW_REASON_ACTIVITY_DROP
      table.insert(rewardsTable, v)
    end
  end
  for k, v in ipairs(starRewards) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    if rewards.itemNum > 0 then
      rewards.bShowNum = true
    else
      rewards.bShowNum = false
    end
    rewards.bShowTip = true
    rewards = self:HandleBossEvoReward(rewards)
    if self:CheckThisRewardShouldShow(rewards) then
      table.insert(rewardsTable, rewards)
    end
  end
  _G.DelayManager:DelayFrames(1, function()
    self.Attr:InitGridView(commonAttrData)
    self.Boss_ItemIist:InitGridView(rewardsTable)
  end)
end

function UMG_ChallengeItem_C:HandleBossEvoReward(RewardItem)
  local RetRewardItem = RewardItem
  if not RetRewardItem then
    Log.Error("UMG_ChallengeItem_C:HandleBossEvoReward RewardItem is nil")
    return RetRewardItem
  end
  if RewardItem.itemId ~= nil and RewardItem.itemType == Enum.GoodsType.GT_BAGITEM then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(RewardItem.itemId)
    local BagItemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, RewardItem.itemId)
    if BagItemConf then
      local BagItemType = BagItemConf.type
      if BagItemType == _G.Enum.BagItemType.BI_BOSS_EVO and nil == BagItemData then
        RetRewardItem.topLabelText = LuaText.BossEvoItem_Title
      end
    end
  end
  return RetRewardItem
end

function UMG_ChallengeItem_C:CheckThisRewardShouldShow(RewardItem)
  local bShow = true
  if not RewardItem then
    Log.Error("UMG_NpcInfo_C:CheckThisRewardShouldShow RewardItem is nil")
    return bShow
  end
  if RewardItem.itemId ~= nil and RewardItem.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(RewardItem.itemId)
    local BagItemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, RewardItem.itemId)
    if BagItemData and BagItemConf then
      local BagItemType = BagItemConf.type
      if BagItemType == _G.Enum.BagItemType.BI_BOSS_EVO and 0 ~= BagItemData.num then
        bShow = false
      end
    end
  end
  return bShow
end

function UMG_ChallengeItem_C:IsCampUnlock()
  if self.DataType == self.ChallengeType.BossData then
    if self.BossData.next_refresh_time and self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000 >= 0 then
      self.is_camp_unlock = false
    else
      self.is_camp_unlock = self.BossData.is_camp_unlock
    end
  end
  return self.is_camp_unlock
end

function UMG_ChallengeItem_C:SetBgColor(Type, seasonLegendaryID)
  if not self.Img_di or self.FlowerData.spec_flower_seed_id then
    return
  end
  if seasonLegendaryID then
    local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
    if seasonLegendaryDataConf then
      local bgPath = seasonLegendaryDataConf.frame_2
      if nil ~= bgPath and "" ~= bgPath then
        self.img_TicketBg_4:SetPath(bgPath)
        return
      end
    end
  end
  if Type == Enum.SkillDamType.SDT_GRASS then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("D4E3BFFF"))
  elseif Type == Enum.SkillDamType.SDT_COMMON then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B6DFE3FF"))
  elseif Type == Enum.SkillDamType.SDT_DEMON then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F0B6CDFF"))
  elseif Type == Enum.SkillDamType.SDT_FIRE then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F5D8BBFF"))
  elseif Type == Enum.SkillDamType.SDT_WATER then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("CEDFE9FF"))
  elseif Type == Enum.SkillDamType.SDT_LIGHT then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4D4ECFF"))
  elseif Type == Enum.SkillDamType.SDT_STONE then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("DBCEB6FF"))
  elseif Type == Enum.SkillDamType.SDT_ICE then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B6D9ECFF"))
  elseif Type == Enum.SkillDamType.SDT_DRAGON then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F5BFBBFF"))
  elseif Type == Enum.SkillDamType.SDT_ELECTRIC then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F5EA9BFF"))
  elseif Type == Enum.SkillDamType.SDT_TOXIC then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("DDB9EDFF"))
  elseif Type == Enum.SkillDamType.SDT_INSECT then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("DDE5BDFF"))
  elseif Type == Enum.SkillDamType.SDT_FIGHT then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F5DABBFF"))
  elseif Type == Enum.SkillDamType.SDT_WING then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("B6DFE3FF"))
  elseif Type == Enum.SkillDamType.SDT_MOE then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FBBAC3FF"))
  elseif Type == Enum.SkillDamType.SDT_GHOST then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C7ADEEFF"))
  elseif Type == Enum.SkillDamType.SDT_MECHANIC then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("BDE5DFFF"))
  elseif Type == Enum.SkillDamType.SDT_PHANTOM then
    self.Img_di:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C1C1EEFF"))
  end
end

function UMG_ChallengeItem_C:NotFoundClick()
  if self.lockState == self.LockType.CampLock then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    local ContentTitle = _G.DataConfigManager:GetLocalizationConf("TIPS").msg
    local ContentText = string.format(_G.DataConfigManager:GetLocalizationConf("magicmanualmodule3_error1").msg, self.WorldCombatConf.living_area_name)
    Context:SetTitle(ContentTitle):SetContent(ContentText):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true):SetClickAnywhereClose(true)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
  if self.lockState == self.LockType.TaskLock then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    local ContentTitle = _G.DataConfigManager:GetLocalizationConf("TIPS").msg
    local ContentText = string.format(_G.DataConfigManager:GetLocalizationConf("magicmanualmodule3_error2").msg, self.WorldCombatConf.task_name)
    Context:SetTitle(ContentTitle):SetContent(ContentText):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true):SetClickAnywhereClose(true)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function UMG_ChallengeItem_C:OnDialogTraceBtnClick()
  if not UE4.UObject.IsValid(self) or self.isDestruct then
    return
  end
  if self.DataType == self.ChallengeType.BossData then
    if self:IsCampUnlock() then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      local content_cfg_id = self.BossData.content_cfg_id
      if not content_cfg_id then
        local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
        if worldMapConf and worldMapConf.npc_refresh_ids then
          content_cfg_id = worldMapConf.npc_refresh_ids[1]
        end
      end
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if bBan then
        return
      end
      if NpcData then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_13101)
      end
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
    if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
      return
    end
    local content_cfg_id = self.BossData.content_cfg_id
    if not content_cfg_id then
      local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
      if worldMapConf and worldMapConf.npc_refresh_ids then
        content_cfg_id = worldMapConf.npc_refresh_ids[1]
      end
    end
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, content_cfg_id)
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
    _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
      centerNPCRefreshId = content_cfg_id,
      bNotRightPanel = true,
      scaleSliderValue = 0.5
    })
    self.Btn:SetBtnText(LuaText.head_to_cancel)
  end
  if self.DataType == self.ChallengeType.FlowerData then
    if self:IsCampUnlock() then
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, self.FlowerData.content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if bBan then
        return
      end
      if NpcData then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_13101)
      end
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
    if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
      return
    end
    local npcInfo = _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.GetNpcInfoByRefreshId, self.FlowerData.content_cfg_id)
    if npcInfo then
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, self.FlowerData.content_cfg_id)
      _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
      _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
        centerNPCRefreshId = npcInfo.npc_refresh_id,
        bNotRightPanel = true,
        scaleSliderValue = 0.5
      })
      self.Btn:SetBtnText(LuaText.head_to_cancel)
    else
      Log.Error("\230\156\141\229\138\161\229\153\168\228\184\139\229\143\145\231\154\132NpcContentId\229\174\162\230\136\183\231\171\175\231\154\132\229\156\176\229\155\190\230\149\176\230\141\174\230\137\190\228\184\141\229\136\176")
    end
  end
  if self.DataType == self.ChallengeType.LegendData then
    if self:IsCampUnlock() then
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, self.LegendData.content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if NpcData and not bBan then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      end
      return
    end
    if self.LegendData.content_cfg_id == NpcRefreshID then
      _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MagicManual_Main_C:OnClickBtnClose")
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByID, -1)
      self.Btn:SetBtnText(LuaText.head_to)
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
        return
      end
      local npcInfo = _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.GetNpcInfoByRefreshId, self.LegendData.content_cfg_id)
      if npcInfo then
        _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, self.LegendData.content_cfg_id)
        _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = npcInfo.npc_refresh_id,
          bNotRightPanel = true,
          scaleSliderValue = 0.5
        })
        self.Btn:SetBtnText(LuaText.head_to_cancel)
      else
        Log.Error("\230\156\141\229\138\161\229\153\168\228\184\139\229\143\145\231\154\132NpcContentId\229\174\162\230\136\183\231\171\175\231\154\132\229\156\176\229\155\190\230\149\176\230\141\174\230\137\190\228\184\141\229\136\176")
      end
    end
  end
end

function UMG_ChallengeItem_C:TraceBtnClick()
  if self.DataType == self.ChallengeType.BossData then
    if not self.BossData then
      Log.Error("\230\156\141\229\138\161\229\153\168\229\136\183\230\150\176\233\151\180\233\154\148\228\184\1863\231\167\146")
      return
    end
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if self.IsReCom or self.BossData.content_cfg_id == NpcRefreshID then
    else
      self:OnDialogTraceBtnClick()
      return
    end
    if self:IsCampUnlock() then
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      local content_cfg_id = self.BossData.content_cfg_id
      if not content_cfg_id then
        local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
        if worldMapConf and worldMapConf.npc_refresh_ids then
          content_cfg_id = worldMapConf.npc_refresh_ids[1]
        end
      end
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if bBan then
        return
      end
      if NpcData then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_13101)
      end
      return
    end
    if self.BossData.content_cfg_id == NpcRefreshID then
      _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MagicManual_Main_C:OnClickBtnClose")
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByID, -1)
      self.Btn:SetBtnText(LuaText.head_to)
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
        return
      end
      local content_cfg_id = self.BossData.content_cfg_id
      if not content_cfg_id then
        local worldMapConf = _G.DataConfigManager:GetWorldMapConf(self.BossData.world_map_cfg_id)
        if worldMapConf and worldMapConf.npc_refresh_ids then
          content_cfg_id = worldMapConf.npc_refresh_ids[1]
        end
      end
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, content_cfg_id)
      _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
      _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
        centerNPCRefreshId = content_cfg_id,
        bNotRightPanel = true,
        scaleSliderValue = 0.5
      })
      self.Btn:SetBtnText(LuaText.head_to_cancel)
    end
  end
  if self.DataType == self.ChallengeType.FlowerData then
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if not self.FlowerData.content_cfg_id then
      return
    end
    if self.IsReCom or self.FlowerData.content_cfg_id == NpcRefreshID then
    else
      self:OnDialogTraceBtnClick()
      return
    end
    if self:IsCampUnlock() then
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, self.FlowerData.content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if bBan then
        return
      end
      if NpcData then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_13101)
      end
      return
    end
    if self.FlowerData.content_cfg_id == NpcRefreshID then
      _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MagicManual_Main_C:OnClickBtnClose")
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByID, -1)
      self.Btn:SetBtnText(LuaText.head_to)
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
        return
      end
      local npcInfo = _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.GetNpcInfoByRefreshId, self.FlowerData.content_cfg_id)
      if npcInfo then
        _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, self.FlowerData.content_cfg_id)
        _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = npcInfo.npc_refresh_id,
          bNotRightPanel = true,
          scaleSliderValue = 0.5
        })
        self.Btn:SetBtnText(LuaText.head_to_cancel)
      else
        Log.Error("\230\156\141\229\138\161\229\153\168\228\184\139\229\143\145\231\154\132NpcContentId\229\174\162\230\136\183\231\171\175\231\154\132\229\156\176\229\155\190\230\149\176\230\141\174\230\137\190\228\184\141\229\136\176")
      end
    end
  end
  if self.DataType == self.ChallengeType.LegendData then
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if self.IsReCom then
    else
      self:OnDialogTraceBtnClick()
      return
    end
    if self:IsCampUnlock() then
      local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcInfoByRefreshId, self.LegendData.content_cfg_id)
      local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
      if NpcData and not bBan then
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = NpcData.npc_refresh_id,
          bNotRightPanel = false,
          scaleSliderValue = 0.5
        })
      end
      return
    end
    if self.LegendData.content_cfg_id == NpcRefreshID then
      _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_MagicManual_Main_C:OnClickBtnClose")
      _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByID, -1)
      self.Btn:SetBtnText(LuaText.head_to)
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicManual_Main_C:OnClickBtnClose")
      if _G.NRCModuleManager:DoCmd(MiniGameModuleCmd.IsPlaying) then
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2331)
        return
      end
      local npcInfo = _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.GetNpcInfoByRefreshId, self.LegendData.content_cfg_id)
      if npcInfo then
        _G.NRCModuleManager:DoCmd(BigMapModuleCmd.TraceNpcByRefreshID, self.LegendData.content_cfg_id)
        _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.CmdRefreshChallengeItemBtn)
        _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap, {
          centerNPCRefreshId = npcInfo.npc_refresh_id,
          bNotRightPanel = true,
          scaleSliderValue = 0.5
        })
        self.Btn:SetBtnText(LuaText.head_to_cancel)
      else
        Log.Error("\230\156\141\229\138\161\229\153\168\228\184\139\229\143\145\231\154\132NpcContentId\229\174\162\230\136\183\231\171\175\231\154\132\229\156\176\229\155\190\230\149\176\230\141\174\230\137\190\228\184\141\229\136\176")
      end
    end
  end
end

function UMG_ChallengeItem_C:RefreshTimeTick()
  if not self.BossData.next_refresh_time then
    self.needTick = false
    self.BtnSwitch:SetActiveWidgetIndex(0)
    return
  end
  local refreshTime = self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000
  if refreshTime >= 0 then
    local min = math.floor(refreshTime / 60)
    local sec = math.ceil(refreshTime - min * 60)
    local btnText = string.format(LuaText.magicmanual_challenge_countdown03, min, sec)
    self.Text_Time:SetText(btnText)
    self.Text_Time_5:SetText(btnText)
  else
    self.NRCImage_52:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.BossData.is_camp_unlock then
      self.Btn:SetBtnText(LuaText.umg_npcinfo_2)
    else
      local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
      if self.BossData.content_cfg_id == NpcRefreshID then
        self.Btn:SetBtnText(LuaText.head_to_cancel)
      else
        self.Btn:SetBtnText(LuaText.head_to)
      end
      if self.isBigMapScene then
        self.Text_Time_1:SetText(self.Distance)
        self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Text_Time_1:SetText(LuaText.magic_manual_distance_invalid)
        self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.needTick = false
    self.BtnSwitch:SetActiveWidgetIndex(0)
  end
end

function UMG_ChallengeItem_C:OnAnimationStarted(anim)
  if anim == self.In then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_ChallengeItem_C:SetLockState()
  if self.lockState ~= self.LockType.None then
    self.NRCImage_52:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.wenhao:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("000000FF"))
    self.Text_Name:SetText("???")
    self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.wenhao:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.BossData.next_refresh_time and self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000 >= 0 then
      self.NRCImage_52:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Icon_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Icon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("0000007F"))
    else
      self.NRCImage_52:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Icon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.npcCfg then
      self.Text_Name:SetText(self.npcCfg.name)
    end
  end
  if self.BossData.next_refresh_time and self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000 >= 0 then
    self.needTick = true
    self.BtnSwitch:SetActiveWidgetIndex(3)
    local refreshTime = self.BossData.next_refresh_time - _G.ZoneServer:GetServerTime() / 1000
    if refreshTime >= 0 then
      local min = math.floor(refreshTime / 60)
      local sec = math.ceil(refreshTime - min * 60)
      local btnText = string.format(LuaText.magicmanual_challenge_countdown03, min, sec)
      self.Text_Time_5:SetText(btnText)
    else
    end
  elseif self.lockState ~= self.LockType.None then
    if self.lockState == self.LockType.CampLock then
      self.Btn1:SetBtnText(LuaText.Camp_Unknow_Pet_Tips_Desc)
    end
    if self.lockState == self.LockType.TaskLock then
      self.Btn1:SetBtnText(LuaText.pre_task)
    end
    self.BtnSwitch:SetActiveWidgetIndex(1)
  elseif self.BossData then
    local NpcRefreshID = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetTraceNpcRefreshID)
    if self:IsCampUnlock() then
      self.Btn:SetBtnText(LuaText.umg_npcinfo_2)
    else
      if self.BossData.content_cfg_id == NpcRefreshID then
        self.Btn:SetBtnText(LuaText.head_to_cancel)
      else
        self.Btn:SetBtnText(LuaText.head_to)
      end
      if self.isBigMapScene then
        self.Text_Time_1:SetText(self.Distance)
        self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Text_Time_1:SetText(LuaText.magic_manual_distance_invalid)
        self.Text_Time_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Text_Time_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.BtnSwitch:SetActiveWidgetIndex(0)
  end
end

function UMG_ChallengeItem_C:OnItemSelected(_bSelected)
end

function UMG_ChallengeItem_C:OnDeactive()
end

function UMG_ChallengeItem_C:OnOpenPetTips()
  if self.DataType == self.ChallengeType.FlowerData then
    local TypeWrap = NRCModuleManager:GetModule("MagicManualModule"):GetFlowerType(self.FlowerData)
    local flag = false
    if TypeWrap and TypeWrap.IsShinyFlower then
      flag = true
    end
    local infoData = {
      petBaseId = self.FlowerData.battle_petbase_id,
      bloodId = self.FlowerData.blood,
      flowerSeedId = self.FlowerData.spec_flower_seed_id,
      star = self.FlowerData.star,
      isShinyFlower = flag,
      bForceShowType = true
    }
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
  elseif self.DataType == self.ChallengeType.BossData then
    local petBaseID = self.WorldCombatConf.world_boss_refer
    local infoData = {
      petBaseId = petBaseID,
      level = self.BossData.level,
      bForceShowType = true
    }
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
  elseif self.DataType == self.ChallengeType.LegendData then
    local battleConf = _G.DataConfigManager:GetBattleConf(self.BattleId)
    if battleConf then
      local battleList = battleConf.npc_battle_list
      if battleList and battleList[1] then
        local posList = battleList[1].pos1_1st
        if posList and posList[1] then
          local monsterConfId = posList[1]
          local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
          if monsterConf then
            local level = 0
            if monsterConf.new_level and #monsterConf.new_level > 0 then
              level = monsterConf.new_level[1]
            end
            local infoData = {
              petBaseId = monsterConf.base_id,
              level = level,
              bForceShowType = true
            }
            _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
          end
        end
      end
    end
  end
end

function UMG_ChallengeItem_C:OnOpenBloodTips()
  if self.DataType == self.ChallengeType.FlowerData then
    local data = {
      base_conf_id = self.FlowerData.battle_petbase_id,
      mutation_type = _G.Enum.MutationDiffType.MDT_NONE,
      blood_id = self.FlowerData.blood
    }
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleBloodPulse, data)
  end
end

function UMG_ChallengeItem_C:OnOpenPetInfoPanel()
  local PetBaseConf
  if self.DataType == self.ChallengeType.LegendData then
    local battleConf = _G.DataConfigManager:GetBattleConf(self.BattleId)
    if battleConf then
      local battleList = battleConf.npc_battle_list
      if battleList and battleList[1] then
        local posList = battleList[1].pos1_1st
        if posList and posList[1] then
          local monsterConfId = posList[1]
          local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
          if monsterConf then
            PetBaseConf = _G.DataConfigManager:GetPetbaseConf(monsterConf.base_id)
          end
        end
      end
    end
  elseif self.DataType == self.ChallengeType.BossData then
    local petBaseId = self.WorldCombatConf.world_boss_refer
    PetBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  elseif self.DataType == self.ChallengeType.FlowerData then
    local petBaseId = self.FlowerData.battle_petbase_id
    PetBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  end
  if PetBaseConf then
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_ChallengeItem_C:OnOpenPetInfoPanel")
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, PetBaseConf.id, true)
  end
end

return UMG_ChallengeItem_C
