local Enum = require("Data.Config.Enum")
local UMG_PetAttribute_C = _G.NRCPanelBase:Extend("UMG_PetAttribute_C")

function UMG_PetAttribute_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_PetAttribute_C:OnDestruct()
end

function UMG_PetAttribute_C:OnActive(bIsFrameItem)
  self.data = self.module:GetData("BagModuleData")
  self.PetItemData = self.data.PetCharacterItem
  self.bIsFrameItem = bIsFrameItem
  if not self.PetItemData then
    Log.Error("\228\184\141\231\159\165\233\129\147\228\187\128\228\185\136\229\142\159\229\155\160\229\175\188\232\135\180PetItemData\230\178\161\228\186\134\239\188\140\232\175\183\230\138\138\230\151\165\229\191\151\230\136\170\229\155\190\229\143\145\231\187\153byzyzhao")
    return
  end
  self:SetCommonPopUpInfo(self.PopUp3)
  self.IsGoodNature = self.data.IsGoodAttributePopUp
  local NumText = self.data.AttributeNumText
  if self.IsGoodNature then
    self.PopUp3:SetTitleTextInfo("\228\191\174\230\148\185\230\128\167\230\160\188\231\154\132\230\173\163\233\157\162\229\189\177\229\147\141")
  else
    self.PopUp3:SetTitleTextInfo("\228\191\174\230\148\185\230\128\167\230\160\188\231\154\132\232\180\159\233\157\162\229\189\177\229\147\141")
  end
  self.PopUp3:SetBtnRightEnableStateNew(false)
  local petNatureConf = _G.DataConfigManager:GetNatureConf(self.PetItemData.nature)
  self.SelectNature = nil
  self.attributeCfg1 = nil
  self.attributeCfg2 = nil
  self.petGoodNature = nil
  self.petBadNature = nil
  if 0 ~= self.PetItemData.changed_nature_pos_attr_type then
    self.petGoodNature = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_pos_attr_type)
  elseif petNatureConf then
    self.petGoodNature = petNatureConf.positive_effect
  end
  if self.data.GoodPetNature then
    self.attributeCfg1 = self.data.GoodPetNature
  else
    self.attributeCfg1 = self.petGoodNature
  end
  if 0 ~= self.PetItemData.changed_nature_neg_attr_type then
    self.petBadNature = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_neg_attr_type)
  elseif petNatureConf then
    self.petBadNature = petNatureConf.negative_effect
  end
  if self.data.BadPetNature then
    self.attributeCfg2 = self.data.BadPetNature
  else
    self.attributeCfg2 = self.petBadNature
  end
  local AttributeList = {
    {
      AttributeType = Enum.AttributeType.AT_HPMAX_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    },
    {
      AttributeType = Enum.AttributeType.AT_PHYATK_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    },
    {
      AttributeType = Enum.AttributeType.AT_SPEATK_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    },
    {
      AttributeType = Enum.AttributeType.AT_PHYDEF_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    },
    {
      AttributeType = Enum.AttributeType.AT_SPEDEF_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    },
    {
      AttributeType = Enum.AttributeType.AT_SPEED_PERCENT,
      IsGoodNature = self.IsGoodNature,
      NumText = NumText,
      petGoodNature = self.petGoodNature,
      petBadNature = self.petBadNature,
      changeGoodNature = self.attributeCfg1,
      changeBadNature = self.attributeCfg2,
      bIsFrameItem = self.bIsFrameItem
    }
  }
  self.SortList:InitGridView(AttributeList)
  for i, _ in ipairs(AttributeList) do
    local Item = self.SortList:GetItemByIndex(i - 1)
    Item:SetParent(self)
    if Item.UiData.AttributeType ~= self.attributeCfg1 or self.IsGoodNature then
    end
    if Item.UiData.AttributeType ~= self.attributeCfg2 or not self.IsGoodNature then
    end
  end
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_PetAttribute_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX then
    return Enum.AttributeType.AT_HPMAX_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYATK then
    return Enum.AttributeType.AT_PHYATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEATK then
    return Enum.AttributeType.AT_SPEATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYDEF then
    return Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEDEF then
    return Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEED then
    return Enum.AttributeType.AT_SPEED_PERCENT
  end
end

function UMG_PetAttribute_C:OnDeactive()
end

function UMG_PetAttribute_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnOk
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PetAttribute_C:OnAddEventListener()
end

function UMG_PetAttribute_C:OnItemSelected(Data)
  if self.IsGoodNature then
    self.SelectNature = Data
  else
    self.SelectNature = Data
  end
  self.PopUp3:SetBtnRightEnableStateNew(true)
end

function UMG_PetAttribute_C:OnOk()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
  if self.IsGoodNature then
    if self.SelectNature == self.petGoodNature then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\228\184\141\232\131\189\233\128\137\230\139\169\228\184\142\229\189\147\229\137\141\230\128\167\230\160\188\229\189\177\229\147\141\229\177\158\230\128\167\231\155\184\229\144\140\231\154\132\229\177\158\230\128\167")
      return
    end
  elseif self.SelectNature == self.petBadNature then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\228\184\141\232\131\189\233\128\137\230\139\169\228\184\142\229\189\147\229\137\141\230\128\167\230\160\188\229\189\177\229\147\141\229\177\158\230\128\167\231\155\184\229\144\140\231\154\132\229\177\158\230\128\167")
    return
  end
  if not self.SelectNature then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.MagicMirror_EffectChoose)
    return
  end
  self:LoadAnimation(2)
  self.IsOkBtn = true
  self:SetBtnVisible(false)
end

function UMG_PetAttribute_C:SetBtnVisible(visible)
  if not visible then
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp3.FullScreen_Close:SetIsEnabled(false)
  else
    self.PopUp3.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp3.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp3.FullScreen_Close:SetIsEnabled(true)
  end
end

function UMG_PetAttribute_C:OnCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
  self:LoadAnimation(2)
  self.IsOkBtn = false
  self:SetBtnVisible(false)
end

function UMG_PetAttribute_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:SetBtnVisible(true)
    if self.IsOkBtn then
      if self.IsGoodNature then
        if self.SelectNature ~= self.petGoodNature then
          self.data.GoodPetNature = self.SelectNature
        else
          self.data.GoodPetNature = nil
        end
      elseif self.SelectNature ~= self.petBadNature then
        self.data.BadPetNature = self.SelectNature
      else
        self.data.BadPetNature = nil
      end
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetAttributePopUp, false)
    else
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetAttributePopUp, false)
    end
  end
end

function UMG_PetAttribute_C:SetBagItemClickAble(clickable)
  self.SortList:SetItemClickAble(clickable)
end

return UMG_PetAttribute_C
