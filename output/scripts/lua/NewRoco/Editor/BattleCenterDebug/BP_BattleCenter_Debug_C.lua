local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local VBattleField = require("NewRoco.Modules.Core.Battle.View.VBattleField")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BP_BattleCenter_Debug_C = NRCClass:Extend("BP_BattleCenter_Debug_C")

function BP_BattleCenter_Debug_C:BornBattleField()
  if self.BattleConf == nil then
    Log.Error("BattleConf is nil, cannot born battle field")
    return
  end
  if not self.PlayerModel then
    self:InitBattleField()
    self:PawnBattleModel()
  end
  self:LineGround()
end

function BP_BattleCenter_Debug_C:InitBattleField()
  local World = _G.UE4Helper.GetCurrentWorld()
  local BattleFieldConfClass = UE4.UObject.Load(_G.UEPath.BP_BattleFieldConf)
  local BattleFields = UE4.UGameplayStatics.GetAllActorsOfClass(World, BattleFieldConfClass)
  local BattleType = self.BattleConf and self.BattleConf.type or self.BattleConf.BattleType.BT_PVE
  for _, BattleField in tpairs(BattleFields) do
    if VBattleField:IsSameType(BattleType, BattleField.BattleType) then
      self.battleFieldConf = BattleField
      break
    end
  end
  self.playerNumber = 1 + #self.BattleConf.npc_battle_ally_list
  self.playerPetNumber = self.BattleConf.challanger_unit_num * self.playerNumber
  self.enemyNumber = #self.BattleConf.npc_battle_list
  self.enemyPetNumber = math.max(self.BattleConf.bechallanger_unit_num * self.enemyNumber, self.BattleConf.bechallanger_unit_num)
  if self.battleFieldConf and self.battleFieldConf.BattleFieldActor then
    self.battleFieldConf.BattleFieldActor:Abs_K2_SetActorLocation_WithoutHit(self:Abs_K2_GetActorLocation(), false, false)
    self.battleFieldConf.BattleFieldActor:K2_SetActorRotation(self:K2_GetActorRotation(), false)
    if self.battleFieldConf then
      if self.playerNumber > 1 or self.enemyNumber > 1 or self.playerPetNumber > 1 or self.enemyPetNumber > 1 then
        self.battleFieldConf:SetCurrentPosNum(self.playerPetNumber, self.playerPetNumber, math.min(2, self.enemyPetNumber), math.min(2, self.enemyPetNumber))
      else
        self.battleFieldConf:SetCurrentPosNum(1, 2, 1, 2)
        if 1 == self.BattleConf.challanger_unit_num and 1 == self.BattleConf.bechallanger_unit_num then
          self.battleFieldConf:SetCurrentPosNum(1, 1, 1, 1)
        elseif 2 == self.BattleConf.challanger_unit_num and 1 == self.BattleConf.bechallanger_unit_num then
          self.battleFieldConf:SetCurrentPosNum(1, 2, 1, 1)
        else
          self.battleFieldConf:SetCurrentPosNum(1, 2, 1, 2)
        end
      end
    end
  end
end

function BP_BattleCenter_Debug_C:GetTeamPositionMap(teamType, isPlayer)
  if isPlayer then
    if teamType == BattleEnum.Team.ENUM_TEAM then
      return self.battleFieldConf.CurrentModePosInfo.TeamatePlayerPos
    else
      return self.battleFieldConf.CurrentModePosInfo.EnemyPlayerPos
    end
  elseif teamType == BattleEnum.Team.ENUM_TEAM then
    return self.battleFieldConf.CurrentModePosInfo.TeamatePetPos
  else
    return self.battleFieldConf.CurrentModePosInfo.EnemyPetPos
  end
end

function BP_BattleCenter_Debug_C:GetPositionInBattleMap(teamEnm, posInField, isPlayer)
  local petPos = self:GetTeamPositionMap(teamEnm, isPlayer)
  if petPos then
    local petPosMap = petPos:Get(posInField)
    if petPosMap then
      return petPosMap:Abs_GetTransform()
    else
      Log.Error("GetPositionInBattleMap Error petPosMap is nil", teamEnm, posInField, isPlayer or "false")
      return petPos:Get(1):Abs_GetTransform()
    end
  else
    Log.Error("GetPositionInBattleMap Error  petPos is nil", teamEnm, posInField, isPlayer or "false")
    return
  end
end

