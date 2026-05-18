local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local Base = MagicActionBase
local MagicActionTriggerOption = Base:Extend("MagicActionTriggerOption")

function MagicActionTriggerOption:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionTriggerOption:OnSubmit(rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if 0 ~= ErrorCode then
    self:Finish(false)
    return
  end
  self.Owner:OnOptionAction()
end

return MagicActionTriggerOption
