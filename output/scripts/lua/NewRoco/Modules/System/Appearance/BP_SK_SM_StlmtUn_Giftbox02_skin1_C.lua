require("UnLuaEx")
local BP_SK_SM_StlmtUn_Giftbox02_skin1_C = NRCClass()
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  local bSuccess = false
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    bSuccess = _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowBox", self)
  end
  if not bSuccess and _G.NRCEventCenter then
    _G.NRCEventCenter:RegisterEvent("BP_SK_SM_StlmtUn_Giftbox02_skin1_C", self, AppearanceModuleEvent.OnAppearanceModuleActive, self.HandleAppearanceModuleActive)
  end
  self.SecondBoxDelayId = false
  self.BoxLoopPerformDelayId = false
  self.bPerforming = false
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:ReceiveEndPlay(endReason)
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowBox", nil)
  end
  if _G.NRCEventCenter then
    _G.NRCEventCenter:UnRegisterEvent(self, AppearanceModuleEvent.OnAppearanceModuleActive, self.HandleAppearanceModuleActive)
  end
  self:StopJumpPerform()
  self.Overridden.ReceiveEndPlay(self, endReason)
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:HandleAppearanceModuleActive()
  if _G.NRCModeManager and _G.AppearanceModuleCmd then
    _G.NRCModeManager:DoCmd(_G.AppearanceModuleCmd.RegisterFashionShowPerformBP, "fashionShowBox", self)
  end
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:StartJumpPerform(bNotFirstLoop)
  if not self or not UE.UObject.IsValid(self) then
    return
  end
  if not bNotFirstLoop and self.bPerforming then
    return
  end
  self.bPerforming = true
  self:BoxDoJumpPerform(true)
  if _G.DelayManager then
    if self.SecondBoxDelayId then
      _G.DelayManager:CancelDelayById(self.SecondBoxDelayId)
      self.SecondBoxDelayId = false
    end
    local delayTime = 2
    local config = _G.DataConfigManager:GetRoleGlobalConfig("second_box_delay")
    if config and config.num then
      delayTime = config.num / 1000
    end
    self.SecondBoxDelayId = _G.DelayManager:DelaySeconds(delayTime, self.BoxDoJumpPerform, self, false)
  end
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:StopJumpPerform()
  self.bPerforming = false
  if _G.DelayManager then
    if self.SecondBoxDelayId then
      _G.DelayManager:CancelDelayById(self.SecondBoxDelayId)
      self.SecondBoxDelayId = false
    end
    if self.BoxLoopPerformDelayId then
      _G.DelayManager:CancelDelayById(self.BoxLoopPerformDelayId)
      self.BoxLoopPerformDelayId = false
    end
  end
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:BoxDoJumpPerform(bIsFirstBox)
  if not self or not UE.UObject.IsValid(self) then
    return
  end
  if bIsFirstBox then
    if self.ABP1 and UE.UObject.IsValid(self.ABP1) then
      self.ABP1.IsLoop = true
      self.NS1:SetActive(true, false)
    end
  elseif self.ABP2 and UE.UObject.IsValid(self.ABP2) then
    self.ABP2.IsLoop = true
    self.NS2:SetActive(true, false)
  end
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:OnABPLeaveMoveState(meshComponent)
  if meshComponent == self.Mesh2 then
    self:OnLastBoxFinishJump()
  end
end

function BP_SK_SM_StlmtUn_Giftbox02_skin1_C:OnLastBoxFinishJump()
  if not self.bPerforming then
    return
  end
  if _G.DelayManager then
    if self.BoxLoopPerformDelayId then
      _G.DelayManager:CancelDelayById(self.BoxLoopPerformDelayId)
      self.BoxLoopPerformDelayId = false
    end
    local delayTime = 4
    local config = _G.DataConfigManager:GetRoleGlobalConfig("loop_box_delay")
    if config and config.num then
      delayTime = config.num / 1000
    end
    self.BoxLoopPerformDelayId = _G.DelayManager:DelaySeconds(delayTime, self.StartJumpPerform, self, true)
  end
end

return BP_SK_SM_StlmtUn_Giftbox02_skin1_C
