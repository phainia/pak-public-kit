local PetUtils = require("NewRoco.Utils.PetUtils")
local Enum = require("Data.Config.Enum")
local UMG_PetCharacter_PopUp_C = _G.NRCPanelBase:Extend("UMG_PetCharacter_PopUp_C")
UMG_PetCharacter_PopUp_C.StateEnum = {
  None = 0,
  LackSelected = 1,
  UnSelected = 2,
  CommonSelected = 3
}
UMG_PetCharacter_PopUp_C.CloseEnum = {
  Cancel = 0,
  OK = 1,
  GoodNature = 2,
  BadNature = 3,
  SuccessClose = 4
}
UMG_PetCharacter_PopUp_C.BtnEnum = {
  None = 0,
  TipsBtn = 1,
  Btn2 = 2,
  ChangeBtn = 3,
  ChangeBtn_1 = 4,
  Btn3 = 5
}

function UMG_PetCharacter_PopUp_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_PetCharacter_PopUp_C:OnDestruct()
end

function UMG_PetCharacter_PopUp_C:OnActive(Success, Param, RspUseId)
  if Param then
    self:SetRenderOpacity(0)
    self.Param = Param
    self.BagItem = Param.BagItem
    self.PetItemData = Param.PetData
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
    local titleIconPath = BagItemConf.icon
    self:SetCommonPopUpInfo(self.PopUp4, BagItemConf.name, titleIconPath, true)
    self.Success = Success
    self:SetPanelInfo(Success)
    self:OnAddEventListener()
    return
  end
  self.data = self.module:GetData("BagModuleData")
  if self.module.PetOpenUseAction then
    self.PopUp4:SetBtnLeftText("\229\143\150\230\182\136")
  else
    self.PopUp4:SetBtnLeftText("\230\155\180\230\141\162\231\178\190\231\129\181")
  end
  self.BagItem = self.data:GetCurSelectedItemData()
  if RspUseId then
    self.BagItemId = RspUseId
  else
    self.BagItemId = self.BagItem and self.BagItem.id
  end
  self.PetItemData = self.data.PetCharacterItem
  self.ChangeState = self.StateEnum.UnSelected
  self.CloseState = self.CloseEnum.Cancel
  self.ChangeNatureName = nil
  self.BtnState = self.BtnEnum.None
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItemId)
  local titleIconPath = BagItemConf.icon
  self:SetCommonPopUpInfo(self.PopUp4, BagItemConf.name, titleIconPath)
  self:SetPanelInfo(Success)
  self:OnAddEventListener()
end

