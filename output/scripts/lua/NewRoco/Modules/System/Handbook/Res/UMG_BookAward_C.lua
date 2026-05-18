local UMG_BookAward_C = _G.NRCPanelBase:Extend("UMG_BookAward_C")

function UMG_BookAward_C:OnConstruct()
  self.data = self.module:GetData("HandbookModuleData")
  self:OnAddEventListener()
end

function UMG_BookAward_C:OnDestruct()
end

function UMG_BookAward_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnCloseButtonClicked)
end

function UMG_BookAward_C:OnActive()
  self:SetAwardInfo()
  self:PlayAnimation(self.Appear)
end

function UMG_BookAward_C:SetAwardInfo()
  local AwardInfo = self.data:GetAwardInfo()
  self.UpList:InitList(AwardInfo)
end

function UMG_BookAward_C:OnDeactive()
end

function UMG_BookAward_C:OnCloseButtonClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Handbook_C:OnPressRewardsBtn")
  self.btnCloseRenamePanel:SetIsEnabled(false)
  self:PlayAnimation(self.Disappear)
end

function UMG_BookAward_C:OnAnimationFinished(Animation)
  if Animation == self.Disappear then
    self:DoClose()
    self.btnCloseRenamePanel:SetIsEnabled(true)
  end
end

return UMG_BookAward_C
