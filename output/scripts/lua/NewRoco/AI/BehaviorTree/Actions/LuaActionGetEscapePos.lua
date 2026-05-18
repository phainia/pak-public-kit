local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetEscapePos = Base:Extend("LuaActionGetEscapePos")

function LuaActionGetEscapePos:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local escapeDis = self.EscapeDistance:GetValue(owner)
  local ownerPos = owner.Npc:GetActorLocation()
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local backwardDir = ownerPos - NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER):GetActorLocationFrameCache()
  backwardDir.Z = 0
  backwardDir:Normalize()
  backwardDir = backwardDir * escapeDis
  local backwardPos = ownerPos + backwardDir
  local NavCheckSucc = true
  backwardPos, NavCheckSucc = npcModule:GetPosInNav(backwardPos, 300, 2000)
  if NavCheckSucc then
    self.OutPoint:SetValue(owner, backwardPos)
  else
    local range = 2000
    local navRandomPos, bSucc = UE4.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, range, nil, UE4.UNRCNavFilter)
    if bSucc then
      self.OutPoint:SetValue(owner, navRandomPos)
    else
      local ranX = math.random(-range, range)
      local ranY = math.random(-range, range)
      local randomPoint = UE4.FVector(ownerPos.X + ranX, ownerPos.Y + ranY, ownerPos.Z)
      randomPoint = npcModule:GetPosInNav(randomPoint, 100, 2000)
      self.OutPoint:SetValue(owner, randomPoint)
      Log.Warning("LuaActionGetEscapePos Use Native RandomPoint. ", tostring(randomPoint))
    end
  end
  self:Finish(true)
end

return LuaActionGetEscapePos
