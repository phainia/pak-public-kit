local Super = require("NewRoco.Modules.System.TakePhotos.Helper.MainPanelAdapter")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Delegate = require("Utils.Delegate")
local LongPressProxy = require("NewRoco/Modules/System/TakePhotos/LongPressProxy")
local NoWindowsMainPanelAdapter = Super:Extend("NoWindowsMainPanelAdapter")

function NoWindowsMainPanelAdapter:Ctor(Panel)
  self.Panel = Panel
end

function NoWindowsMainPanelAdapter:OnInit()
  Super.OnInit(self)
  local playerModule = _G.NRCModuleManager:GetModule("PlayerModule")
  playerModule:RegisterEvent(self, PlayerModuleEvent.ON_INPUT_TOUCH_START, self.OnInputTouchStart)
  playerModule:RegisterEvent(self, PlayerModuleEvent.ON_INPUT_TOUCH_END, self.OnInputTouchEnd)
  self:UpdateFighters()
end

function NoWindowsMainPanelAdapter:OnDestroy()
  local playerModule = _G.NRCModuleManager:GetModule("PlayerModule")
  playerModule:UnRegisterEvent(self, PlayerModuleEvent.ON_INPUT_TOUCH_START)
  playerModule:UnRegisterEvent(self, PlayerModuleEvent.ON_INPUT_TOUCH_END)
  self.player.inputComponent:SetCameraControlEnable(self, true)
end

function NoWindowsMainPanelAdapter:OnInputTouchStart(bJoystick, bInputJoystick, Fighter)
  if bJoystick then
    if bInputJoystick then
      self.MoveFighter = Fighter
    else
      self.MoveFighter = nil
    end
    self:UpdateFighters()
  end
end

function NoWindowsMainPanelAdapter:OnInputTouchEnd(bJoystick)
  if bJoystick then
    self.MoveFighter = nil
    self:UpdateFighters()
  end
end

function NoWindowsMainPanelAdapter:UpdateFighters()
  if 0 == self.MoveFighter then
    self.FovFighter1 = 1
    self.FovFighter2 = 2
  elseif 1 == self.MoveFighter then
    self.FovFighter1 = 0
    self.FovFighter2 = 2
  elseif 2 == self.MoveFighter then
    self.FovFighter1 = 0
    self.FovFighter2 = 1
  else
    self.FovFighter1 = 0
    self.FovFighter2 = 1
  end
end

function NoWindowsMainPanelAdapter:TickFov(Dt)
  local locationX0, locationY0, bPressed0 = UE.UNRCStatics.GetTouchStateFromRocoPreInputProcessor(self.FovFighter1)
  local locationX1, locationY1, bPressed1 = UE.UNRCStatics.GetTouchStateFromRocoPreInputProcessor(self.FovFighter2)
  if not self.FovFighter1 then
    bPressed0 = false
  end
  if not self.FovFighter2 then
    bPressed1 = false
  end
  if bPressed0 and bPressed1 then
    local dx = locationX1 - locationX0
    local dy = locationY1 - locationY0
    local Pixels = UE.FVector2D(dx, dy):Size()
    if not self.bInCameraControl then
      self.bInCameraControl = true
      self.baseFov = self.playerCameraManager.FOV
      self.baseDis = Pixels
      self.player.inputComponent:SetCameraControlEnable(self, false)
      self.Panel.CurrMode.bInScreenZoomControl = true
    else
      local dtPixels = Pixels - self.baseDis
      local dtZoomFov = dtPixels * -0.1
      local zoomFov = self.baseFov + dtZoomFov
      self:ChangeModeFov(zoomFov)
    end
  else
    if self.bInCameraControl then
      self.player.inputComponent:SetCameraControlEnable(self, true)
      self.Panel.CurrMode.bInScreenZoomControl = false
    end
    self.bInCameraControl = false
  end
end

function NoWindowsMainPanelAdapter:OnTick(Dt)
  self:TickFov(Dt)
  Super.OnTick(self, Dt)
end

function NoWindowsMainPanelAdapter:OnRefreshByMode()
end

return NoWindowsMainPanelAdapter
