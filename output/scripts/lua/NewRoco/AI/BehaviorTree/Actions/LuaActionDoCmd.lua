local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionDoCmd = Base:Extend("LuaActionDoCmd")

function LuaActionDoCmd:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaActionDoCmd:ParseParams(InputParams)
  local RawParams = {}
  for Param in string.gmatch(InputParams, "([^;]+)") do
    Param = string.match(Param, "^%s*(.-)%s*$")
    table.insert(RawParams, Param)
  end
  local ParsedParams = {}
  for _, RawParam in ipairs(RawParams) do
    local ConvertedParam = self:AutoConvertType(RawParam)
    table.insert(ParsedParams, ConvertedParam)
  end
  return ParsedParams
end

function LuaActionDoCmd:AutoConvertType(StringValue)
  local ToNumber = tonumber(StringValue)
  if ToNumber then
    return ToNumber
  end
  local LowerStringValue = string.lower(StringValue)
  if "true" == LowerStringValue then
    return true
  elseif "false" == LowerStringValue then
    return false
  else
    return StringValue
  end
end

function LuaActionDoCmd:OnStart(AIController, ...)
  local RawCmd = self.Cmd and self.Cmd:GetValue(AIController)
  local ParsedParams = self:ParseParams(self.InputParams and self.InputParams:GetValue(AIController))
  if RawCmd then
    local Result = _G.NRCModuleManager:DoCmd(RawCmd, table.unpack(ParsedParams))
    return self:Finish(Result)
  end
  return self:Finish(false)
end

return LuaActionDoCmd
