local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local RunAwayWorldLeaderAction = Base:Extend("RunAwayWorldLeaderAction")
FsmUtils.MergeMembers(Base, RunAwayWorldLeaderAction, {})

function RunAwayWorldLeaderAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function RunAwayWorldLeaderAction:OnEnter()
  self:OpenRoleHpDefeatedTip()
end

function RunAwayWorldLeaderAction:OpenRoleHpDefeatedTip()
  local player = BattleManager.battlePawnManager.TeamatePlayer
  local finishNotify = BattleManager.battleRuntimeData.battleSettleData.data
  if player and finishNotify then
    local settleInfo = finishNotify.settle_info.battler_info
    local battlerInfo
    for i, v in ipairs(settleInfo) do
      if v.id == player.guid then
        battlerInfo = v
        break
      end
    end
    if battlerInfo and battlerInfo.hp then
      local changeHp = battlerInfo.hp - player.roleInfo.base.hp
      if changeHp >= 0 then
        self:Finish()
        return
      end
      local asyncData = {
        player = player,
        isLast = true,
        isShowLetter = true
      }
      asyncData.black_hp_result = player.roleInfo.base.black_hp
      asyncData.hp_result = battlerInfo.hp
      asyncData.hp_change = changeHp
      asyncData.tips_key = "worldcombat_exit_tips"
      _G.NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.OpenRoleHpDefeatedTipPanel)
      self:SafeDelaySeconds("d_Finish", BattleConst.Show.PveRoleHpShowTimeOnRunAway, self.Finish, self)
      return
    end
  end
  self:Finish()
end

function RunAwayWorldLeaderAction:OnFinish()
  _G.NRCModuleManager:DoCmdAsync(nil, BattleUIModuleCmd.CloseRoleHpDefeatedTipPanel)
  self.fsm:SendEvent(BattleEvent.EnterNormalOver, self)
end

return RunAwayWorldLeaderAction
