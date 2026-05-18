local BigMapModuleEnum = require("NewRoco.Modules.System.BigMap.BigMapModuleEnum")
local UMG_CompItem_Tracking_C = _G.NRCPanelBase:Extend("UMG_CompItem_Tracking_C")

function UMG_CompItem_Tracking_C:OnEnable(traceAniAction, traceAniType)
  if not traceAniAction then
    Log.Error("UMG_CompItem_Tracking_C:OnEnable missing traceAniAction")
    return
  end
  if not traceAniType then
    Log.Error("UMG_CompItem_Tracking_C:OnEnable missing traceAniType")
    return
  end
  if traceAniAction == BigMapModuleEnum.TraceAniAction.Play and traceAniType == BigMapModuleEnum.TraceAniType.TraceLoop then
    self:PlayAnimation(self.TraceLoop, 0, 0)
    return
  end
  local animationFunc, animationName
  if traceAniAction == BigMapModuleEnum.TraceAniAction.Play then
    animationFunc = self.PlayAnimation
  elseif traceAniAction == BigMapModuleEnum.TraceAniAction.Stop then
    animationFunc = self.StopAnimation
  end
  if traceAniType == BigMapModuleEnum.TraceAniType.TraceStart then
    animationName = self.TraceStart
  elseif traceAniType == BigMapModuleEnum.TraceAniType.TraceLoop then
    animationName = self.TraceLoop
  elseif traceAniType == BigMapModuleEnum.TraceAniType.TraceEnd then
    animationName = self.TraceEnd
  end
  if animationFunc and animationName then
    animationFunc(self, animationName)
  end
end

function UMG_CompItem_Tracking_C:OnAnimationFinished(anim)
  if anim == self.TraceStart then
    self:PlayAnimation(self.TraceLoop, 0, 0)
  end
end

return UMG_CompItem_Tracking_C
