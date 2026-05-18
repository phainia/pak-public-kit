local Base = require("NewRoco.Modules.System.Activity.AttrBinding.AttrBindingObject")
local TextCtrlBinding = Base:Extend("TextCtrlBinding")

function TextCtrlBinding:OnSet(_ctrl, _text)
  if _ctrl and UE4.UObject.IsValid(_ctrl) then
    _ctrl:SetText(_text or "")
  end
end

return TextCtrlBinding
