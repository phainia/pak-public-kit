local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local AIDefines = require("NewRoco.AI.AIDefines")
local SceneAnimEnum = require("NewRoco.Modules.Core.Scene.Common.SceneAnimEnum")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionTurnTo = Base:Extend("LuaActionTurnTo")
LuaActionTurnTo.delayNotice = false
local targetDir = UE.FVector(0, 0, 0)

function LuaActionTurnTo:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local target
  self.interrupted = false
  if self.Target == nil then
    Log.Warning("<LuaActionTurnTo>\232\138\130\231\130\185\230\156\170\233\133\141\231\189\174Target")
    return self:Finish(false)
  end
  local targetType = self.Target:GetType()
  if targetType == LuaParamType.Vector then
    target = self.Target:GetValue(owner)
  elseif targetType == LuaParamType.Object then
    local targetActor = self.Target:GetValue(owner)
    if not targetActor then
      if not LuaActionTurnTo.delayNotice then
        Log.DebugFormat("[LuaActionTurnTo] \231\155\174\230\160\135\228\184\186\231\169\186, BBkey = %s, \232\175\183\230\163\128\230\159\165\232\161\140\228\184\186\230\160\145\233\128\187\232\190\145\239\188\129", tostring(self.Target.key))
        LuaActionTurnTo.delayNotice = true
        a.task(function()
          a.wait(au.DelaySeconds(5))
          LuaActionTurnTo.delayNotice = false
        end)()
      end
      return self:Finish(false)
    end
    if targetActor.GetActorLocation then
      target = targetActor:GetActorLocation()
    elseif targetActor.Abs_K2_GetActorLocation then
      target = targetActor:Abs_K2_GetActorLocation()
    else
      return self:Finish(false)
    end
  else
    Log.Error("ArgumentsError, GetPosition target expected type is vector or object ")
    self:Finish(false)
    return
  end
  if nil == target then
    return self:Finish(false)
  end
  local ownerPos = owner.Npc:GetActorLocation()
  targetDir:Set(target.X - ownerPos.X, target.Y - ownerPos.Y, 0)
  local targetRotation = targetDir:ToRotator()
  local currentYaw = owner.Npc:GetActorRotation().Yaw
  if math.abs(targetRotation.Yaw - currentYaw) < 0.1 then
    return self:Finish(true)
  end
  local turnSpeed = self.TurnSpeed:GetValue(owner) or 0
  if turnSpeed <= 0 then
    owner.Npc:SetActorRotation(targetRotation)
    return self:Finish(true)
  end
  self.isEnd = false
  local TurnComp = owner.Npc.TurnComponent
  if TurnComp then
    local time = math.abs(targetRotation.Yaw - currentYaw) / turnSpeed
    time = math.clamp(time, 0.5, 2)
    self.d_timeout = _G.DelayManager:DelaySeconds(2 + time, self.TurnTimeOut, self, TurnComp)
    local bUseAnimLength
    if self.UseAnimLength then
      bUseAnimLength = self.UseAnimLength:GetValue(owner) or false
    else
      bUseAnimLength = true
    end
    local AnimRate
    if bUseAnimLength then
      AnimRate = self.AnimSpeedScale and self.AnimSpeedScale:GetValue(owner) or 1.0
      if AnimRate <= 0 then
        AnimRate = 1.0
      elseif AnimRate < 0.1 then
        AnimRate = 0.1
      end
    else
      AnimRate = 1.0
    end
    TurnComp:StartTurn_S(targetRotation.Yaw, time, true, bUseAnimLength, AnimRate, self, self.TurnEnd)
  else
    self.d_timeout = _G.DelayManager:DelaySeconds(2, self.TurnTimeOut, self)
  end
  return
end

function LuaActionTurnTo:TurnTimeOut(TurnComp)
  self.d_timeout = nil
  if TurnComp and TurnComp:IsTurning() then
    self.interrupted = true
    TurnComp:StopTurn(AIDefines.ActionResult.Aborted, true)
    return self:Finish(false)
  end
  self:TurnEnd(AIDefines.ActionResult.Aborted)
end

function LuaActionTurnTo:TurnEnd(result)
  if self.interrupted then
    return
  end
  if self.d_timeout then
    _G.DelayManager:CancelDelayById(self.d_timeout)
    self.d_timeout = nil
  end
  if result == AIDefines.ActionResult.Invalid or result == AIDefines.ActionResult.Failed then
    return self:Finish(false)
  end
  if result == AIDefines.ActionResult.Aborted then
    return self:Finish(true)
  end
  return self:Finish(true)
end

function LuaActionTurnTo:OnInterrupt(AIController, Finalized)
  self.interrupted = true
  if self.d_timeout then
    _G.DelayManager:CancelDelayById(self.d_timeout)
    self.d_timeout = nil
  end
  local owner = AIController
  if owner.Npc.TurnComponent then
    owner.Npc.TurnComponent:StopTurn(AIDefines.ActionResult.Aborted, true)
  end
end

return LuaActionTurnTo
