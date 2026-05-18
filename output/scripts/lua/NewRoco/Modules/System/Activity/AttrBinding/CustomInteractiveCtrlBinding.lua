local Base = require("NewRoco.Modules.System.Activity.AttrBinding.InteractiveCtrlBinding")
local CustomInteractiveCtrlBinding = Base:Extend("CustomInteractiveCtrlBinding")

function CustomInteractiveCtrlBinding:Ctor(callbackName, callback, callbackThis)
  Base.Ctor(self, callback, callbackThis)
  self.weakRef.callbackName = callbackName
  self.weakRef.callbackThis = callbackThis or _G
  assert(callbackName, "callbackName should not be nil!")
  assert(self.weakRef.callbackThis[callbackName], string.format("function %s not exists!", callbackName))
end

function CustomInteractiveCtrlBinding:RegisterCallback(ctrl)
  local callbackName = self.weakRef.callbackName
  local callbackThis = self.weakRef.callbackThis
  if callbackThis and callbackName then
    local callbackFunctorIndex = callbackName .. "_functor"
    callbackThis[callbackFunctorIndex] = _G.MakeWeakFunctor(self, self.Trigger)
    callbackThis[callbackName] = function(_this, ...)
      if _this and _this[callbackFunctorIndex] then
        _this[callbackFunctorIndex](...)
      end
    end
  end
end

function CustomInteractiveCtrlBinding:UnRegisterCallback(ctrl)
  local callbackName = self.weakRef.callbackName
  local callbackThis = self.weakRef.callbackThis
  if callbackThis and callbackName then
    local callbackFunctorIndex = callbackName .. "_functor"
    callbackThis[callbackFunctorIndex] = nil
    callbackThis[callbackName] = self.callbackFunctor.func
  end
end

return CustomInteractiveCtrlBinding
