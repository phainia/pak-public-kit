local UMG_Tempreture_Hot_C = _G.NRCPanelBase:Extend("UMG_Tempreture_Hot_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TemperatureEnum = require("NewRoco.Modules.Core.Scene.Component.Temperature.TemperatureEnum")

function UMG_Tempreture_Hot_C:OnConstruct()
end

function UMG_Tempreture_Hot_C:OnDestruct()
end

function UMG_Tempreture_Hot_C:OnActive()
  self:DoCustomOpen()
end

function UMG_Tempreture_Hot_C:OnDeactive()
end

function UMG_Tempreture_Hot_C:OnEnable()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:SendEvent(PlayerModuleEvent.ON_BODY_TEMP_STATE_CHANGED, TemperatureEnum.BodyState.HOT)
end

function UMG_Tempreture_Hot_C:OnDisable()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:SendEvent(PlayerModuleEvent.ON_BODY_TEMP_STATE_CHANGED, TemperatureEnum.BodyState.NORMAL)
  end
end

function UMG_Tempreture_Hot_C:DoCustomOpen()
  self:StopAllAnimations()
  self:PlayAnimation(self.HotOpen)
  self:PlayAnimation(self.HotLoop, 0, 0)
  self:OnEnable()
end

function UMG_Tempreture_Hot_C:DoCustomClose()
  self:StopAllAnimations()
  self:PlayAnimation(self.HotClose)
end

function UMG_Tempreture_Hot_C:OnAnimationFinished(Animation)
  if Animation == self.HotClose then
    self:DoClose()
  end
end

return UMG_Tempreture_Hot_C
