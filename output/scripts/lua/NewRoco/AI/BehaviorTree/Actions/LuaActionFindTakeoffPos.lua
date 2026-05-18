local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionFindTakeoffPos = Base:Extend("LuaActionFindTakeoffPos")

function LuaActionFindTakeoffPos:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local rayNum = self.RayNum:GetValue(owner)
  local rayElev = self.RayElev:GetValue(owner)
  local testRadius = self.TestRadius:GetValue(owner)
  local intentionType = self.Intention:GetValue(owner)
  local targetVec
  if 0 ~= intentionType then
    if self.Target.type == LuaParamType.Vector then
      targetVec = self.Target:GetValue(owner)
    elseif self.Target.type == LuaParamType.Object then
      local targetObj = self.Target:GetValue(owner)
      if targetObj and targetObj.viewObj then
        targetVec = targetObj.viewObj:Abs_K2_GetActorLocation()
      else
        Log.Warning("BT:LuaActionFindTakeoffPos, Object convert failed")
        self:Finish(false)
        return
      end
    else
      Log.Warning("BT:LuaActionFindTakeoffPos, error TargetType")
      self:Finish(false)
      return
    end
  end
  local selfPos = owner.Npc:GetActorLocation()
  local selfFwd = owner.Npc:GetForwardVector()
  local targetDir = UE4.UKismetMathLibrary.Subtract_VectorVector(targetVec, selfPos)
  local rayList = {}
  local dotList = {}
  for i = 0, rayNum - 1 do
    local bias = i * 360 / rayNum
    local biasDir = selfFwd:RotateAngleAxis(bias, UE4Helper.UpVector)
    biasDir.X = biasDir.X * math.cos(math.rad(rayElev))
    biasDir.Y = biasDir.Y * math.cos(math.rad(rayElev))
    biasDir.Z = math.sin(math.rad(rayElev))
    local nextPos = UE4.UKismetMathLibrary.Add_VectorVector(UE4.UKismetMathLibrary.Multiply_VectorFloat(biasDir, testRadius), selfPos)
    if 0 == intentionType then
      table.insert(rayList, nextPos)
    else
      local biasDot = targetDir:Dot(biasDir)
      local nth = #dotList + 1
      for _ = 1, #dotList do
        if 1 == intentionType and biasDot < dotList[_] or 2 == intentionType and biasDot > dotList[_] then
          nth = _
          break
        end
      end
      table.insert(dotList, nth, biasDot)
      table.insert(rayList, nth, nextPos)
    end
  end
  local resultPoints = {}
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)
  for _, lineEnd in ipairs(rayList) do
    local Hit, Success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), selfPos, lineEnd, TraceChannel, false, nil, 0)
    if Success then
      if GlobalConfig.DebugLuaBTree then
        UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), selfPos, lineEnd, UE4.FLinearColor(1, 0, 0, 1), 2, 1)
      end
    else
      if GlobalConfig.DebugLuaBTree then
        UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), selfPos, lineEnd, UE4.FLinearColor(0, 1, 0, 1), 2, 1)
      end
      table.insert(resultPoints, lineEnd)
      if 0 ~= intentionType then
        break
      end
    end
  end
  if 0 == #resultPoints then
    if GlobalConfig.DebugLuaBTree then
      Log.Debug("[LuaActionFindTakeoffPos] Cant Fly")
    end
    self:Finish(false)
    return
  else
    local targetPoint = resultPoints[math.random(#resultPoints)]
    self.OutPoint:SetValue(owner, targetPoint)
    if GlobalConfig.DebugLuaBTree then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), targetPoint, 20, 10, UE4.FLinearColor(0, 1, 0, 1), 2, 5)
    end
  end
  self:Finish(true)
end

return LuaActionFindTakeoffPos
