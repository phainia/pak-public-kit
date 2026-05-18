local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattleFriendAssistEnterAction = Base:Extend("BattleFriendAssistEnterAction")
FsmUtils.MergeMembers(Base, BattleFriendAssistEnterAction, {})

function BattleFriendAssistEnterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleFriendAssistEnterAction:GetTarget()
  self.targetPets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM) or {}
  self.targetModels = {}
  for i, v in ipairs(self.targetPets) do
    self.targetModels[i] = v.model
  end
end

function BattleFriendAssistEnterAction:LoadBallPath()
  local ballAddPath = {}
  self.ballAddPathNum = 0
  for i = 1, #self.targetPets do
    self.ballAddPathNum = self.ballAddPathNum + 1
    ballAddPath[i] = BattleUtils.GetPetBallPath(self.targetPets[i].card.petInfo.battle_common_pet_info)
  end
  self.playerBallActors = {}
  self.playerBallCount = 0
  for index, Path in pairs(ballAddPath) do
    NRCResourceManager:LoadResAsync(self, Path, 255, -1, function(caller, resRequest, modelClass)
      self:LoadPlayerBallPathOver(resRequest, modelClass, index)
    end, function(caller, resRequest, errMsg)
      Log.Error("BattleFriendAssistEnterAction LoadResAsync failed teamClassPath1=", Path, errMsg)
    end)
  end
end

function BattleFriendAssistEnterAction:LoadPlayerBallPathOver(resRequest, modelClass, Index)
  local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(0, 0, 0))
  local World = UE4Helper.GetCurrentWorld()
  local ballActor = World:SpawnActor(modelClass, Transform)
  ballActor:InitOutSceneAsync(nil, function(actor)
    self:SaveBallActor(actor, Index)
  end)
end

function BattleFriendAssistEnterAction:HideSceneObjectsAndShowBattleObjects()
  if self.hasHideSceneObjectsAndShowBattleObjects then
    return
  end
  self.hasHideSceneObjectsAndShowBattleObjects = true
  self:ShowPawnActor(BattleEnum.Team.ENUM_TEAM)
  self:ShowPawnActor(BattleEnum.Team.ENUM_ENEMY)
  local HideScenePetDelegate = self:GetProperty(BattleConst.FsmVarNames.HideScenePetDelegate)
  if HideScenePetDelegate then
    HideScenePetDelegate:Invoke()
  else
    Log.Debug("BattlePlayThrowBallEnterAnimAction OnHidePlayer")
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
    NRCModeManager:DoCmd(NPCModuleCmd.EnterBattle, BattleManager.battleRuntimeData.NearbyValidBattleLocation, BattleConst.Define.BattleFieldRange)
    BattleUtils.PinOnTheGroundForAllPawn()
  end
  local HideSceneTreesDelegate = self:GetProperty(BattleConst.FsmVarNames.HideSceneTreesDelegate)
  if HideSceneTreesDelegate then
    HideSceneTreesDelegate:Invoke()
  end
end

function BattleFriendAssistEnterAction:SaveBallActor(actor, Index)
  if self.finished then
    return
  end
  if not self.playerBallActors then
    self.playerBallActors = {}
  end
  if not self.playerBallCount then
    self.playerBallCount = 0
  end
  self.playerBallActors[Index] = actor
  self.playerBallCount = self.playerBallCount + 1
  self:CheckAllActorsLoaded()
end

function BattleFriendAssistEnterAction:OnEnter()
  local CheckAppearanceMode = self:GetProperty("CheckAppearanceMode", false)
  if CheckAppearanceMode and BattleUtils.IsTriggerAppearanceInField(CheckAppearanceMode) then
    self:Finish()
    return
  end
  if not BattleUtils.IsFriendAssist() then
    self:Finish()
    return
  end
  self:GetTarget()
  self:LoadBallPath()
  self.loadedSkill = false
  self.hasHideSceneObjectsAndShowBattleObjects = false
  local skillPath = BattleConst.NpcAssistZhaoHuan
  _G.NRCResourceManager:LoadResAsync(self, skillPath, -1, 10, function(caller, resRequest, modelClass)
    self:OnAllSkillLoaded(resRequest, modelClass)
  end, self.OnSkillFinish)
end

function BattleFriendAssistEnterAction:OnAllSkillLoaded(request, skillClass)
  if self.finished then
    return
  end
  self.loadedSkill = true
  self.skillClass = skillClass
  self:CheckAllActorsLoaded()
