local MainPanelAdapter = Class("MainPanelAdapter")
local Delegate = require("Utils.Delegate")

function MainPanelAdapter:OnInit()
  self.player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.playerCameraManager = self.player:GetUEController().PlayerCameraManager
  self.OnFovChanged = Delegate()
end

function MainPanelAdapter:OnDestroy()
end

function MainPanelAdapter:ResetKeys()
end

function MainPanelAdapter:RefreshByMode()
  self:ChangeModeFov(self.Panel.CurrMode:GetFov())
  self:OnRefreshByMode()
end

function MainPanelAdapter:OnRefreshByMode()
end

function MainPanelAdapter:GetModeFov()
  return self.Panel.CurrMode:GetFov()
end

function MainPanelAdapter:OnReset()
  self:ChangeModeFov(self.Panel.CurrMode:GetFov())
end

function MainPanelAdapter:ChangeModeFov(Fov)
  local Mode = self.Panel.CurrMode
  local MiniFov = Mode:GetMiniFov()
  local MaxiFov = Mode:GetMaxiFov()
  Mode:SetFov(math.clamp(Fov, MiniFov, MaxiFov))
  self.OnFovChanged:Invoke(Mode:GetFov())
end

function MainPanelAdapter:NativeChangeFov(Fov)
  self.playerCameraManager.FOV = Fov
end

function MainPanelAdapter:OnTickFov(Dt)
  local Mode = self.Panel.CurrMode
  local TargetFov = Mode:GetFov()
  local cameraManager = self.playerCameraManager
  local cameraFov = cameraManager.FOV
  if math.abs(cameraFov - TargetFov) > 0.01 then
    local LerpFov = self:LerpFov(cameraFov, TargetFov, Dt)
    self:NativeChangeFov(LerpFov)
  end
end

function MainPanelAdapter:OnTick(Dt)
  self:OnTickFov(Dt)
end

function MainPanelAdapter:LerpFov(PrevFov, TargetFov, DeltaTime)
  if DeltaTime > 0.0166 then
    local FovSpeed = (TargetFov - PrevFov) / DeltaTime
    local LerpTarget = PrevFov
    local RemainingTime = DeltaTime
    while RemainingTime > 1.0E-4 do
      local LerpDt = math.min(RemainingTime, 0.0166)
      LerpTarget = LerpTarget + FovSpeed * LerpDt
      RemainingTime = RemainingTime - LerpDt
      local f = math.clamp(LerpDt * 10, 0, 1)
      TargetFov = LerpTarget * f + (1 - f) * PrevFov
      PrevFov = TargetFov
    end
  else
    local f = math.clamp(DeltaTime * 10, 0, 1)
    TargetFov = TargetFov * f + (1 - f) * PrevFov
  end
  return TargetFov
end

return MainPanelAdapter
