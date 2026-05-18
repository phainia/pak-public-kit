local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionInstancePortas = Base:Extend("NPCActionBattle")

function NPCActionInstancePortas:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionInstancePortas:Execute()
  Base.Execute(self)
end

function NPCActionInstancePortas:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  DelayManager:DelaySeconds(3, self.Finish, self)
end

return NPCActionInstancePortas
