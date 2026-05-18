local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_TUIBlocker = NRCClass:Extend("BP_TUIBlocker")

function BP_TUIBlocker:Initialize(Initializer)
  self:CalcScaleFactor()
end

function BP_TUIBlocker:SetLocation(v)
  self:Abs_K2_SetActorLocation_WithoutHit(v, false)
end

function BP_TUIBlocker:CalcScaleFactor()
end

function BP_TUIBlocker:StartBlock(blockType)
  local player = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local cameraManager = player.viewObj:GetController().PlayerCameraManager
    local CameraLocation = cameraManager:Abs_GetCameraLocation()
    local CameraForward = UE.UKismetMathLibrary.GetForwardVector(cameraManager:GetCameraRotation())
    local Distance = 50
    local SpawnLocation = CameraLocation + CameraForward * Distance
    self:Abs_K2_SetActorLocation_WithoutHit(SpawnLocation, false)
    local component = self:GetComponentByClass(UE4.UStaticMeshComponent)
    component:SetVisibility(true)
    component:K2_SetRelativeLocation(UE4.FVector(blockType[1], blockType[2], blockType[3]), false, nil, false)
    component:SetRelativeScale3D(UE4.FVector(blockType[4], blockType[5], blockType[6]))
    self:LookAtScreen()
  end
end

function BP_TUIBlocker:StopBlock()
  local component = self:GetComponentByClass(UE.UStaticMeshComponent)
  component:SetVisibility(false)
end

return BP_TUIBlocker
