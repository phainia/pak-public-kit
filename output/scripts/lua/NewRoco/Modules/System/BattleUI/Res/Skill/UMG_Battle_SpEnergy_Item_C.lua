local UMG_Battle_SpEnergy_Item_C = _G.NRCPanelBase:Extend("UMG_Battle_SpEnergy_Item_C")

function UMG_Battle_SpEnergy_Item_C:OnConstruct()
  self.StackNum = 0
  self.StackInUI = 0
  self.isRemove = false
end

function UMG_Battle_SpEnergy_Item_C:OnDestruct()
  self.parentList = nil
end

function UMG_Battle_SpEnergy_Item_C:ResetAnimParam()
  self.shouldPlayClose = false
  self.shouldPlayTrigger = false
end

function UMG_Battle_SpEnergy_Item_C:InitByData(spEnergyList, spEnergyElement)
  self.parentList = spEnergyList
  self.dam_type = spEnergyElement.dam_type
  self.isRemove = false
  self.isPlayingAnim = false
  self.isToHalf = false
  self:SetStack(1)
  self:ResetAnimParam()
  self:SetIcon(spEnergyElement.dam_type)
  self:StopAllAnimations()
  self:PlayAnim(self.open)
end

function UMG_Battle_SpEnergy_Item_C:SetServerPos(posNumber)
  self.PosInServer = posNumber
end

function UMG_Battle_SpEnergy_Item_C:SetIcon(damageType)
  self:TypeChange(damageType)
  local typeDic = _G.DataConfigManager:GetTypeDictionary(damageType)
  if typeDic then
    self.SpEnergyImage:SetPath(typeDic.field_res)
    self.SpEnergyImage_1:SetPath(typeDic.field_res)
  end
end

function UMG_Battle_SpEnergy_Item_C:AddEnergy(stackNumber)
  self.StackNum = stackNumber
  if not self:IsAnimationPlaying(self.close) then
    self:SetStack(self.StackNum)
    self:PlayAnim(self.add)
  end
end

function UMG_Battle_SpEnergy_Item_C:DecreaseEnergy(stackNumber)
  self.StackNum = stackNumber
  if not self:IsAnimationPlaying(self.close) then
    self:SetStack(self.StackNum)
    self:PlayAnim(self.sub)
  end
end

function UMG_Battle_SpEnergy_Item_C:Remove()
  self.isRemove = true
  if not self:IsAnimationPlaying(self.close) then
    self:PlayAnim(self.close)
  else
    self.shouldPlayClose = true
  end
end

function UMG_Battle_SpEnergy_Item_C:Trigger()
  if not self:IsAnimationPlaying(self.close) then
    self:PlayAnim(self.stock)
  else
    self.shouldPlayTrigger = true
  end
end

function UMG_Battle_SpEnergy_Item_C:PlayAnim(InAnimation)
  self.isPlayingAnim = true
  if self.isToHalf then
    self.isToHalf = false
    self:StopAnimation(self.toHalf)
  end
  self.ParentCanvas:SetRenderOpacity(1)
  self:PlayAnimation(InAnimation)
end

function UMG_Battle_SpEnergy_Item_C:PlayNextAnim()
  if self.shouldPlayClose then
    self:PlayAnim(self.close)
  elseif self.shouldPlayTrigger then
    self:PlayAnim(self.stock)
  elseif self.StackInUI < self.StackNum then
    self:SetStack(self.StackNum)
    self:PlayAnim(self.sub)
  elseif self.StackInUI > self.StackNum then
    self:SetStack(self.StackNum)
    self:PlayAnim(self.add)
  else
    self:ToHalfAlpha()
  end
  self:ResetAnimParam()
end

function UMG_Battle_SpEnergy_Item_C:ToHalfAlpha()
  if not self.isPlayingAnim and self.parentList then
    if self.parentList.isHalfAlpha then
      if not self.isToHalf and 1 == self.ParentCanvas:GetRenderOpacity() then
        self.isToHalf = true
        self:PlayAnimation(self.toHalf)
      end
    elseif not self.isToHalf then
      self.ParentCanvas:SetRenderOpacity(1)
    end
  end
end

function UMG_Battle_SpEnergy_Item_C:SetStack(stackNumber)
  self.StackNum = stackNumber
  self.StackInUI = stackNumber
  if stackNumber <= 0 then
    self:SetNumber(0)
  else
    self:SetNumber(self.StackNum)
  end
end

function UMG_Battle_SpEnergy_Item_C:OnAnimationFinished(animation)
  if not self:IsValid() then
    self:LogError("OnAnimationFinished panel is destroyed")
    return
  end
  if animation == self.close then
    if self.isRemove then
      self:RemoveFromParent()
    end
  elseif animation ~= self.toHalf then
    self.isPlayingAnim = false
    self:PlayNextAnim()
  elseif animation == self.toHalf and self.isToHalf then
    self.isToHalf = false
    if self.parentList and not self.parentList.isHalfAlpha then
      self:ToHalfAlpha()
    end
  end
end

return UMG_Battle_SpEnergy_Item_C
