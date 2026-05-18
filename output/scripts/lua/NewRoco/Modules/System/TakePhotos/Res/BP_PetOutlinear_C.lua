local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")
local BP_PetOutlinear_C = Class()

function BP_PetOutlinear_C:ReceiveBeginPlay()
  self.BP_RocoWidgetComponent:SetWidgetSpace(UE.EWidgetSpace.Screen)
  self.bTakingPhotos = false
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  Module:RegisterEvent(self, TakePhotosModuleEvent.OnBeginTakingPhotos, self.OnBeginTakingPhotos)
  Module:RegisterEvent(self, TakePhotosModuleEvent.OnFinishTakingPhotos, self.OnFinishTakingPhotos)
  UpdateManager:Register(self)
end

function BP_PetOutlinear_C:ReceiveEndPlay()
  self.bTakingPhotos = false
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  Module:UnRegisterEvent(self, TakePhotosModuleEvent.OnBeginTakingPhotos, self.OnBeginTakingPhotos)
  Module:UnRegisterEvent(self, TakePhotosModuleEvent.OnFinishTakingPhotos, self.OnFinishTakingPhotos)
  UpdateManager:UnRegister(self)
end

function BP_PetOutlinear_C:OnBeginTakingPhotos()
  self.bTakingPhotos = true
  self:SetVisible(false)
end

function BP_PetOutlinear_C:OnFinishTakingPhotos()
  self.bTakingPhotos = false
  if not self:IfInVisible() then
    self:SetVisible(true)
  end
end

function BP_PetOutlinear_C:SetVisible(bVisible)
  return self:SetActorHiddenInGame(not bVisible)
end

function BP_PetOutlinear_C:IfInVisible()
  return not self._bEnabled or not self._Parent or self.bTakingPhotos
end

function BP_PetOutlinear_C:SetOutlineEnabled(bEnable, Parent, Type, Offset, MeshBoundsScale)
  local bInVisible = self:IfInVisible()
  self._bEnabled = bEnable
  self._Parent = Parent
  self._AttachOffset = Offset or FVectorZero
  self._AttachScale = DEBUG_STATIC_IDENTIFY_SCALE or MeshBoundsScale or 1
  self._ParentType = Type or 0
  local OldParent = self:GetAttachParentActor()
  if bEnable and not bInVisible and OldParent ~= Parent then
    Log.Debug("BP_PetOutlinear_C:SetOutlineEnabled Transit", self, Parent:GetName(), Parent, self:GetAttachParentActor())
    bInVisible = true
  end
  local bNewInVisible = self:IfInVisible()
  if bInVisible ~= bNewInVisible then
    if bNewInVisible then
      self:DoFadeOut()
    else
      self:K2_AttachToActor(Parent, "", UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative)
      self:K2_SetActorRelativeLocation(Offset, false, nil, true)
      self:DoFadeIn()
    end
    return true, bNewInVisible
  end
  return false
end

function BP_PetOutlinear_C:RemoveFromParent()
  self:K2_DetachFromActor(UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative)
end

function BP_PetOutlinear_C:DoFadeOut()
  Log.Debug("BP_PetOutlinear_C:DoFadeOut", self)
  local Widget = self.BP_RocoWidgetComponent:GetWidget()
  if Widget then
    Widget:StopAnim(self)
  end
end

function BP_PetOutlinear_C:OnFadeOut()
  UpdateManager:UnRegister(self)
  if self:IfInVisible() and UE.UObject.IsValid(self) then
    self:SetVisible(false)
    self:K2_DetachFromActor(UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative, UE.EAttachmentRule.KeepRelative)
  end
end

function BP_PetOutlinear_C:OnFadeIn()
  if not self:IfInVisible() and UE.UObject.IsValid(self) then
    self:SetVisible(true)
  end
end

function BP_PetOutlinear_C:DoFadeIn()
  Log.Debug("BP_PetOutlinear_C:DoFadeIn", self, self._Parent:GetName())
  UpdateManager:Register(self)
  self:OnTick()
  self:SetVisible(true)
  local Widget = self.BP_RocoWidgetComponent:GetWidget()
  if Widget then
    Widget:StartAnim(self)
  end
end

function BP_PetOutlinear_C:GetParentStaticMeshComponent()
  return self._Parent:GetComponentByClass(UE.UStaticMeshComponent)
end

local FVector2DOne = UE.FVector2D(1, 1)

function BP_PetOutlinear_C:OnTick()
  if not UE.UObject.IsValid(self._Parent) then
    self:SetVisible(false)
    return
  end
  if not self.BP_RocoWidgetComponent:GetWidget() then
    return
  end
  local StaticMeshComponent = self:GetParentStaticMeshComponent()
  local CapsuleComponent = self._Parent.CapsuleComponent
  if 2 == self._ParentType or not CapsuleComponent and StaticMeshComponent then
    if not StaticMeshComponent then
      self:SetVisible(false)
      return
    end
    local StaticMesh = StaticMeshComponent.StaticMesh
    if StaticMesh then
      local Bounds = StaticMesh:GetBounds()
      local Extent = Bounds.BoxExtent
      local Scale = self._AttachScale * self._Parent:GetActorScale3D().X
      local Width = math.max(Extent.Y, Extent.X) * 2 * Scale
      local Height = Extent.Z * 2 * Scale
      self:RefreshBySize(Width, Height)
      return
    end
  end
  if not CapsuleComponent then
    self:SetVisible(false)
    return
  end
  local Height = CapsuleComponent:GetScaledCapsuleHalfHeight() * 2
  local Width = CapsuleComponent:GetScaledCapsuleRadius() * 2
  if Height > 320 then
    Height = 320
  end
  if Width > 320 then
    Width = 320
  end
  if Height < 80 then
    Height = 80
  end
  if Width < 80 then
    Width = 80
  end
  self:RefreshBySize(Width, Height)
