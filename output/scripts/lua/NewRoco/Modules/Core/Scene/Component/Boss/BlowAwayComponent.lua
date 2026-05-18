local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local BlowAwayComponent = Base:Extend("BlowAwayComponent")

function BlowAwayComponent:Attach(owner)
  Base.Attach(self, owner)
  self.lockedAI = false
  self.serverSession = nil
  local petbaseConf = self.owner:GetConfPetData()
  self.axial_density = 1
  self.radial_density = 1
  if petbaseConf then
    self.axial_density = tonumber(petbaseConf.axial_density) or 1
    self.radial_density = tonumber(petbaseConf.radial_density) or 1
  end
end

function BlowAwayComponent:DeAttach()
  self:RemoveCallback()
  local AIComp = self.owner.AIComponent
  if AIComp and self.lockedAI then
    AIComp:ForceLock(false)
    self.lockedAI = false
  end
end

function BlowAwayComponent:CanLaunch()
  local aic = self.owner.AIComponent
  if aic and aic:HasControlFlags(Enum.SceneAiControlFlags.SACF_DISABLE_BLOW_AWAY) then
    Log.PrintScreenMsg("[BlowAwayComponent]%s \229\155\160ControlFlag[SACF_DISABLE_BLOW_AWAY] \228\184\141\232\162\171\229\144\185\233\163\158", self.owner.config.name)
    return false
  end
  if self.owner:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_INTERACTING) or self.owner:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_FIGHTING) then
    Log.PrintScreenMsg("[BlowAwayComponent]%s \229\155\160LogicStatus\228\184\186INTERACTION\230\136\150FIGHTING \228\184\141\232\162\171\229\144\185\233\163\158", self.owner.config.name)
    return false
  end
  if 0 == self.axial_density and 0 == self.radial_density then
    Log.PrintScreenMsg("[BlowAwayComponent] %s \229\155\160petbase\233\133\141\231\189\174[*_density=0] \228\184\141\232\162\171\229\144\185\233\163\158", self.owner.config.name)
    return false
  end
  local hid = self.owner.HiddenComponent
  if hid and hid:IsMimicType() and hid:IsHidden() then
    Log.PrintScreenMsg("[BlowAwayComponent] %s \229\155\160\229\185\187\229\140\150\228\184\173 \228\184\141\232\162\171\229\144\185\233\163\158", self.owner.config.name)
    return false
  end
  local snapComp = self.owner.SocketSnapComponent
  if snapComp and snapComp:IsSnapping() then
    Log.PrintScreenMsg("[BlowAwayComponent] %s \229\155\160\229\144\184\233\153\132\228\184\173 \228\184\141\232\162\171\229\144\185\233\163\158", self.owner.config.name)
    return false
  end
  return true
end

function BlowAwayComponent:LaunchByWindArea(center, radial_force, axial_force)
  if not self:CanLaunch() then
    return false
  end
  local selfPos = self.owner:GetActorLocation()
  local finalVel = UE.FVector(selfPos.X - center.X, selfPos.Y - center.Y, 0)
  finalVel:Normalize()
  finalVel = finalVel * (radial_force * self.radial_density)
  finalVel.Z = axial_force * self.axial_density
  return self:Launch(finalVel, selfPos)
end

function BlowAwayComponent:LaunchByServer(blowRequest, from, to, initial_velocity)
  self.serverSession = blowRequest
end

local ServerBlowAwayForce

