local UMG_Nourish_Tips_C = _G.NRCPanelBase:Extend("UMG_Nourish_Tips_C")

function UMG_Nourish_Tips_C:OnActive(content)
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.TweenIn)
  self:AddButtonListener(self.HotArea, self.OnClose)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(content.BagItem.id)
  local PetFruitConf = _G.DataConfigManager:GetPetFruitConf(content.BagItem.id)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(content.PetBaseId)
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
  self.TitleText:SetText(bagItemConf.name)
  self.Type:SetText(bagItemConf.type_desc)
  self.OwnedText:SetText(content.BagItem.num)
  self.ContentText:SetText(bagItemConf.description)
  self.FruitItem1:OnItemUpdate(PetBaseConf)
  self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("pet_fruit_review_title").msg)
  for i = 1, #content.pet_form_factor_tag do
    if content.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
      self.Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local factor_desc
      for j = 1, #PetFruitConf.pet_refresh do
        if PetFruitConf.pet_refresh[j].pet_form_factor_tag == content.pet_form_factor_tag[i] then
          factor_desc = PetFruitConf.pet_refresh[j].factor_desc
        end
      end
      self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_change_preview").msg, factor_desc, PetBaseConf.form))
      break
    end
    if i == #content.pet_form_factor_tag then
      self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if 1 == content.type then
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Nourish_Tips_C:OnDeactive()
  self:RemoveButtonListener(self.HotArea)
end

function UMG_Nourish_Tips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Common_Tips_C:OnClose")
  self:PlayAnimation(self.TweenOut)
end

function UMG_Nourish_Tips_C:OnAnimationFinished(anim)
  if anim == self.TweenOut then
    self.module.NourishTipsOpen = false
    self:DoClose()
  end
end

return UMG_Nourish_Tips_C
