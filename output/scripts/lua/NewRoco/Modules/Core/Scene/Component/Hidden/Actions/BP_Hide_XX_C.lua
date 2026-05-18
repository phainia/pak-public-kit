local Delegate = require("Utils.Delegate")
local CurveStatics = require("NewRoco.Utils.CurveStatics")
local CURVE_PATH = "CurveFloat'/Game/NewRoco/Modules/AI/Movement/Config/C_MeteorProgress.C_MeteorProgress'"
local FxPath_XX_End = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/hide/NR_Hide_XX_End.NR_Hide_XX_End'"
local Sound_MeteorDown = 4067
local BP_Hide_XX_C = Class()

function BP_Hide_XX_C:Ctor()
  self.FallenEvent = Delegate()
  self.isShowing = false
  self.key = 0
  self.d_DisableEffect = nil
end

function BP_Hide_XX_C:ReceiveEndPlay(EndPlayReason)
  if self.isShowing then
    self.FallenEvent:Invoke(AIDefines.ActionResult.Aborted)
    self.FallenEvent:Clear()
    UpdateManager:UnRegister(self)
    self.isShowing = false
  end
  if self.d_DisableEffect then
    DelayManager:CancelDelayById(self.d_DisableEffect)
    self.d_DisableEffect = nil
  end
  if self.d_Sound then
    DelayManager:CancelDelayById(self.d_Sound)
    self.d_Sound = nil
  end
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end

local BeginBias = _G.DataConfigManager:GetNpcGlobalConfig("hd_meteor_width_bias").num / 100
local EndBias = _G.DataConfigManager:GetNpcGlobalConfig("hd_meteor_height_bias").num / 100

function BP_Hide_XX_C:SplineMove(StartPos, EndPos, caller, callback)
  if self.d_Sound then
    DelayManager:CancelDelayById(self.d_Sound)
  end
  self.d_Sound = DelayManager:DelaySeconds(1, function()
    self.d_Sound = nil
    NRCAudioManager:PlaySound3DAtLocationAuto(Sound_MeteorDown, EndPos, "BP_Hide_XX_C:SplineMove")
  end)
  if self.isShowing then
    self.FallenEvent:Invoke(AIDefines.ActionResult.Aborted)
    self.FallenEvent:Clear()
    return
  else
    self.Effect:SetActive(true)
    self.XingXing:SetVisibility(true)
    UpdateManager:Register(self, true)
    self.isShowing = true
  end
  local selfPos = self:K2_GetActorLocation()
  self.FallenEvent:Add(caller, callback)
  self.key = 0
  UE.UNRCStatics.FillSplineAsMeteor(self.Spline, StartPos - selfPos, EndPos - selfPos, BeginBias, EndBias)
end

function BP_Hide_XX_C:AbortMove()
  if self.isShowing then
    self.FallenEvent:Invoke(AIDefines.ActionResult.Aborted)
    self.FallenEvent:Clear()
    self:OnMoveEnd(true)
  end
end

function BP_Hide_XX_C:OnTick(DeltaTime)
  if not self.isShowing then
    UpdateManager:UnRegister(self)
    return
  end
  local currentProgress = self.ProgressCurve:GetFloatValue(self.key)
  local Trans = self.Spline:GetTransformAtSplineInputKey(math.clamp(currentProgress, 0, 1), UE.ESplineCoordinateSpace.World, false)
  self.Effect:K2_SetWorldLocation(Trans.Translation, false, nil, false)
  self.XingXing:K2_SetWorldLocation(Trans.Translation + UE.FVector(0, 0, 100), false, nil, false)
  self.XingXing:K2_SetWorldRotation(Trans.Rotation:ToRotator(), false, nil, false)
  if currentProgress >= 1 then
    self:OnMoveEnd()
    return
  end
  self.key = self.key + math.min(DeltaTime, 0.033)
end

function BP_Hide_XX_C:OnMoveEnd(abort)
  if self.d_DisableEffect then
    DelayManager:CancelDelayById(self.d_DisableEffect)
  end
  self.d_DisableEffect = DelayManager:DelayFrames(2, function()
    self.d_DisableEffect = nil
    self.Effect:SetActive(false)
  end)
  self.XingXing:SetVisibility(false)
  UpdateManager:UnRegister(self)
  self.isShowing = false
  self.FallenEvent:Invoke(AIDefines.ActionResult.Success)
  self.FallenEvent:Clear()
  if not abort then
    local location = self.XingXing:Abs_K2_GetComponentLocation()
    local rotation = UE4.FRotator()
    UE.UNiagaraFunctionLibrary.SpawnSystemAtLocation(_G.UE4Helper.GetCurrentWorld(), self.XX_End, location, rotation, UE4Helper.OneVector, true, true, UE.ENCPoolMethod.None)
  end
end

return BP_Hide_XX_C
