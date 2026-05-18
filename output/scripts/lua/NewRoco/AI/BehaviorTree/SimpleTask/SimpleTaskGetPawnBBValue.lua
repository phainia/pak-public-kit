local Base = require("NewRoco.AI.BehaviorTree.SimpleTask.SimpleTaskBase")
local SimpleTaskGetPawnBBValue = Base:Extend("SimpleTaskGetPawnBBValue")

function SimpleTaskGetPawnBBValue.Execute(...)
  local args = {
    ...
  }
  local target = args[1]
  local bbKey = args[2]
  if target and target.Controller then
    local ctrler = target.Controller
    if ctrler.Blackboard then
      local result = ctrler.Blackboard:GetValueAsObject(bbKey)
      return result
    end
  end
  return nil
end

return SimpleTaskGetPawnBBValue
