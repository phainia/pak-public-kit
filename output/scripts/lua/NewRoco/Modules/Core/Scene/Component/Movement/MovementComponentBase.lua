local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local MovementComponentBase = Base:Extend("MovementComponentBase")

function MovementComponentBase:Attach(owner)
  Base.Attach(self, owner)
  self.ueController = self.owner.ueController
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_APPLY_STATUS, self.OnApplyPlayerStatus)
end

function MovementComponentBase:DeAttach()
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_APPLY_STATUS, self.OnApplyPlayerStatus)
end

function MovementComponentBase:OnApplyPlayerStatus(...)
end

function MovementComponentBase:IsMoving()
  if self.isMoving then
    return true
  end
  if self.ueController then
    return self.ueController:IsPawnMoving()
  end
  return false
end

function MovementComponentBase:GetIsMoving()
  return self.isMoving or self:IsMoving()
end

function MovementComponentBase:SetIsMoving(IsMoving, Tag)
  if self.isMovingTag == nil then
    self.isMovingTag = {}
  end
  Tag = Tag or "Default"
  if table.contains(self.isMovingTag, Tag) ~= IsMoving then
    if IsMoving then
      table.insert(self.isMovingTag, Tag)
      self.isMoving = true
    else
      table.removeValue(self.isMovingTag, Tag)
      self.isMoving = #self.isMovingTag > 0
    end
  end
end

function MovementComponentBase:SetIsMovingTagOnce(Tag)
  if self.isMovingTagOnce == nil then
    self.isMovingTagOnce = {}
  end
  table.insert(self.isMovingTagOnce, Tag)
  self:SetIsMoving(true, Tag)
end

function MovementComponentBase:ClearMovingTagOnce()
  if self.isMovingTagOnce then
    local size = #self.isMovingTagOnce
    for i = size, 1, -1 do
      self:SetIsMoving(false, self.isMovingTagOnce[i])
      table.remove(self.isMovingTagOnce, i)
    end
  end
end

function MovementComponentBase:TransferTo(Pos)
  local viewObj = self.owner.viewObj
  if viewObj then
    return
  end
  self:StopMovement(true)
  viewObj:Abs_K2_SetActorLocation_WithoutHit(Pos)
end

function MovementComponentBase:StopMovement(Disable)
  local viewObj = self.owner.viewObj
  if not viewObj then
    return
  end
  if viewObj.CharacterMovement then
    if Disable then
      viewObj.CharacterMovement:DisableMovement()
    else
      viewObj.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
    end
  end
end

function MovementComponentBase:GetRotation()
  local viewObj = self.owner.viewObj
  if not viewObj or not viewObj.CharacterMovement then
    return
  end
  return viewObj.CharacterMovement.UpdatedComponent:K2_GetComponentRotation()
end

function MovementComponentBase:SetRotation(Rotation)
  local viewObj = self.owner.viewObj
  if not viewObj or not viewObj.CharacterMovement then
    return
  end
  return viewObj.CharacterMovement.UpdatedComponent:K2_SetWorldRotation(Rotation)
end

function MovementComponentBase:Move2Area(AreaId)
  local pos = SceneUtils.GetPosInArea(AreaId)
  if pos then
    self:MoveTo(pos)
  end
end

function MovementComponentBase:MoveTo(pos)
  local pawn = self.owner.viewObj
  if pawn and pawn:IsA(UE4.APawn) then
    self.isPathFinding = true
    local HitLocation, HitResult = UE4.UNavigationSystemV1.Abs_NavigationRaycast(pawn, pawn:Abs_K2_GetActorLocation(), pos)
    if HitResult then
      pos = HitLocation
    end
    UE4.UAIBlueprintHelperLibrary.SimpleMoveToLocation(pawn:GetController(), pos)
  end
end

return MovementComponentBase
