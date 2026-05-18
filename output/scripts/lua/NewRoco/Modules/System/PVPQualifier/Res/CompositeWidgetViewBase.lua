local Base = NRCClass
local AnimationSequenceManager = require("NewRoco.Modules.System.PVPQualifier.Res.AnimationSequenceManager")
local CompositeWidgetViewBase = Base:Extend("CompositeWidgetViewBase")
local AllowedFunctions = {
  "AddButtonListener",
  "RemoveButtonListener",
  "PlayAnimation",
  "StopAnimation"
}
for i = 1, #AllowedFunctions do
  local funcName = AllowedFunctions[i]
  CompositeWidgetViewBase[funcName] = function(self, ...)
    return self.ownerPanel[funcName](self.ownerPanel, ...)
  end
end

function CompositeWidgetViewBase:Ctor(panelObject, memberNames, ...)
  Base.Ctor(self)
  self.ownerPanel = panelObject
  self:CopyMembers(memberNames)
  self.animationSequenceManager = AnimationSequenceManager(panelObject)
end

function CompositeWidgetViewBase.CheckReservedMemberNames(memberNames)
  for i = 1, #memberNames do
    local memberName = memberNames[i]
    if "ownerPanel" == memberName then
      Log.Error("CompositeWidgetViewBase.CreateInstance \228\184\141\229\133\129\232\174\184\228\189\191\231\148\168\228\191\157\231\149\153\230\136\144\229\145\152\229\144\141\229\173\151 ownerPanel")
    end
  end
end

function CompositeWidgetViewBase:CopyMembers(memberNames)
  if _G.RocoEnv.IS_EDITOR then
    CompositeWidgetViewBase.CheckReservedMemberNames(memberNames)
  end
  for i = 1, #memberNames do
    local memberName = memberNames[i]
    self[memberName] = self.ownerPanel[memberName]
  end
end

function CompositeWidgetViewBase:OnConstruct(...)
end

function CompositeWidgetViewBase:OnDestruct(...)
  if self.animationSequenceManager then
    self.animationSequenceManager:OnDestruct()
    self.animationSequenceManager = nil
  end
end

function CompositeWidgetViewBase:OnActive(...)
end

function CompositeWidgetViewBase:OnDeactive(...)
end

function CompositeWidgetViewBase:OnTick()
end

function CompositeWidgetViewBase:OnAnimationFinished(anim)
  if self.animationSequenceManager and self.animationSequenceManager:IsPlayingAnimationSequence() then
    self.animationSequenceManager:OnAnimationFinished(anim)
  end
end

function CompositeWidgetViewBase:PlayAnimationSequence(animations, onComplete)
  if self.animationSequenceManager then
    return self.animationSequenceManager:PlayAnimationSequence(animations, onComplete)
  end
  Log.Error("CompositeWidgetViewBase:AnimationSequenceManager is not initialized")
end

function CompositeWidgetViewBase:StopCurrentAnimation()
  if self.animationSequenceManager then
    return self.animationSequenceManager:StopCurrentAnimation()
  end
end

function CompositeWidgetViewBase:StopAnimation(animationName)
  if self.animationSequenceManager then
    return self.animationSequenceManager:StopAnimation(animationName)
  end
  local animObj = self.ownerPanel[animationName]
  if animObj then
    self.ownerPanel:StopAnimation(animObj)
  end
end

function CompositeWidgetViewBase:SafeCall(widget, funcName, ...)
  if widget then
    local func = widget[funcName]
    if func then
      func(widget, ...)
    end
  end
end

function CompositeWidgetViewBase:SafeSet(widget, k, v)
  if widget then
    widget[k] = v
  end
end

return CompositeWidgetViewBase
