local UMG_Nourish_Hint_C = _G.NRCPanelBase:Extend("UMG_Nourish_Hint_C")

function UMG_Nourish_Hint_C:OnActive(CampFruitItemData, FruitData, placeName, IsPutIn)
  _G.NRCAudioManager:PlaySound2DAuto(1002, "CampingModule:OpenNourishRightFruit")
  self.IsPutIn = IsPutIn
  local FruitCountDownTime = self.module:GetFruitCountDownTime()
  local bagItemConf, petBaseInfo
  if IsPutIn then
    self.data = FruitData
    bagItemConf = _G.DataConfigManager:GetBagItemConf(FruitData.BagItem.id)
    petBaseInfo = _G.DataConfigManager:GetPetbaseConf(FruitData.PetBaseId)
  else
    self.data = CampFruitItemData
    bagItemConf = _G.DataConfigManager:GetBagItemConf(CampFruitItemData.BagItemId)
    petBaseInfo = _G.DataConfigManager:GetPetbaseConf(CampFruitItemData.PetBaseId)
  end
  if self.IsPutIn then
    self.textBuffDesc:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("use_pet_fruit_tips").msg, petBaseInfo.name, placeName, bagItemConf.name))
    if FruitCountDownTime and FruitCountDownTime > 0 then
      local days = math.floor(FruitCountDownTime / 60 / 60 / 24)
      local hours = math.floor((FruitCountDownTime - days * 24 * 3600) / 3600)
      local minutes = math.floor((FruitCountDownTime - days * 24 * 3600 - hours * 3600) / 60)
      if days > 0 then
        self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("use_pet_fruit_inCD_tips").msg, days .. LuaText.umg_nourish_hint_1 .. hours .. LuaText.umg_nourish_hint_2))
      else
        self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("use_pet_fruit_inCD_tips").msg, hours .. LuaText.umg_nourish_hint_3 .. minutes .. LuaText.umg_nourish_hint_4))
      end
    else
    end
  else
    self.textBuffDesc:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_cancel_tips").msg, petBaseInfo.name, tostring(_G.DataConfigManager:GetGlobalConfig("pet_fruit_cancel_CD").num)))
  end
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
end

function UMG_Nourish_Hint_C:SetTimeDownText()
  if self.IsPutIn then
    local Time = self.module:GetFruitCountDownTime()
    if Time and Time > 0 then
      local days = math.floor(Time / 60 / 60 / 24)
      local hours = math.floor((Time - days * 24 * 3600) / 3600)
      local minutes = math.floor((Time - days * 24 * 3600 - hours * 3600) / 60)
      if days > 0 then
        self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("use_pet_fruit_inCD_tips").msg, days .. LuaText.umg_nourish_hint_1 .. hours .. LuaText.umg_nourish_hint_2))
      else
        self.MaxLevelHint:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("use_pet_fruit_inCD_tips").msg, hours .. LuaText.umg_nourish_hint_3 .. minutes .. LuaText.umg_nourish_hint_4))
      end
    else
    end
  end
end

function UMG_Nourish_Hint_C:OnDeactive()
  self:RemoveEventListener()
end

function UMG_Nourish_Hint_C:OnAddEventListener()
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnOKBtnClick)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnCancelBtnClick)
end

function UMG_Nourish_Hint_C:RemoveEventListener()
  self:RemoveButtonListener(self.Btn1.btnLevelUp, self.OnOKBtnClick)
  self:RemoveButtonListener(self.Btn2.btnLevelUp, self.OnCancelBtnClick)
end

function UMG_Nourish_Hint_C:OnOKBtnClick()
  if self.IsPutIn then
    self.module:CmdZonePutFruitInCampReq(self.data.BagItem.id, self.data)
  else
    self.module:CmdZoneTakeFruitOutCampReq(self.data.BagItemId)
  end
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_Hint_C:OnCancelBtnClick()
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_Hint_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:DoClose()
  end
end

return UMG_Nourish_Hint_C
