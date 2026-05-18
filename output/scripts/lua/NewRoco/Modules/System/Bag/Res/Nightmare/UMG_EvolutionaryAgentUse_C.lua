local UMG_EvolutionaryAgentUse_C = _G.NRCPanelBase:Extend("UMG_EvolutionaryAgentUse_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_EvolutionaryAgentUse_C:OnActive(showType, arg)
  self.arg = arg
  self:OnAddEventListener()
  self.moduleData = self.module:GetData("BagModuleData")
  self.ShowType = showType
  self:SetCommonPopUpInfo(self.PopUp4)
  if showType == self.moduleData.PurificationEnum.SELECT then
    _G.NRCModuleManager:DoCmd(BagModuleCmd.SetEvolutionarySelectedItem, nil)
    self.Switcher:SetActiveWidgetIndex(0)
    self.PopUp4:SetBtnLeftText("\229\143\150\230\182\136")
    self.PopUp4:SetBtnRightText("\231\161\174\229\174\154")
    self:ShowSelectPetPanel()
  elseif showType == self.moduleData.PurificationEnum.USE then
    self.Switcher:SetActiveWidgetIndex(1)
    self.PopUp4:SetBtnLeftText("\229\143\150\230\182\136")
    self.PopUp4:SetBtnRightText("\231\161\174\232\174\164")
    self:ShowUsePetPanel()
  elseif showType == self.moduleData.PurificationEnum.SUCCESS then
    self.Switcher:SetActiveWidgetIndex(2)
    self.PopUp4:SetBtnLeftText("\230\159\165\231\156\139\232\175\166\230\131\133")
    self.PopUp4:SetBtnRightText("\231\161\174\232\174\164")
    self:ShowSuccessPanel()
  end
  self:LoadAnimation(0)
end

function UMG_EvolutionaryAgentUse_C:OnDeactive()
  self:UnRegisterEvent(self, BagModuleEvent.SetEvolutionarySelectedItem)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.GetEvolutionarySuccessPet)
end

function UMG_EvolutionaryAgentUse_C:OnAddEventListener()
  self:RegisterEvent(self, BagModuleEvent.SetEvolutionarySelectedItem, self.SetBtnAbleAndItemData)
  _G.NRCEventCenter:RegisterEvent(self.name, self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.GetEvolutionarySuccessPet)
end

function UMG_EvolutionaryAgentUse_C:OnBtnLeftClicked()
  local switcherIndex = self.Switcher:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:OnSelectCancelButtonClicked()
  elseif 1 == switcherIndex then
    self:OnUseCancelButtonClicked()
  elseif 2 == switcherIndex then
    self:OnSuccessCheckButtonClicked()
  end
end

function UMG_EvolutionaryAgentUse_C:OnBtnRightClicked()
  local switcherIndex = self.Switcher:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:OnSelectConfirmButtonClicked()
  elseif 1 == switcherIndex then
    self:OnUseConfirmButtonClicked()
  elseif 2 == switcherIndex then
    self:OnSuccessConfirmButtonClicked()
  end
end

function UMG_EvolutionaryAgentUse_C:OnConstruct()
  self.CloseCB = nil
  self.ShowType = nil
  self:SetChildViews(self.PopUp4)
end

function UMG_EvolutionaryAgentUse_C:OnCloseButtonClicked()
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    local closeCb = self.CloseCB
    self:DoClose()
    if closeCb then
      closeCb()
    end
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_EvolutionaryAgentUse_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnLeftClicked
  CommonPopUpData.Btn_RightHandler = self.OnBtnRightClicked
  CommonPopUpData.ClosePanelHandler = self.OnCloseButtonClicked
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_EvolutionaryAgentUse_C:ShowSelectPetPanel()
  local selectItemData = self.moduleData.curSelectedItemData
  local itemId = selectItemData.id
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
  self.PopUp4:SetTitleTextInfo(bagItemConf.name)
  self.PopUp4:SetTitleIconInfo(bagItemConf.icon)
  self.PopUp4:SetDescInfo(LuaText.Choose_Nightmare_Elite_Pure_Tips)
  self.PopUp4:SetBtnRightEnableStateNew(false)
  local evolutionaryPetList = self.arg
  self.List:InitGridView(evolutionaryPetList)
  for i = 1, self.List:GetItemCount() do
    local item = self.List:GetItemByIndex(i - 1)
    item:ShowBloodPulse()
    item:ShowNightmare()
  end
end

function UMG_EvolutionaryAgentUse_C:OnSelectCancelButtonClicked()
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:OnSelectConfirmButtonClicked()
  local selectPetData = self.moduleData:GetEvolutionarySelectedItem()
  if selectPetData then
    local function cb()
      _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.OpenEvolutionaryUsePanel)
    end
    
    self.CloseCB = cb
    self:LoadAnimation(2)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Choose_Nightmare_Elite_Pure_Tips)
  end
end

function UMG_EvolutionaryAgentUse_C:SetBtnAbleAndItemData(_data)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data[1].gid)
  local allText = string.format(LuaText.Checked_Nightmare_Elite_Pure_Tips1, petData.name)
  self.PopUp4:SetDescInfo(allText)
  self.PopUp4:SetBtnRightEnableStateNew(true)
