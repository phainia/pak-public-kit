local Base = require("NewRoco.Modules.System.Activity.AttrBinding.AttrBindingObject")
local InteractiveCtrlBinding = Base:Extend("InteractiveCtrlBinding")

function InteractiveCtrlBinding:Ctor(callback, callbackThis)
  Base.Ctor(self)
  assert(callback, "callback should not be nil!")
  self.callbackFunctor = _G.MakeWeakFunctor(callbackThis, callback)
  self.constraintsFunctors = {}
end

function InteractiveCtrlBinding:SetConstraintsHandler(handler, handlerThis)
  self.onConstraintsFunctor = _G.MakeWeakFunctor(handlerThis, handler)
end

function InteractiveCtrlBinding:AddCallbackConstraints(constraints, constraintsThis)
  local functor = _G.MakeWeakFunctor(constraintsThis, constraints)
  if functor then
    table.insert(self.constraintsFunctors, functor)
  end
end

function InteractiveCtrlBinding:OnBind(_ctrl, _attr)
  self:RegisterCallback(_ctrl)
end

function InteractiveCtrlBinding:OnUnBind(_ctrl, _attr)
  self:UnRegisterCallback(_ctrl)
end

function InteractiveCtrlBinding:OnTrigger(_ctrl, _attr, ...)
  local enableCallback = true
  if self.constraintsFunctors and #self.constraintsFunctors > 0 then
    enableCallback = false
    for _, _constraintsFunctor in ipairs(self.constraintsFunctors) do
      local constraintsPass = not _constraintsFunctor(_attr, ...)
      if constraintsPass then
        enableCallback = true
        break
      end
    end
  end
  if enableCallback then
    if self.callbackFunctor then
      self.callbackFunctor(_attr, ...)
    end
  elseif self.onConstraintsFunctor then
    self.onConstraintsFunctor(_attr, ...)
  end
end

function InteractiveCtrlBinding:RegisterCallback(ctrl)
end

function InteractiveCtrlBinding:UnRegisterCallback(ctrl)
end

return InteractiveCtrlBinding