function BP_BattleCenter_Debug_C:PawnBattlePlayer(modelId, teamType, posInField, AttachPos)
  local model = BattleConst.Human_Male
  if modelId then
    local npcCfg = _G.DataConfigManager:GetNpcConf(modelId, true)
    if npcCfg then
      model = npcCfg.model_conf
    end
  end
  local modelConf = _G.DataConfigManager:GetModelConf(model)
  local modelPath = "Blueprint'/Game/NewRoco/Modules/Core/Battle/Player/C001_0001/BP_Battle_C001_0001.BP_Battle_C001_0001_C'"
  if modelConf then
    modelPath = modelConf.path
  end
  local Uclass = UE4.UObject.Load(modelPath)
  local Transform = self:GetPositionInBattleMap(teamType, posInField, true)
  local player = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(Uclass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if AttachPos then
    if not self.NPCAttackPoint then
      self.NPCAttackPoint = {}
    end
    if not self.NPCAttackPoint[posInField] then
      self.NPCAttackPoint[posInField] = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(UE4.AActor, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
      self.NPCAttackPoint[posInField]:AddComponentByClass(UE4.USceneComponent, false, UE.FTransform(), false)
      self.NPCAttackPoint[posInField]:Abs_K2_SetActorTransform(Transform, false, nil, false)
    end
    self.NPCAttackPoint[posInField].Tags = {
      "NPCAttackPoint" .. posInField
    }
    self.NPCAttackPoint[posInField]:K2_AttachToActor(self, nil, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, false)
    player:K2_AttachToActor(self.NPCAttackPoint[posInField], nil, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, false)
    local x, y = AttachPos[1] or 0, AttachPos[2] or 0
    player:K2_SetActorRelativeLocation(UE4.FVector(x, y, 0), false, nil, false)
  else
    player:K2_AttachToActor(self, nil, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, false)
  end
  local skMesh = player:GetComponentByClass(UE4.USkeletalMeshComponent)
  if skMesh then
    skMesh.bReceivesDecals = false
  end
  return player
end

function BP_BattleCenter_Debug_C:PawnBattlePet(modelPath, teamType, posInField)
  local Uclass = UE4.UObject.Load(modelPath)
  local Transform = self:GetPositionInBattleMap(teamType, posInField)
  local pet = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(Uclass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  pet:K2_AttachToActor(self, nil, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, false)
  local skMesh = pet:GetComponentByClass(UE4.USkeletalMeshComponent)
  if skMesh then
    skMesh.bReceivesDecals = false
  end
  return pet
end

function BP_BattleCenter_Debug_C:GetPetModelPathById(petId)
  local config = _G.DataConfigManager:GetMonsterConf(petId, true)
  config = config or _G.DataConfigManager:GetPetConf(petId, true)
  local petBaseId = 3452
  if config then
    petBaseId = config.base_id
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId, true)
  local modelId = 14462
  if petBaseConf then
    modelId = petBaseConf.model_conf
  end
  local modelConf = _G.DataConfigManager:GetModelConf(modelId, true)
  if modelConf then
    return modelConf.path
  end
  return "Blueprint'/Game/ArtRes/BP/Pets/Com_YaJiJi1Ar_002/BP_Com_YaJiJi1Ar_002.BP_Com_YaJiJi1Ar_002_C'"
end

function BP_BattleCenter_Debug_C:PawnBattleModel()
  if self.battleFieldConf == nil then
    Log.Error("battleFieldConf is nil, cannot pawn battle model")
    return
  end
  for i, v in ipairs(self.BattleConf.npc_battle_ally_list) do
    if not self.PlayerModel then
      self.PlayerModel = {}
    end
    if v.battle_model_ally and v.battle_model_ally > 0 then
      table.insert(self.PlayerModel, self:PawnBattlePlayer(v.battle_model_ally, BattleEnum.Team.ENUM_TEAM, i))
    end
    for j = 1, self.BattleConf.challanger_unit_num do
      if not self.PlayerPetModel then
        self.PlayerPetModel = {}
      end
      table.insert(self.PlayerPetModel, self:PawnBattlePet(self:GetPetModelPathById(v.pos1_1st_ally[1]), BattleEnum.Team.ENUM_TEAM, (i - 1) * self.BattleConf.challanger_unit_num + j))
    end
  end
  if not self.PlayerModel then
    self.PlayerModel = {}
  end
  local playerIndex = #self.BattleConf.npc_battle_ally_list + 1
  table.insert(self.PlayerModel, self:PawnBattlePlayer(1010001, BattleEnum.Team.ENUM_TEAM, playerIndex))
  for j = 1, self.BattleConf.challanger_unit_num do
    if not self.PlayerPetModel then
      self.PlayerPetModel = {}
    end
    table.insert(self.PlayerPetModel, self:PawnBattlePet(self:GetPetModelPathById(), BattleEnum.Team.ENUM_TEAM, (playerIndex - 1) * self.BattleConf.challanger_unit_num + j))
  end
  if not self.EnemyModel then
    self.EnemyModel = {}
  end
  for i, v in ipairs(self.BattleConf.npc_battle_list) do
    if v.battle_model_1st and v.battle_model_1st > 0 then
      local actorPos = v.npc_location or {}
      if _G.DebugBattleCenterHasDirtyData and BattleCenterDebugManager and BattleCenterDebugManager.ChangeConfs and BattleCenterDebugManager.ChangeConfs[self.BattleConfId] then
        actorPos = BattleCenterDebugManager.ChangeConfs[self.BattleConfId].npc_location[i] or {}
      end
      table.insert(self.EnemyModel, self:PawnBattlePlayer(v.battle_model_1st, BattleEnum.Team.ENUM_ENEMY, i, actorPos))
    end
    for j = 1, self.BattleConf.bechallanger_unit_num do
      if not self.EnemyPetModel then
        self.EnemyPetModel = {}
      end
      table.insert(self.EnemyPetModel, self:PawnBattlePet(self:GetPetModelPathById(v.pos1_1st[1]), BattleEnum.Team.ENUM_ENEMY, (i - 1) * self.BattleConf.bechallanger_unit_num + j))
    end
  end
  if not self.EnemyPetModel then
    self.EnemyPetModel = {}
  end
  for i = #self.EnemyPetModel, self.enemyPetNumber - 1 do
    table.insert(self.EnemyPetModel, self:PawnBattlePet(self:GetPetModelPathById(), BattleEnum.Team.ENUM_ENEMY, i + 1))
  end
end

function BP_BattleCenter_Debug_C:LineGround()
  local groundCenter = LineTraceUtils.GetPointValidLocationByLine(self:Abs_K2_GetActorLocation(), nil, nil, self:Abs_K2_GetActorLocation())
  groundCenter.z = groundCenter.z + 10
  self:Abs_K2_SetActorLocation(groundCenter, false, nil, false)
  for _, v in pairs(self.PlayerModel or {}) do
    local groundPoint = LineTraceUtils.GetPointValidLocationByLine(v:Abs_K2_GetActorLocation(), nil, nil, self:Abs_K2_GetActorLocation())
    groundPoint.z = groundPoint.z + v:GetCurrentHalfHeight()
    v:Abs_K2_SetActorLocation(groundPoint, false, nil, false)
  end
  for _, v in pairs(self.EnemyModel or {}) do
    local groundPoint = LineTraceUtils.GetPointValidLocationByLine(v:Abs_K2_GetActorLocation(), nil, nil, self:Abs_K2_GetActorLocation())
    groundPoint.z = groundPoint.z + v:GetCurrentHalfHeight()
    v:Abs_K2_SetActorLocation(groundPoint, false, nil, false)
  end
  for _, v in pairs(self.PlayerPetModel or {}) do
    local groundPoint = LineTraceUtils.GetPointValidLocationByLine(v:Abs_K2_GetActorLocation(), nil, nil, self:Abs_K2_GetActorLocation())
    groundPoint.z = groundPoint.z + v:GetCurrentHalfHeight()
    v:Abs_K2_SetActorLocation(groundPoint, false, nil, false)
  end
  for _, v in pairs(self.EnemyPetModel or {}) do
    local groundPoint = LineTraceUtils.GetPointValidLocationByLine(v:Abs_K2_GetActorLocation(), nil, nil, self:Abs_K2_GetActorLocation())
    groundPoint.z = groundPoint.z + v:GetCurrentHalfHeight()
    v:Abs_K2_SetActorLocation(groundPoint, false, nil, false)
  end
end

function BP_BattleCenter_Debug_C:SetBattleConf(battleConf)
  if nil == battleConf then
    Log.Error("battleConf is nil, cannot set battle conf")
    return
  end
  if self.BattleConf and self.BattleConf.id == battleConf.id then
    return
  end
  self:DestroyBattleField()
  self.BattleConf = battleConf
  self.BattleConfId = battleConf.id
end

function BP_BattleCenter_Debug_C:DestroyBattleField()
  if self.PlayerModel then
    for _, v in pairs(self.PlayerModel) do
      v:K2_DestroyActor()
    end
    self.PlayerModel = nil
  end
  if self.EnemyModel then
    for _, v in pairs(self.EnemyModel) do
      v:K2_DestroyActor()
    end
    self.EnemyModel = nil
  end
  if self.PlayerPetModel then
    for _, v in pairs(self.PlayerPetModel) do
      v:K2_DestroyActor()
    end
    self.PlayerPetModel = nil
  end
  if self.EnemyPetModel then
    for _, v in pairs(self.EnemyPetModel) do
      v:K2_DestroyActor()
    end
    self.EnemyPetModel = nil
  end
end

function BP_BattleCenter_Debug_C:SaveToLua()
  if self.BattleConf == nil then
    Log.Error("battleConf is nil, cannot save to lua")
    return
  end
  if BattleCenterDebugManager then
    if not BattleCenterDebugManager.ChangeConfs then
      BattleCenterDebugManager.ChangeConfs = {}
    end
    _G.DebugBattleCenterHasDirtyData = true
    local npcPos = {}
    BattleCenterDebugManager.ChangeConfs[self.BattleConf.id] = {
      pos = self:Abs_K2_GetActorLocation(),
      rot = self:K2_GetActorRotation(),
      npc_location = npcPos
    }
    if self.EnemyModel then
      for _, v in ipairs(self.EnemyModel) do
        local onePos = v:K2_GetRootComponent():GetRelativeTransform().Translation
        local posTable = {
          onePos.x,
          onePos.y,
          onePos.z
        }
        table.insert(npcPos, posTable)
      end
    end
  end
end

return BP_BattleCenter_Debug_C
