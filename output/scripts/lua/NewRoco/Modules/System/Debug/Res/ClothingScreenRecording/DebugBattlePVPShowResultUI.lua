local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DebugBattlePVPShowResultUI = NRCClass()

function DebugBattlePVPShowResultUI:Ctor()
end

function DebugBattlePVPShowResultUI:PlaySkillInfo()
  self.BattleManager = _G.BattleManager
  local PlayerTeamPets = _G.BattleManager.battlePawnManager:GetPlayerTeamPets()
  local EnemyPets = _G.BattleManager.battlePawnManager:GetEnemyAllPets()
  if 0 == #PlayerTeamPets or 0 == #EnemyPets then
    Log.Debug("BattlePet Location Info #PlayerTeamPets=", #PlayerTeamPets, "#EnemyPets=", #EnemyPets)
    return
  end
  for i, battleNpc in ipairs(_G.BattleManager.battlePawnManager.battleNpcList) do
    battleNpc:HideNpc()
  end
  self.WinPlayer = self.BattleManager.battlePawnManager.TeamatePlayer
  self.LosePlayer = self.BattleManager.battlePawnManager.EnemyPlayer
  self.SkillComponent = self.BattleManager.vBattleField.battleFieldActor.Skill
  self.teamPet = PlayerTeamPets[1]
  self.EnemyPets = EnemyPets[1]
  local LastHitBaseId = self.teamPet.card.petInfo and self.teamPet.card.petInfo.battle_common_pet_info.base_conf_id
  local LastHitGID = self.teamPet.card.petInfo and self.teamPet.card.petInfo.battle_common_pet_info.gid
  local LastHitPetCard = self.BattleManager.battlePawnManager:GetCardByCommonGuid(self.WinPlayer.teamEnm, LastHitGID)
  local skillPath
  local isTriggerSuit = false
  local preBaseId = -1
  if LastHitPetCard then
    preBaseId = LastHitPetCard.petBaseConf.id
    if preBaseId ~= LastHitBaseId then
      LastHitPetCard:RefreshByBaseConf(LastHitBaseId)
    end
    skillPath = LastHitPetCard.AppearancePath:GetPVPOver()
    isTriggerSuit = LastHitPetCard.AppearancePath.PVPOverSuiId > 0
  else
    skillPath, isTriggerSuit = self.WinPlayer.FashionData:GetPVPOver()
  end
  self.NeedWaitLoadPet = false
  if isTriggerSuit then
    self.winPet = _G.BattleManager.battlePawnManager:GetFirstPet(self.WinPlayer.teamEnm)
    local winCard
    if not self.winPet then
      winCard = self.WinPlayer.deck.cards[1]
      if winCard then
        winCard.pos = 1
        winCard.posInField = 1
        self.NeedWaitLoadPet = true
      end
    elseif self.winPet.card.petBaseConf.id ~= LastHitBaseId then
      self.NeedWaitLoadPet = true
      winCard = self.winPet.card
      self.winPet:OnRecall()
    elseif LastHitGID == self.winPet.card.petInfo.battle_common_pet_info.gid and LastHitBaseId ~= preBaseId then
      self.NeedWaitLoadPet = true
      winCard = self.winPet.card
      self.winPet:OnRecall()
    end
    if self.NeedWaitLoadPet then
      winCard:RefreshByBaseConf(self.WinPlayer.FashionData.LastHitPetBaseId)
      winCard:SetInBattleField(true)
      self.winPet = BattleManager.battlePawnManager:PawnPet(self.WinPlayer.teamEnm, self.WinPlayer.team, winCard, self.WinPlayer, nil, true)
    end
  end
  self.skillPath = skillPath
  self:LoadCamera()
end

function DebugBattlePVPShowResultUI:LoadCamera()
  BattleSkillManager:PreLoadSingleRes(BattleConst.BattleCharacterMaskCamera, true, self, self.OnCameraResLoad)
end

function DebugBattlePVPShowResultUI:OnCameraResLoad(isLoadSucceed, skillPath)
  self:PlayStart()
end

function DebugBattlePVPShowResultUI:PlayStart()
  BattleSkillManager:PreLoadSingleRes(self.skillPath, true, self, self.OnSkillResLoad, self.teamPet)
end

function DebugBattlePVPShowResultUI:OnSkillResLoad(isLoadSucceed, skillPath, Caster)
  if not isLoadSucceed then
    return
  end
  local skillPathInfo = skillPath
  local skillClass = BattleSkillManager:GetLoadedClass(skillPathInfo)
  if not skillClass then
    Log.ErrorFormat("Failed to load skill class %s", skillPath)
    return
  end
  self:CreateCharacterMaskCamera()
  self.WinPlayer:ShowPlayer()
  self.LosePlayer:ShowPlayer()
  local skill = self.SkillComponent:FindOrAddSkillObj(skillClass)
  local Characters = self.BattleManager.battlePawnManager:GetAllPawnActorForSkill()
  if Characters[BattleConst.CharacterIndex.Player1] and Characters[BattleConst.CharacterIndex.Player1] ~= self.WinPlayer.model then
    for i = BattleConst.CharacterIndex.Player1, BattleConst.CharacterIndex.Player_Pet4 do
      local cache = Characters[i]
      Characters[i] = Characters[i + BattleConst.CharacterIndex.Player_Pet4 + 1]
      Characters[i + BattleConst.CharacterIndex.Player_Pet4 + 1] = cache
    end
  end
  if self.winPet then
    self.winPet:ShowPet(false)
    self.winPet:SetIKEnable(false)
    Characters[BattleConst.CharacterIndex.Player_Pet1] = self.winPet.model
    if self.winPet.model and self.winPet.model.mesh then
      self.winPet.model.mesh.BoundsScale = self.winPet.model.mesh.BoundsScale * 20
      self.winPet.model.mesh.bNRCUseFixedSkelBounds = false
    end
  end
  local hasOpenUiEvent = _G.SkillUtils.SkillObjHasLuaEvent(skill, UE4.ERocoSkillLuaEventType.OpenUI)
  if not hasOpenUiEvent then
    self:OpenBattlePVPResultPanel()
  end
  skill:RegisterEventCallback("Start", self, self.SkillStart)
  skill:RegisterEventCallback("OpenUI", self, self.OpenBattlePVPResultPanel)
  skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  skill:SetCharacters(Characters)
  skill.BattleGenderType = self.WinPlayer.roleInfo.base.sex
  skill:SetCaster(self.WinPlayer.model)
  if self.WinPlayer.model and self.WinPlayer.model.mesh then
    self.WinPlayer.model.mesh.BoundsScale = self.WinPlayer.model.mesh.BoundsScale * 20
    self.WinPlayer.model.mesh.bNRCUseFixedSkelBounds = false
  end
  if self.winPet then
    skill:SetTargets({
      self.winPet.model
    })
  else
    skill:SetTargets({
      self.LosePlayer.model
    })
  end
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBuffInfo)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ClosePVPValueNumberPanel)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OnShowBatleResult)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow)
  self.SkillComponent:PlaySkill(skill)
