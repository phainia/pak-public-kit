require("UnLuaEx")
local Base = NRCClass
local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local BP_DimoInputHandle_C = Base:Extend("BP_DimoInputHandle_C")

function BP_DimoInputHandle_C:MoveForward(value)
  if math.abs(value) > 0 then
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerMove)
    return self.Overridden.MoveForward(self, value)
  end
  return false
end

function BP_DimoInputHandle_C:MoveRight(value)
  if math.abs(value) > 0 then
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerMove)
    return self.Overridden.MoveRight(self, value)
  end
  return false
end

function BP_DimoInputHandle_C:Turn(value, ignoreMouse)
  if math.abs(value) > 0 then
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerCameraMove)
    return self.Overridden.Turn(self, value, ignoreMouse)
  end
  return false
end

function BP_DimoInputHandle_C:LookUp(value, ignoreMouse)
  if math.abs(value) > 0 then
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerCameraMove)
    return self.Overridden.LookUp(self, value, ignoreMouse)
  end
  return false
end

function BP_DimoInputHandle_C:TouchMove(direction, value)
  if math.abs(value) > 0 then
    value = 1
    _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerMove)
    return self.Overridden.TouchMove(self, direction, value)
  end
  return false
end

function BP_DimoInputHandle_C:TouchTurn(direction, isRate)
  _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerCameraMove)
  return self.Overridden.TouchTurn(self, direction, isRate)
end

return BP_DimoInputHandle_C
