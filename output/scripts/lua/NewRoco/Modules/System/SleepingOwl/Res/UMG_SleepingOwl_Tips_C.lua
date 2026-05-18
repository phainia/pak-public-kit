local UMG_SleepingOwl_Tips_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Tips_C")

function UMG_SleepingOwl_Tips_C:OnActive(content)
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:LoadAnimation(0)
  self:AddButtonListener(self.HotArea, self.OnClose)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(content.BagItem.id)
  local PetFruitConf = _G.DataConfigManager:GetOwlPetFruitConf(content.BagItem.id)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(content.PetBaseId)
  local itemName = bagItemConf.name
  local itemDesc = bagItemConf.description
  local isHaveBook, fruitItemName, fruitItemDesc = _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdCheckItemInHandbook, content.BagItem.id)
  if isHaveBook then
    itemName = fruitItemName
    itemDesc = fruitItemDesc
  end
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
  self.TitleText:SetText(itemName)
  self.Type:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.OwnedText:SetText(content.BagItem.num)
  self.ContentText:SetText(itemDesc)
  self.FruitItem1:OnItemUpdate(PetBaseConf)
  self.NRCText_43:SetText(bagItemConf.type_desc)
  self.Hint:SetText(_G.DataConfigManager:GetLocalizationConf("pet_fruit_review_title").msg)
  if content.pet_form_factor_tag ~= nil and nil ~= next(content.pet_form_factor_tag) then
    for i = 1, #content.pet_form_factor_tag do
      if content.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
        self.Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local factor_desc
        for j = 1, #PetFruitConf.pet_refresh do
          if PetFruitConf.pet_refresh[j].pet_form_factor_tag == content.pet_form_factor_tag[i] then
            factor_desc = PetFruitConf.pet_refresh[j].factor_desc
          end
        end
        self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_change_preview").msg, factor_desc))
        break
      end
      if i == #content.pet_form_factor_tag then
        self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 1 == content.type then
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if content.BagItem.fruit_active_timestamp then
    local isNotCd, timeStr = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnGetFruitCd, content.BagItem.fruit_active_timestamp)
    self.Countdown:SetVisibility(isNotCd and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MaxLevelHint_1:SetText(string.format(LuaText.fruit_CD, timeStr))
    self.seconds = self.module:GetActiveCountdown(content.BagItem.fruit_active_timestamp) - 1
    if self.seconds > 0 then
      self:OnUpdateTime()
    end
  end
end

function UMG_SleepingOwl_Tips_C:OnUpdateTime()
  self:DelaySeconds(1, function()
    self.seconds = self.seconds - 1
    local str = self.module:GetCdStr(self.seconds)
    self.Countdown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MaxLevelHint_1:SetText(string.format(LuaText.fruit_CD, str))
    if self.seconds > 0 then
      self:OnUpdateTime()
    else
      self:CancelDelay()
      self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end, self)
end

function UMG_SleepingOwl_Tips_C:OnDeactive()
  self:RemoveButtonListener(self.HotArea)
  self:CancelDelay()
end

function UMG_SleepingOwl_Tips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Common_Tips_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_SleepingOwl_Tips_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self.module.NourishTipsOpen = false
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_SleepingOwl_Tips_C