end

function DebugBattlePVPShowResultUI:CreateCharacterMaskCamera()
  local asset = _G.BattleResourceManager:GetCacheAssetDirect(BattleConst.BattleCharacterMaskCamera)
  local BattleCharacterMaskCameraClass = asset
  if not UE.UObject.IsValid(BattleCharacterMaskCameraClass) then
    return false, "BattlePVPShowResultUI:CreateCharacterMaskCamera BattleCharacterMaskCameraClass is not valid"
  end
  local world = _G.UE4Helper.GetCurrentWorld()
  local cameraTransform = UE.FTransform()
  local battleCharacterMaskCamera = world:Abs_SpawnActor(BattleCharacterMaskCameraClass, cameraTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil)
  _G.BattleManager.vBattleField.battleCharacterMaskCamera = battleCharacterMaskCamera
  if not UE.UObject.IsValid(battleCharacterMaskCamera) then
    return false
  end
  return true
end

function DebugBattlePVPShowResultUI:SkillStart(Event, Skill)
  self:AdjustPlayer()
  _G.DelayManager:DelayFrames(2, self.InitCharacterMaskCamera, self, Skill)
  _G.DelayManager:DelayFrames(2, self.AdjustPlayer, self)
end

function DebugBattlePVPShowResultUI:AdjustPlayer()
  local player = self.WinPlayer.model
  local enemy = self.LosePlayer.model
  local player = {
    player or {},
    enemy or {}
  }
  for _, v in pairs(player) do
    if v and v.GetHalfHeight then
      local HalfHeight = v:GetHalfHeight()
      local pos = v:Abs_K2_GetActorLocation()
      if pos then
        local groundPoint = LineTraceUtils.GetPointValidLocationByLine(pos, HalfHeight) or pos
        local newLocation = UE4.FVector(groundPoint.X, groundPoint.Y, groundPoint.Z + HalfHeight)
        v:Abs_K2_SetActorLocation_WithoutHit(newLocation)
      end
    end
  end
