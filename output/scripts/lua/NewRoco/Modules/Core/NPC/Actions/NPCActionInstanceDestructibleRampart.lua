local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionInstanceDestructibleRampart = Base:Extend("NPCActionBattle")

function NPCActionInstanceDestructibleRampart:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionInstanceDestructibleRampart:Execute()
  Base.Execute(self)
end

function NPCActionInstanceDestructibleRampart:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  DelayManager:DelaySeconds(3, self.Finish, self)
end

return NPCActionInstanceDestructibleRampart