end

function BP_PetOutlinear_C:RefreshBySize(Width, Height)
  local Rotation = self:GetLookRotation()
  local MinValue = math.min(Height, Width)
  local PitchRadians = UE.UKismetMathLibrary.DegreesToRadians(Rotation.Pitch)
  local PitchHeight = math.max(math.cos(PitchRadians) * Height, MinValue)
  local Component = self.BP_RocoWidgetComponent
  local Widget = Component:GetWidget()
  if not self._Widget or Widget ~= self._Widget then
    self._Widget = Widget
    self.Canvas = Widget.CanvasPanel_AimTakingPhoto
    self.CanvasSlot = self.Canvas.Slot
    self.CanvasPanel_Root = Widget.CanvasPanel_Root
  end
  local Size = UE.FVector2D(Width, PitchHeight)
  self:Refresh(Size, Rotation)
end

function BP_PetOutlinear_C:GetLookRotation()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Controller = player:GetUEController()
  local Rotation = Controller.PlayerCameraManager:GetCameraRotation()
  local Forward = -Rotation:GetForwardVector()
  Rotation = Forward:ToRotator()
  return Rotation
end

function BP_PetOutlinear_C:RefreshByScreenSpace(Size)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local CameraLocation, CameraRotation = NRCModuleManager:DoCmd(TakePhotosModuleCmd.GetIdentifyLookViewInfo)
  if not CameraLocation then
    return
  end
  local playerController = localPlayer:GetUEController()
  local fov = playerController.PlayerCameraManager.FOV
  local distance = (CameraLocation - self:Abs_K2_GetActorLocation()):Size()
  local scale = 1000.0 / (distance + 1.0E-6) / math.tan(math.rad(fov / 2))
  Size.Y = Size.Y * scale
  Size.X = Size.X * scale
  local NewSize = UE.FVector2D(Size.X, Size.Y)
  local Scale = FVector2DOne
  local MinSize = 160
  if MinSize > Size.X or MinSize > Size.Y then
    NewSize = UE.FVector2D(Size.X, Size.Y)
    if Size.X < Size.Y then
      NewSize.X = MinSize
      NewSize.Y = Size.Y / Size.X * MinSize
      Scale = Size / NewSize
    else
      NewSize.Y = MinSize
      NewSize.X = Size.X / Size.Y * MinSize
      Scale = Size / NewSize
    end
  end
  local Component = self.BP_RocoWidgetComponent
  Component:SetDrawSize(NewSize)
  self.CanvasSlot:SetSize(NewSize)
  self.CanvasSlot:SetPosition(-NewSize / 2)
  self.CanvasPanel_Root:SetRenderScale(Scale)
end

function BP_PetOutlinear_C:Refresh(Size, Rotation)
  local bUsingScreenSpace = true
  if bUsingScreenSpace then
    self:RefreshByScreenSpace(Size)
    return
  end
  local Component = self.BP_RocoWidgetComponent
  self.BP_RocoWidgetComponent:K2_SetWorldRotation(Rotation, true, nil, true)
  local Scale = FVector2DOne
  local MinSize = 160
  local NewSize = Size
  if MinSize > Size.X or MinSize > Size.Y then
    NewSize = UE.FVector2D(Size.X, Size.Y)
    if Size.X < Size.Y then
      NewSize.X = MinSize
      NewSize.Y = Size.Y / Size.X * MinSize
      Scale = Size / NewSize
    else
      NewSize.Y = MinSize
      NewSize.X = Size.X / Size.Y * MinSize
      Scale = Size / NewSize
    end
  end
  if MinSize < NewSize.X and MinSize < NewSize.Y then
    Scale = UE.FVector2D(1, 1)
    Component:SetDrawSize(NewSize)
    if MinSize < NewSize.X then
      Scale.X = Scale.X * NewSize.X / MinSize
      NewSize.X = MinSize
    end
    if MinSize < NewSize.Y then
      Scale.Y = Scale.Y * NewSize.Y / MinSize
      NewSize.Y = MinSize
    end
    self.CanvasSlot:SetSize(NewSize)
    self.CanvasSlot:SetPosition(-NewSize / 2)
    self.CanvasPanel_Root:SetRenderScale(Scale)
  else
    Component:SetDrawSize(NewSize * 10)
    self.CanvasSlot:SetSize(NewSize)
    self.CanvasSlot:SetPosition(-NewSize / 2)
    self.CanvasPanel_Root:SetRenderScale(Scale)
  end
end

return BP_PetOutlinear_C
