local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionTriggerOption = Base:Extend("PetActionTriggerOption")

function PetActionTriggerOption:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.bContinueWhenSuccess = self.Config.action_param1 ~= "1"
end

function PetActionTriggerOption:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 ~= rsp.ret_info.ret_code and false then
    Log.Error("PetActionTriggerOption failed with return code ", rsp.ret_info.ret_code)
    return
  end
  self.Owner:OnOptionAction()
end

function PetActionTriggerOption:ContinueWhenSuccess()
  return self.bContinueWhenSuccess
end

return PetActionTriggerOption
