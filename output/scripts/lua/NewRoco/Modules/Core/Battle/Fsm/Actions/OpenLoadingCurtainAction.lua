local Base = BattleActionBase
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local OpenLoadingCurtainAction = Base:Extend("OpenLoadingCurtainAction")
FsmUtils.MergeMembers(Base, OpenLoadingCurtainAction, {})

function OpenLoadingCurtainAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function OpenLoadingCurtainAction:OnEnter()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OpenLoadingCurtain, self, self.Finish)
end

return OpenLoadingCurtainAction
