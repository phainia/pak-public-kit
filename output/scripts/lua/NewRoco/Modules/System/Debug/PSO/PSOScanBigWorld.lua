local JsonUtils = require("Common.JsonUtils")
local DebugTabScenePublic = require("NewRoco.Modules.System.Debug.Tabs.DebugTabScenePublic")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
PSOScanBigwrold = {}
local L_Bigworld_01_Release = "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release"

function PSOScanBigwrold:InitPlayer(enable)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(true, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  self.StartRunPos = self.player:GetActorLocation()
end

function PSOScanBigwrold:DisableOcclusion()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.AllowPrecomputedVisibility 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSoftwareOcclusion 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSDOC 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.HZBOcclusion 0")
end

function PSOScanBigwrold:Start()
  self.StartPos = UE4.FVector(332800, 486400, 50000)
  self.EndPos = UE4.FVector(691200, 742400, 50000)
  self.StartRunPos = self.StartPos
  self.MoveSpeedX = 600
  self.MoveSpeedY = 600
  self.CurBigWorldPos = UE4.FVector(self.StartPos.X, self.StartPos.Y, self.StartPos.Z)
  self.TotalRunPos = 0
  self.TimeInterval = 0.2
  self:DisableOcclusion()
  _G.UpdateManager:Register(self)
  self:LoadBigworldLevel()
end

function PSOScanBigwrold:LoadBigworldLevel()
  NRCEventCenter:RegisterEvent("LoadBigWorldLevel", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnBigWorldLoaded)
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
  self.player = nil
  LevelHelper:OpenLevel(L_Bigworld_01_Release)
  Log.Debug("PSOScanBigwrold:LoadBigworldLevel: OpenLevel ", L_Bigworld_01_Release)
end

function PSOScanBigwrold:OnBigWorldLoaded()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnBigWorldLoaded)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    DebugTabScenePublic:GhostMode()
    self:AutoMoveAnywhereEnd()
    PSOScanBigwrold.AutoMoveTimer = _G.TimerManager:CreateTimer(PSOScanBigwrold, "AutoMoveTimer", 9999999, PSOScanBigwrold.OnMoveNext, nil, self.TimeInterval)
  end)
end

function PSOScanBigwrold:OnMoveNext()
  self.TotalRunPos = self.TotalRunPos + 1
  Log.DebugFormat("PSOScanBigwrold.OnMoveNext[%d]=%d,%d,%d", self.TotalRunPos, self.CurBigWorldPos.X, self.CurBigWorldPos.Y, self.CurBigWorldPos.Z)
  local Pos = SceneUtils.GetPosInLand(self.CurBigWorldPos, 83, 90, 500000)
  self.player:SetActorLocation(Pos)
  self:UpdateNextPos()
end

function PSOScanBigwrold:UpdateNextPos()
  self.CurBigWorldPos.Y = self.CurBigWorldPos.Y + self.MoveSpeedY
  if self.CurBigWorldPos.Y > self.EndPos.Y or self.CurBigWorldPos.Y < self.StartPos.Y then
    self.CurBigWorldPos.X = self.CurBigWorldPos.X + self.MoveSpeedX
    self.MoveSpeedY = self.MoveSpeedY * -1
    if self.CurBigWorldPos.X > self.EndPos.X then
      self:AutoMoveAnywhereEnd()
      self:End()
    end
  end
end

function PSOScanBigwrold:AutoMoveAnywhereEnd()
  if self.AutoMoveTimer then
    if not self.player then
      self:InitPlayer(false)
    end
    if self.player then
      self.player:SetActorLocation(self.StartRunPos)
      self.player:SetViewVisible(true, true)
    end
    self.AutoMoveTimer:Stop()
    self.AutoMoveTimer = nil
    DebugTabScenePublic:GhostMode()
    Log.Debug("PSOScanBigwrold.AutoMoveAnywhereEnd:", self.StartRunPos.X, self.StartRunPos.Y, self.StartRunPos.Z)
  end
end

function PSOScanBigwrold:End()
  _G.UpdateManager:UnRegister(self)
  self.player = nil
  Log.Debug("NRCAutoDDC End")
end

Speed = 256

function PSOScanBigwrold:OnTick(dt)
  if not self.player then
    return
  end
  self.player.ueController.Pawn:AddControllerYawInput(dt * Speed)
end

return PSOScanBigwrold
