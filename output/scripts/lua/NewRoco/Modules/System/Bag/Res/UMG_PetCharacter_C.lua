local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_PetCharacter_C = _G.NRCPanelBase:Extend("UMG_PetCharacter_C")

function UMG_PetCharacter_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_PetCharacter_C:OnDestruct()
end

function UMG_PetCharacter_C:OnActive(_SelectItem)
  self.BagItem = _SelectItem
  self.data = self.module:GetData("BagModuleData")
  self:InitPanel()
  self:SetItemList()
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_PetCharacter_C:InitPanel()
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  if BagItemConf.item_behavior[1].ratio[1] then
    local allTextStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChoose_Gold").msg
    self.CanDoubleChange = true
    self.PopUp3:SetDescInfo(allTextStr)
  else
    self.CanDoubleChange = false
    local allTextStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChoose_Silver").msg
    self.PopUp3:SetDescInfo(allTextStr)
  end
  local titleIconPath = BagItemConf.icon
  self:SetCommonPopUpInfo(self.PopUp3, BagItemConf.name, titleIconPath)
  if self.data.PetCharacterItem then
    self.PopUp3:SetBtnRightEnableStateNew(true)
  else
    self.PopUp3:SetBtnRightEnableStateNew(false)
  end
end

function UMG_PetCharacter_C:SetItemList()
  local petinfolist = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  self.GridView:InitGridView(petinfolist)
  if petinfolist and #petinfolist > 0 then
    for i, _ in ipairs(petinfolist) do
      local Item = self.GridView:GetItemByIndex(i - 1)
      Item:SetParent(self)
      if self.data.PetCharacterItem and self.data.PetCharacterItem.gid == Item.data.gid then
        self.GridView:SelectItemByIndex(i - 1)
      end
    end
  end
end

function UMG_PetCharacter_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClose
  CommonPopUpData.Btn_RightHandler = self.OnOK
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PetCharacter_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_PetCharacter_C", self, BagModuleEvent.SetPetCharacterItemCanSelect, self.SetPetCharacterItemCanSelect)
end

function UMG_PetCharacter_C:OnItemSelected(Data)
  self.data.PetCharacterItem = Data
  if self.CanDoubleChange then
    local allTextStr = string.format(_G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChose_Gold").msg, self.data.PetCharacterItem.name)
    self.PopUp3:SetDescInfo(allTextStr)
  else
    local allTextStr = string.format(_G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChose_Silver").msg, self.data.PetCharacterItem.name)
    self.PopUp3:SetDescInfo(allTextStr)
  end
  if self.data.PetCharacterItem then
    self.PopUp3:SetBtnRightEnableStateNew(true)
  else
    self.PopUp3:SetBtnRightEnableStateNew(false)
  end
end

function UMG_PetCharacter_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self.IsOkBtn = false
  self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.PopUp3.FullScreen_Close:SetIsEnabled(false)
  self.GridView:SetItemClickAble(false)
  self:LoadAnimation(2)
end

function UMG_PetCharacter_C:SetPetCharacterItemCanSelect(CanSelect, data)
  self.GridView:SetItemClickAble(CanSelect)
  self.PopUp3.Btn_Left.btnLevelUp:SetIsEnabled(CanSelect)
  self.PopUp3.Btn_Right.btnLevelUp:SetIsEnabled(CanSelect)
  if CanSelect then
    self:OnItemSelected(data)
  end
end

function UMG_PetCharacter_C:OnOK()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_PET_CHANGE_NATURE_EFFECT, true)
  if isBan then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnOK")
  if self.data.PetCharacterItem then
    self.IsOkBtn = true
    self.GridView:SetItemClickAble(false)
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:LoadAnimation(2)
  else
    local tipsStr
    if self.CanDoubleChange then
      tipsStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChoose_Gold").msg
    else
      tipsStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_PetChoose_Silver").msg
    end
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
  end
end

function UMG_PetCharacter_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.IsOkBtn then
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetCharacterPopUp, true)
    else
      self.data.PetCharacterItem = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetCharacterTips, false)
    end
  end
end

function UMG_PetCharacter_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.SetPetCharacterItemCanSelect, self.SetPetCharacterItemCanSelect)
end

return UMG_PetCharacter_C
