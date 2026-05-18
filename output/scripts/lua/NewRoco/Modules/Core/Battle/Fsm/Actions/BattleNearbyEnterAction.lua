local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattleNearbyEnterAction = BattleActionBase:Extend("BattleNearbyEnterAction")

function BattleNearbyEnterAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleNearbyEnterAction:OnEnter()
  self.timeout = 100.0
  self.IsPrepare = false
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED, BattleEvent.PLAYER_SPAWNED)
end

function BattleNearbyEnterAction:StartPrepare()
  if not self.IsPrepare then
    self.IsPrepare = true
    self.BattleManager:PrepareBattle()
  end
end

function BattleNearbyEnterAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED or eventName == BattleEvent.PLAYER_SPAWNED then
    self.timeout = 100.0
    return true
  end
end

function BattleNearbyEnterAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattleNearbyEnterAction:CheckMainWindowReady()
  if not self.checkMainWindowTime then
    self.checkMainWindowTime = os.time()
  else
    local waitTime = os.time() - self.checkMainWindowTime
    if waitTime > 5 then
      self.checkMainWindowTime = os.time()
      BattleManager:OpenBattleMainWindow()
      return
    end
  end
  return BattleUtils.IsMainWindowReady()
end

function BattleNearbyEnterAction:CheckBattleSceneReady()
  return true
end

function BattleNearbyEnterAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if BattleManager.isEnterActionWaitResDone and not ServerData.values.battleMode and not self:CheckMainWindowReady() then
    return
  end
  self:StartPrepare()
  if BattleManager.isEnterActionWaitResDone and not self:CheckBattlePrepareOver() then
    return
  end
  if BattleManager.isEnterActionWaitResDone then
    self:OnLoaded()
  else
    self:Finish()
  end
end

function BattleNearbyEnterAction:RestorePet(flag)
  Log.Debug("Try Restore Pet Scale!")
  local Pets = self.PawnManager:GetInFieldAllPet(flag)
  if Pets then
    for _, pet in ipairs(Pets) do
      pet:SetScale(1)
    end
  else
    Log.Error("Can't restore pet!!!!!!")
  end
end

function BattleNearbyEnterAction:OnLoaded()
  if _G.enableAdaptiveBattlePetPos then
    local pets = BattleManager.battlePawnManager:GetPlayerTeamPets()
    for i, v in ipairs(pets) do
      if v then
        BattleManager.vBattleField:AdaptiveMyBattlePetPos(v.model)
        v:PinOnTheGround()
      end
    end
    local enemyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    if enemyPet then
      BattleManager.vBattleField:AdaptiveEnemyBattlePetPos(enemyPet)
      enemyPet:PinOnTheGround()
    end
  end
  self:RestorePet(BattleEnum.Team.ENUM_TEAM)
  self:RestorePet(BattleEnum.Team.ENUM_ENEMY)
  for i, v in ipairs(self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
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
  for i, v in ipairs(self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
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
  self.BattleManager:PlayBattleBGM()
  self:Finish()
end

function BattleNearbyEnterAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
end

function BattleNearbyEnterAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  self.BattleManager = nil
  self.BattleField = nil
  self.CameraManager = nil
end

return BattleNearbyEnterAction