function UMG_PetCharacter_PopUp_C:SetPanelInfo(Success)
  if not self.PetItemData then
    return
  end
  local petNatureConf = _G.DataConfigManager:GetNatureConf(self.PetItemData.nature)
  if not petNatureConf then
    return
  end
  self.Success = Success
  if self.Success then
    self.PopUp4:SetBtnLeftText(LuaText.UMG_Bag_PopUp5)
    local attributeCfg1, attributeCfg2
    if self.data and self.data.GoodPetNature then
      attributeCfg1 = self.data.GoodPetNature
    elseif 0 ~= self.PetItemData.changed_nature_pos_attr_type then
      attributeCfg1 = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_pos_attr_type)
    else
      attributeCfg1 = petNatureConf.positive_effect
    end
    if self.data and self.data.BadPetNature then
      attributeCfg2 = self.data.BadPetNature
    elseif 0 ~= self.PetItemData.changed_nature_neg_attr_type then
      attributeCfg2 = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_neg_attr_type)
    else
      attributeCfg2 = petNatureConf.negative_effect
    end
    self:SetNatureIcon(self.attributeIcon_4, attributeCfg1)
    self:SetNatureIcon(self.attributeIcon_5, attributeCfg2)
    local PetGrowLevel, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.PetItemData)
    if PetGrowLevel >= 999 then
      GrowOrder = 6
    end
    local Number = string.format("%s%s%s", "-", petNatureConf.negative_effect_proportion // 100, "%")
    local Number_1 = (petNatureConf.positive_effect_proportion + petNatureConf.positive_effect_grow * (GrowOrder - 1)) // 100
    local Text = string.format("%s%s%s", "+", Number_1, "%")
    self.OwnedText_4:SetText(Text)
    self.OwnedText_5:SetText(Number)
    local natureConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NATURE_CONF):GetAllDatas()
    local ChangedNatureName
    for i, v in ipairs(natureConf) do
      if v.positive_effect == attributeCfg1 and v.negative_effect == attributeCfg2 then
        ChangedNatureName = v.name
        break
      end
    end
    if ChangedNatureName then
      local allTextStr = string.format(_G.DataConfigManager:GetLocalizationConf("MagicMirror_NatureModified").msg, self.PetItemData.name, ChangedNatureName)
      self.PopUp4:SetDescInfo(allTextStr)
      self.PopUp4:SetBtnRightEnableStateNew(true)
    end
  end
  if not self.Param then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItemId)
    if BagItemConf and BagItemConf.item_behavior then
      if BagItemConf.item_behavior[1].ratio[1] then
        self.CanDoubleChange = true
      else
        self.CanDoubleChange = false
      end
      if not self.data.GoodPetNature and not self.data.BadPetNature then
        local allTextStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_EffectChoose").msg
        self.PopUp4:SetDescInfo(allTextStr)
        self.PopUp4:SetBtnRightEnableStateNew(false)
      end
      if BagItemConf.item_behavior[1].ratio[1] then
      else
        self.TransitionalImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Transitional:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.bIsFrameItem = true
        self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    local attributeCfg1, attributeCfg2
    if 0 ~= self.PetItemData.changed_nature_pos_attr_type then
      attributeCfg1 = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_pos_attr_type)
    else
      attributeCfg1 = petNatureConf.positive_effect
    end
    if 0 ~= self.PetItemData.changed_nature_neg_attr_type then
      attributeCfg2 = self:GetChangeAttrReqEnum(self.PetItemData.changed_nature_neg_attr_type)
    else
      attributeCfg2 = petNatureConf.negative_effect
    end
    self:SetNatureIcon(self.attributeIcon, attributeCfg1)
    self:SetNatureIcon(self.attributeIcon_2, attributeCfg2)
    local PetGrowLevel, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.PetItemData)
    if PetGrowLevel >= 999 then
      GrowOrder = 6
    end
    local Number = string.format("%s%s%s", "-", petNatureConf.negative_effect_proportion // 100, "%")
    local Number_1 = (petNatureConf.positive_effect_proportion + petNatureConf.positive_effect_grow * (GrowOrder - 1)) // 100
    local Text = string.format("%s%s%s", "+", Number_1, "%")
    self.OwnedText:SetText(Text)
    self.OwnedText_2:SetText(Number)
    self.GoodNatureText = Text
    self.BadNatureText = Number
    local attributeCfg3, attributeCfg4
    if self.data.GoodPetNature then
      attributeCfg3 = self.data.GoodPetNature
      self:SetNatureIcon(self.attributeIcon_1, attributeCfg3)
      self.OwnedText_1:SetText(Text)
    else
      self.UpOrDec_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.attributeIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText_1:SetText(" -")
    end
    if self.data.BadPetNature then
      attributeCfg4 = self.data.BadPetNature
      self:SetNatureIcon(self.attributeIcon_3, attributeCfg4)
      self.OwnedText_3:SetText(Number)
    else
      self.UpOrDec_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.attributeIcon_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText_3:SetText(" -")
    end
    self:GetChangedNature(attributeCfg1, attributeCfg2, self.data.GoodPetNature, self.data.BadPetNature)
  end
  self.NumText:SetText(self.PetItemData.level)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetItemData.base_conf_id)
  if petNatureConf then
    self.CharacterText:SetText(petNatureConf.name or "")
  end
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      self.PetHeadIcon:SetIconPathAndMaterial(self.PetItemData.base_conf_id, self.PetItemData.mutation_type, self.PetItemData.glass_info)
    end
  end
  if Success then
    if self.Param then
      self:PlayAnimation(self.Use, self.Use:GetEndTime())
    else
      self:PlayAnimation(self.Use)
    end
  else
    self:LoadAnimation(0)
  end
