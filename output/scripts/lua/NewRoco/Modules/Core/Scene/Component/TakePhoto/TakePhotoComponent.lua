local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TakePhotoComponent = Base:Extend("TakePhotoComponent")
local CameraPath = "/Game/NewRoco/Modules/Core/NPC/TakePhoto/BP_TakePhotoCamera.BP_TakePhotoCamera_C"
local CameraTransform = UE.FTransform(UE.FRotator(-42, -13, 9.2):ToQuat(), UE.FVector(1.718, -15.26, -5), UE.FVector(0.5))
local CameraSocket = "Bip001-R-Hand"

function TakePhotoComponent:Attach(owner)
  Base.Attach(self, owner)
  _G.PlayerResourceManager:LoadResources_PlayerPerform(self, CameraPath, false, self.OnLoadCameraSuccess, self.OnLoadCameraFail)
  local player = self.owner
  player:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  player:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_RIDING_ACTUALLY, self.OnRide)
  player:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_VISIBLE_CHANGE, self.OnPlayerVisibleChange)
  player:AddEventListener(self, PlayerModuleEvent.ON_AVATAR_READY, self.OnAvatarReady)
  self._curCameraStatus = 0
end

function TakePhotoComponent:OnLoadCameraSuccess(asset)
  self.CameraMesh = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(asset, UE.FTransform(), UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if self.CameraMesh then
    self.CameraMesh:SetActorHiddenInGame(true)
  end
  self.DelayID = _G.DelayManager:DelayFrames(1, function()
    self.DelayID = nil
    self:HandleTakePhotoStatus()
  end)
end

function TakePhotoComponent:OnLoadCameraFail(asset)
  Log.Debug("TakePhotoComponent OnLoadCameraFail")
end

function TakePhotoComponent:OnPlayerStatusChanged(status, value, opCode)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO or status == ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF or status == ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD then
    self:HandleTakePhotoStatus()
  end
end

function TakePhotoComponent:OnRide()
  self:HandleTakePhotoStatus()
end

function TakePhotoComponent:HandleTakePhotoStatus()
  if self.owner and UE.UObject.IsValid(self.owner.viewObj) then
    local statusComponent = self.owner.statusComponent
    if statusComponent then
      if statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO) then
        if self._curCameraStatus ~= ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO then
          self:HoldCamera()
        end
      elseif statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF) then
        if self._curCameraStatus ~= ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF then
          self:HandCamera()
        end
      elseif statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD) then
        if self._curCameraStatus ~= ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD then
          self:FloatingCamera()
        end
      else
        if UE.UObject.IsValid(self.owner.viewObj) then
          self.owner.viewObj.TakePhotoCamera = nil
          self.owner.viewObj.TakePhotoHand = false
        end
        if self.CameraMesh then
          self.CameraMesh:SetVisible(false)
        end
        self._curCameraStatus = 0
      end
    end
  end
end

