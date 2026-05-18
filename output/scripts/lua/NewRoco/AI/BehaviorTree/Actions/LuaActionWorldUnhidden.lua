local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWorldUnhidden = Base:Extend("LuaActionWorldUnhidden")

function LuaActionWorldUnhidden:OnStart(AIController, ...)
  local owner = AIController
  local hideComp = owner.Npc:GetComponent(HiddenComponent)
  local Immediate = self.Immediate and self.Immediate:GetValue(owner)
  if not hideComp or not hideComp:CanHide() then
    return self:Finish(true)
  end
  if Immediate then
    hideComp:ResetHide()
    self:Finish(true)
  else
    self.owner = owner
    if hideComp:GetState() == HiddenComponent.State.PendingStart then
      hideComp:RegisterEnteringDelegate(self, self.HideEntered)
    else
      hideComp:EndHide(self, self.HideFinish)
    end
  end
end

function LuaActionWorldUnhidden:HideEntered(result, comp)
  if self.owner then
    if AIDefines.ActionResult.Ok(result) then
      comp:EndHide(self, self.HideFinish)
    else
      self.owner = nil
      self:Finish(true)
    end
  end
end

function LuaActionWorldUnhidden:HideFinish(result)
  if self.owner then
    self.owner = nil
    self:Finish(AIDefines.ActionResult.Ok(result))
  end
end

function LuaActionWorldUnhidden:OnInterrupt(owner, Finalized)
  self.owner = nil
end

return LuaActionWorldUnhidden
