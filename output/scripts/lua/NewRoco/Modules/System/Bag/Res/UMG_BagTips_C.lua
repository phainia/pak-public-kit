local UMG_BagTips_C = _G.NRCPanelBase:Extend("UMG_BagTips_C")

function UMG_BagTips_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_BagTips_C:OnDestruct()
end

function UMG_BagTips_C:OnActive()
  self.data = self.module:GetData("BagModuleData")
  self.BagItem = self.data:GetCurSelectedItemData()
  local text = ""
  if self.BagItem then
    self.BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
    if self.BagItemConf.item_behavior[1].use_action == Enum.ItemBehavior.IB_CHANGE_NATURE_EFFECT then
      text = "\229\143\170\233\128\137\230\139\169\228\186\134\228\184\128\233\161\185\230\128\167\230\160\188\229\189\177\229\147\141\239\188\140\230\152\175\229\144\166\231\161\174\232\174\164\228\191\174\230\148\185\239\188\159"
    elseif self.BagItemConf.item_behavior[1].use_action == Enum.ItemBehavior.IB_CHANGE_BLOOD_BOSS or self.data.ChangeBlood and self.data.ChangeBlood >= Enum.PetBloodType.PBT_BOSS then
      text = "\231\178\190\231\129\181\232\142\183\229\190\151\233\166\150\233\162\134\232\161\128\232\132\137\229\144\142\229\176\134<span color=\"#af3d3eff\">\228\184\141\232\131\189\229\134\141\228\191\174\230\148\185</>\228\184\186\229\133\182\228\187\150\232\161\128\232\132\137"
    end
  end
  self.text_1:SetText(text)
  self:OnAddEventListener()
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo(self.PopUp3)
  self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_BagTips_C:OnDeactive()
end

function UMG_BagTips_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
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

function UMG_BagTips_C:OnAddEventListener()
end

function UMG_BagTips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
  self:SetBtnVisible(false)
end

function UMG_BagTips_C:SetBtnVisible(visible)
  if not visible then
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_BagTips_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:SetBtnVisible(true)
    _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.BagTips, false)
  end
end

function UMG_BagTips_C:OnOK()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
  if self.BagItemConf.item_behavior[1].use_action == Enum.ItemBehavior.IB_CHANGE_NATURE_EFFECT then
    self.module:ChangePetCharacterSuccess()
  elseif self.BagItemConf.item_behavior[1].use_action == Enum.ItemBehavior.IB_CHANGE_BLOOD_BOSS or self.data.ChangeBlood and self.data.ChangeBlood >= Enum.PetBloodType.PBT_BOSS then
    self.module:ChangePetBloodSuccess()
  end
end

return UMG_BagTips_C