function TakePhotoComponent:HoldCamera()
  self.owner.viewObj.TakePhotoCamera = nil
  if UE.UObject.IsValid(self.CameraMesh) then
    local isRide = self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
    if not isRide then
      local isLink = self.owner:IsInTogetherMove()
      if isLink then
        self.owner.viewObj.TakePhotoHand = false
        local viewObj = self.owner.viewObj
        local pawnRadius, pawnHalfHeight = viewObj.CapsuleComponent:GetScaledCapsuleSize()
        self.CameraMesh:K2_AttachToActor(viewObj, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
        local pawnForward = viewObj:GetActorForwardVector()
        local pawnRight = viewObj:GetActorRightVector()
        local Location = viewObj:K2_GetActorLocation() + (pawnForward - pawnRight) * pawnRadius * 0.717
        Location.Z = Location.Z + pawnHalfHeight
        self.CameraMesh:K2_SetActorLocation(Location, false, nil, false)
        self.CameraMesh:SetActorRelativeScale3D(UE.FVector(0.5))
        self.CameraMesh:SetVisible(true)
        self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO
      else
        self.owner.viewObj.TakePhotoHand = true
        self.CameraMesh:K2_AttachToComponent(self.owner.viewObj.Mesh, CameraSocket, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
        self.CameraMesh:K2_SetActorRelativeTransform(CameraTransform, false, nil, false)
        self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO
        self.CameraMesh:SetVisible(true)
      end
    else
      self.owner.viewObj.TakePhotoHand = false
      local ridePet = self.owner:GetRidePetBP()
      if UE.UObject.IsValid(ridePet) then
        local petRadius, petHalfHeight = ridePet.CapsuleComponent:GetScaledCapsuleSize()
        self.CameraMesh:K2_AttachToActor(self.owner.viewObj, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
        local petForward = ridePet:GetActorForwardVector()
        local Location = ridePet:K2_GetActorLocation() + petForward * petRadius
        Location.Z = Location.Z + petHalfHeight
        self.CameraMesh:K2_SetActorLocation(Location, false, nil, false)
        self.CameraMesh:SetActorRelativeScale3D(UE.FVector(0.5))
        self.CameraMesh:SetVisible(true)
        self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO
      end
    end
  end
end

function TakePhotoComponent:HandCamera()
  self.owner.viewObj.TakePhotoHand = false
  if UE.UObject.IsValid(self.CameraMesh) then
    local isRide = self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
    if not isRide then
      self.owner.viewObj.TakePhotoCamera = self.CameraMesh
      self.CameraMesh:SetVisible(true)
      self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF
    else
      self.owner.viewObj.TakePhotoCamera = nil
      local ridePet = self.owner:GetRidePetBP()
      if UE.UObject.IsValid(ridePet) then
        local petRadius, petHalfHeight = ridePet.CapsuleComponent:GetScaledCapsuleSize()
        self.CameraMesh:SetVisible(true)
        self.CameraMesh:K2_AttachToActor(self.owner.viewObj, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
        local petForward = ridePet:GetActorForwardVector()
        local petRight = ridePet:GetActorRightVector()
        local Location = ridePet:K2_GetActorLocation() + (petForward - petRight) * petRadius * 0.717
        self.CameraMesh:K2_SetActorLocation(Location, false, nil, false)
        self.CameraMesh:SetActorRelativeScale3D(UE.FVector(0.5))
        self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF
      end
    end
  end
end

function TakePhotoComponent:FloatingCamera()
  self.owner.viewObj.TakePhotoHand = false
  self.owner.viewObj.TakePhotoCamera = nil
  if _G.DataModelMgr.PlayerDataModel:IsVisitState() or _G.HomeModuleCmd and _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.InHome) or self.owner:IsInTogetherMove() then
    Log.Debug("TakePhotoComponent:FloatingCamera Skip: InVisit or InHome or IsLink ")
    self.CameraMesh:SetVisible(false)
  else
    local isRide = self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
    if isRide then
      local ridePet = self.owner:GetRidePetBP()
      if UE.UObject.IsValid(ridePet) then
        local petRadius, petHalfHeight = ridePet.CapsuleComponent:GetScaledCapsuleSize()
        self.CameraMesh:K2_AttachToActor(self.owner.viewObj, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
        local petForward = ridePet:GetActorForwardVector()
        local petRight = ridePet:GetActorRightVector()
        local Location = ridePet:K2_GetActorLocation() + (petForward - petRight) * petRadius * 0.717
        Location.Z = Location.Z + petHalfHeight
        self.CameraMesh:K2_SetActorLocation(Location, false, nil, false)
        self.CameraMesh:SetActorRelativeScale3D(UE.FVector(0.5))
        self.CameraMesh:SetVisible(true)
        self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD
      end
    else
      local viewObj = self.owner.viewObj
      local pawnRadius, pawnHalfHeight = viewObj.CapsuleComponent:GetScaledCapsuleSize()
      self.CameraMesh:K2_AttachToActor(viewObj, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, false)
      local pawnForward = viewObj:GetActorForwardVector()
      local pawnRight = viewObj:GetActorRightVector()
      local Location = viewObj:K2_GetActorLocation() + (pawnForward - pawnRight) * pawnRadius * 0.717
      Location.Z = Location.Z + pawnHalfHeight
      self.CameraMesh:K2_SetActorLocation(Location, false, nil, false)
      self.CameraMesh:SetActorRelativeScale3D(UE.FVector(0.5))
      self.CameraMesh:SetVisible(true)
      self._curCameraStatus = ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD
    end
  end
end

function TakePhotoComponent:OnPlayerVisibleChange(isVisible)
  if UE.UObject.IsValid(self.CameraMesh) then
    if not isVisible then
      self.CameraMesh:SetVisible(false)
    elseif self._curCameraStatus and 0 ~= self._curCameraStatus then
      self.CameraMesh:SetVisible(true)
    end
  end
end

function TakePhotoComponent:OnAvatarReady()
  self:HandleTakePhotoStatus()
end

function TakePhotoComponent:DeAttach()
  if self.DelayID then
    _G.DelayManager:CancelDelayById(self.DelayID)
    self.DelayID = nil
  end
  local player = self.owner
  player:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_RIDING_ACTUALLY, self.OnRide)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_VISIBLE_CHANGE, self.OnPlayerVisibleChange)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_AVATAR_READY, self.OnAvatarReady)
  if self.CameraMesh then
    self.CameraMesh:K2_DestroyActor()
    self.CameraMesh = nil
  end
  Base.DeAttach(self)
end

return TakePhotoComponent
