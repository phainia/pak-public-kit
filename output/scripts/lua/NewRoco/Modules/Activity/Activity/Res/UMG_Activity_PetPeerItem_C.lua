local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_PetPeerItem_C = Base:Extend("UMG_Activity_PetPeerItem_C")

function UMG_Activity_PetPeerItem_C:OnConstruct()
  Base.OnConstruct(self)
  self.activityInst = nil
  self.parentPanel = nil
  self:OnAddEventListeners()
end

function UMG_Activity_PetPeerItem_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
end

function UMG_Activity_PetPeerItem_C:OnAddEventListeners()
  self:AddButtonListener(self.ChoosePetButton, self.OnChoosePetButtonClicked)
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnBtnReceiveClicked)
  self:AddButtonListener(self.AddButton, self.OnBtnAddClicked)
end

function UMG_Activity_PetPeerItem_C:OnEnter()
  self:EnableAnimations(true)
  self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#d56c1fff"))
  self:PlayAnimationImmediately(self.In)
end

function UMG_Activity_PetPeerItem_C:OnLeave()
  self:DisableAnimations()
end

function UMG_Activity_PetPeerItem_C:OnItemUpdate(_data, datalist, index)
  Base.OnItemUpdate(self, _data, datalist, index)
  local activityInst = _data.customData
  self.parentPanel = _data.parent
  self.activityInst = activityInst
  if activityInst then
    self:RefreshUI(activityInst)
  end
end

function UMG_Activity_PetPeerItem_C:RefreshUI(activityInst)
  local isReachCondition = activityInst:IsActivityLevelOpen()
  local choosePetID, choosePetEggID = activityInst:GetChoosedPetBaseIDAndEggID()
  local isCommited = activityInst:HasReceivedPartnerPetEgg()
  self.Btn3.HorizontalBox_33:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local iconState = UE4.ESlateVisibility.Collapsed
  local chooseBtnState = UE4.ESlateVisibility.Collapsed
  if 0 ~= choosePetID and 0 ~= choosePetEggID then
    iconState = UE4.ESlateVisibility.SelfHitTestInvisible
    chooseBtnState = UE4.ESlateVisibility.Visible
    self:SetIocn(choosePetEggID)
    local name = activityInst:GetSelectPetName(choosePetID, activityInst:IsChooseInheritPet())
    self.Text_Describe_1:SetText(LuaText.PET_Partner_3)
    self.Text_Describe:SetText(name)
    self.ItemSwitcher:SetActiveWidgetIndex(1)
    self.TextSwitcher_1:SetActiveWidgetIndex(1)
    self.BgSwitcher:SetActiveWidgetIndex(0)
  else
    self.Text_Describe:SetText(LuaText.PET_Partner_1)
    self.ItemSwitcher:SetActiveWidgetIndex(0)
    self.TextSwitcher_1:SetActiveWidgetIndex(0)
    self.Text_luoke:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BgSwitcher:SetActiveWidgetIndex(1)
  end
  if isCommited then
    self.Switcher:SetActiveWidgetIndex(3)
    self.Panel_AlreadyReceived:SetVisibility(UE4.ESlateVisibility.selfHitTestInvisible)
    self.Panel_AlreadyReceived:SetRenderOpacity(1)
    self.NRCImage:SetRenderOpacity(1)
    self.NRCImage:SetRenderScale(UE4.FVector2D(0.85, 0.85))
    self.NRCImage_184:SetRenderOpacity(1)
    chooseBtnState = UE4.ESlateVisibility.Collapsed
  else
    self.Panel_AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if isReachCondition then
      if 0 ~= choosePetID and 0 ~= choosePetEggID then
        self.Switcher:SetActiveWidgetIndex(2)
      else
        self.Switcher:SetActiveWidgetIndex(1)
      end
    else
      self.Switcher:SetActiveWidgetIndex(0)
      self.Btn3.Quantity_1:SetText(LuaText.PET_Partner_6)
      self.Btn3.Quantity_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self.Icon:SetVisibility(iconState)
  self.ChoosePetButton:SetVisibility(chooseBtnState)
  self.Btn6.RedDot:SetupKey(446, {
    activityInst:GetActivityId()
  })
  self.RedDot:SetupKey(445, {
    activityInst:GetActivityId()
  })
end

function UMG_Activity_PetPeerItem_C:SetIocn(itemID)
  local bagItemInfo = _G.DataConfigManager:GetBagItemConf(itemID)
  if bagItemInfo then
    self.Icon:SetPath(bagItemInfo.big_icon)
  end
end

function UMG_Activity_PetPeerItem_C:OnChoosePetButtonClicked()
  local isCommited = self.activityInst:HasReceivedPartnerPetEgg()
  if not isCommited then
    _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_Activity_PetPeerItem_C:OnBtnAddClicked")
    _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenSelectPartnerPetPanel, self.activityInst)
  end
end

function UMG_Activity_PetPeerItem_C:OnBtnReceiveClicked()
  if self.parentPanel then
    self.parentPanel:OnBtnReceiveClicked()
  end
end

function UMG_Activity_PetPeerItem_C:OnItemSelected(isSelected)
  local choosePetID, choosePetEggID = self.activityInst:GetChoosedPetBaseIDAndEggID()
  if 0 ~= choosePetID and 0 ~= choosePetEggID then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, choosePetEggID, Enum.GoodsType.GT_BAGITEM, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 5)
  else
    _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenSelectPartnerPetPanel, self.activityInst)
  end
end

function UMG_Activity_PetPeerItem_C:OnBtnAddClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_Activity_PetPeerItem_C:OnBtnAddClicked")
  self:OnItemSelected(true)
end

function UMG_Activity_PetPeerItem_C:OnRefreshItemView()
  self:RefreshUI(self.activityInst)
end

function UMG_Activity_PetPeerItem_C:OnPlayerReceiveAnimation()
  self:PlayAnimationImmediately(self.Reward_get)
end

return UMG_Activity_PetPeerItem_C
