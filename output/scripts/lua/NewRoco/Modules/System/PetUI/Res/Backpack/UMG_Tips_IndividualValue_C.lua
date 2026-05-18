local UMG_Tips_IndividualValue_C = _G.NRCPanelBase:Extend("UMG_Tips_IndividualValue_C")

function UMG_Tips_IndividualValue_C:OnActive(name)
  self.NRCText:SetText(name)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002013, "UMG_Tips_IndividualValue_C:OnActive")
  self.NRCText_76:SetText(LuaText.filter_attribute_list)
  local des = string.format(LuaText.pet_statistics_talent_description, name)
  self.ChangeCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ChangeText:SetText(des)
  self:LoadAnimation(0)
end

function UMG_Tips_IndividualValue_C:OnDeactive()
end

function UMG_Tips_IndividualValue_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnClickbtnCloseTips)
end

function UMG_Tips_IndividualValue_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Tips_IndividualValue_C:OnDestruct()
end

function UMG_Tips_IndividualValue_C:OnAnimationFinished(anim)
end

function UMG_Tips_IndividualValue_C:OnClickbtnCloseTips()
  self:LoadAnimation(2)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002014, "UMG_Tips_IndividualValue_C:OnClickbtnCloseTips")
end

function UMG_Tips_IndividualValue_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Tips_IndividualValue_C
