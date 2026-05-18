local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionInstanceWeightPlate = Base:Extend("NPCActionBattle")

function NPCActionInstanceWeightPlate:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionInstanceWeightPlate:Execute()
  Base.Execute(self)
end

function NPCActionInstanceWeightPlate:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  DelayManager:DelaySeconds(3, self.Finish, self)
end

return NPCActionInstanceWeightPlate
