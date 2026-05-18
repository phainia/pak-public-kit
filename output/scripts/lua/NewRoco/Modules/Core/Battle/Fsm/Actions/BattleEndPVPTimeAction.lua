local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleEndPVPTimeAction = Base:Extend("BattleEndPVPTimeAction")
FsmUtils.MergeMembers(Base, BattleEndPVPTimeAction, {})

function BattleEndPVPTimeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleEndPVPTimeAction:OnEnter()
  if BattleUtils.IsPvp() then
    _G.BattleEventCenter:Dispatch(BattleEvent.END_PVP_ROUND_TIME)
    self:HidePVPWaitSelectPet()
  end
  self:Finish()
end

function BattleEndPVPTimeAction:HidePVPWaitSelectPet()
  if _G.BattleManager.battleRuntimeData:GetEnemyOnThinking() then
    _G.BattleManager.battleRuntimeData:SetEnemyOnThinking(false)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_HideTips)
    local playerModel = _G.BattleManager.battlePawnManager:GetPlayerEnemyTeam().model
    if playerModel then
      playerModel:HideThinking()
    end
  end
end

return BattleEndPVPTimeAction
