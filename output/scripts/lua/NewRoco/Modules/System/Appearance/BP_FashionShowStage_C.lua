require("UnLuaEx")
local BP_FashionShowStage_C = NRCClass()
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")

function BP_FashionShowStage_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  local bSuccess = false
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    bSuccess = _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowStage", self)
  end
  if not bSuccess and _G.NRCEventCenter then
    _G.NRCEventCenter:RegisterEvent("BP_FashionShowStage_C", self, AppearanceModuleEvent.OnAppearanceModuleActive, self.HandleAppearanceModuleActive)
  end
  if self.BP_GodRayNew_1 and self.BP_GodRayNew_1.ChildActor then
    self.BP_GodRayNew_1.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_1.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_1.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_1, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  if self.BP_GodRayNew_2 and self.BP_GodRayNew_2.ChildActor then
    self.BP_GodRayNew_2.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_2.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_2.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_2, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  if self.BP_GodRayNew_3 and self.BP_GodRayNew_3.ChildActor then
    self.BP_GodRayNew_3.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_3.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_3.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_3, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  if self.BP_GodRayNew_4 and self.BP_GodRayNew_4.ChildActor then
    self.BP_GodRayNew_4.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_4.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_4.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_4, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  if self.BP_GodRayNew_5 and self.BP_GodRayNew_5.ChildActor then
    self.BP_GodRayNew_5.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_5.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_5.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_5, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  if self.BP_GodRayNew_6 and self.BP_GodRayNew_6.ChildActor then
    self.BP_GodRayNew_6.ChildActor:K2_GetRootComponent():SetMobility(UE4.EComponentMobility.Movable)
    self.BP_GodRayNew_6.ChildActor:K2_DetachFromActor()
    self.BP_GodRayNew_6.ChildActor:K2_AttachToComponent(self.BP_GodRayNew_6, "None", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  end
  self.bLightOn = true
end

function BP_FashionShowStage_C:ReceiveEndPlay(endReason)
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowStage", nil)
  end
  if _G.NRCEventCenter then
    _G.NRCEventCenter:UnRegisterEvent(self, AppearanceModuleEvent.OnAppearanceModuleActive, self.HandleAppearanceModuleActive)
  end
  self.Overridden.ReceiveEndPlay(self, endReason)
end

function BP_FashionShowStage_C:HandleAppearanceModuleActive()
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowStage", self)
  end
end

function BP_FashionShowStage_C:TurnOnTheLight()
  if self.bLightOn then
    return
  end
  self.bLightOn = true
  self:BPTurnOnTheLight()
end

function BP_FashionShowStage_C:TurnOffTheLight()
  if not self.bLightOn then
    return
  end
  self.bLightOn = false
  self:BPTurnOffTheLight()
end

return BP_FashionShowStage_C
