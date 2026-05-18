local UMG_BattleShowImage_C = _G.NRCPanelBase:Extend("UMG_BattleShowImage_C")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
UMG_BattleShowImage_C.SetTeamDataType = {USE_BATTLE_PLAYER_INFO = 1, MAX = 2}
UMG_BattleShowImage_C.PlayerType = {
  Player = 1,
  Player2 = 2,
  Enemy = 3,
  Enemy2 = 4
}
UMG_BattleShowImage_C.PlayerTypeSlotNameMapIndexMap = {
  [UMG_BattleShowImage_C.PlayerType.Player] = 1,
  [UMG_BattleShowImage_C.PlayerType.Player2] = 2,
  [UMG_BattleShowImage_C.PlayerType.Enemy] = 3,
  [UMG_BattleShowImage_C.PlayerType.Enemy2] = 4
}

function UMG_BattleShowImage_C:OnActive()
end

function UMG_BattleShowImage_C:OnDeactive()
end

function UMG_BattleShowImage_C:OnAddEventListener()
end

function UMG_BattleShowImage_C:OnConstruct()
  self.SlotNameMap = {
    [1] = "Slot_Player1",
    [2] = "Slot_Player2",
    [3] = "Slot_Enemy1",
    [4] = "Slot_Enemy2"
  }
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(4)
end

function UMG_BattleShowImage_C:OnDestruct()
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(0)
  self:ClearWorld()
  if self.teamModelRequest then
    NRCResourceManager:UnLoadRes(self.teamModelRequest)
  end
  if self.teamModel2Request then
    NRCResourceManager:UnLoadRes(self.teamModel2Request)
  end
  if self.enemyModelRequest then
    NRCResourceManager:UnLoadRes(self.enemyModelRequest)
  end
  if self.enemyModel2Request then
    NRCResourceManager:UnLoadRes(self.enemyModel2Request)
  end
  self.ShakeResRequest = nil
  if self.captureComponent then
    self.captureComponent.showOnlyActors:Clear()
  end
  self.successCallBack = nil
  self.parentWidget = nil
end

function UMG_BattleShowImage_C:ClearWorld()
  if self.teamModel and self.teamModel.RocoSkill then
    SkillUtils.ClearSkillObj(self.teamModel.RocoSkill)
    self.previewWorld:DestroyActor(self.teamModel)
    self.teamModel:Release()
  end
  if self.enemyModel and self.enemyModel.RocoSkill then
    SkillUtils.ClearSkillObj(self.enemyModel.RocoSkill)
    self.previewWorld:DestroyActor(self.enemyModel)
    self.enemyModel:Release()
  end
  self.teamModel = nil
  self.teamModelRef = nil
  self.enemyModel = nil
  self.enemyModelRef = nil
  self.teamModel2 = nil
  self.teamModel2Ref = nil
  self.enemyModel2 = nil
  self.enemyModel2Ref = nil
end

function UMG_BattleShowImage_C:GetModelPath(roleInfo)
  local ModelConfID = BattleUtils.GetPlayerModelId(roleInfo)
  local modelConfig = _G.DataConfigManager:GetModelConf(ModelConfID)
  if modelConfig then
    return modelConfig.path
  else
    Log.Error("UMG_BattleShowImage_C.GetModelPath:modelConfig is nil ModelConfID=", ModelConfID, "please check the \"MODEL_CONF\" config")
  end
end

function UMG_BattleShowImage_C:GetTransformBySlotName(slotName)
  local slotActor = self.previewWorld:getActorByName(slotName)
  local transform = slotActor:GetTransform()
  return transform
end

function UMG_BattleShowImage_C:SetModelTransform(model, playerType)
  if not UE.UObject.IsValid(model) then
    return
  end
  local slotName = self.SlotNameMap[UMG_BattleShowImage_C.PlayerTypeSlotNameMapIndexMap[playerType]]
  local transform = self:GetTransformBySlotName(slotName)
  local halfHeight = 0
  if model:IsA(UE.ARocoCharacter) then
    local character = model
    halfHeight = character:GetHalfHeight()
  end
  local location = UE.FVector(transform.Translation.X, transform.Translation.Y, transform.Translation.Z + halfHeight)
  model:Abs_K2_SetActorLocation_WithoutHit(location)
end

function UMG_BattleShowImage_C:SetAllModelsTransform()
  self:SetModelTransform(self.teamModel, UMG_BattleShowImage_C.PlayerType.Player)
  self:SetModelTransform(self.teamModel2, UMG_BattleShowImage_C.PlayerType.Player2)
  self:SetModelTransform(self.enemyModel, UMG_BattleShowImage_C.PlayerType.Enemy)
  self:SetModelTransform(self.enemyModel2, UMG_BattleShowImage_C.PlayerType.Enemy2)
end

