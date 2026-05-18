local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local ScenePlayerFsmEnum = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.PlayerFsmEnum")
local LuaActionTestData = Base:Extend("LuaActionTestData")

function LuaActionTestData:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaActionTestData:OnStart(AIController, ...)
  Base.OnStart(self, ...)
  local aiController = AIController
  Log.DebugFormat("-------------------------- Normal")
  Log.DebugFormat("-------------------------- Array")
  Log.DebugFormat("-------------------------- Blackboard")
  Log.DebugFormat("-------------------------- StartSet")
end

function LuaActionTestData:LogArrayParam(HeadString, ParamArray, aiController)
  if not ParamArray then
    Log.ErrorFormat("LuaActionTestData Array in nil:%s", HeadString)
    return
  end
  for i = 1, #ParamArray do
    Log.DebugFormat("LuaActionTestData Array:%s, %s", HeadString, tostring(ParamArray[i]:GetValue(aiController)))
  end
end

return LuaActionTestData
