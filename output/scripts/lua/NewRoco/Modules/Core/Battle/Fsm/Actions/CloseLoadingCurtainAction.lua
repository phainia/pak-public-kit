local Base = BattleActionBase
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local CloseLoadingCurtainAction = Base:Extend("CloseLoadingCurtainAction")
FsmUtils.MergeMembers(Base, CloseLoadingCurtainAction, {})

function CloseLoadingCurtainAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function CloseLoadingCurtainAction:OnEnter()
  BattleBudget:GC(true)
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.CloseLoadingCurtain)
  self:Finish()
end

return CloseLoadingCurtainAction
