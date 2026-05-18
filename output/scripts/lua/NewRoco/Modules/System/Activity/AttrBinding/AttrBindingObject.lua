local AttrBindingObject = Class("AttrBindingObject")

function AttrBindingObject:Ctor()
  self.weakRef = {}
end

function AttrBindingObject:__Dctor()
  self:UnBind()
end

function AttrBindingObject:Bind(_ctrl, _attr, _onAttrChange, _onAttrChangeCaller)
  self:UnBind()
  self.weakRef.ctrl = _ctrl
  if _onAttrChange then
    self.onAttrChangeCallback = _G.MakeWeakFunctor(_onAttrChangeCaller, _onAttrChange)
  end
  self:Set(_attr)
  self:OnBind(_ctrl, _attr)
end

function AttrBindingObject:UnBind()
  self:OnUnBind(self.weakRef.ctrl, self.attr)
  self.attr = nil
  self.weakRef.ctrl = nil
  self.onAttrChangeCallback = nil
end

function AttrBindingObject:Set(_attr)
  local _ctr = self:GetCtrl()
  self.attr = _attr
  self:OnSet(_ctr, _attr)
  if self.onAttrChangeCallback then
    self.onAttrChangeCallback(_ctr, _attr)
  end
end

function AttrBindingObject:Get()
  return self.attr
end

function AttrBindingObject:GetCtrl()
  return self.weakRef.ctrl
end

function AttrBindingObject:Trigger(...)
  self:OnTrigger(self.weakRef.ctrl, self.attr, ...)
end

function AttrBindingObject:OnBind(_ctrl, _attr)
end

function AttrBindingObject:OnUnBind(_ctrl, _attr)
end

function AttrBindingObject:OnSet(_ctrl, _attr)
end

function AttrBindingObject:OnTrigger(_ctrl, _attr, ...)
end

return AttrBindingObject
