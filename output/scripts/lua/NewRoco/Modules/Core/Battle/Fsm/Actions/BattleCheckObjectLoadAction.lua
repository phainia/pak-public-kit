local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleCheckObjectLoadAction = BattleActionBase:Extend("BattleCheckObjectLoadAction")

function BattleCheckObjectLoadAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleCheckObjectLoadAction:OnEnter()
  self.timeout = 100.0
  self.IsPrepare = false
  _G.BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED, BattleEvent.PLAYER_SPAWNED)
  self:OnTick()
end

function BattleCheckObjectLoadAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED or eventName == BattleEvent.PLAYER_SPAWNED then
    self.timeout = 100.0
    return true
  end
end

function BattleCheckObjectLoadAction:CheckBattlePrepareOver()
  for i, v in ipairs(self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
    if not v.player:IsLoadOver() then
      Log.Debug("CheckBattlePrepareOver \231\173\137\229\190\133\230\136\145\230\150\185\232\167\146\232\137\178\229\138\160\232\189\189")
      return false
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.card:IsInBattle() and not p:IsLoadOver() then
          Log.Debug("CheckBattlePrepareOver \231\173\137\229\190\133\230\136\145\230\150\185\231\178\190\231\129\181\229\138\160\232\189\189", p.card.name, p.card.posInField)
          return false
        end
      end
    end
  end
  for i, v in ipairs(self.PawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    if not v.player:IsLoadOver() then
      Log.Debug("CheckBattlePrepareOver \231\173\137\229\190\133\230\149\140\230\150\185\232\167\146\232\137\178\229\138\160\232\189\189")
      return false
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.card:IsInBattle() and not p:IsLoadOver() then
          Log.Debug("CheckBattlePrepareOver \231\173\137\229\190\133\230\149\140\230\150\185\231\178\190\231\129\181\229\138\160\232\189\189", p.card.name, p.card.posInField)
          return false
        end
      end
    end
  end
  return true
end

function BattleCheckObjectLoadAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if not self:CheckBattlePrepareOver() then
    return
  end
  if self.IsPrepare then
    return
  end
  self.IsPrepare = true
  self:OnLoaded()
end

function BattleCheckObjectLoadAction:OnLoaded()
  if not BattleUtils.IsB1FinalBattle() then
    BattleManager:PlayBattleBGM()
  end
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
  self:Finish()
end

function BattleCheckObjectLoadAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
end

function BattleCheckObjectLoadAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  self.BattleManager = nil
  self.BattleField = nil
  self.CameraManager = nil
end

return BattleCheckObjectLoadAction