function UMG_BattleShowImage_C:LoadedAllPlayer()
  self:AddPetToScene(self.teamModel)
  if self.teamModel2 then
    self:AddPetToScene(self.teamModel2)
  end
  self:AddPetToScene(self.enemyModel)
  if self.enemyModel2 then
    self:AddPetToScene(self.enemyModel2)
  end
  self:SetAllModelsTransform()
  self.teamPlayerList = {
    teamPlayer = self.teamModel,
    teamPlayer2 = self.teamModel2,
    enemyPlayer = self.enemyModel,
    enemyPlayer2 = self.enemyModel2,
    playerBallActors = self.playerBallActors,
    enemyBallActors = self.enemyBallActors
  }
  self.LoadSuitTotal = 2
  self.LoadSuitCount = 0
  self:TryLoadSuit(self.enemyModel, self.enemyPlayer)
  self:TryLoadSuit(self.teamModel, self.teamPlayer)
end

function UMG_BattleShowImage_C:TryLoadSuit(Model, Player)
  if Player and Player.roleInfo.role_addi_info and Player.roleInfo.role_addi_info.appearance_info then
    local wearing_item = Player.roleInfo.role_addi_info.appearance_info.wearing_item or Player.roleInfo.role_addi_info.appearance_info.fashion_id
    local salonIds = Player.roleInfo.role_addi_info.appearance_info.salon_item_data
    if wearing_item then
      Model:SetDefaultSuit(Model.Mesh, Player.roleInfo.base.sex, wearing_item, salonIds, self.LoadSuitSuccess, self)
    else
      self:LoadSuitSuccess()
    end
  else
    self:LoadSuitSuccess()
  end
end

function UMG_BattleShowImage_C:LoadSuitSuccess()
  self.LoadSuitCount = self.LoadSuitCount + 1
  if self.LoadSuitCount >= self.LoadSuitTotal and self.successCallBack then
    self.successCallBack(self.teamPlayerList, self.parentWidget)
    self.successCallBack = nil
  end
end

function UMG_BattleShowImage_C:LoadModelSceneOver(player)
  if player.AnimConfig and player.RocoAnim then
    player.RocoAnim:SetAnimConfig(player.AnimConfig)
  end
  player.mesh:SetForcedLOD(1)
  self.loadedCount = self.loadedCount + 1
  self:CheckAllActorsLoaded()
end

function UMG_BattleShowImage_C:LoadModelPathOver(resRequest, modelClass, playerType)
  local slotName = self.SlotNameMap[UMG_BattleShowImage_C.PlayerTypeSlotNameMapIndexMap[playerType]]
  local transform = self:GetTransformBySlotName(slotName)
  local player = self.previewWorld:SpawnActor(modelClass, transform)
  player:InitOutSceneAsync(self, self.LoadModelSceneOver)
  if playerType == UMG_BattleShowImage_C.PlayerType.Player then
    self.teamModel = player
    self.teamModelRef = UnLua.Ref(self.teamModel)
    self.teamModelRequest = resRequest
  elseif playerType == UMG_BattleShowImage_C.PlayerType.Enemy then
    self.enemyModel = player
    self.enemyModelRef = UnLua.Ref(self.enemyModel)
    self.enemyModelRequest = resRequest
  elseif playerType == UMG_BattleShowImage_C.PlayerType.Enemy2 then
    self.enemyModel2 = player
    self.enemyModel2Ref = UnLua.Ref(self.enemyModel2)
    self.enemyModel2Request = resRequest
  elseif playerType == UMG_BattleShowImage_C.PlayerType.Player2 then
    self.teamModel2 = player
    self.teamModel2Ref = UnLua.Ref(self.teamModel2)
    self.teamModel2Request = resRequest
  end
end

function UMG_BattleShowImage_C:CheckAllActorsLoaded()
  if self.loadedCount == self.LoadModeTotal and self.playerBallCount == #self.playerBallPath and self.enemyBallCount == #self.enemyBallPath then
    self:LoadedAllPlayer()
  end
end

