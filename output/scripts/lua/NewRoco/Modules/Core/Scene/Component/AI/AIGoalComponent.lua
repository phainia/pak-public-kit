local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local AIGoalComponent = ActorComponent:Extend("AIGoalComponent")

function AIGoalComponent:Attach(owner)
  ActorComponent.Attach(self, owner)
end

function AIGoalComponent:DeAttach()
  ActorComponent.DeAttach(self)
end

function AIGoalComponent:SetEnable(enable)
  ActorComponent.SetEnable(self, enable)
end

function AIGoalComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
end

function AIGoalComponent:AddGoal(goal, ...)
end

function AIGoalComponent:ClearGoal()
end

return AIGoalComponent
