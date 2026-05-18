local EventDispatcher = require("Common.EventDispatcher")
local BehaviorConfBase = NRCClass()

function BehaviorConfBase:Ctor(Type, Param)
  EventDispatcher():Attach(self)
  self.Type = Type
  self.Param = Param
end

function BehaviorConfBase:Check()
end

function BehaviorConfBase:Execute()
end

return BehaviorConfBase
