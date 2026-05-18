local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LuaActionGetLeaveBattleFieldPos = Base:Extend("LuaActionGetLeaveBattleFieldPos")

function LuaActionGetLeaveBattleFieldPos:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local randomDis = math.random(10, self.RandomDistanceEx:GetValue(owner))
  local battleCenter, battleRange = owner:GetBattleCenterInfo()
  if nil == battleCenter or nil == battleRange then
    self:Finish(true)
    return
  end
  local dir = owner.Npc:GetActorLocation() - battleCenter
  dir.Z = 0
  dir:Normalize()
  if 0 == dir.X and 0 == dir.Y then
    dir.X = 1
  end
  local targetPos = battleCenter + dir * (battleRange + randomDis + 100)
  local findSucc = true
  local NavPos = SceneUtils.GetPosInNav(targetPos, 100, 2000)
  if NavPos then
    self.OutPoint:SetValue(owner, NavPos)
  else
    targetPos = battleCenter + dir * battleRange * -1.0
    NavPos = SceneUtils.GetPosInNav(targetPos, 100, 2000)
    if NavPos then
      self.OutPoint(owner, NavPos)
    else
      local targetPosUp = battleCenter + battleRange * UE4.FVector(1, 0, 0)
      local targetPosDown = battleCenter + battleRange * UE4.FVector(0, 1, 0)
      local targetPosRight = battleCenter + battleRange * UE4.FVector(-1, 0, 0)
      local targetPosLeft = battleCenter + battleRange * UE4.FVector(0, -1, 0)
      targetPosUp = SceneUtils.GetPosInNav(targetPosUp, 100, 2000)
      targetPosDown = SceneUtils.GetPosInNav(targetPosUp, 100, 2000)
      targetPosRight = SceneUtils.GetPosInNav(targetPosUp, 100, 2000)
      targetPosLeft = SceneUtils.GetPosInNav(targetPosUp, 100, 2000)
      if targetPosUp then
        self.OutPoint(targetPosUp)
      elseif targetPosDown then
        self.OutPoint(targetPosDown)
      elseif targetPosRight then
        self.OutPoint(targetPosRight)
      elseif targetPosLeft then
        self.OutPoint(targetPosLeft)
      else
        self.OutPoint:SetValue(owner, owner:Abs_K2_GetActorLocation())
        findSucc = false
      end
    end
  end
  self:Finish(findSucc)
end

return LuaActionGetLeaveBattleFieldPos
