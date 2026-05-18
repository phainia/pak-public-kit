local Class = _G.MakeSimpleClass
local EventDispatcher = require("Common.EventDispatcher")
local DataModelBase = Class("DataModelBase")

function DataModelBase:Ctor()
  EventDispatcher():Attach(self)
  self.dirty = false
end

function DataModelBase:MakeDirty()
  self.dirty = true
  _G.DelayManager:DelayFrames(1, function()
    self:Update()
  end)
end

function DataModelBase:Update()
  if self.dirty then
    self.dirty = false
    self:OnUpdate()
  end
end

function DataModelBase:OnUpdate()
end

return DataModelBase
