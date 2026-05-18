local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local UMG_LoadingUI_C = _G.NRCPanelBase:Extend("UMG_LoadingUI_C")

function UMG_LoadingUI_C:OnConstruct()
  self.curProcess = 0
  self.targetProcess = 0
  self.liveTime = -1
  self.IsClosing = false
end

function UMG_LoadingUI_C:OnDestruct()
end

function UMG_LoadingUI_C:OnActive(content, process, tips, liveTime)
  self:Log("OnActive")
  self:OnEnable()
end

function UMG_LoadingUI_C:OnDeactive()
  self:Log("OnDeactive")
end

function UMG_LoadingUI_C:OnEnable()
  self:Log("OnEnable")
  self.IsClosing = false
  self.curProcess = 0
  self.targetProcess = 0
  self:SetProcess(0)
  if false == _G.GlobalConfig.SetFastLoadingWorldRendering then
    self:ShowBackGround()
  end
  UE4Helper.SetEnableWorldRendering(false)
  self:PlayAnimation(self.Loading, 0, 1, 0, 0.0, false)
end

function UMG_LoadingUI_C:OnDisable()
  self:Log("UMG_LoadingUI_C:OnDisable")
  _G.NRCEventCenter:DispatchEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED)
end

function UMG_LoadingUI_C:SetData(content, process, tips, liveTime)
  self:Log("SetData", content, process, tips, liveTime)
  if _G.GlobalConfig.SetFastLoadingWorldRendering == false then
    self:ShowBackGround()
  end
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.targetProcess = process * 100
  self.IsClosing = false
  if nil ~= liveTime then
    self:DelayClose(liveTime)
  else
    self:StopAnimation(self.Out, 0)
  end
end

function UMG_LoadingUI_C:DelayClose(delayTime)
  self:Log("DelayClose", delayTime)
  delayTime = delayTime or 0
  if not self.IsClosing then
    if delayTime <= 0 then
      delayTime = 0
    else
      self:StopAnimation(self.Out)
    end
    self.liveTime = delayTime
    self.IsClosing = true
  end
end

function UMG_LoadingUI_C:OnTick(deltaTime)
  if self.enableView then
    if self.targetProcess > self.curProcess then
      local delta = (self.targetProcess - self.curProcess) * deltaTime * 0.1
      if self.liveTime < 1 then
        delta = 0.1
      end
      if delta < 1 then
        delta = 1
      end
      self.curProcess = self.curProcess + delta
      if self.curProcess > self.targetProcess then
        self.curProcess = self.targetProcess
      end
    else
      self.curProcess = self.targetProcess
    end
    self:SetProcess(self.curProcess)
    if not self.IsClosing or self.liveTime < -2 then
    elseif self.liveTime < 0 then
      self.liveTime = self.liveTime - deltaTime
      if self.liveTime < -2 then
        self:Log("StopAllAnimations")
        Log.Error("UMG_LoadingUI_C:ClosePanel")
        self.module:ClosePanel("UMG_LoadingUI")
      end
    elseif deltaTime > self.liveTime then
      self:Log("PlayAnimation ResetNiagaraInNewWorld")
      UE4Helper.SetEnableWorldRendering(true)
      self:ResetNiagaraInNewWorld()
      _G.GEMPostManager:GEMPostStepEvent("EnterLoadingEnd")
      self.liveTime = -0.01
    else
      self.liveTime = self.liveTime - deltaTime
    end
  end
end

function UMG_LoadingUI_C:SetProcess(process)
  self:SetAnimationCurrentTime(self.Loading, process * 1.6 / 100)
  self.JinduImg:SetPercent(process / 100)
end

function UMG_LoadingUI_C:ShowBackGround()
end

function UMG_LoadingUI_C:OnAnimationFinished(anima)
  self:Log("OnAnimationFinished", self.IsClosing, anima)
  if anima == self.In and self.IsClosing == false and false == _G.GlobalConfig.SetFastLoadingWorldRendering then
    UE4Helper.SetEnableWorldRendering(false)
  end
end

function UMG_LoadingUI_C:MapLoaded()
  self.mapLoaded = true
end

function UMG_LoadingUI_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if _G.GlobalConfig.DebugOpenUI then
    UE4Helper.SetEnableWorldRendering(true)
    self:DoClose()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_LoadingUI_C
