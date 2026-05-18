local LuaParamBase = NRCClass()

function LuaParamBase:Ctor(enableMFBT)
  self.isMFBTEnable = enableMFBT
  if nil == enableMFBT then
    enableMFBT = false
  end
end

function LuaParamBase:GetValue(AIController)
end

function LuaParamBase:SetValue(AIController, Value)
end

function LuaParamBase:GetType()
  return self.type
end

return LuaParamBase