end

function UMG_PetCharacter_PopUp_C:GetChangeAttrReqEnum(attribute)
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

function UMG_PetCharacter_PopUp_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon, HideBtn)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  if HideBtn then
    CommonPopUpData.HideBtn = true
  else
    CommonPopUpData.Btn_LeftHandler = self.OnCancelOrClose
    CommonPopUpData.Btn_RightHandler = self.OnOK
  end
  CommonPopUpData.ClosePanelHandler = self.CloseBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_PetCharacter_PopUp_C:GetChangedNature(positive_effect, negative_effect, changed_positive_effect, changed_negative_effect)
  if self.CanDoubleChange then
    if not (not changed_positive_effect or changed_negative_effect) or changed_negative_effect and not changed_positive_effect then
      self.ChangeState = self.StateEnum.LackSelected
    elseif changed_positive_effect and changed_negative_effect then
      self.ChangeState = self.StateEnum.None
    end
  elseif changed_negative_effect then
    self.ChangeState = self.StateEnum.None
  end
  local natureConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NATURE_CONF):GetAllDatas()
  if self.ChangeState ~= self.StateEnum.UnSelected then
    for i, v in ipairs(natureConf) do
      if changed_negative_effect and changed_positive_effect then
        if v.positive_effect == changed_positive_effect and v.negative_effect == changed_negative_effect then
          self.ChangeNatureName = v.name
          break
        end
      elseif changed_negative_effect and not changed_positive_effect then
        if v.positive_effect == positive_effect and v.negative_effect == changed_negative_effect then
          self.ChangeNatureName = v.name
          break
        end
      elseif changed_positive_effect and not changed_negative_effect and v.positive_effect == changed_positive_effect and v.negative_effect == negative_effect then
        self.ChangeNatureName = v.name
        break
      end
    end
  end
  if self.ChangeNatureName then
    local allTextStr = string.format(_G.DataConfigManager:GetLocalizationConf("MagicMirror_NaturePreview").msg, self.PetItemData.name, self.ChangeNatureName)
    self.PopUp4:SetDescInfo(allTextStr)
    self.PopUp4:SetBtnRightEnableStateNew(true)
  elseif self.ChangeState ~= self.StateEnum.UnSelected then
    local allTextStr = string.format(_G.DataConfigManager:GetLocalizationConf("MagicMirror_ChooseSameNature").msg, self.PetItemData.name)
    self.PopUp4:SetDescInfo(allTextStr)
    self.PopUp4:SetBtnRightEnableStateNew(false)
  end
end

function UMG_PetCharacter_PopUp_C:OnDeactive()
end

function UMG_PetCharacter_PopUp_C:SetNatureIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_PetCharacter_PopUp_C:OnAddEventListener()
  self:AddButtonListener(self.ChangeBtn, self.GoodNatureChange)
  self:AddButtonListener(self.ChangeBtn_1, self.BadNatureChange)
  self:AddButtonListener(self.Tipsbtn, self.OpenTips)
end

function UMG_PetCharacter_PopUp_C:OpenTips()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.TipsBtn
  self:BtnClick()
end

