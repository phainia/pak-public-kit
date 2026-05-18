local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_NpcInfo_TeamBattle_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_TeamBattle_C")

function UMG_NpcInfo_TeamBattle_C:OnActive()
end

function UMG_NpcInfo_TeamBattle_C:OnDeactive()
end

function UMG_NpcInfo_TeamBattle_C:OnAddEventListener()
end

function UMG_NpcInfo_TeamBattle_C:OnConstruct()
  self.TheShinyFlowerDescField = MagicManualUtils.InitFlowerCueBubble(self.CueBubble, self, self.OnGetFlowerInfo)
end

function UMG_NpcInfo_TeamBattle_C:OnDestruct()
end

function UMG_NpcInfo_TeamBattle_C:_UpdateTeamBattle(_props)
  self.Leader:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_Boss:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Star_List:InitGridView(_props.starList)
  self.Star:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.isLimitedFlower then
    self.Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Title_Image:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Title_Image:SetPath(_props.titleImagePath)
  self.npcName_3:SetText(_props.title)
  self.FlowerBloodBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Image_Icon_1:SetPath(_props.imageIconPath)
  self.npcDesc_2:SetText(_props.desc)
  self.PetIcon:SetPath(_props.petIconPath)
  self.PetName:SetText(_props.petName)
  local Attrs = {
    self.Attr1,
    self.Attr2
  }
  if 1 == #_props.unit_type then
    Attrs[2]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local index = 1
  for i = #_props.unit_type, 1, -1 do
    local petType = _props.unit_type[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    Attrs[index].Icon:SetPath(typeDic.type_icon)
    Attrs[index].Outline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    index = index + 1
  end
  self.RemainTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.shouldTextTime then
    self.RemainTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if BigMapUtils.IsHomeScene(SceneUtils.GetSceneID()) then
      local warnText = DataConfigManager:GetLocalizationConf("home_to_world_maptips_info_old").msg
      self.Text_RemainTime:SetText(warnText)
    else
      self.Text_RemainTime:SetText(_props.timeText)
    end
  end
  local level, IsReCom = MagicManualUtils.GetFlowerLevel(_props.star, _props.teamBattleInfo.spec_flower_seed_id)
  if IsReCom then
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.Text_Grade:SetText(string.format(LuaText.umg_petskilltemple2_1, level))
  self.Text_Grade:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CostIcon:SetPath(_props.costIconPath)
  self.NRCText_60:SetText(_props.costText)
  self.ConsumeText:SetText(_props.consumeText)
  self.ConsumeText_1:SetText(_props.consumeText1)
  self.ItemRequired:SetText(_G.LuaText.worldmap_tips_reward_text)
  self.Icon_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.hasReward then
    self.Icon_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_List:InitGridView(_props.rewardList)
  end
  self:SetFlowerSeedFusionInfo(_props.teamBattleInfo)
end

function UMG_NpcInfo_TeamBattle_C:SetFlowerSeedFusionInfo(teamBattleInfo)
  if teamBattleInfo.visit_flower_seed_boss_datas then
    self.FriendsShared:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local visit_flower_seed_boss_datas = {}
    for k, v in ipairs(teamBattleInfo.visit_flower_seed_boss_datas) do
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
  else
    self.FriendsShared:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_NpcInfo_TeamBattle_C:_UpdateBossBattle(_props)
  self.Leader:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Title_Image:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_Boss:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Pet_Boss:SetPath(_props.petBossImagePath)
  self.npcName_3:SetText(_props.title)
  self.npcDesc_2:SetText(_props.desc)
  self.PetIcon:SetPath(_props.petIconPath)
  self.PetName:SetText(_props.petName)
  local Attrs = {
    self.Attr1,
    self.Attr2
  }
  if 1 == #_props.unit_type then
    Attrs[2]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local index = 1
  for i = #_props.unit_type, 1, -1 do
    local petType = _props.unit_type[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    Attrs[index].Icon:SetPath(typeDic.type_icon)
    Attrs[index].Outline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    index = index + 1
  end
  self.RemainTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local level, IsReCom = MagicManualUtils.GetBossLevel(_props.npcRefreshId)
  if IsReCom then
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.Text_Grade:SetText(string.format(LuaText.umg_petskilltemple2_1, level))
  self.Text_Grade:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CostIcon:SetPath(_props.costIconPath)
  self.NRCText_60:SetText(_props.costText)
  if _props.hasConsumeText then
    self.ConsumeText:SetText(_props.consumeText)
    self.ConsumeText_1:SetText(_props.consumeText1)
  end
  self.ItemRequired:SetText(_G.LuaText.worldmap_tips_reward_text)
  self.Icon_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.hasReward then
    self.Icon_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_List:InitGridView(_props.rewardList)
  end
end

function UMG_NpcInfo_TeamBattle_C:_UpdateLegendaryBattle(_props)
  self.Title_Image:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_Boss:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BgSwitcher:SetActiveWidgetIndex(1)
  self.Pet_Boss:SetPath(_props.petBossIconPath)
  self.CanvasPanel_6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.npcName_3:SetText(_props.title)
  self.npcDesc_2:SetText(_props.desc)
  if _props.isConsumeTextRed then
    self.ConsumeText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(_props.colorRed))
  else
    self.ConsumeText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(_props.colorEnough))
  end
  self.ConsumeText:SetText(_props.consumeText)
  self.ConsumeText_1:SetText(_props.consumeText1)
  self.CostIcon:SetPath(_props.costIconPath)
  self.CostIcon_1:SetPath(_props.costIcon1Path)
  self.NRCText_60:SetText(_props.costText)
  self.Leader:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text_Times:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.shouldShowTimeText then
    self.Text_Times:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_Times:SetText(_props.timeText)
  end
  self.ItemRequired:SetText(_G.LuaText.worldmap_tips_reward_text)
  self.Icon_List:InitGridView(_props.rewardList)
  local unLockLevel = 0
  local StarList = {}
  local startStarNum = 0
  local seasonLegendaryID, strRemainTime
  if _props and _props.npcRefreshId then
    seasonLegendaryID = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetSeasonLegendaryID, _props.npcRefreshId)
    if seasonLegendaryID then
      local seasonLegendaryDataConf = _G.DataConfigManager:GetSeasonLegendaryBattleEvent(seasonLegendaryID)
      if seasonLegendaryDataConf then
        StarList = seasonLegendaryDataConf.battle_id
        unLockLevel = seasonLegendaryDataConf.world_level
        startStarNum = seasonLegendaryDataConf.start_difficulty
        if seasonLegendaryDataConf.start_time and seasonLegendaryDataConf.duration then
          local start_time = ActivityUtils.ToTimestamp(seasonLegendaryDataConf.start_time)
          local end_time = start_time + seasonLegendaryDataConf.duration
          local refreshTime = end_time - _G.ZoneServer:GetServerTime() / 1000
          if refreshTime >= 0 then
            local day = math.floor(refreshTime / 86400)
            local hour = math.floor((refreshTime - day * 86400) / 3600)
            local min = math.floor((refreshTime - day * 86400 - hour * 3600) / 60)
            local sec = math.floor(refreshTime % 60)
            if day > 0 then
              strRemainTime = string.format(LuaText.activity_RTS1, day, hour)
            elseif hour > 0 then
              strRemainTime = string.format(LuaText.activity_RTS2, hour, min)
            else
              strRemainTime = string.format(LuaText.magicmanual_challenge_countdown03, min, sec)
            end
          end
        end
      end
    else
      local LegendaryBattleEventConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.LEGENDARY_BATTLE_EVENT):GetAllDatas()
      for k, v in pairs(LegendaryBattleEventConf) do
        if v.refresh_content_id_2 == _props.npcRefreshId then
          StarList = v.battle_id
          local ActivityConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ACTIVITY_CONF):GetAllDatas()
          for _, value in pairs(ActivityConf) do
            if value.base_id and #value.base_id > 0 and value.base_id[1] == k then
              unLockLevel = value.world_level_required or 0
              break
            end
          end
          unLockLevel = v.world_level
          startStarNum = v.start_difficulty
        end
      end
    end
  end
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  local playerWorldLv = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  if visitorList and #visitorList > 0 then
    playerWorldLv = visitorList[1].world_lv
  end
  local maxLevel = unLockLevel + #StarList
  local curChooseStarNum = 0
  if playerWorldLv >= maxLevel then
    curChooseStarNum = startStarNum + maxLevel - 1
  else
    curChooseStarNum = startStarNum + (playerWorldLv - unLockLevel)
  end
  local index = curChooseStarNum - startStarNum + 1
  local BattleId = 0
  if index > 0 and index <= #StarList then
    BattleId = StarList[index]
  else
    BattleId = StarList[#StarList]
  end
  if nil == BattleId or nil == _G.DataConfigManager:GetBattleConf(BattleId) or nil == _G.DataConfigManager:GetBattleConf(BattleId).npc_battle_list then
    Log.Error("npc_battle_list is nil")
    return
  end
  local monsterConfId = _G.DataConfigManager:GetBattleConf(BattleId).npc_battle_list[1].pos1_1st[1]
  local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
  local level = 0
  if monsterConf.new_level and #monsterConf.new_level > 0 then
    level = monsterConf.new_level[1]
  end
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel() + 1
  local WorldLevelConf = DataConfigManager:GetWorldLevelConf(worldLevel)
  local petTopLevel = WorldLevelConf and WorldLevelConf.pet_top_level or 0
  if level <= petTopLevel then
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  else
    self.Text_Grade:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.Text_Grade:SetText("")
  self.Text_Grade:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.legendaryLevel = level
  self.legendaryPetBaseId = monsterConf.base_id
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.legendaryPetBaseId)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  self.PetIcon:SetPath(modelConf.icon)
  self.PetName:SetText(petBaseConf.name)
  local unit_type = petBaseConf.unit_type
  local Attrs = {
    self.Attr1,
    self.Attr2
  }
  if 1 == #unit_type then
    Attrs[2]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local index = 1
  for i = #unit_type, 1, -1 do
    local petType = unit_type[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    Attrs[index].Icon:SetPath(typeDic.type_icon)
    Attrs[index].Outline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    index = index + 1
  end
  if strRemainTime then
    self.RemainTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_RemainTime:SetText(strRemainTime)
  else
    self.RemainTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_NpcInfo_TeamBattle_C:OnEnable(battleType, props)
  self.props = props
  self.battleType = battleType
  if 0 == battleType then
    self:_UpdateTeamBattle(props)
  elseif 1 == battleType then
    self:_UpdateBossBattle(props)
  elseif 2 == battleType then
    self:_UpdateLegendaryBattle(props)
  end
  self:AddButtonListener(self.PetBtn, self.OnOpenPetTips)
  self:AddButtonListener(self.DepartmentBtn, self.OnOpenPetTips)
  self:AddButtonListener(self.FlowerBloodBtn, self.OnOpenBloodTips)
end

function UMG_NpcInfo_TeamBattle_C:OnDisable()
  self:RemoveButtonListener(self.PetBtn, self.OnOpenPetTips)
  self:RemoveButtonListener(self.DepartmentBtn)
  self:RemoveButtonListener(self.FlowerBloodBtn, self.OnOpenBloodTips)
end

function UMG_NpcInfo_TeamBattle_C:OnOpenPetTips()
  if 0 == self.battleType then
    local flag = false
    if self.props and self.props.FlowerTypeWrap and self.props.FlowerTypeWrap.IsShinyFlower then
      flag = true
    end
    local teamBattleInfo = self.props.teamBattleInfo
    if teamBattleInfo then
      local infoData = {
        petBaseId = teamBattleInfo.battle_petbase_id,
        bloodId = teamBattleInfo.blood,
        flowerSeedId = teamBattleInfo.spec_flower_seed_id,
        star = teamBattleInfo.star,
        isShinyFlower = flag,
        bForceShowType = true
      }
      _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
    end
  elseif 1 == self.battleType then
    local level, IsReCom = MagicManualUtils.GetBossLevel(self.props.npcRefreshId)
    local infoData = {
      petBaseId = self.props.petBaseId,
      level = level,
      bForceShowType = true
    }
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
  elseif 2 == self.battleType then
    local infoData = {
      petBaseId = self.legendaryPetBaseId,
      level = self.legendaryLevel,
      bForceShowType = true
    }
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
  end
end

function UMG_NpcInfo_TeamBattle_C:OnOpenBloodTips()
  local teamBattleInfo = self.props.teamBattleInfo
  if teamBattleInfo then
    local data = {
      base_conf_id = teamBattleInfo.battle_petbase_id,
      mutation_type = _G.Enum.MutationDiffType.MDT_NONE,
      blood_id = teamBattleInfo.blood
    }
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleBloodPulse, data)
  end
