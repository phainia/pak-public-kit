local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaBoolParam = require("NewRoco.AI.BehaviorTree.LuaParams.LuaBoolParam")
local LuaActionSingleTest = Base:Extend("LuaActionSingleTest")

function LuaActionSingleTest:OnStart(AIController, ...)
  Base.OnStart(self, ...)
  local aiController = AIController
  local begin
  begin = os.clock()
  for i = 1, 1000000 do
    Value = aiController:GetMfbbInt("TestCPPCall")
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139C++\232\176\131\231\148\168: %.3fs\n", os.clock() - begin))
  begin = os.clock()
  local testLuaBlackboard = {}
  testLuaBlackboard.TestCPPCall = 10
  local testInt
  for i = 1, 1000000 do
    testInt = testLuaBlackboard.TestCPPCall
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139Lua\232\176\131\231\148\168: %.3fs\n", os.clock() - begin))
  begin = os.clock()
  local testLuaNilTable = LuaBoolParam()
  local testNil
  for i = 1, 1000000 do
    testNil = testLuaNilTable.NilValue
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139\232\175\187\229\143\150nil\229\143\152\233\135\143: %.3fs\n", os.clock() - begin))
  begin = os.clock()
  testLuaNilTable.ExistValue = true
  local testExist = testLuaNilTable.ExistValue
  for i = 1, 1000000 do
    testExist = testLuaNilTable.ExistValue
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139\232\175\187\229\143\150\229\183\178\230\156\137\229\143\152\233\135\143: %.3fs\n", os.clock() - begin))
  begin = os.clock()
  local TestGValue
  for i = 1, 1000000 do
    TestGValue = GlobalConfig.DebugLuaBTree
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139\232\175\187\229\143\150_G\232\161\168: %.3fs\n", os.clock() - begin))
  begin = os.clock()
  local LocalGlobalConfig = GlobalConfig
  local TestLocalValue
  for i = 1, 1000000 do
    TestLocalValue = LocalGlobalConfig.DebugLuaBTree
  end
  print(string.format("(100w\230\172\161)\229\141\149\230\181\139Local\231\188\147\229\173\152\229\143\152\233\135\143: %.3fs\n", os.clock() - begin))
end

return LuaActionSingleTest