function UMG_BattleShowImage_C:SetTeamData(battlePlayerData, ballPath, enemyBallPath, parentWidget, successCallBack, type)
  self.playerBallPath = ballPath or {}
  self.enemyBallPath = enemyBallPath or {}
  self.playerBallActors = {}
  self.enemyBallActors = {}
  local teamPlayer = battlePlayerData.teamPlayer
  local teamPlayer2 = battlePlayerData.teamPlayer2
  local enemyPlayer = battlePlayerData.enemyPlayer
  local enemyPlayer2 = battlePlayerData.enemyPlayer2
  self.enemyPlayer = enemyPlayer
  self.teamPlayer = teamPlayer
  self.parentWidget = parentWidget
  self.successCallBack = successCallBack
  self.LoadModeTotal = 2
  if teamPlayer2 then
    self.LoadModeTotal = self.LoadModeTotal + 1
  end
  if enemyPlayer2 then
    self.LoadModeTotal = self.LoadModeTotal + 1
  end
  self.loadedCount = 0
  self.playerBallCount = 0
  self.enemyBallCount = 0
  for index, Path in pairs(self.playerBallPath) do
    if Path == BattleConst.BallPaths.None then
      self.playerBallCount = self.playerBallCount + 1
      self:CheckAllActorsLoaded()
    else
      NRCResourceManager:LoadResAsync(self, Path, 255, -1, function(caller, resRequest, modelClass)
        self:LoadPlayerBallPathOver(resRequest, modelClass, index)
      end, function(caller, resRequest, errMsg)
        Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath1=", path, errMsg)
      end)
    end
  end
  for index, Path in pairs(self.enemyBallPath) do
    if Path == BattleConst.BallPaths.None then
      self.enemyBallCount = self.enemyBallCount + 1
      self:CheckAllActorsLoaded()
    else
      NRCResourceManager:LoadResAsync(self, Path, 255, -1, function(caller, resRequest, modelClass)
        self:LoadEnemyBallPathOver(resRequest, modelClass, index)
      end, function(caller, resRequest, errMsg)
        Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath1=", path, errMsg)
      end)
    end
  end
  if type == UMG_BattleShowImage_C.SetTeamDataType.MAX then
    local teamClassPath1 = self:GetModelPath(1)
    NRCResourceManager:LoadResAsync(self, teamClassPath1, 255, -1, function(caller, resRequest, modelClass)
      self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Player)
    end, function(caller, resRequest, errMsg)
      Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath1=", teamClassPath1, errMsg)
    end)
    local teamClassPath2 = self:GetModelPath(1)
    NRCResourceManager:LoadResAsync(self, teamClassPath2, 255, -1, function(caller, resRequest, modelClass)
      self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Player2)
    end, function(caller, resRequest, errMsg)
      Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath2=", teamClassPath2, errMsg)
    end)
  else
    if not enemyPlayer or not enemyPlayer.roleInfo then
      return
    end
    if not teamPlayer or not teamPlayer.roleInfo then
      return
    end
    local teamClassPath1 = self:GetModelPath(teamPlayer.roleInfo)
    NRCResourceManager:LoadResAsync(self, teamClassPath1, 255, -1, function(caller, resRequest, modelClass)
      self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Player)
    end, function(caller, resRequest, errMsg)
      Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath1=", teamClassPath1, errMsg)
    end)
    if teamPlayer2 then
      local teamClassPath2
      if teamPlayer2.roleInfo then
        teamClassPath2 = self:GetModelPath(teamPlayer2.roleInfo)
      end
      if teamPlayer2.card then
        teamClassPath2 = teamPlayer2.card.resourcePath
      end
      NRCResourceManager:LoadResAsync(self, teamClassPath2, 255, -1, function(caller, resRequest, modelClass)
        self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Player2)
      end, function(caller, resRequest, errMsg)
        Log.Error("UMG_BattleShowImage_C LoadResAsync failed teamClassPath2=", teamClassPath2, errMsg)
      end)
    end
    local enemyClassPath1 = self:GetModelPath(enemyPlayer.roleInfo)
    NRCResourceManager:LoadResAsync(self, enemyClassPath1, 255, -1, function(caller, resRequest, modelClass)
      self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Enemy)
    end, function(caller, resRequest, errMsg)
      Log.Error("UMG_BattleShowImage_C LoadResAsync failed enemyClassPath1=", enemyClassPath1, errMsg)
    end)
    if enemyPlayer2 then
      local enemyClassPath2 = self:GetModelPath(enemyPlayer2.roleInfo)
      NRCResourceManager:LoadResAsync(self, enemyClassPath2, 255, -1, function(caller, resRequest, modelClass)
        self:LoadModelPathOver(resRequest, modelClass, UMG_BattleShowImage_C.PlayerType.Enemy2)
      end, function(caller, resRequest, errMsg)
        Log.Error("UMG_BattleShowImage_C LoadResAsync failed enemyClassPath2=", enemyClassPath2, errMsg)
      end)
    end
  end
end

function UMG_BattleShowImage_C:LoadPlayerBallPathOver(resRequest, modelClass, Index)
  local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(0, 0, 0))
  local ballActor = self.previewWorld:SpawnActor(modelClass, Transform)
  ballActor:InitOutSceneAsync(nil, function(actor)
    self.playerBallActors[Index] = actor
    self.playerBallCount = self.playerBallCount + 1
    self:CheckAllActorsLoaded()
  end)
end

function UMG_BattleShowImage_C:LoadEnemyBallPathOver(resRequest, modelClass, Index)
  local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(0, 0, 0))
  local ballActor = self.previewWorld:SpawnActor(modelClass, Transform)
  ballActor:InitOutSceneAsync(nil, function(actor)
    self.enemyBallActors[Index] = actor
    self.enemyBallCount = self.enemyBallCount + 1
    self:CheckAllActorsLoaded()
  end)
end

function UMG_BattleShowImage_C:AddPetToScene(playerActor)
  playerActor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, UE4.ERocoCustomMovementMode.MOVE_N)
  playerActor:SetIKEnable(false)
  playerActor:SetActorHiddenInGame(false)
  local mesh = playerActor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.bForceMipStreaming = true
  mesh.BoundsScale = mesh.BoundsScale * 10
  playerActor.mesh = mesh
end

return UMG_BattleShowImage_C
