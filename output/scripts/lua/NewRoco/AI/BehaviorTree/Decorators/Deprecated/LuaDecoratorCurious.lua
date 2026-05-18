local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorCurious = Base:Extend("LuaDecoratorCurious")

function LuaDecoratorCurious:PerformConditionCheck(OwnerController, ...)
  local owner = OwnerController
  local distance = self.Distance:GetValue(owner)
  local compareDis = self.CompareDistance:GetValue(owner)
  local isExpose = self.RelaxCD:GetValue(owner)
  local sensity = self.Sensity:GetValue(owner)
  local bDistance = distance <= compareDis
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local subState = localPlayer.viewObj.PlayerFsm:GetCurState().subStateID
  local bState = isExpose or nil ~= subState and 8 == subState
  local bSensity = sensity > 0
  return bDistance and bState or bSensity
end

return LuaDecoratorCurious
