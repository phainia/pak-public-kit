local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_Bag_CommonPopUp_C = _G.NRCPanelBase:Extend("UMG_Bag_CommonPopUp_C")

function UMG_Bag_CommonPopUp_C:OnConstruct()
  self.data = self.module:GetData("BagModuleData")
  self.BagItem = nil
  self.PetData = nil
  self.MedalBondConfList = {}
  self:SetChildViews(self.PopUp4)
  self:OnAddEventListener()
end

function UMG_Bag_CommonPopUp_C:OnDestruct()
end

function UMG_Bag_CommonPopUp_C:OnActive(BagItem)
  self.BagItem = BagItem
  self:SetCommonPopUpInfo(self.PopUp4)
  self:SetPanelInfo()
  self:LoadAnimation(0)
end

function UMG_Bag_CommonPopUp_C:OnDeactive()
end

function UMG_Bag_CommonPopUp_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClickCloseBtn
  CommonPopUpData.Btn_RightHandler = self.OnClickConfirm
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Bag_CommonPopUp_C:OnAddEventListener()
  self:RegisterEvent(self, BagModuleEvent.SelectCommonPetHeadPictureEvent, self.OnSelectCommonPetHeadPictureEvent)
end

function UMG_Bag_CommonPopUp_C:SetPanelInfo()
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  if BagItemConf then
    local use_action = BagItemConf.item_behavior[1] and BagItemConf.item_behavior[1].use_action
    if use_action == Enum.ItemBehavior.IB_GIVE_MEDAL then
      self:SetBaseInfo(false)
      self:SetListInfo()
    end
  end
end

function UMG_Bag_CommonPopUp_C:SetBaseInfo(_IsSelect)
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  local MedalId = BagItemConf.item_behavior[1] and BagItemConf.item_behavior[1].ratio and BagItemConf.item_behavior[1].ratio[1]
  if MedalId then
    local MedalConf = _G.DataConfigManager:GetMedalConf(MedalId)
    local Text
    if MedalConf.medal_type == _G.Enum.MedalType.MT_IND then
      if _IsSelect then
        Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_4").msg
        Text = string.format(Text, self.PetData.name)
        self.PopUp4:SetBtnRightEnableStateNew(true)
      else
        Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_2").msg
        self.PopUp4:SetBtnRightEnableStateNew(false)
      end
    elseif MedalConf.medal_type == _G.Enum.MedalType.MT_SPECIES then
      if _IsSelect then
        Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_3").msg
        local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetData.base_conf_id)
        if PetBaseConf and PetBaseConf.pet_evolution_id[1] then
          local PetEvolutionConf = _G.DataConfigManager:GetPetEvolutionConf(PetBaseConf.pet_evolution_id[1])
          Text = string.format(Text, PetEvolutionConf.evolution_chain[1].pet_name)
        end
        self.PopUp4:SetBtnRightEnableStateNew(true)
      else
        Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_1").msg
        self.PopUp4:SetBtnRightEnableStateNew(false)
      end
    elseif MedalConf.medal_type == _G.Enum.MedalType.MT_BOND then
      if _IsSelect then
        if self.isSpeciesMedal then
          Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_3").msg
          Text = string.format(Text, self.PetData.name)
        else
          Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_9").msg
          Text = string.format(Text, self.PetData.name)
        end
        self.PopUp4:SetBtnRightEnableStateNew(true)
      else
        if self.isSpeciesMedal then
          Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_2").msg
        else
          Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_1").msg
        end
        self.PopUp4:SetBtnRightEnableStateNew(false)
      end
    end
    self.PopUp4:SetDescInfo(Text)
  end
  self.PopUp4:SetTitleTextInfo(BagItemConf.name)
  self.PopUp4:SetTitleIconInfo(BagItemConf.icon)
end

function UMG_Bag_CommonPopUp_C:SetListInfo()
  self.isSpeciesMedal = false
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItem.id)
  local MedalId = BagItemConf.item_behavior[1].ratio[1]
  if MedalId then
    local MedalConf = _G.DataConfigManager:GetMedalConf(MedalId)
    local PetDataList = self.data:GetMedalPetList(MedalConf)
    PetDataList = self.data:GetNoEquipmentMedalPet(PetDataList, MedalConf)
    self.isSpeciesMedal = _G.NRCModuleManager:DoCmd(BagModuleCmd.CheckIsSpeciesMedal, MedalConf)
    if self.isSpeciesMedal then
      PetDataList = self:GetOriginalPetList(MedalConf)
    end
    self.List:InitGridView(PetDataList)
    for i, PetData in ipairs(PetDataList) do
      local Item = self.List:GetItemByIndex(i - 1)
      if MedalConf.medal_type == _G.Enum.MedalType.MT_IND then
        if Item then
          Item:SetEvolutionChainPetInfo(PetData.level)
        end
      elseif (MedalConf.medal_type == _G.Enum.MedalType.MT_SPECIES or MedalConf.medal_type == _G.Enum.MedalType.MT_BOND) and Item then
        Item:SetMedalType(MedalConf.medal_type)
      end
    end
  end
end

function UMG_Bag_CommonPopUp_C:GetOriginalPetList(MedalConf)
  local PetDataList = self.data:GetMedalPetList(MedalConf)
  PetDataList = self.data:GetNoEquipmentMedalPet(PetDataList, MedalConf)
  local petList = {}
  for _, pet in pairs(PetDataList) do
    local baseConfId, name = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetOriginalPet, pet.base_conf_id)
    if baseConfId and name then
      local isAdded = false
      for _, _pet in pairs(petList) do
        if _pet.base_conf_id == baseConfId then
          isAdded = true
          break
        end
      end
      if not isAdded then
        local temp = {
          base_conf_id = baseConfId,
          name = name,
          gid = pet.gid
        }
        table.insert(petList, temp)
      end
    end
  end
  return petList
end

function UMG_Bag_CommonPopUp_C:OnSelectCommonPetHeadPictureEvent(_PetData)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Bag_CommonPopUp_C:OnSelectCommonPetHeadPictureEvent")
  self.PetData = _PetData
  self:SetBaseInfo(true)
end

function UMG_Bag_CommonPopUp_C:OnClickConfirm()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_CommonPopUp_C:OnClickCloseBtn")
  if not self.PetData then
    local Text = _G.DataConfigManager:GetLocalizationConf("use_medal_gift_tips_5").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Text)
    return
  end
  _G.NRCModuleManager:DoCmd(BagModuleCmd.UseBagItem, self.BagItem.gid, self.BagItem.id, 1, self.PetData.gid)
  self:LoadAnimation(2)
end

function UMG_Bag_CommonPopUp_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_CommonPopUp_C:OnClickCloseBtn")
  self:LoadAnimation(2)
end

function UMG_Bag_CommonPopUp_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Bag_CommonPopUp_C
