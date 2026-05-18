local Super = require("NewRoco.Modules.System.TakePhotos.Helper.MainPanelAdapter")
local RelationTreeEvent = reload("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local WindowsMainPanelAdapter = Super:Extend("WindowsMainPanelAdapter")

function WindowsMainPanelAdapter:Ctor(Panel)
  self.Panel = Panel
end

function WindowsMainPanelAdapter:OnInit()
  Super.OnInit(self)
  local mappingContext = self.Panel:AddInputMappingContext("IMC_PhotoGraph")
  if mappingContext then
    mappingContext:BindAction("IA_PgExitQuick", self.Panel, "OnPcExit", UE.ETriggerEvent.Triggered)
    mappingContext:BindAction("IA_PgExit", self.Panel, "OnPcExit", UE.ETriggerEvent.Triggered)
    mappingContext:BindAction("IA_PgOpenAlbum", self.Panel, "OnPcOpenAlbum", UE.ETriggerEvent.Triggered)
    mappingContext:BindAction("IA_PgResetCamera", self.Panel, "OnPcResetCamera", UE.ETriggerEvent.Triggered)
    mappingContext:BindAction("IA_PgOpenSettingUI", self.Panel, "OnPcOpenSettingUI", UE.ETriggerEvent.Triggered)
  end
  self._configSlice = _G.DataConfigManager:GetGlobalConfigByKeyType("mouse_wheel_scroll_camera_scale", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
  self.CurrentInputMappingContext = nil
end

function WindowsMainPanelAdapter:OnDestroy()
end

function WindowsMainPanelAdapter:OnReset()
  Super.OnReset(self)
  self:SyncWheelNum()
end

function WindowsMainPanelAdapter:OnRefreshByMode()
  self:SyncWheelNum()
  self:ToggleInputMappingContext()
end

function WindowsMainPanelAdapter:ToggleInputMappingContext()
  if self.CurrentInputMappingContext then
    self.CurrentInputMappingContext:DisableInputMappingContext()
  end
  if self.Panel.CurrMode.Mgr:Is1PMode() then
    self.CurrentInputMappingContext = self.Panel:GetInputMappingContext("IMC_PhotoGraphLocal")
    if not self.CurrentInputMappingContext then
      self.CurrentInputMappingContext = self.Panel:AddInputMappingContext("IMC_PhotoGraphLocal")
    else
      self.CurrentInputMappingContext:EnableInputMappingContext()
    end
    self.CurrentInputMappingContext:BindAction("IA_PgEnter1PMode", self.Panel, "OnPcEnter1PMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterSelfieMode", self.Panel, "OnPcEnterSelfieMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterTripodMode", self.Panel, "OnPcEnterTripodMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgTakePhoto", self.Panel, "OnPcTakePhoto", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelUp", self.Panel, "OnPcWheelUp", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelDown", self.Panel, "OnPcWheelDown", UE.ETriggerEvent.Triggered)
  elseif self.Panel.CurrMode.Mgr:IsTripodMode() then
    self.CurrentInputMappingContext = self.Panel:GetInputMappingContext("IMC_PhotoGraphTripod")
    if not self.CurrentInputMappingContext then
      self.CurrentInputMappingContext = self.Panel:AddInputMappingContext("IMC_PhotoGraphTripod")
    else
      self.CurrentInputMappingContext:EnableInputMappingContext()
    end
    self.CurrentInputMappingContext:BindAction("IA_PgTakePhoto", self.Panel, "OnPcTakePhoto", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelUp", self.Panel, "OnPcWheelUp", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelDown", self.Panel, "OnPcWheelDown", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnter1PMode", self.Panel, "OnPcEnter1PMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterSelfieMode", self.Panel, "OnPcEnterSelfieMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterTripodMode", self.Panel, "OnPcEnterTripodMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraUpStart", self.Panel, "OnPcCameraUpStart", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraUpEnd", self.Panel, "OnPcCameraUpEnd", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraDownStart", self.Panel, "OnPcCameraDownStart", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraDownEnd", self.Panel, "OnPcCameraDownEnd", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraLeftStart", self.Panel, "OnPcCameraLeftStart", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraLeftEnd", self.Panel, "OnPcCameraLeftEnd", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraRightStart", self.Panel, "OnPcCameraRightStart", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraRightEnd", self.Panel, "OnPcCameraRightEnd", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraMouseMove", self.Panel, "OnPcCameraMove", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgTripodToWorld", self.Panel, "OnPcTripodToWorld", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWorldToTripod", self.Panel, "OnPcWorldToTripod", UE.ETriggerEvent.Triggered)
  elseif self.Panel.CurrMode.Mgr:IsWorldMode() then
    self.CurrentInputMappingContext = self.Panel:GetInputMappingContext("IMC_PhotoGraphWorld")
    if not self.CurrentInputMappingContext then
      self.CurrentInputMappingContext = self.Panel:AddInputMappingContext("IMC_PhotoGraphWorld")
    else
      self.CurrentInputMappingContext:EnableInputMappingContext()
    end
    self.CurrentInputMappingContext:BindAction("IA_PgTripodToWorld", self.Panel, "OnPcTripodToWorld", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWorldToTripod", self.Panel, "OnPcWorldToTripod", UE.ETriggerEvent.Triggered)
  elseif self.Panel.CurrMode.Mgr:IsSelfieMode() then
    self.CurrentInputMappingContext = self.Panel:GetInputMappingContext("IMC_PhotoGraphSelf")
    if not self.CurrentInputMappingContext then
      self.CurrentInputMappingContext = self.Panel:AddInputMappingContext("IMC_PhotoGraphSelf")
    else
      self.CurrentInputMappingContext:EnableInputMappingContext()
    end
    self.CurrentInputMappingContext:BindAction("IA_PgTakePhoto", self.Panel, "OnPcTakePhoto", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelUp", self.Panel, "OnPcWheelUp", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgWheelDown", self.Panel, "OnPcWheelDown", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraMouseMove", self.Panel, "OnPcCameraMove", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnter1PMode", self.Panel, "OnPcEnter1PMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterSelfieMode", self.Panel, "OnPcEnterSelfieMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgEnterTripodMode", self.Panel, "OnPcEnterTripodMode", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraMouseMoveStart", self.Panel, "OnPcMouseMoveStart", UE.ETriggerEvent.Triggered)
    self.CurrentInputMappingContext:BindAction("IA_PgCameraMouseMoveEnd", self.Panel, "OnPcMouseMoveEnd", UE.ETriggerEvent.Triggered)
  end
  self:ResetKeys()
end

function WindowsMainPanelAdapter.InitializePCInputs(PanelClass)
  local Functions = {
    "OnPcExit",
    "OnPcTakePhoto",
    "OnPcResetCamera",
    "OnPcOpenSettingUI",
    "OnPcWheelDown",
    "OnPcWheelUp",
    "OnPcCameraMove",
    "OnPcCameraUpStart",
    "OnPcCameraUpEnd",
    "OnPcCameraDownStart",
    "OnPcCameraDownEnd",
    "OnPcCameraLeftEnd",
    "OnPcCameraLeftStart",
    "OnPcCameraRightStart",
    "OnPcCameraRightEnd",
    "OnPcEnter1PMode",
    "OnPcEnterSelfieMode",
    "OnPcEnterTripodMode",
    "OnPcOpenExpression",
    "OnPcOpenAlbum",
    "OnPcTripodToWorld",
    "OnPcWorldToTripod",
    "OnPcMouseMoveStart",
    "OnPcMouseMoveEnd"
  }
  for _, Name in pairs(Functions) do
    if WindowsMainPanelAdapter[Name] then
      PanelClass[Name] = function(Panel, ...)
        return WindowsMainPanelAdapter[Name](Panel.Adapter, ...)
      end
    end
  end
end

function WindowsMainPanelAdapter:ResetKeys()
  self:OnPcCameraDownEnd()
  self:OnPcCameraUpEnd()
  self:OnPcCameraLeftEnd()
  self:OnPcCameraRightEnd()
end

function WindowsMainPanelAdapter:OnPcExit()
  if self.Panel.SettingPanelProxy.Adapter:IsOpened() then
    self.Panel.SettingPanelProxy.Adapter:Close()
    return
  end
  self.Panel:OnReqClose()
end

function WindowsMainPanelAdapter:OnPcCameraUpStart()
  self.Panel._TripodControlPad._BtnTripodUpOperation.btnLevelUp.OnPressed:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraUpEnd()
  self.Panel._TripodControlPad._BtnTripodUpOperation.btnLevelUp.OnReleased:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraDownStart()
  self.Panel._TripodControlPad._BtnTripodDownOperation.btnLevelUp.OnPressed:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraDownEnd()
  self.Panel._TripodControlPad._BtnTripodDownOperation.btnLevelUp.OnReleased:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraLeftStart()
  self.Panel._TripodControlPad._BtnTripodLeftOperation.btnLevelUp.OnPressed:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraLeftEnd()
  self.Panel._TripodControlPad._BtnTripodLeftOperation.btnLevelUp.OnReleased:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraRightStart()
  self.Panel._TripodControlPad._BtnTripodRightOperation.btnLevelUp.OnPressed:Broadcast()
end

function WindowsMainPanelAdapter:OnPcCameraRightEnd()
  self.Panel._TripodControlPad._BtnTripodRightOperation.btnLevelUp.OnReleased:Broadcast()
end

function WindowsMainPanelAdapter:OnPcEnterTripodMode()
  self.Panel:OnReqTripod()
end

function WindowsMainPanelAdapter:OnPcEnterSelfieMode()
  self.Panel:OnReqSelfie()
end

function WindowsMainPanelAdapter:OnPcEnter1PMode()
  self.Panel:OnReq1PHand()
end

function WindowsMainPanelAdapter:OnPcOpenAlbum()
  self.Panel:OnReqOpenAlbum()
end

function WindowsMainPanelAdapter:OnPcOpenExpression()
end

function WindowsMainPanelAdapter:OnPcTripodToWorld()
  self.Panel:OnReqTripodToWorld()
end

function WindowsMainPanelAdapter:OnPcWorldToTripod()
  self.Panel:OnReqWorldToTripod()
end

function WindowsMainPanelAdapter:OnPcCameraMove(fVectorValue)
  if not UE4Helper.IsPCMode() then
    return
  end
  local dir = UE.FVector2D(fVectorValue.X * 0.45, -fVectorValue.Y * 0.06)
  local Mode = self.Panel.CurrMode
  if Mode then
    if Mode.Mgr:IsTripodMode() then
      Mode.Mgr.TakePhotosModeTripod:OnInputTurn(dir)
    elseif Mode.Mgr:IsSelfieMode() then
      Mode.Mgr.TakePhotosModeSelfie:OnInputTurn(dir, fVectorValue)
    end
  end
end

function WindowsMainPanelAdapter:OnPcMouseMoveStart()
  local Mode = self.Panel.CurrMode
  if Mode and Mode.Mgr:IsSelfieMode() then
    Mode.Mgr.TakePhotosModeSelfie:OnToggleMouseMoveStatus(true)
  end
end

function WindowsMainPanelAdapter:OnPcMouseMoveEnd()
  local Mode = self.Panel.CurrMode
  if Mode and Mode.Mgr:IsSelfieMode() then
    Mode.Mgr.TakePhotosModeSelfie:OnToggleMouseMoveStatus(false)
  end
end

function WindowsMainPanelAdapter:OnPcOpenSettingUI()
  self.Panel.SettingPanelProxy:OnReqOpen()
end

function WindowsMainPanelAdapter:OnPcResetCamera()
  self.Panel:OnReqReset()
end

function WindowsMainPanelAdapter:OnPcTakePhoto()
  self.Panel:OnReqTakePhoto()
end

function WindowsMainPanelAdapter:OnPcWheelDown()
  local Mode = self.Panel.CurrMode
  if not Mode or Mode.Mgr:IsWorldMode() then
    return
  end
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local hasOptions = false
  if mainUIModule then
    local npcInteractPanel = mainUIModule:GetPanel("NPCInteractMain")
    hasOptions = npcInteractPanel and npcInteractPanel.GetShowOptionNum and npcInteractPanel:GetShowOptionNum() > 0
  end
  if hasOptions then
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RelationInteractionNext, true)
    return
  end
  local isTaking = self.Panel:IsTakingPhotos()
  if isTaking then
    return
  end
  self.ThisFrameWheelDown = true
end

function WindowsMainPanelAdapter:OnPcWheelUp()
  local Mode = self.Panel.CurrMode
  if not Mode or Mode.Mgr:IsWorldMode() then
    return
  end
  local mainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  local hasOptions = false
  if mainUIModule then
    local npcInteractPanel = mainUIModule:GetPanel("NPCInteractMain")
    hasOptions = npcInteractPanel and npcInteractPanel.GetShowOptionNum and npcInteractPanel:GetShowOptionNum() > 0
  end
  if hasOptions then
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RelationInteractionPrevious, true)
    return
  end
  local isTaking = self.Panel:IsTakingPhotos()
  if isTaking then
    return
  end
  self.ThisFrameWheelUp = true
end

function WindowsMainPanelAdapter:TickFov(Dt)
  local Mode = self.Panel.CurrMode
  if not Mode then
    return
  end
  if not self._pcWheelNum then
    return
  end
  if not self.ThisFrameWheelUp and not self.ThisFrameWheelDown then
    return
  end
  if self.ThisFrameWheelUp then
    self.ThisFrameWheelUp = false
    if self._pcWheelNum > 0 then
      self._pcWheelNum = self._pcWheelNum - 0.5
    end
  end
  if self.ThisFrameWheelDown then
    self.ThisFrameWheelDown = false
    if self._pcWheelNum < self._configSlice then
      self._pcWheelNum = self._pcWheelNum + 0.5
    end
  end
  local Percent = self._pcWheelNum / self._configSlice
  local MiniFov = Mode:GetMiniFov()
  local MaxiFov = Mode:GetMaxiFov()
  local TargetFov = Percent * (MaxiFov - MiniFov) + MiniFov
  self:ChangeModeFov(TargetFov)
end

function WindowsMainPanelAdapter:SyncWheelNum()
  local Mode = self.Panel.CurrMode
  if Mode and not Mode.Mgr:IsWorldMode() then
    local MiniFov = Mode:GetMiniFov()
    local MaxiFov = Mode:GetMaxiFov()
    self._pcWheelNum = (Mode:GetFov() - Mode:GetMiniFov()) / (MaxiFov - MiniFov) * self._configSlice
  end
end

function WindowsMainPanelAdapter:OnTick(Dt)
  self:TickFov(Dt)
  Super.OnTick(self, Dt)
end

return WindowsMainPanelAdapter