function UMG_PetCharacter_PopUp_C:BtnClick()
  if self.BtnState == self.BtnEnum.TipsBtn then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.PetItemData)
  elseif self.BtnState == self.BtnEnum.Btn2 then
    if self.Success then
      self.data.PetCharacterItem = nil
      self.data.GoodPetNature = nil
      self.data.BadPetNature = nil
      if self.module.IsPetInfoMainToPanel then
        local openPetData, index, bIsRevertMainPanel = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetData)
        if not openPetData then
          bIsRevertMainPanel = true
        end
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.EnablePanelPetMain)
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, bIsRevertMainPanel)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.RefreshPetRightPanel, true)
        _G.NRCModuleManager:DoCmd(BagModuleCmd.CloseBagMainPanel)
      else
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsBagToOpenPanel)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
        NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
          subPanelIndex = 4,
          callback = self.OnUMGLoadFinished
        })
        self:DoClose()
      end
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
      self.CloseState = self.CloseEnum.Cancel
      self:LoadAnimation(2)
    end
    self:SetBtnVisible(false)
  elseif self.BtnState == self.BtnEnum.ChangeBtn then
    self.CloseState = self.CloseEnum.GoodNature
    self:LoadAnimation(2)
    self:SetBtnVisible(false)
  elseif self.BtnState == self.BtnEnum.ChangeBtn_1 then
    self.CloseState = self.CloseEnum.BadNature
    self:LoadAnimation(2)
    self:SetBtnVisible(false)
  elseif self.BtnState == self.BtnEnum.Btn3 then
    if self.Success then
      self:OnClose()
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
      if self.ChangeState ~= self.StateEnum.UnSelected and not self.ChangeNatureName then
        local tipsStr = LuaText.nature_change_must_different
        _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
      elseif self.ChangeState == self.StateEnum.UnSelected then
        local tipsStr = _G.DataConfigManager:GetLocalizationConf("MagicMirror_EffectChoose").msg
        _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
      elseif self.ChangeState == self.StateEnum.LackSelected then
        self.CloseState = self.CloseEnum.OK
        self:LoadAnimation(2)
        self:SetBtnVisible(false)
      else
        self.module:ChangePetCharacterSuccess()
      end
    end
  end
  self:DelaySeconds(0.4, function()
    self.BtnState = self.BtnEnum.None
  end)
end

function UMG_PetCharacter_PopUp_C:SetBtnVisible(visible)
  if not visible then
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    if self.ChangeBtn:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
    self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.ChangeBtn:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PetCharacter_PopUp_C:BadNatureChange()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.ChangeBtn_1
  self:BtnClick()
end

function UMG_PetCharacter_PopUp_C:GoodNatureChange()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.ChangeBtn
  self:BtnClick()
end

function UMG_PetCharacter_PopUp_C:OnOK()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.Btn3
  self:BtnClick()
end

function UMG_PetCharacter_PopUp_C:CloseBtnClick()
  if self.Param then
    self:LoadAnimation(2)
    return
  end
  if self.BtnState ~= self.BtnEnum.None then
    self.PopUp4:SetLock(false)
    return
  end
  if self.Success then
    self.BtnState = self.BtnEnum.Btn3
    self:BtnClick()
  else
    self.BtnState = self.BtnEnum.Btn2
    self:BtnClick()
  end
end

function UMG_PetCharacter_PopUp_C:OnCancelOrClose()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.Btn2
  self:BtnClick()
end

function UMG_PetCharacter_PopUp_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    if self.Param then
      self:DoClose()
      return
    end
    self:SetBtnVisible(true)
    if self.CloseState == self.CloseEnum.Cancel then
      self.data.GoodPetNature = nil
      self.data.BadPetNature = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetCharacterPopUp, false)
    elseif self.CloseState == self.CloseEnum.OK then
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.BagTips, true)
    elseif self.CloseState == self.CloseEnum.BadNature then
      self.data.IsGoodAttributePopUp = false
      self.data.AttributeNumText = self.BadNatureText
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetAttributePopUp, true, nil, self.bIsFrameItem)
    elseif self.CloseState == self.CloseEnum.GoodNature then
      self.data.IsGoodAttributePopUp = true
      self.data.AttributeNumText = self.GoodNatureText
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.PetAttributePopUp, true, nil, self.bIsFrameItem)
    elseif self.CloseState == self.CloseEnum.SuccessClose then
      self.data.PetCharacterItem = nil
      self.data.GoodPetNature = nil
      self.data.BadPetNature = nil
      self:DoClose()
    end
  elseif Animation == self.Use then
    if self.Param then
      self:SetRenderOpacity(1)
    end
    local text = _G.DataConfigManager:GetLocalizationConf("BAG_USE_ITEM_SUCCESS").msg
    self.PopUp4:SetTitleTextInfo(text)
  end
end

function UMG_PetCharacter_PopUp_C:OnClose()
  if self.Success then
    self.CloseState = self.CloseEnum.SuccessClose
    self:LoadAnimation(2)
    self:SetBtnVisible(false)
  end
end

return UMG_PetCharacter_PopUp_C
