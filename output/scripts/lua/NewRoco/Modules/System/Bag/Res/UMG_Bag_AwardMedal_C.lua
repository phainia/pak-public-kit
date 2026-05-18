local UMG_Bag_AwardMedal_C = _G.NRCPanelBase:Extend("UMG_Bag_AwardMedal_C")

function UMG_Bag_AwardMedal_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  self:OnAddEventListener()
end

function UMG_Bag_AwardMedal_C:OnDestruct()
end

function UMG_Bag_AwardMedal_C:OnActive(GoodsChangeItem, PetGid)
  local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(PetGid)
  self:SetCommonPopUpInfo(self.PopUp1)
  local Text
  if GoodsChangeItem.medal then
    local MedalConf = _G.DataConfigManager:GetMedalConf(GoodsChangeItem.medal.conf_id)
    self.Icon:SetPath(MedalConf.big_icon)
    self.NRCText_4:SetText(MedalConf.name)
    local medal_type = _G.DataModelMgr.PlayerDataModel:GetMedalTypeByPetMedal(GoodsChangeItem.medal)
    if medal_type == _G.Enum.MedalType.MT_IND then
      self.MedalSwitch:SetActiveWidgetIndex(0)
      self.HeadIcon_1:SetIconPathAndMaterial(PetData.base_conf_id, PetData.mutation_type, PetData.glass_info)
      self.NumText:SetText(PetData.level)
      local MedalGift = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_7").msg
      Text = string.format(MedalGift, PetData.name, MedalConf.name)
      self.PopUp1:SetDescInfo(Text)
    elseif medal_type == _G.Enum.MedalType.MT_SPECIES or medal_type == _G.Enum.MedalType.MT_BOND then
      local isSpeciesMedal = _G.NRCModuleManager:DoCmd(BagModuleCmd.CheckIsSpeciesMedal, MedalConf)
      local MedalGift = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_6").msg
      if isSpeciesMedal then
        local baseConfId, name = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetOriginalPet, PetData.base_conf_id)
        self.MedalSwitch:SetActiveWidgetIndex(1)
        self.HeadIcon:SetIconPathAndMaterial(baseConfId)
        Text = string.format(MedalGift, name, MedalConf.name)
      else
        self.MedalSwitch:SetActiveWidgetIndex(1)
        self.HeadIcon:SetIconPathAndMaterial(PetData.base_conf_id, PetData.mutation_type, PetData.glass_info)
        Text = string.format(MedalGift, PetData.name, MedalConf.name)
      end
      self.PopUp1:SetDescInfo(Text)
    end
  end
  self:LoadAnimation(0)
end

function UMG_Bag_AwardMedal_C:OnDeactive()
end

function UMG_Bag_AwardMedal_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
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
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Bag_AwardMedal_C:OnAddEventListener()
end

function UMG_Bag_AwardMedal_C:OnClickCloseBtn()
  self:LoadAnimation(2)
end

function UMG_Bag_AwardMedal_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Bag_AwardMedal_C
