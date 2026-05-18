local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BeastCheckFieldReady = Base:Extend("BeastCheckFieldReady")
FsmUtils.MergeMembers(Base, BeastCheckFieldReady, {})

function BeastCheckFieldReady:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(Base.ActionType.ClientLoadResAction)
end

function BeastCheckFieldReady:OnEnter()
  self:OnTick(0)
end

function BeastCheckFieldReady:OnTick(DeltaTime)
  if not self.fsm:GetProperty("BeastLoadBattleLevel", false) then
    return
  end
  if self.fsm:GetProperty("BeastLoadSequence", nil) == nil then
    return
  end
  self:Finish()
end

return BeastCheckFieldReady
