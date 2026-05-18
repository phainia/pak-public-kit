local UMG_NightmareSettlement_C = _G.NRCPanelBase:Extend("UMG_NightmareSettlement_C")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")

function UMG_NightmareSettlement_C:OnActive()
  self.Module = NRCModuleManager:GetModule("MiniGameModule")
  self.Module:RegisterEvent(self, MiniGameModuleEvent.End, self.OnEnd)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_NightmareSettlement_C:OnDeactive()
  if self.Module then
    self.Module:UnRegisterEvent(self, MiniGameModuleEvent.End)
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_NightmareSettlement_C:OnAnimationFinished(anim)
  if anim == self.Purification_Complete then
    self:DoClose()
  end
end

function UMG_NightmareSettlement_C:OnEnd(fail)
  if not fail and self.Module:GetNightmareType() == Enum.MiniGameType.MINIGAME_NIGHTMARE_SPACE then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(self.Purification_Complete)
  end
end

return UMG_NightmareSettlement_C
