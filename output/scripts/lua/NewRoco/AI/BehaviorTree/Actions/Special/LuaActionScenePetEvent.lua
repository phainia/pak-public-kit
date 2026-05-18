local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LuaActionScenePetEvent = Base:Extend("LuaActionScenePetEvent")

function LuaActionScenePetEvent:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local vecParam = self.Param:GetValue(owner)
  vecParam = SceneUtils.ConvertAbsoluteToRelative(vecParam)
  local Model = owner.Npc.viewObj
  if Model and Model.SceneAction and Model.OnSceneActionEnd then
    self.owner = owner
    Model:SceneAction(vecParam)
    self._onActionEnd = owner:AddDelegateListener(Model.OnSceneActionEnd, self, self.OnActionEnd)
    return
  end
  self:Finish(true)
end

function LuaActionScenePetEvent:OnActionEnd()
  if self._onActionEnd then
    self.owner:RemoveDelegateListener(self.owner.Npc.viewObj.OnSceneActionEnd, self._onActionEnd)
    self._onActionEnd = nil
    self.owner = nil
  end
  self:Finish(true)
end

return LuaActionScenePetEvent
