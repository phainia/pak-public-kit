local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattlePlayAnimBaseAction
local BattlePlayPetStartBattleAnimAction = Base:Extend("BattlePlayPetStartBattleAnimAction")

function BattlePlayPetStartBattleAnimAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattlePlayPetStartBattleAnimAction:OnEnter()
  Log.Debug("BattlePlayPetStartBattleAnimAction OnEnter")
  local CheckAppearanceMode = self:GetProperty("CheckAppearanceMode", false)
  if CheckAppearanceMode and BattleUtils.IsTriggerAppearanceInField(CheckAppearanceMode) then
    self:Finish()
    return
  end
  if BattleUtils.IsFriendAssist() then
    self:Finish()
    return
  end
  BattleUtils.CloseBattleAndTaskBlackLoading()
  local pet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  local enemyPet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  if not pet or not enemyPet then
    self:Finish()
    return
  end
  local animCla = BattleConst.Define.ThrowFrontEnterSecond
  if enemyPet.card.petState:GetBackStab() then
    animCla = BattleConst.Define.ThrowBackEnterSecond
  end
  self:SaveBlackBoardValues()
  self.LerpCamera = false
  local targets = {
    enemyPet.model
  }
  if enemyPet.card.petState:GetSleep() then
    targets = {}
  end
  self:Play(pet, targets, animCla, true)
  _G.BattleManager:PlayBattleBGM()
end

function BattlePlayPetStartBattleAnimAction:CustomCastG6BeforePlay(skillObj)
  if self.caster and self.caster.model and self.caster.card then
    BattleUtils.SetParticleKeyForSkillObj(self.caster.model, skillObj, self.caster.card.medalBlackBoard)
  end
  skillObj:RegisterEventCallback("ChangeCameraToSkill", self, self.ChangeCameraToSkill)
end

function BattlePlayPetStartBattleAnimAction:ChangeCameraToSkill()
  _G.BattleManager.TransBattleCamera(UE.ESkillBattleTransCamera.SkillPlayer, 0.5, UE4.EViewTargetBlendFunction.VTBlend_Linear)
end

function BattlePlayPetStartBattleAnimAction:OnPlayPetAnim()
  local enemyPet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local state = self:GetLastAiStatus(enemyPet.card.petInfo.battle_inside_pet_info.ai_info.ai_status or 0)
  enemyPet:PlayAnimByName(BattleConst.EnterAnimName[state + 1] or BattleConst.EnterAnimName[1], 1, 0, 0.25, 0.25, 1, 0)
end

function BattlePlayPetStartBattleAnimAction:GetLastAiStatus(status)
  if not status or status <= 0 then
    return 0
  end
  local realAIStatus = 0
  local realAIStatusPriority = 0
  local enterBattles = _G.DataConfigManager:GetAllByName("ENTERBATTLE_BUFF_PRIORITY")
  for _, v in pairs(enterBattles) do
    if status & 1 << v.ai_status > 0 and (0 == realAIStatus or realAIStatusPriority < v.buff_priority) then
      realAIStatus = v.ai_status
      realAIStatusPriority = v.buff_priority
    end
  end
  return realAIStatus
end

function BattlePlayPetStartBattleAnimAction:HideWorldPet0()
  self:OnHideBattlePet()
  self:OnShowBattlePlayer()
  self:OnHidePlayer()
  local HideSceneTreesDelegate = self:GetProperty(BattleConst.FsmVarNames.HideSceneTreesDelegate)
  if HideSceneTreesDelegate then
    HideSceneTreesDelegate:Invoke()
  end
  local Cache = BattleUtils.GetTraceNpc()
  if Cache and Cache.npc then
    Cache.npc:SetVisibleForBattleReason(false)
  end
  local playerTeams = self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
  for _, v in ipairs(playerTeams) do
    if v.player.model then
      v.player:ShowPlayer()
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsInBattle() and not p.card:IsBeCatch() and p.card:IsAlive() then
          p:ShowPet()
          p.model:SetActorScale3D(UE4.FVector(1, 1, 1))
        end
      end
    end
  end
  playerTeams = self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)
  for _, v in ipairs(playerTeams) do
    if v.player.model then
      v.player:ShowPlayer()
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsInBattle() and not p.card:IsBeCatch() and p.card:IsAlive() then
          p:ShowPet()
          p.model:SetActorScale3D(UE4.FVector(1, 1, 1))
        end
      end
    end
  end
end

function BattlePlayPetStartBattleAnimAction:ActionStart()
end

