local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local UMG_Ability_DimoDash_C = _G.NRCUmgClass:Extend("UMG_Ability_DimoDash_C")

function UMG_Ability_DimoDash_C:Construct()
  self.Btn_Slot.OnPressed:Add(self, self.OnSlotPressed)
  self.Btn_Slot.OnClicked:Add(self, self.OnSlotClicked)
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_DimoDash_C", self, CreatePlayerEvent.PlayerStopDash, self.OnStopDash)
end

function UMG_Ability_DimoDash_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, CreatePlayerEvent.PlayerStopDash, self.OnStopDash)
end

function UMG_Ability_DimoDash_C:OnSlotClicked()
end

function UMG_Ability_DimoDash_C:OnSlotPressed()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local isDashing = playerModule.playerActor.bIsDashing
  if not isDashing then
    playerModule.playerActor:StartDash()
    isDashing = playerModule.playerActor.bIsDashing
    if isDashing then
      _G.NRCEventCenter:DispatchEvent(CreatePlayerEvent.PlayerDash)
      self:PlayAnimation(self.isDashing)
    else
      self:PlayAnimation(self.press)
    end
  else
    playerModule.playerActor:StopDash()
  end
end

function UMG_Ability_DimoDash_C:OnStopDash()
  self:StopAllAnimations()
  self:PlayAnimation(self.stopDashing)
end

function UMG_Ability_DimoDash_C:OnAnimationFinished(anim)
  if anim == self.isDashing then
    self:PlayAnimation(self.DashingLoop, nil, 99999)
  end
end

return UMG_Ability_DimoDash_C
