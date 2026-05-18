local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleCheckGrasResLoadOverAction = Base:Extend("BattleCheckGrasResLoadOverAction")
FsmUtils.MergeMembers(Base, BattleCheckGrasResLoadOverAction, {})

function BattleCheckGrasResLoadOverAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleCheckGrasResLoadOverAction:OnEnter()
end

function BattleCheckGrasResLoadOverAction:CheckLoadOver()
  return BattleManager.vBattleField:CheckGrassResIsOver()
end

function BattleCheckGrasResLoadOverAction:OnTick()
  if not self:CheckLoadOver() then
    return
  end
  self:Finish()
end

function BattleCheckGrasResLoadOverAction:OnExit()
end

return BattleCheckGrasResLoadOverAction
