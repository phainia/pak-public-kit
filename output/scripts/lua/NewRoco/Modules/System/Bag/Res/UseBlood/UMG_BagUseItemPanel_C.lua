local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BagUseItemPanel_C = _G.NRCPanelBase:Extend("UMG_BagUseItemPanel_C")

function UMG_BagUseItemPanel_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_BagUseItemPanel_C:OnDestruct()
end

function UMG_BagUseItemPanel_C:OnActive(CurSelectItem, PetList)
  self.petList = PetList
  self.BagItem = CurSelectItem
  self.data = self.module:GetData("BagModuleData")
  self:OnAddEventListener()
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  self:SetCommonPopUpInfo(self.PopUp3, bagItemConf.name, bagItemConf.icon)
  self:LoadAnimation(0)
  self.GridView:InitGridView(self.petList)
  if self.petList and #self.petList > 0 then
    for i, _ in ipairs(self.petList) do
      local Item = self.GridView:GetItemByIndex(i - 1)
      if self.data.PetBloodItem and self.data.PetBloodItem.gid == Item.data.gid then
        self.GridView:SelectItemByIndex(i - 1)
        break
      end
    end
  end
  if not self.data.PetBloodItem then
    self.PopUp3:SetDescInfo("\232\175\183\233\128\137\230\139\169\228\184\128\229\143\170\231\178\190\231\129\181\239\188\140\228\191\174\230\148\185\229\133\182\232\161\128\232\132\137\229\177\158\230\128\167")
    self.PopUp3:SetBtnRightEnableStateNew(false)
  end
  self:BindInputAction()
end

function UMG_BagUseItemPanel_C:BtnCloseClick()
  if self:GetIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BagBlood").CANCEL
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "BagModule", "BagBlood", touchReasonType)
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_BagUseItemPanel_C:SetPetBloodItemSelect(data)
  self:OnItemSelected(data)
end

function UMG_BagUseItemPanel_C:OnItemSelected(Data)
  self.data.PetBloodItem = Data
  local allTextStr = string.format(LuaText.all_nature_blood_pet_choose, self.data.PetBloodItem.name)
  self.PopUp3:SetDescInfo(allTextStr)
  self.PopUp3:SetBtnRightEnableStateNew(true)
end

function UMG_BagUseItemPanel_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.SetPetBloodItemSelect, self.SetPetBloodItemSelect)
end

function UMG_BagUseItemPanel_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
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

function UMG_BagUseItemPanel_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    if self.IsOkBtn then
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.BagBloodPopup, true)
    else
      self.data.PetBloodItem = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.BagBlood, false)
    end
  end
end

function UMG_BagUseItemPanel_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_BagUseItemPanel_C", self, BagModuleEvent.SetPetBloodItemSelect, self.SetPetBloodItemSelect)
end

function UMG_BagUseItemPanel_C:OnOK()
  if self:GetIsSelectBtn() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnOK")
  if self.data.PetBloodItem then
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BagBlood").OK
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "BagModule", "BagBlood", touchReasonType)
    self.IsOkBtn = true
    self.GridView:SetItemClickAble(false)
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:LoadAnimation(2)
  else
    local tipsStr = LuaText.blood_changed_pet_not_choose
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
  end
end

function UMG_BagUseItemPanel_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_BagUseItemPanel")
  if mappingContext then
    mappingContext:BindAction("IA_CloseBagUseItemPanel", self, "OnPcClose2")
  end
end

function UMG_BagUseItemPanel_C:OnPcClose2()
  self:BtnCloseClick()
end

return UMG_BagUseItemPanel_C