end

function UMG_NpcInfo_TeamBattle_C:OnGetFlowerInfo()
  return self.FlowerInfo
end

function UMG_NpcInfo_TeamBattle_C:UpdateShinyFlowerInfo(flower, props)
  local TypeWrap = props.FlowerInfoTypeWrap
  self.FlowerInfo = flower
  if flower and TypeWrap.IsShinyFlower then
    MagicManualUtils.RefreshCurBubbleText(self.TheShinyFlowerDescField, props.npcRefreshId)
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Visible)
    if props.shouldSetPetIcon then
      self.PetIcon:SetPath(props.petIconPath)
    end
    if self.Star_1 then
      self.NRCSwitcher_56:SetActiveWidgetIndex(1)
      self.Star_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif TypeWrap and TypeWrap.Is7StarHardFlower then
    MagicManualUtils.RefreshCueBubbleNature(self.CueBubble, flower)
    if self.Predestined then
      self.Predestined:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Visible)
  else
    if self.Star_1 then
      self.Star_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.CueBubble:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_NpcInfo_TeamBattle_C:RefreshTeamBattleTimeText(shouldShowTime, timeText)
  self.RemainTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if shouldShowTime then
    self.RemainTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_RemainTime:SetText(timeText)
  end
end

return UMG_NpcInfo_TeamBattle_C
