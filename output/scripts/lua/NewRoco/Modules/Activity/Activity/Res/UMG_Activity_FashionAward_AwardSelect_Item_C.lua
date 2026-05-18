local UMG_Activity_FashionAward_AwardSelect_Item_C = _G.NRCViewBase:Extend("UMG_Activity_FashionAward_AwardSelect_Item_C")

function UMG_Activity_FashionAward_AwardSelect_Item_C:OnConstruct()
  self:AddButtonListener(self.ExamineBtn, self.OnExamineBtnClick)
  self:AddButtonListener(self.ClickBtn, self.OnChoose)
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetName(name)
  self.Name:SetText(name)
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetCharacterImage(characterImage)
  self.CharacterImage:SetPath(characterImage)
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetPetIcon(petIcon)
  self.PetIcon:SetPath(petIcon)
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetAlreadyHave(alreadyHave)
  if alreadyHave then
    self.AlreadyHaveMarker:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(self.Reward_get)
  else
    self.AlreadyHaveMarker:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetSelect(isSelect)
  self:StopAllAnimations()
  if isSelect then
    self:PlayAnimation(self.Selected)
    self:PlayAnimation(self.Selected_Loop, 0, 0)
  else
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetExamineBtnCallback(callback)
  if callback then
    self.examineBtnCallback = callback
    self.ExamineBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ExamineBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:SetSelectCallback(callback)
  self.selectCallback = callback
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:OnExamineBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_FashionAward_AwardSelect_Item_C:OnExamineBtnClick")
  local callback = self.examineBtnCallback
  if callback then
    callback()
  end
end

function UMG_Activity_FashionAward_AwardSelect_Item_C:OnChoose()
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Activity_FashionAward_AwardSelect_Item_C:OnChoose")
  local callback = self.selectCallback
  if callback then
    callback()
  end
end

return UMG_Activity_FashionAward_AwardSelect_Item_C