end

function DebugBattlePVPShowResultUI:InitCharacterMaskCamera(skill)
  local Blackboard = UE.UObject.IsValid(skill) and skill:GetBlackboard()
  local cameraActor = Blackboard and Blackboard:GetValueAsObject("camActor_0001")
  local vBattleField = _G.BattleManager and _G.BattleManager.vBattleField
  local battleCharacterMaskCamera = vBattleField and vBattleField.battleCharacterMaskCamera
  if UE.UObject.IsValid(battleCharacterMaskCamera) then
    local winPlayer = self.WinPlayer
    local winPlayerModel = winPlayer and winPlayer.model
    local winPet = self.winPet
    local winPetModel = winPet and winPet.model
    local actorList = {}
    if UE.UObject.IsValid(winPlayerModel) then
      table.insert(actorList, winPlayerModel)
    end
    if UE.UObject.IsValid(winPetModel) then
      table.insert(actorList, winPetModel)
    end
    battleCharacterMaskCamera:SetShowOnlyActorList(actorList)
  end
  if UE.UObject.IsValid(battleCharacterMaskCamera) and UE.UObject.IsValid(cameraActor) then
    battleCharacterMaskCamera:SetFollowTarget(cameraActor)
  end
end

function DebugBattlePVPShowResultUI:OnSkillEnd(event, internalSkill)
  local Blackboard = internalSkill:GetBlackboard()
  FsmUtils.SaveAsProperty(_G.BattleManager.stateFsm, Blackboard, "camActor_0001")
  FsmUtils.SaveAsProperty(_G.BattleManager.stateFsm, Blackboard, "camActor_0001_SA")
end

function DebugBattlePVPShowResultUI:OpenBattlePVPResultPanel()
  local data = {
    settle_info = ProtoMessage:newBattleSettleInfo(),
    seen_monster_id = {},
    ret_info = ProtoMessage:newRetInfo(),
    reward = ProtoMessage:newGoodsReward(),
    evolution_complete = nil,
    pet_info = {},
    bag_info = {},
    will_leave_visit = nil,
    consumed_carryons = {},
    pvp_score_records = {},
    pvp_score = nil,
    fashion_suit_info = {
      suit_id = 49,
      petbase_pvp_win_num = 6,
      level = nil,
      components_is_worn = {}
    },
    ride_id = nil,
    world_nums = {},
    simple_pets = {
      {
        pet_id = self.teamPet.guid,
        owner_uin = self.WinPlayer.guid,
        pet_conf_id = self.teamPet.card.petInfo.battle_common_pet_info.conf_id,
        pet_base_id = self.teamPet.card.petInfo.battle_common_pet_info.base_conf_id,
        name = self.teamPet.card.petInfo.battle_common_pet_info.name,
        mutation = self.teamPet.card.petInfo.battle_common_pet_info.mutation_type,
        side = nil,
        level = self.teamPet.card.petInfo.battle_common_pet_info.level,
        glass_info = self.teamPet.card.petInfo.battle_common_pet_info.glass_info
      },
      {
        pet_id = self.EnemyPets.guid,
        owner_uin = self.LosePlayer.guid,
        pet_conf_id = self.EnemyPets.card.petInfo.battle_common_pet_info.conf_id,
        pet_base_id = self.EnemyPets.card.petInfo.battle_common_pet_info.base_conf_id,
        name = self.EnemyPets.card.petInfo.battle_common_pet_info.name,
        mutation = self.EnemyPets.card.petInfo.battle_common_pet_info.mutation_type,
        side = nil,
        level = self.EnemyPets.card.petInfo.battle_common_pet_info.level,
        glass_info = self.EnemyPets.card.petInfo.battle_common_pet_info.glass_info
      }
    },
    pvp_rank_settle_info = ProtoMessage:newPvpRankSettleInfo(),
    create_battle_ret = nil,
    cli_startup_channel = nil,
    last_pvp_battle_type = nil,
    last_pvp_battle_ai_desc = nil
  }
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattlePVPResultPanel, data)
end

return DebugBattlePVPShowResultUI
