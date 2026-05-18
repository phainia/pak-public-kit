local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleSwitchConfigAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleSwitchConfigAction")
local Base = BattleSwitchConfigAction
local BattleFBSwitchToP2Action = Base:Extend("BattleFBSwitchToP2Action")
FsmUtils.MergeMembers(Base, BattleFBSwitchToP2Action, {})

function BattleFBSwitchToP2Action:OnEnter()
  if not BattleUtils.IsFinalBattleP1() then
    self:Finish()
    return
  end
  BattleEventCenter:Bind(self, BattleEvent.PET_SPAWNED, BattleEvent.PLAYER_SPAWNED)
  Base.OnEnter(self)
  self:LoadOver(self)
end

function BattleFBSwitchToP2Action:HandleLoadOver()
  if _G.enableAdaptiveBattlePetPos then
    local enemyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    if enemyPet then
      BattleManager.vBattleField:AdaptiveEnemyBattlePetPos(enemyPet)
      enemyPet:PinOnTheGround()
    end
  end
end

function BattleFBSwitchToP2Action:OnFinish()
  Base.OnFinish(self)
  local List = _G.ProtoMessage:newFBEyeOpen()
  List.IsOpen = 1
  _G.DataModelMgr.RemoteStorage:Set("IsFBEyeOpen", ".Next.FBEyeOpen", List)
  _G.BattleManager:PlayBattleBGM()
end

return BattleFBSwitchToP2Action
