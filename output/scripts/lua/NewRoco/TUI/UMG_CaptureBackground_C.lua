local UMG_CaptureBackground_C = _G.NRCPanelBase:Extend("UMG_CaptureBackground_C")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local UIUtils = require("NewRoco.Utils.UIUtils")
local TotalCapturingCount = 0

local function GetBackgroundCaptureRt()
  local player = _G.PlayerModuleCmd and _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local controller = player:GetUEController()
    if controller and UE.UObject.IsValid(controller) then
      local cameraManager = controller.playerCameraManager
      if cameraManager and UE.UObject.IsValid(cameraManager) then
        return cameraManager:GetTextureTarget2D()
      end
    end
  end
end

local function SetBackgroundCaptureRtInUse(owner)
  local RT_capture = GetBackgroundCaptureRt()
  if RT_capture and UE.UObject.IsValid(RT_capture) then
    UIUtils.AddImageRTInUse(RT_capture, owner)
  end
end

local function SetBackgroundCaptureRtNotUse(owner)
  local RT_capture = GetBackgroundCaptureRt()
  if RT_capture and UE.UObject.IsValid(RT_capture) and not UIUtils.RemoveImageRTNoUse(RT_capture, owner) then
    UE4.UNRCStatics.ChangeTextureToCustomSize(RT_capture, 1, 1, false)
  end
end

function UMG_CaptureBackground_C:OnConstruct()
  self.bCapturing = false
  local ShouldRestoreEnableWorldRendering = false
  local IsCapture = self:GetIsCapture()
  if self.IsCaptureTransparent or IsCapture then
    ShouldRestoreEnableWorldRendering = true
    UE4Helper.SetEnableWorldRendering(true, false, "CaptureBackground")
  end
  if self.IsCaptureTransparent then
    self:SetCaptureTranspanent(true)
  elseif IsCapture then
    self:StartCapture(true)
  end
  if ShouldRestoreEnableWorldRendering then
    _G.DelayManager:DelayFrames(1, function()
      UE4Helper.SetEnableWorldRendering(nil, nil, "CaptureBackground")
    end)
  end
end

function UMG_CaptureBackground_C:OnDestruct()
  if self.bCapturing then
    TotalCapturingCount = TotalCapturingCount - 1
  end
end

function UMG_CaptureBackground_C:OnActive()
  self.IsCapture = nil
end

function UMG_CaptureBackground_C:OnDeactive()
end

function UMG_CaptureBackground_C:StartCapture(respectTotalCapturingCount)
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  if _G.PlayerModuleCmd == nil then
    return
  end
  if nil == respectTotalCapturingCount then
    respectTotalCapturingCount = false
  end
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    Log.Error("player is nil")
    return
  end
  local cameraManager = player:GetUEController().PlayerCameraManager
  if not cameraManager then
    Log.Error("cameraManager is nil")
    return
  end
  if not cameraManager then
    return
  end
  local uiCamera = _G.NRCModuleManager:DoCmd(DialogueModuleCmd.GetUICamera)
  local RT_capture
  if not uiCamera then
    if 0 == TotalCapturingCount or not respectTotalCapturingCount then
      cameraManager:StartCaptureBlurScene2D(4, 4)
    end
    RT_capture = cameraManager:GetTextureTarget2D()
  else
    if 0 == TotalCapturingCount or not respectTotalCapturingCount then
      cameraManager:StartCaptureBlurScene2D(4, 4)
    end
    RT_capture = cameraManager:GetTextureTarget2D()
  end
  if not self.bCapturing then
    TotalCapturingCount = TotalCapturingCount + 1
    self.bCapturing = true
  end
  if self.SetMaterialIstance then
    self:SetMaterialIstance(RT_capture)
  else
    Log.Error("self.SetMaterialIstance Not Found")
  end
end

function UMG_CaptureBackground_C:SetCaptureTranspanent(respectTotalCapturingCount)
  if nil == respectTotalCapturingCount then
    respectTotalCapturingCount = false
  end
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraManager = player:GetUEController().playerCameraManager
  local uiCamera = _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.GetUICamera)
  local RT_capture
  if not uiCamera then
    if 0 == TotalCapturingCount or not respectTotalCapturingCount then
      cameraManager:StartCaptureBlurScene2D(1, 0)
    end
    RT_capture = cameraManager:GetTextureTarget2D()
  else
    if 0 == TotalCapturingCount or not respectTotalCapturingCount then
      cameraManager:StartCaptureBlurScene2D()
    end
    RT_capture = cameraManager:GetTextureTarget2D()
  end
  if not self.bCapturing then
    TotalCapturingCount = TotalCapturingCount + 1
    self.bCapturing = true
  end
  if self.SetMaterialIstance then
    self:SetMaterialIstance(RT_capture)
  else
    Log.Error("self.SetMaterialIstance Not Found")
  end
end

return UMG_CaptureBackground_C
