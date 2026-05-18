local Base = BattleActionBase
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattlePvPCloseAirWallAction = Base:Extend("BattlePvPCloseAirWallAction")
FsmUtils.MergeMembers(Base, BattlePvPCloseAirWallAction, {})

function BattlePvPCloseAirWallAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePvPCloseAirWallAction:OnEnter()
  self:CheckStopRide()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBattlePvpState)
  self:Finish()
end

function BattlePvPCloseAirWallAction:CheckStopRide(notify)
  if BattleUtils.IsPvpRank() then
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if Player then
      Player:StopRide()
    end
  end
end

function BattlePvPCloseAirWallAction:OnFinish()
end

function BattlePvPCloseAirWallAction:OnExit()
end

return BattlePvPCloseAirWallAction
