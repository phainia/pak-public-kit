local CampingModuleEvent = require("NewRoco.Modules.System.Camping.CampingModuleEvent")
local UMG_Nourish_Fruit_C = _G.NRCPanelBase:Extend("UMG_Nourish_Fruit_C")

function UMG_Nourish_Fruit_C:OnActive(ItemData, campfire)
  self.Title:SetText(_G.DataConfigManager:GetLocalizationConf("pet_fruit_bag_title").msg)
  self.MaxLevelHint_1:SetText(_G.DataConfigManager:GetLocalizationConf("pet_fruit_bag_use_tips").msg)
  self.NoFruitText:SetText(_G.DataConfigManager:GetLocalizationConf("have_no_pet_fruit_tips").msg)
  self.campfire = campfire
  self.SelectItemIndex = nil
  self.CanDropOff = true
  self:RefreshPanel(ItemData)
  self:OnAddEventListener()
  self:PlayAnimation(self.Select_In)
  self.IsSelectIn = true
end

function UMG_Nourish_Fruit_C:PlaySelectInAnimation()
  if self.IsSelectIn then
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.IsSelectIn = true
  self:PlayAnimation(self.Select_In)
end

function UMG_Nourish_Fruit_C:OnDeactive()
  self:RemoveEventListener()
end

function UMG_Nourish_Fruit_C:RefreshPanel(ItemData)
  self.ItemData = ItemData
  local PetFruitList = self.module:GetPetFruitList()
  Log.Dump(PetFruitList, 6, "self.module:GetPetFruitList()")
  self.List:Clear()
  if PetFruitList and #PetFruitList >= 1 then
    self.List:ClearSelection()
    self.List:InitGridView(PetFruitList)
  end
  if self.ItemData then
    self.PanelSwitcher:SetActiveWidgetByWidgetName("Property")
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local Time = self.module:GetFruitCountDownTime()
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.ItemData.BagItemId)
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.ItemData.PetBaseId)
    local PetFruitConf = _G.DataConfigManager:GetPetFruitConf(self.ItemData.BagItemId)
    if Time and Time > 0 then
      self.BtnSwitcher:SetActiveWidgetByWidgetName("Time")
      local days = math.floor(Time / 60 / 60 / 24)
      local hours = math.floor((Time - days * 24 * 3600) / 3600)
      local minutes = math.floor((Time - days * 24 * 3600 - hours * 3600) / 60)
      if days > 0 then
        self.MaxLevelHint:SetText(days .. LuaText.umg_nourish_fruit_1 .. hours .. LuaText.umg_nourish_fruit_2)
      else
        self.MaxLevelHint:SetText(hours .. LuaText.umg_nourish_fruit_3 .. minutes .. LuaText.umg_nourish_fruit_4)
      end
    else
      self.BtnSwitcher:SetActiveWidgetByWidgetName("Dropoff")
    end
    if 2 ~= self.ItemData.AdvantageType then
      self.Switcher_175:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if 3 ~= self.ItemData.AdvantageType then
        self.Switcher_175:SetActiveWidgetIndex(1)
      else
        self.Switcher_175:SetActiveWidgetIndex(0)
      end
    else
      self.Switcher_175:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.Name:SetText(BagItemConf.name)
    self.NRCImage_101:SetPath(BagItemConf.icon)
    self.Describe:SetText(BagItemConf.description)
    self.FruitItem1:OnItemUpdate(PetBaseConf)
    for i = 1, #self.ItemData.pet_form_factor_tag do
      if self.ItemData.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
        self.Factor:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local factor_desc
        for j = 1, #PetFruitConf.pet_refresh do
          if PetFruitConf.pet_refresh[j].pet_form_factor_tag == self.ItemData.pet_form_factor_tag[i] then
            factor_desc = PetFruitConf.pet_refresh[j].factor_desc
          end
        end
        self.MaxLevelHint1:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_change_preview").msg, factor_desc, PetBaseConf.form))
        break
      end
      if i == #self.ItemData.pet_form_factor_tag then
        self.Factor:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  elseif PetFruitList and #PetFruitList >= 1 then
    self.PanelSwitcher:SetActiveWidgetByWidgetName("FruitList")
    self.BtnSwitcher:SetActiveWidgetByWidgetName("Select")
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.PanelSwitcher:SetActiveWidgetByWidgetName("ForOwning")
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Nourish_Fruit_C:SetSelectFruitItemIndex(Index, ItemData)
  if 1 == ItemData.type then
    self.Btn_PutIn:SetClickAble(false)
  else
    self.Btn_PutIn:SetClickAble(true)
  end
  self.SelectItemIndex = Index
  self.BtnSwitcher:SetActiveWidgetByWidgetName("Fruit")
  self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Nourish_Fruit_C:SetTimeDownText()
  if self.ItemData then
    local Time = self.module:GetFruitCountDownTime()
    if Time and Time > 0 then
      self.BtnSwitcher:SetActiveWidgetByWidgetName("Time")
      local days = math.floor(Time / 60 / 60 / 24)
      local hours = math.floor((Time - days * 24 * 3600) / 3600)
      local minutes = math.floor((Time - days * 24 * 3600 - hours * 3600) / 60)
      if days > 0 then
        self.MaxLevelHint:SetText(days .. LuaText.umg_nourish_fruit_1 .. hours .. LuaText.umg_nourish_fruit_2)
      else
        self.MaxLevelHint:SetText(hours .. LuaText.umg_nourish_fruit_3 .. minutes .. LuaText.umg_nourish_fruit_4)
      end
    else
      self.BtnSwitcher:SetActiveWidgetByWidgetName("Dropoff")
    end
  end
end

function UMG_Nourish_Fruit_C:OnAddEventListener()
  self:AddButtonListener(self.backBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.Btn_PutIn.btnLevelUp, self.OnPutInBtnClick)
  self:AddButtonListener(self.Btn_Dropoff.btnLevelUp, self.OnDropOffBtnClick)
end

function UMG_Nourish_Fruit_C:RemoveEventListener()
  self:RemoveButtonListener(self.backBtn.btnClose, self.OnCloseBtnClick)
  self:RemoveButtonListener(self.Btn_PutIn.btnLevelUp, self.OnPutInBtnClick)
  self:RemoveButtonListener(self.Btn_Dropoff.btnLevelUp, self.OnDropOffBtnClick)
end

function UMG_Nourish_Fruit_C:OnPutInBtnClick()
  if not self.campfire then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OpenNourishHintPanel, true)
end

function UMG_Nourish_Fruit_C:OnDropOffBtnClick()
  if not self.campfire then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.OpenNourishHintPanel, false)
end

function UMG_Nourish_Fruit_C:OnCloseBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1007, "CampingModule:OpenNourishRightFruit")
  if self:IsAnimationPlaying(self.Select_In) or self:IsAnimationPlaying(self.Select_Out) then
    return
  end
  self.IsSelectIn = false
  self:DispatchEvent(CampingModuleEvent.ShowCloseNourishBtn, true)
  self:PlayAnimation(self.Select_Out)
end

function UMG_Nourish_Fruit_C:OnAnimationFinished(anim)
  if anim == self.Select_Out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if anim == self.Select_In and 0 == self.PanelSwitcher:GetActiveWidgetIndex() then
    self.module:LogNotConfPetFruit()
  end
end

return UMG_Nourish_Fruit_C
