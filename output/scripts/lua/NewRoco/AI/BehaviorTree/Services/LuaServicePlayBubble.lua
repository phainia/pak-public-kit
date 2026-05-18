local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local LuaServicePlayBubble = Base:Extend("LuaServicePlayBubble")

function LuaServicePlayBubble:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local BubbleType = self.BubbleType:GetValue(owner)
  local BubbleComp = owner.Npc:EnsureComponent(BubbleComponent)
  BubbleComp:Play(nil, BubbleType, self, self.OnBubbleFinish, owner)
end

function LuaServicePlayBubble:OnEnd(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local BubbleComp = owner.Npc:EnsureComponent(BubbleComponent)
  BubbleComp:StopAll()
  local model = owner.Npc.viewObj
  if model then
    local animComp = model:GetAnimComponent()
    animComp:StopAllMontage(0.25)
  end
end

function LuaServicePlayBubble:OnBubbleFinish(Success, Actor)
  if not Actor then
    return
  end
end

return LuaServicePlayBubble
