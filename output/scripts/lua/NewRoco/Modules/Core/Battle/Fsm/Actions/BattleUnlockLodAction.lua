local Base = BattleActionBase
local BattleUnlockLodAction = Base:Extend("BattleUnlockLodAction")

function BattleUnlockLodAction:Ctor()
  Base.Ctor(self)
end

function BattleUnlockLodAction:OnEnter()
  self:Finish()
end

return BattleUnlockLodAction
