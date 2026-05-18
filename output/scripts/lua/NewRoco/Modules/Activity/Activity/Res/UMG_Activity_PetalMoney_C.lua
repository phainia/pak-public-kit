local UMG_Activity_PetalMoney_C = _G.NRCViewBase:Extend("UMG_Activity_PetalMoney_C")

function UMG_Activity_PetalMoney_C:OnConstruct()
  self:AddButtonListener(self.btn, self.OnClickBtn)
end

function UMG_Activity_PetalMoney_C:OnDestruct()
end

function UMG_Activity_PetalMoney_C:SetPetal(numStr)
  self.TextQuantity:SetText(numStr)
end

function UMG_Activity_PetalMoney_C:SetClickCallback(_caller, _handler)
  self.clickCallback = _G.MakeWeakFunctor(_caller, _handler)
end

function UMG_Activity_PetalMoney_C:SetRedPoint(_key, _extraKey)
  self.RedDot:SetupKey(_key, _extraKey)
end

function UMG_Activity_PetalMoney_C:PlayRewardAnimation(_available)
  if _available then
    self:PlayAnimation(self.select)
  elseif self.rewardAvailable then
    self:PlayAnimationReverse(self.select)
  end
  self.rewardAvailable = _available
end

function UMG_Activity_PetalMoney_C:OnClickBtn()
  if self.clickCallback then
    self.clickCallback()
  end
end

return UMG_Activity_PetalMoney_C