function BattlePlayPetStartBattleAnimAction:SaveBlackBoardValues()
  local bbValues = {}
  local aiStatus = self:GetEnemyAIStatus()
  if not aiStatus then
    table.insert(bbValues, {"Normal", "True"})
  else
    local isAIStatus, statusString = BattleUtils.IsBattleAIStatus(aiStatus, true)
    if not isAIStatus then
      table.insert(bbValues, {"Normal", "True"})
    elseif "Hanging" == statusString then
    else
      local bSetupSleep = false
      do
        local enemyPet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
        if enemyPet then
          local BattleThrowBallEnterFocusPet = require("NewRoco.Modules.Core.Battle.Scene.BattleThrowBallEnterFocusPet")
          local animComponent = enemyPet:GetAnimComponent()
          bSetupSleep = BattleThrowBallEnterFocusPet.TrySetupBBValueForSleep(aiStatus, animComponent, bbValues)
        end
      end
      if bSetupSleep then
      else
        table.insert(bbValues, {statusString, "True"})
      end
    end
  end
  self:SetCacheBlackboardValue(bbValues)
end

function BattlePlayPetStartBattleAnimAction:GetEnemyAIStatus()
  local initInfo = BattleUtils.GetBattleInitInfo()
  for _, v in ipairs(initInfo.enemy_team) do
    for i, pet in ipairs(v.pets or {}) do
      if BattleUtils.GetInBattle(pet.battle_inside_pet_info) then
        return pet.battle_inside_pet_info.ai_info.ai_status
      end
    end
  end
  return nil
end

function BattlePlayPetStartBattleAnimAction:OnHidePlayer()
  Log.Debug("BattlePlayThrowBallEnterAnimAction OnHidePlayer")
  local Caches = BattleUtils.GetAllTraceNpc()
  if Caches then
    for _, Cache in ipairs(Caches) do
      if Cache and Cache.npc then
        if Cache.npc.AIComponent then
          Cache.npc.AIComponent:LockForBattleReason()
        end
        Cache.npc:SetVisibleForBattleReason(false)
      end
    end
  end
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
  NRCModeManager:DoCmd(NPCModuleCmd.EnterBattle, BattleManager.battleRuntimeData.NearbyValidBattleLocation, BattleConst.Define.BattleFieldRange)
  BattleUtils.PinOnTheGroundForAllPawn()
end

function BattlePlayPetStartBattleAnimAction:OnShowBattlePlayer()
  for i, v in ipairs(BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
    self:ShowPlayer(v)
  end
  for i, v in ipairs(BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    self:ShowPlayer(v)
  end
end

function BattlePlayPetStartBattleAnimAction:ShowPlayer(battleTeam)
  Log.Warning("BattlePlayPetStartBattleAnimAction:ShowBattlePet")
  if battleTeam.player and battleTeam.player.model and UE4.UObject.IsValid(battleTeam.player.model) then
    battleTeam.player:ShowPlayer()
    local sceneComp = battleTeam.player.model:GetComponentByClass(UE4.USceneComponent)
    if sceneComp then
      sceneComp:SetVisibility(true)
    end
    battleTeam.player.model:TryHelmetOn()
    local battlePlayerComponents = battleTeam.player.battlePlayerComponents
    if battlePlayerComponents and battlePlayerComponents.HideMark then
      battleTeam.player.battlePlayerComponents:HideMark()
    end
  end
  if battleTeam.pets then
    for _, p in pairs(battleTeam.pets) do
      if p.model and p.card:IsExistAtField() then
        p:ShowPet()
      end
    end
  end
end

function BattlePlayPetStartBattleAnimAction:OnHideBattlePet()
  for i, v in ipairs(BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
    if v.player and v.player.model then
      v.player:HidePlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(false)
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:HidePet()
        end
      end
    end
  end
  for i, v in ipairs(BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    if v.player and v.player.model then
      v.player:HidePlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(false)
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:HidePet()
        end
      end
    end
  end
end

function BattlePlayPetStartBattleAnimAction:End()
  if self.skillObj and UE4.UObject.IsValid(self.skillObj) then
    local Blackboard = self.skillObj:GetBlackboard()
    self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID1)
    self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID1_SA)
    self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID2)
    self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID2_SA)
    BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_TEAM, false)
    BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_ENEMY, false)
  end
end

function BattlePlayPetStartBattleAnimAction:SaveObject(bb, name)
  Log.Debug("BattlePlayThrowBallEnterAnimAction SaveObject:", name, bb:GetValueAsObject(name))
  self.fsm:SetProperty(name, bb:GetValueAsObject(name))
  bb:RemoveObjectValue(name)
end

return BattlePlayPetStartBattleAnimAction
