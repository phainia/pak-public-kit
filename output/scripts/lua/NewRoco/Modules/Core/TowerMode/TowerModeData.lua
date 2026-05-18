local TowerModeData = _G.NRCData:Extend("TowerModeData")

function TowerModeData:Ctor()
  self.stageID = nil
  self.curStage = nil
  self.battleID = nil
  self.StageConfigure = nil
  self.IsMultiplayerPV = false
  self.NPC = nil
  self.SelectLevelIndex = self.curStage or 1
  self.firstIndex = self.curStage or 1
  self.EnemyList = {}
  self.EnemyList_1 = {}
  self.EnemyList_2 = {}
  self.LevelList = {}
  NRCData.Ctor(self)
end

function TowerModeData:initialize()
  local ClimbChapterConf = _G.DataConfigManager:GetClimbChapterConf(self.stageID)
  self.SelectLevelIndex = self.curStage or 1
  self.firstIndex = self.curStage or 1
  if self.SelectLevelIndex > #ClimbChapterConf.stage then
    self.SelectLevelIndex = #ClimbChapterConf.stage
    self.firstIndex = #ClimbChapterConf.stage
  end
  Log.Debug(self.SelectLevelIndex, "TowerModeData:initialize")
end

function TowerModeData:GetLevelList()
  local ClimbChapterConf = _G.DataConfigManager:GetClimbChapterConf(self.stageID)
  local LevelList = {}
  local IsPassType = -1
  for i, ClimbChapter in ipairs(ClimbChapterConf.stage) do
    if i < self.curStage then
      IsPassType = 1
    elseif i == self.curStage then
      IsPassType = 0
    else
      IsPassType = -1
    end
    local LevelNumber = string.format("%02d", i)
    local StageConf = _G.DataConfigManager:GetStageConf(ClimbChapter)
    self:SetEnemyPet(StageConf.battle_id)
    local RewardInfo = self:SetRewardInfo(StageConf.show_reward_id)
    if self.IsMultiplayerPV then
      table.insert(LevelList, {
        stage = ClimbChapter,
        IsPassType = IsPassType,
        LevelNumber = LevelNumber,
        StageConf = StageConf,
        EnemyList_1 = self.EnemyList_1,
        EnemyList_2 = self.EnemyList_2,
        RewardInfo = RewardInfo
      })
    else
      table.insert(LevelList, {
        stage = ClimbChapter,
        IsPassType = IsPassType,
        LevelNumber = LevelNumber,
        StageConf = StageConf,
        EnemyList = self.EnemyList,
        RewardInfo = RewardInfo
      })
    end
  end
  table.insert(LevelList, 1, {stage = -1})
  table.insert(LevelList, 2, {stage = -1})
  table.insert(LevelList, {stage = -1})
  table.insert(LevelList, {stage = -1})
  self.LevelList = LevelList
  return LevelList
end

function TowerModeData:SetEnemyPet(battle_id)
  local BattleId = battle_id
  local BattleConf = _G.DataConfigManager:GetBattleConf(BattleId)
  local EnemyId = {}
  local EnemyList = {}
  local EnemyList_1 = {}
  local EnemyList_2 = {}
  if 1 == #BattleConf.npc_battle_list then
    self.IsMultiplayerPV = false
  else
    self.IsMultiplayerPV = true
  end
  for i, v in ipairs(BattleConf.npc_battle_list) do
    table.insert(EnemyId, {
      v.pos1_1st[1],
      v.pos2_1st[1],
      v.pos3_1st[1],
      v.pos4_1st[1],
      v.pos5_1st[1],
      v.pos6_1st[1]
    })
  end
  for i, Pos in ipairs(EnemyId) do
    for j, PosId in ipairs(Pos) do
      local MonsterConf = _G.DataConfigManager:GetMonsterConf(PosId)
      if MonsterConf then
        local petBaseConf = _G.DataConfigManager:GetPetbaseConf(MonsterConf.base_id)
        local TowerPetLevel = self:SetPetLevel(MonsterConf.new_level)
        if petBaseConf then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          if self.IsMultiplayerPV then
            if 1 == i then
              table.insert(EnemyList_1, {
                modelConf = modelConf,
                PetLevel = TowerPetLevel,
                petBaseConf = petBaseConf
              })
            else
              table.insert(EnemyList_2, {
                modelConf = modelConf,
                PetLevel = TowerPetLevel,
                petBaseConf = petBaseConf
              })
            end
          else
            table.insert(EnemyList, {
              modelConf = modelConf,
              PetLevel = TowerPetLevel,
              petBaseConf = petBaseConf
            })
          end
        end
      end
    end
  end
  self.EnemyList = EnemyList
  self.EnemyList_1 = EnemyList_1
  self.EnemyList_2 = EnemyList_2
end

function TowerModeData:SetPetLevel(new_level)
  local levelList = new_level
  local heroLv = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel() or 0
  if heroLv > levelList[2] then
    local Remainder = heroLv % levelList[3]
    if Remainder > 0 then
      local addLevel = Remainder * levelList[4]
      return levelList[1] + addLevel
    end
  end
  return levelList[1]
end

function TowerModeData:SetRewardInfo(show_reward_id)
  local RewardList = {}
  local RewardID = show_reward_id
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardID)
  if not RewardConf then
    return
  end
  local RewardItems = RewardConf.RewardItem
  if not RewardItems then
    return
  end
  if 0 == #RewardItems then
    return
  end
  for _, RewardItem in ipairs(RewardItems) do
    if RewardItem.Type == Enum.GoodsType.GT_NONE then
    elseif RewardItem.Type == Enum.GoodsType.GT_PET_HP then
    elseif RewardItem.Type == Enum.GoodsType.GT_REWARD then
    elseif RewardItem.Type == Enum.GoodsType.GT_CREATENPC then
    else
      table.insert(RewardList, RewardItem)
    end
  end
  return RewardList
end

function TowerModeData:SetFirstIndex(FirstIndex)
  self.firstIndex = FirstIndex
end

function TowerModeData:SetSelectLevelIndex(SelectIndex)
  self.SelectLevelIndex = SelectIndex
end

return TowerModeData
