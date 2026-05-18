local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = FsmAction
local FsmDoCmdAction = Base:Extend("FsmDoCmdAction")
FsmUtils.MergeMembers(Base, FsmDoCmdAction, {
  {name = "Cmd", type = "string"},
  {
    name = "SaveResultAs",
    type = "string"
  }
})

function FsmDoCmdAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function FsmDoCmdAction:OnEnter()
  local Cmd = self:GetProperty("Cmd", "")
  local ResultName = self:GetProperty("SaveResultAs", "")
  if string.IsNilOrEmpty(Cmd) then
    Log.Warning("\228\188\160\229\133\165\231\154\132Cmd\228\184\141\229\173\152\229\156\168\239\188\140\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174", Cmd)
  else
    local Result = _G.NRCModeManager:DoCmd(Cmd)
    if not string:IsNilOrEmpty(ResultName) then
      self.fsm:SetProperty(ResultName, Result)
    end
  end
  self:Finish()
end

function FsmDoCmdAction:OnExit()
end

return FsmDoCmdAction
