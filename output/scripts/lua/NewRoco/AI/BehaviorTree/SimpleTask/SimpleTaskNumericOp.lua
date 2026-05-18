local Base = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskBase")
local SimpleTaskNumericOp = Base:Extend("SimpleTaskNumericOp")

function SimpleTaskNumericOp.Execute(left, right, operation)
  local result = 0
  operation = string.lower(operation)
  if "add" == operation or "+" == operation then
    result = left + right
  elseif "sub" == operation or "-" == operation then
    result = left - right
  elseif "mul" == operation or "*" == operation then
    result = left * right
  elseif "div" == operation or "/" == operation then
    result = left / right
  elseif "mod" == operation or "%" == operation then
    result = left % right
  elseif "cross" == operation then
    result = left:Cross(right)
  else
    Log.Error("Invalid operation arguments")
  end
  return result
end

return SimpleTaskNumericOp
