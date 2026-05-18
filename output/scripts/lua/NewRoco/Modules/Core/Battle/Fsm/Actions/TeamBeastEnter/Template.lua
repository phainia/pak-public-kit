local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local Template = Base:Extend("Template")
FsmUtils.MergeMembers(Base, Template, {})

function Template:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function Template:OnEnter()
end

function Template:OnFinish()
end

return Template