end

function UMG_EvolutionaryAgentUse_C:ShowUsePetPanel()
  local selectPet = self.arg
  local selectItemData = self.moduleData.curSelectedItemData
  local itemId = selectItemData.id
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
  self.PopUp4:SetTitleTextInfo(bagItemConf.name)
  self.PopUp4:SetTitleIconInfo(bagItemConf.icon)
  local allText = string.format(LuaText.Checked_Nightmare_Elite_Pure_Tips2, selectPet[1].name)
  self.PopUp4:SetDescInfo(allText)
  self.PopUp4:SetBtnRightEnableStateNew(true)
  self.HeadIcon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
  self.HeadIcon_1:SetIconPathAndMaterial(selectPet[1].base_conf_id, selectPet[1].mutation_type, selectPet[1].glass_info)
  self.NumText_1:SetText(selectPet[1].level)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(selectPet[1].blood_id)
  self.BloodPulse_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.icon_1:SetPath(PetBloodConf.icon)
  local targetPetBloodConf = _G.DataConfigManager:GetPetBloodConf(Enum.PetBloodType.PBT_FANTASTIC)
  self.HeadCanvas_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slash:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HeadIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
  local isShining = false
  if selectPet[1].mutation_type and PetMutationUtils.GetMutationValue(selectPet[1].mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    isShining = true
  end
  if isShining then
    self.HeadIcon_2:SetIconPathAndMaterial(selectPet[1].base_conf_id, _G.Enum.MutationDiffType.MDT_SHINING)
  else
    self.HeadIcon_2:SetIconPathAndMaterial(selectPet[1].base_conf_id, _G.Enum.MutationDiffType.MDT_NONE)
  end
  self.NumText_2:SetText(selectPet[1].level)
  self.BloodPulse_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.icon_2:SetPath(targetPetBloodConf.icon)
end

function UMG_EvolutionaryAgentUse_C:OnUseCancelButtonClicked()
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:OnUseConfirmButtonClicked()
  _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.UseEvolutionaryItem)
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:GetEvolutionarySuccessPet(GoodsChangeItem, CmdID)
  local petData = GoodsChangeItem.pet_data
  if not petData then
    return
  end
  
  local function cb()
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.OpenEvolutionarySuccessPanel, petData)
  end
  
  self.CloseCB = cb
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:ShowSuccessPanel()
  local petData = self.arg
  self.BossBlood:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HeadIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
  self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
  self.NumText:SetText(petData.level)
  self.BloodPulse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petData.blood_id)
  self.icon:SetPath(PetBloodConf.icon)
  local petBloodConf = _G.DataConfigManager:GetPetBloodConf(petData.blood_id)
  local allText = string.format(LuaText.Nightmare_Elite_Recovery_Blood_Tips, petData.name, petBloodConf.blood_name)
  self.PopUp4:SetTitleTextInfo("\228\189\191\231\148\168\230\136\144\229\138\159")
  self.PopUp4:SetDescInfo(allText)
  self.PopUp4:SetBtnRightEnableStateNew(true)
  local skill_data = petData.skill.skill_data
  local skillConf
  for _, skill in pairs(skill_data) do
    if skill.skill_src == Enum.PetNewSkillSrc.PNSS_PET_BLOOD then
      skillConf = _G.DataConfigManager:GetSkillConf(skill.id)
      break
    end
  end
  if skillConf then
    self.NormalBlood:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtSkillName:SetText(skillConf.name)
    self.SkillIcon:SetPath(skillConf.icon)
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    local Name, Path
    if typeDic then
      Path = typeDic.tips_res
    end
    if skillConf and 1 ~= skillConf.damage_type then
      Name = tostring(skillConf.dam_para[1])
    else
      Name = "-"
    end
    local SkillTypeList = {
      {Name = Name, Path = Path}
    }
    self.Attr:InitGridView(SkillTypeList)
    self.TxtPnum:SetText(skillConf.energy_cost[1])
  else
    self.NormalBlood:SetVisibility(UE4.ESlateVisibility.Collapsed)
    Log.Error(string.format("\230\178\161\230\156\137\232\161\128\232\132\137\230\138\128\232\131\189\230\149\176\230\141\174\239\188\140\231\178\190\231\129\181id\239\188\154%d\239\188\140\232\161\128\232\132\137id\239\188\154%d", petData.base_conf_id, petData.blood_id))
  end
end

function UMG_EvolutionaryAgentUse_C:OnSuccessConfirmButtonClicked()
  self:LoadAnimation(2)
end

function UMG_EvolutionaryAgentUse_C:OnSuccessCheckButtonClicked()
  if self.module.IsPetInfoMainToPanel then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.EnablePanelPetMain)
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.arg.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, true)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.RefreshPetRightPanel, true)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.CloseBagMainPanel)
  else
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.arg.gid)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsBagToOpenPanel)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, true)
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
      subPanelIndex = 4,
      callback = self.OnUMGLoadFinished
    })
    self:DoClose()
  end
end

function UMG_EvolutionaryAgentUse_C:ClosePanel()
  self:DoClose()
end

return UMG_EvolutionaryAgentUse_C
