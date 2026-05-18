local BP_NPCCharacter_C = require("NewRoco.Modules.Core.NPC.BP_NPCCharacter_C")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = BP_NPCCharacter_C
local BP_PEO_Scene_C = Base:Extend("BP_PEO_Scene_C")
local SmallNumber = 1.0E-5
local TurningThreshold = 2
local NPCOverlapCooldown

local function GetNPCOverlapCooldown()
  if nil == NPCOverlapCooldown then
    local Conf = _G.DataConfigManager:GetNpcGlobalConfig("npc_overlap_cooldown")
    if Conf and Conf.num then
      NPCOverlapCooldown = Conf.num or 500
    else
      NPCOverlapCooldown = 500
    end
  end
  return NPCOverlapCooldown
end

function BP_PEO_Scene_C:Initialize(...)
  Base.Initialize(self, ...)
  self.d_dispatchOverlapPlayerCooldown = nil
  self.overlapCooldown = GetNPCOverlapCooldown()
end

function BP_PEO_Scene_C:OnTurn(targetYaw, time)
  self.delayedTurn = nil
  if self.Overlap_Alpha > SmallNumber then
    self.delayedTurn = {targetYaw = targetYaw, time = time}
  else
    self.curTurnTarget = targetYaw
    self:ConsumeTurn(time)
  end
end

function BP_PEO_Scene_C:OnStopTurn()
  self.delayedTurn = nil
  self:Event_StopTurn()
end

function BP_PEO_Scene_C:OnLoadResource()
  Base.OnLoadResource(self)
  self.EnableInjectAnim = true
  self.ReceiveHitSetting.bSkipSelfMoveTrue = false
  self.ReceiveHitSetting.ActorClassFilter:AddUnique(UE.ARocoLocalPlayer)
  self.ReceiveHitSetting.ActorClassFilter:AddUnique(UE.ANPCBaseActor)
  self.ReceiveHitSetting.ActorClassFilter:AddUnique(UE.ARocoVehicleCharacter)
  self.ReceiveHitSetting.ComponentClassFilter:AddUnique(UE.UCapsuleComponent)
  self.ReceiveHitSetting.ComponentClassFilter:AddUnique(UE.UShapeComponent)
end

function BP_PEO_Scene_C:OverrideOverlapCooldown(newCooldown)
  self.overlapCooldown = newCooldown or GetNPCOverlapCooldown()
end

function BP_PEO_Scene_C:OnOverlap(source, without_event)
  local currentOverlapMs = os.msTime()
  local time_diff = currentOverlapMs - (self.lastOverlapMs or 0)
  if time_diff < (self.overlapCooldown or GetNPCOverlapCooldown()) then
    return
  end
  self.lastOverlapMs = currentOverlapMs
  if self.Turn_Alpha > SmallNumber then
  elseif not self:GetAnimComponent():IsAnyAnimPlaying() then
    if not without_event and self.sceneCharacter then
      self.sceneCharacter:SendEvent(NPCModuleEvent.BE_PEO_OVERLAP)
    end
    self:BpOnOverlap(source)
  end
end

function BP_PEO_Scene_C.CalcDeltaYaw(from, to)
  local deltaYaw = math.fmod(to - from, 360)
  if deltaYaw > 180 then
    deltaYaw = deltaYaw - 360
  elseif deltaYaw <= -180 then
    deltaYaw = deltaYaw + 360
  end
  return deltaYaw
end

function BP_PEO_Scene_C:ConsumeTurn(time)
  time = time or 1.67
  local cur = self:K2_GetActorRotation()
  local deltaYaw = self.CalcDeltaYaw(cur.Yaw, self.curTurnTarget)
  if math.abs(deltaYaw) < TurningThreshold then
    self:TurnEnd(true)
  else
    self:Event_Turn(deltaYaw, time)
  end
end

function BP_PEO_Scene_C:TurnEnd(Succ)
  if self.sceneCharacter and self.sceneCharacter.TurnComponent then
    local result = Succ and AIDefines.ActionResult.Success or AIDefines.ActionResult.Failed
    self.sceneCharacter.TurnComponent:StopTurn(result, false)
  end
end

function BP_PEO_Scene_C:BpTurnEnd(Succ)
  self:TurnEnd(Succ)
end

function BP_PEO_Scene_C:BpOverlapEnd(isInterrupt)
  if not isInterrupt and self.delayedTurn then
    self:OnTurn(self.delayedTurn.targetYaw, self.delayedTurn.time)
    self.delayedTurn = nil
  end
end

function BP_PEO_Scene_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  self:DispatchOverlap(Other)
end

function BP_PEO_Scene_C:DispatchOverlap(Other)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local isLocalPlayer = player.viewObj == Other
  local isLocalPlayerRidingPet = not isLocalPlayer and player.viewObj == Other.Rider
  local otherVel = Other:GetVelocity()
  if isLocalPlayer or isLocalPlayerRidingPet then
    if self.d_dispatchOverlapPlayerCooldown == nil then
      if not otherVel:IsNearlyZero(0.1) and self.GetAnimComponent and not self:GetAnimComponent():IsAnyAnimPlaying() then
        self:OnOverlap(Other)
      end
      local isAttackBan = _G.FunctionBanModuleCmd and _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_BT_ATTACK, false, false)
      if isAttackBan then
        return
      end
      local selfVel = self:GetVelocity()
      if not isLocalPlayerRidingPet and not selfVel:IsNearlyZero(0.1) then
        local dirToPlayer = Other:K2_GetActorLocation() - self:K2_GetActorLocation()
        local integrateVel = otherVel + selfVel
        if integrateVel:Dot(dirToPlayer) > 0 and integrateVel:Size2D() > 100 then
          player:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, selfVel, false)
          dirToPlayer.Z = 0
          dirToPlayer:Normalize()
          player.viewObj:LaunchCharacter(dirToPlayer * 150, true, false)
          self.d_dispatchOverlapPlayerCooldown = DelayManager:DelaySeconds(1, function()
            self.d_dispatchOverlapPlayerCooldown = nil
          end)
        end
      end
    end
  else
    local throwSession = Other.ThrowSession
    if throwSession and throwSession.owner_id == player:GetServerId() and self.GetAnimComponent and not self:GetAnimComponent():IsAnyAnimPlaying() then
      self:OnOverlap(Other, true)
    end
  end
end

function BP_PEO_Scene_C:ReceiveTick(DeltaSeconds)
  local canStopTick = true
  if not self:TickUpdateRotate(DeltaSeconds) then
    canStopTick = false
  end
  if self.battlePetController then
    self.battlePetController:OnTick(DeltaSeconds)
  end
  if not self:TickFlyProperty(DeltaSeconds) then
    canStopTick = false
  end
  if not self:TickGradualFade(DeltaSeconds) then
    canStopTick = false
  end
  if self.inBattle and (self.MimicActor or self.MimicMesh) then
    canStopTick = false
  end
  if canStopTick then
    self:SetActorNeedTick(false)
  end
  self:ProcessGradualCallBack()
end

return BP_PEO_Scene_C
