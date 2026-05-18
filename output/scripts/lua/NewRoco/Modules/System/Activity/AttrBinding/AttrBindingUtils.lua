local AttrBindingUtils = {}

function AttrBindingUtils.CreateTextBinding()
  local TextCtrlBinding = require("NewRoco.Modules.System.Activity.AttrBinding.TextCtrlBinding")
  return TextCtrlBinding()
end

function AttrBindingUtils.CreateBtnBinding(callback, callbackThis)
  local BtnCtrlBinding = require("NewRoco.Modules.System.Activity.AttrBinding.BtnCtrlBinding")
  return BtnCtrlBinding(callback, callbackThis)
end

function AttrBindingUtils.CreateCustomInteractiveBinding(callbackName, callback, callbackThis)
  local CustomInteractiveCtrlBinding = require("NewRoco.Modules.System.Activity.AttrBinding.CustomInteractiveCtrlBinding")
  return CustomInteractiveCtrlBinding(callbackName, callback, callbackThis)
end

return AttrBindingUtils
