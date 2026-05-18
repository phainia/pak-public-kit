local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattleSwitchConfigAction = Base:Extend("BattleSwitchConfigAction")
FsmUtils.MergeMembers(Base, BattleSwitchConfigAction, {})

function BattleSwitchConfigAction:OnEnter()
  self.PawnManger = _G.BattleManager.battlePawnManager
  local roundStarNotify = self.fsm:GetProperty("roundStarNotify")
  if not roundStarNotify then
    self:Finish()
    return
  end
  local playerTeam = self.PawnManger:GetPlayerMyTeam()
  if playerTeam then
    _G.BattleEventCenter:Dispatch(BattleEvent.PLAYER_LEAVE_GAME, playerTeam, true)
  end
  self.selfPlayID = playerTeam.guid
  local enemyTeam = self.PawnManger:GetPlayerEnemyTeam()
  if enemyTeam then
    _G.BattleEventCenter:Dispatch(BattleEvent.PLAYER_LEAVE_GAME, enemyTeam, true)
  end
  self.PawnManger:ClearPawnObj()
  self:SimulateEnterNotify(roundStarNotify)
  self.PrepareTable = {self}
  self.PawnManger:SetBattleInitInfo(BattleUtils.GetBattleInitInfo(), self.PrepareTable)
end

function BattleSwitchConfigAction:SimulateEnterNotify(roundNotify)
  local fakeNotify = BattleUtils.SimulateEnterNotify(roundNotify, self.selfPlayID)
  if not fakeNotify then
    self:Finish()
    return
  end
  _G.BattleManager.battleRuntimeData.battleType = fakeNotify.battle_mode
  _G.BattleManager.battleRuntimeData:SetBattleInitInfo(fakeNotify, true)
  _G.BattleManager.vBattleField.battleFieldConf = nil
  _G.BattleManager.vBattleField:ResetAttachPoint()
  _G.BattleManager.vBattleField:Init(fakeNotify.init_info)
  _G.BattleManager:SetPotentialTaskID(fakeNotify)
end

function BattleSwitchConfigAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PET_SPAWNED or eventName == BattleEvent.PLAYER_SPAWNED then
    self:LoadOver(...)
    self.timeout = 100.0
  end
end

function BattleSwitchConfigAction:LoadOver(object)
  if self.PrepareTable and #self.PrepareTable > 0 then
    for i, v in ipairs(self.PrepareTable) do
      if v == object then
        table.remove(self.PrepareTable, i)
        break
      end
    end
    if 0 == #self.PrepareTable then
      self:HandleLoadOver()
      self:Finish()
    end
  end
end

function BattleSwitchConfigAction:HandleLoadOver()
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
end

function BattleSwitchConfigAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
end

return BattleSwitchConfigAction
