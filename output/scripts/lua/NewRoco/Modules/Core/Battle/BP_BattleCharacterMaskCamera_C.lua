local NRCClass = require("Core.NRCClass")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = NRCClass
local BP_BattleCharacterMaskCamera_C = Base:Extend("BP_BattleCharacterMaskCamera_C")

function BP_BattleCharacterMaskCamera_C:Ctor()
  Base.Ctor(self)
end

function BP_BattleCharacterMaskCamera_C:Initialize(Initializer)
end

function BP_BattleCharacterMaskCamera_C:ReceiveBeginPlay()
  self:UpdateCameraSettings(0)
  self:ChangeTextureToMatchScreen()
  self:SetTickEnable(true)
  local option = {}
  option.isCharacterMaskCapturing = true
  local runtimeData = _G.BattleManager.battleRuntimeData
  if runtimeData then
    runtimeData.resultUiState = option
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.RESULT_UI_STATE_UPDATE, option)
end

function BP_BattleCharacterMaskCamera_C:ReceiveEndPlay()
  self:SetTickEnable(false)
  local SceneCaptureComponent2D = self.SceneCaptureComponent2D
  if UE.UObject.IsValid(SceneCaptureComponent2D) then
    SceneCaptureComponent2D.ShowOnlyActors:Clear()
  end
  local option = {}
  option.isCharacterMaskCapturing = false
  local runtimeData = _G.BattleManager.battleRuntimeData
  if runtimeData then
    runtimeData.resultUiState = option
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.RESULT_UI_STATE_UPDATE, option)
end

function BP_BattleCharacterMaskCamera_C:SetTickEnable(Enable)
  if Enable then
    _G.UpdateManager:Register(self)
  else
    _G.UpdateManager:UnRegister(self)
  end
end

function BP_BattleCharacterMaskCamera_C:OnTick(DeltaSeconds)
  self:UpdateTransform(DeltaSeconds)
  self:UpdateCameraSettings(DeltaSeconds)
end

function BP_BattleCharacterMaskCamera_C:UpdateTransform(DeltaSeconds)
  local followTarget = self.followTarget
  if UE.UObject.IsValid(followTarget) then
    local cameraPosition = followTarget:Abs_K2_GetActorLocation()
    local cameraRotation = followTarget:K2_GetActorRotation()
    self:Abs_K2_SetActorLocationAndRotation_WithoutHit(cameraPosition, cameraRotation)
  end
end

function BP_BattleCharacterMaskCamera_C:UpdateCameraSettings(DeltaSeconds)
  local followTarget = self.followTarget
  local followTargetCamera = UE.UObject.IsValid(followTarget) and followTarget:IsA(UE.ACameraActor) and followTarget
  local CameraComponent = followTargetCamera and followTargetCamera:GetComponentByClass(UE.UCameraComponent)
  local FieldOfView = CameraComponent and CameraComponent.FieldOfView or 50
  local SceneCaptureComponent2D = self.SceneCaptureComponent2D
  local TextureTarget = SceneCaptureComponent2D and SceneCaptureComponent2D.TextureTarget
  if UE.UObject.IsValid(SceneCaptureComponent2D) then
    SceneCaptureComponent2D.FOVAngle = FieldOfView
  end
  if UE.UObject.IsValid(TextureTarget) and RocoEnv.IS_EDITOR then
    self:ChangeTextureToMatchScreen()
  end
end

function BP_BattleCharacterMaskCamera_C:ChangeTextureToMatchScreen()
  local World = UE4Helper.GetCurrentWorld()
  local SceneCaptureComponent2D = self.SceneCaptureComponent2D
  local TextureTarget = SceneCaptureComponent2D and SceneCaptureComponent2D.TextureTarget
  if UE.UObject.IsValid(TextureTarget) then
    UE4.UNRCStatics.ChangeTextureToMatchScreen(TextureTarget, World, 0)
  end
end

function BP_BattleCharacterMaskCamera_C:SetShowOnlyActorList(actorList)
  local SceneCaptureComponent2D = self.SceneCaptureComponent2D
  if not UE.UObject.IsValid(SceneCaptureComponent2D) then
    return
  end
  for i, actor in ipairs(actorList) do
    SceneCaptureComponent2D.ShowOnlyActors:Add(actor)
    local battlePlayerBase = actor
    local AvatarDecorator = battlePlayerBase.AvatarDecorator
    if UE.UObject.IsValid(AvatarDecorator) then
      local decoratorArray = AvatarDecorator:GetDecorators()
      local decoratorList = decoratorArray:ToTable()
      for j, decorator in ipairs(decoratorList) do
        SceneCaptureComponent2D.ShowOnlyActors:Add(decorator)
      end
    end
  end
end

function BP_BattleCharacterMaskCamera_C:SetFollowTarget(target)
  self.followTarget = target
end

return BP_BattleCharacterMaskCamera_C
