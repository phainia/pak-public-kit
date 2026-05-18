local Base = BattleActionBase
local BattleLockLodAction = Base:Extend("BattleLockLodAction")

function BattleLockLodAction:Ctor()
  Base.Ctor(self)
end

function BattleLockLodAction:OnEnter()
  self:Finish()
end

return BattleLockLodAction