end

function BattleFriendAssistEnterAction:CheckAllActorsLoaded()
  if self.loadedSkill and self.playerBallCount == self.ballAddPathNum then
    self:OnSkillLoad()
  end
end

function BattleFriendAssistEnterAction:OnSkillLoad()
  BattleUtils.CloseBattleAndTaskBlackLoading()
  local battlePlayer = BattleManager.battlePawnManager.TeamatePlayer
  if not battlePlayer or not battlePlayer.model then
    self:OnSkillFinish()
    return
  end
  local skillObj = battlePlayer.model.RocoSkill:AddSkillObjFromClassAndReturn(self.skillClass)
  if not self.skillClass or not skillObj then
    self:OnSkillFinish()
    return
  end
  local characters = BattleManager.battlePawnManager:GetAllPawnActorForSkill()
  local ballPath = BattleUtils.GetPetBallPath(self.targetPets[1].card.petInfo.battle_common_pet_info)
  local ballAddPath = {"None", "None"}
  for i = 2, #self.targetPets do
    ballAddPath[i - 1] = BattleUtils.GetPetBallPath(self.targetPets[i].card.petInfo.battle_common_pet_info)
  end
  local Blackboard = skillObj:GetBlackboard()
  for index, path in pairs(self.playerBallActors) do
    if self.playerBallActors and self.playerBallActors[index] then
      Blackboard:SetValueAsObject(string.format("_ID_AUTOGENERATE_BALL%d", index - 1), self.playerBallActors[index])
    end
  end
  skillObj.PlayerAmountType = 2
  local teamPets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM) or {}
  for _, pet in ipairs(teamPets) do
    BattleUtils.SetParticleKeyForSkillObj(pet.model, skillObj, pet.card.medalBlackBoard)
  end
  skillObj:SetDynamicData({BallPath = ballPath, BallAdditionalPaths = ballAddPath})
  skillObj:SetCaster(characters[1])
  skillObj:SetTargets(self.targetModels)
  skillObj:SetCharacters(characters)
  skillObj:RegisterEventCallback("ActionStart", self, self.HideSceneObjectsAndShowBattleObjects)
  skillObj:RegisterEventCallback("AdjustCamera", self, self.AdjustCamera)
  skillObj:RegisterEventCallback("End", self, self.OnSkillFinish)
  skillObj:RegisterEventCallback("PreEnd", self, self.OnSkillFinish)
  battlePlayer:PlaySkillObject(skillObj)
end

function BattleFriendAssistEnterAction:AdjustCamera(Event, skill)
  local Blackboard
  if skill then
    Blackboard = skill:GetBlackboard()
  else
    return
  end
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ShowHPBars)
  if Blackboard then
    self:SaveObject(Blackboard, BattleConst.PlayerShow.Cam)
    self:SaveObject(Blackboard, BattleConst.PlayerShow.Cam_SA)
  end
end

function BattleFriendAssistEnterAction:SaveObject(bb, name)
  FsmUtils.SaveAsProperty(self.fsm, bb, name)
end

function BattleFriendAssistEnterAction:OnSkillFinish(Event, Skill)
  self:HideSceneObjectsAndShowBattleObjects()
  self:ReleaseBallActor()
  BattleUtils.CloseBattleAndTaskBlackLoading()
  self:Finish()
end

function BattleFriendAssistEnterAction:ShowPawnActor(teamEnum)
  for i, v in ipairs(_G.BattleManager.battlePawnManager:GetAllTeam(teamEnum)) do
    if v.player and v.player.model then
      v.player:ShowPlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(true)
      end
      v.player.model:TryHelmetOn()
      if v.player.battlePlayerComponents and v.player.battlePlayerComponents.HideMark then
        v.player.battlePlayerComponents:HideMark()
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:ShowPet()
        end
      end
    end
  end
end

function BattleFriendAssistEnterAction:ReleaseBallActor()
  if self.playerBallActors then
    for _, ballActor in pairs(self.playerBallActors) do
      if ballActor and UE4.UObject.IsValid(ballActor) then
        ballActor:K2_DestroyActor()
      end
    end
    self.playerBallActors = nil
  end
end

function BattleFriendAssistEnterAction:OnFinish()
end

return BattleFriendAssistEnterAction