function BlowAwayComponent:Launch(vel, cachedSelfPos)
  local view = self.owner.viewObj
  if not view then
    Log.DebugFormat("BlowAwayComponent:Launch, but no view object, npcid=%d", self.owner.config.id)
    return false
  end
  if not view:IsA(UE.ACharacter) then
    Log.WarningFormat("BlowAwayComponent:Launch, but view is not a Character, npcid=%d", self.owner.config.id)
    return false
  end
  local AIComp = self.owner.AIComponent
  if AIComp then
    if not self.lockedAI then
      AIComp:ForceLock(true, true)
      self.lockedAI = true
    end
    if AIComp.isServerAI then
      vel.X = 0
      vel.Y = 0
      if not ServerBlowAwayForce then
        local Force = _G.DataConfigManager:GetNpcGlobalConfig("server_blow_away_force", true)
        ServerBlowAwayForce = Force and Force.num or 500
      end
      vel.Z = ServerBlowAwayForce
    end
  end
  cachedSelfPos = cachedSelfPos or self.owner:GetActorLocation()
  if 0 ~= vel.X or 0 ~= vel.Y then
    local gravity = view:GetMovementComponent():GetGravityZ()
    if 0 == gravity then
      gravity = 0.1
    end
    local t = math.abs(vel.Z / gravity) * 2
    local futureDistance = t * vel:Size2D()
    local futurePos = cachedSelfPos + UE.FVector(t * vel.X, t * vel.Y, 0)
    if _G.GlobalConfig.DebugLuaBTree then
      UE.UKismetSystemLibrary.Abs_DrawDebugSphere(view, futurePos, 100, 7, UE.FLinearColor(1, 0, 0, 1), 10, 3)
    end
    local rad = self.owner:GetScaledRadius()
    local Dir2D = UE.FVector(vel.X, vel.Y, 0)
    Dir2D:Normalize()
    local HitLocation, HitResult = UE.UNavigationSystemV1.Abs_NavigationRaycast(view, cachedSelfPos + Dir2D * rad, futurePos, nil, UE.UNRCNavFilter, view:GetController())
    if HitResult then
      if _G.GlobalConfig.DebugLuaBTree then
        UE.UKismetSystemLibrary.Abs_DrawDebugSphere(view, HitLocation, 100, 7, UE.FLinearColor(0, 1, 0, 1), 10, 3)
      end
      local newDistance = math.max(HitLocation:Dist2D(cachedSelfPos) - rad, 0)
      local ratio = math.clamp(newDistance / futureDistance, 0, 1)
      vel.X = vel.X * ratio
      vel.Y = vel.Y * ratio
    end
  end
  local HidComp = self.owner.HiddenComponent
  if HidComp and HidComp:IsDrillType() and HidComp:IsHidden() then
    HidComp:ResetHide(true)
  end
  local AnimComp = self.owner:GetAnimComponent()
  if AnimComp then
    AnimComp:StopAllMontage(0.2)
  end
  view:LaunchCharacter(vel, true, true)
  if not self.movementModeChangedCallback then
    self.movementModeChangedCallback = _G.SimpleDelegateFactory:CreateCallback(self, self.OnMovementModeChanged)
    view.MovementModeChangedDelegate:Add(view, self.movementModeChangedCallback)
  end
  return true
end

function BlowAwayComponent:OnMovementModeChanged(character, preMoveMode, preCustomMode)
  local view = self.owner.viewObj
  if view ~= character then
    Log.WarningFormat("BlowAwayComponent:OnMovementModeChanged not match character? npcid=%d", self.owner.config.id)
  end
  local MoveComp = character:GetMovementComponent()
  local notFalling = MoveComp.MovementMode ~= UE.EMovementMode.MOVE_Falling
  if notFalling then
    self:OnBlowEnd()
    self:RemoveCallback()
  end
end

function BlowAwayComponent:OnBlowEnd()
  local AIComp = self.owner.AIComponent
  if AIComp then
    if self.lockedAI then
      AIComp:ForceLock(false)
      self.lockedAI = false
    end
    if AIComp.isServerAI then
      self.owner:ReportPosition(ProtoEnum.SetNpcPosType.SNPT_AI_MOVE)
    end
  end
  if self.serverSession then
  end
end

function BlowAwayComponent:RemoveCallback()
  if self.movementModeChangedCallback then
    local view = self.owner.viewObj
    if view then
      view.MovementModeChangedDelegate:Remove(view, self.movementModeChangedCallback)
    end
    self.movementModeChangedCallback = nil
  end
end

return BlowAwayComponent
