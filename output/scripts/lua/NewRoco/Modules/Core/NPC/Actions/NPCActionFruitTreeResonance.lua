local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionFruitTreeResonance = Base:Extend("NPCActionFruitTreeResonance")

function NPCActionFruitTreeResonance:OnSubmit(Rsp)
  Base.OnSubmit(self, Rsp)
  if 0 == Rsp.ret_info.ret_code and self.Info.act_exec_success then
    local View = self:GetOwnerNPCView()
    if View and UE4.UObject.IsValid(View) then
      self.AudioSessionID = _G.NRCAudioManager:PlaySound3DWithActorAuto(41700381, View, "FruitTreeResonance")
      View:HiddenBurstNiagara(false)
    end
  end
end

function NPCActionFruitTreeResonance:OnPlayerLeaveActionArea()
  local View = self:GetOwnerNPCView()
  if View and UE4.UObject.IsValid(View) then
    if self.AudioSessionID ~= nil then
      _G.NRCAudioManager:ReleaseSession(self.AudioSessionID, true, "FruitTreeResonance", false, 0.1)
    end
    View:HiddenBurstNiagara(true)
  end
  Base.OnPlayerLeaveActionArea(self)
end

return NPCActionFruitTreeResonance
