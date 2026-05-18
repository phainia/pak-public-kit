local Base = require("NewRoco.Modules.System.Activity.AttrBinding.InteractiveCtrlBinding")
local BtnCallbackName = "BtnCtrlBindingCallback"
local BtnCallbackFunctor = "BtnCtrlBindingFunctor"
local BtnCtrlBinding = Base:Extend("BtnCtrlBinding")

function BtnCtrlBinding:AttachUIView(uiView)
  assert(type(uiView) == "table" and UE4.UNRCTUIStatics.IsUObject(uiView), "owner must be an UObject table!")
  self.weakRef.btnOwner = uiView
end

function BtnCtrlBinding:RegisterCallback(ctrl)
  assert(self.weakRef.btnOwner, "should call AttachUIView first!")
  if ctrl then
    local uiView = self.weakRef.btnOwner
    if uiView then
      uiView[BtnCallbackFunctor] = _G.MakeWeakFunctor(self, self.Trigger)
      uiView[BtnCallbackName] = function(_this, ...)
        if _this and _this[BtnCallbackFunctor] then
          _this[BtnCallbackFunctor](...)
        end
      end
      ctrl.OnClicked:Add(uiView, uiView[BtnCallbackName])
    end
  end
end

function BtnCtrlBinding:UnRegisterCallback(ctrl)
  if ctrl then
    local uiView = self.weakRef.btnOwner
    if uiView then
      uiView[BtnCallbackFunctor] = nil
      uiView[BtnCallbackName] = nil
    end
    ctrl.OnClicked:Clear()
  end
end

return BtnCtrlBinding
