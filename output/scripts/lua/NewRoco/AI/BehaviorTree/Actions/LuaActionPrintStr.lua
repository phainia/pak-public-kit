local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionPrintStr = Base:Extend("LuaAcionPrintStr")

function LuaActionPrintStr:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local output = self.Output:GetValue(owner)
  local outputStr = tostring(output)
  UE4.UKismetSystemLibrary.PrintString(owner:GetWorld(), outputStr, self.PrintToScreen:GetValue(owner))
  self:Finish(true)
end

return LuaActionPrintStr
