local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorTest = Base:Extend("LuaDecoratorTest")
local TestDT = require("NewRoco.AI.BehaviorTree.Decorators.LuaDecoratorNumericCompare")

function LuaDecoratorTest:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  local leftVal = self.LeftValue:GetValue(owner)
  local rightVal = self.RightValue:GetValue(owner)
  local result = leftVal > rightVal
  print("Compare result " .. tostring(result))
  return true
end

function LuaDecoratorTest:InitTestDT()
  if not self.testDT then
    self.testDT = TestDT()
    self.testDT.LeftValue = self.LeftValue
    self.testDT.RightValue = self.RightValue
    self.testDT.Operation = self.Operation
  end
end

function LuaDecoratorTest:RunTestDT(loopCount, OwnerController)
  for i = 1, loopCount do
    self.testDT:PerformConditionCheck(OwnerController)
  end
end

function LuaDecoratorTest:InitTable()
  if not self.TestTable then
    self.TestTable = {}
    for i = 1, 1000000 do
      self.TestTable[i] = i
    end
  end
end

function LuaDecoratorTest:RandVisit()
  for i = 1, 1000000 do
    local rand = math.random(1, 1000000)
    local val = self.TestTable[rand]
  end
end

return LuaDecoratorTest
