local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BagBright_C = _G.NRCPanelBase:Extend("UMG_BagBright_C")

function UMG_BagBright_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_BagBright_C:OnDestruct()
end

function UMG_BagBright_C:OnActive(BagItem, PetTalentList)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    self:SetCommonPopUpInfo(self.PopUp3, "", "")
    return
  end
  self.petList = PetTalentList
  self.BagItem = BagItem
  self.data = self.module:GetData("BagModuleData")
  self:OnAddEventListener()
  if self.BagItem then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
    self.UseAction = bagItemConf.item_behavior[1].use_action
    self:SetCommonPopUpInfo(self.PopUp3, bagItemConf.name, bagItemConf.icon)
  end
  self.GridView:InitGridView(self.petList)
  if self.petList and #self.petList > 0 then
    for i, _ in ipairs(self.petList) do
      local Item = self.GridView:GetItemByIndex(i - 1)
      Item:SetParent(self)
      if self.data.PetTalentItem and self.data.PetTalentItem.gid == Item.data.gid then
        self.GridView:SelectItemByIndex(i - 1)
      end
    end
  end
  if self.data.PetTalentItem then
    local allTextStr = string.format(LuaText.talent_change_pet_choose, self.data.PetTalentItem.name)
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      allTextStr = string.format(LuaText.talent_improve_pet_choose, self.data.PetTalentItem.name)
    end
    self.PopUp3:SetDescInfo(allTextStr)
    self.PopUp3:SetBtnRightEnableStateNew(true)
  elseif self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    self.PopUp3:SetDescInfo(LuaText.talent_improve_talent_choose)
    self.PopUp3:SetBtnRightEnableStateNew(false)
  else
    self.PopUp3:SetDescInfo(LuaText.change_attribute_select_tip)
    self.PopUp3:SetBtnRightEnableStateNew(false)
  end
  self:LoadAnimation(0)
end

function UMG_BagBright_C:BtnCloseClick()
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_BagBright_C:SetPetTalentItemCanSelect(CanSelect, data)
  self.GridView:SetItemClickAble(CanSelect)
  self.PopUp3.Btn_Left.btnLevelUp:SetIsEnabled(CanSelect)
  self.PopUp3.Btn_Right.btnLevelUp:SetIsEnabled(CanSelect)
  if CanSelect then
    self:OnItemSelected(data)
  end
end

function UMG_BagBright_C:OnItemSelected(Data)
  self.data.PetTalentItem = Data
  local allTextStr = string.format(LuaText.talent_change_pet_choose, self.data.PetTalentItem.name)
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    allTextStr = string.format(LuaText.talent_improve_pet_choose, self.data.PetTalentItem.name)
  end
  self.PopUp3:SetDescInfo(allTextStr)
  self.PopUp3:SetBtnRightEnableStateNew(true)
end

function UMG_BagBright_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.SetPetTalentItemCanSelect, self.SetPetTalentItemCanSelect)
end

function UMG_BagBright_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    if self.IsOkBtn then
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.TalentPopup, true)
    else
      self.data.PetTalentItem = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.BagBright, false)
    end
  end
end

function UMG_BagBright_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.BtnCloseClick
  CommonPopUpData.Btn_RightHandler = self.OnOK
  CommonPopUpData.ClosePanelHandler = self.BtnCloseClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_BagBright_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_BagBright_C", self, BagModuleEvent.SetPetTalentItemCanSelect, self.SetPetTalentItemCanSelect)
end

function UMG_BagBright_C:OnOK()
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_IMPROVE_TALENT, true)
    if isBan then
      return
    end
  else
    local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_CHANGE_TALENT, true)
    if isBan then
      return
    end
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnOK")
  if self.data.PetTalentItem then
    self.IsOkBtn = true
    self.GridView:SetItemClickAble(false)
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:LoadAnimation(2)
  else
    local tipsStr = LuaText.change_attribute_select_pet_tip
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      tipsStr = LuaText.talent_improve_pet_not_choose
    end
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
  end
end

return UMG_BagBright_C
