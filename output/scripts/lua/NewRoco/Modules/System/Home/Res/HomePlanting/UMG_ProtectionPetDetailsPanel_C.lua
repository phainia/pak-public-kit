local UMG_ProtectionPetDetailsPanel_C = _G.NRCPanelBase:Extend("UMG_ProtectionPetDetailsPanel_C")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_ProtectionPetDetailsPanel_C:OnConstruct()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self:SetChildViews(self.CommonPetDetails, self.UMG_PetRate)
end

function UMG_ProtectionPetDetailsPanel_C:OnEnable()
end

function UMG_ProtectionPetDetailsPanel_C:OnDisable()
end

function UMG_ProtectionPetDetailsPanel_C:OnActive(petInfo, lifeCycleCaller, lifeCycleCallback)
  if not petInfo or not petInfo.data then
    return
  end
  self.data = self.module.data
  self.lifeCycleCaller = lifeCycleCaller
  self.lifeCycleCallback = lifeCycleCallback
  self.GuardBtn.Title_1:SetText(LuaText.plant_no_guard_btn_text)
  self.changeBtn4.Title_1:SetText(LuaText.plant_guard_btn_text)
  self:SetPetInfo(petInfo)
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
  if self.data.NPCActionOpenGuard and self.data.NPCActionOpenGuard.MoveDetailPanelCamera then
    self.data.NPCActionOpenGuard:MoveDetailPanelCamera(true)
  end
  if lifeCycleCaller and lifeCycleCallback then
    lifeCycleCallback(lifeCycleCaller, 0)
  end
end

function UMG_ProtectionPetDetailsPanel_C:OnDeactive()
  self:OnRemoveEventListener()
  if self.lifeCycleCaller and self.lifeCycleCallback then
    self.lifeCycleCallback(self.lifeCycleCaller, 2)
  end
  self.lifeCycleCaller = nil
  self.lifeCycleCallback = nil
end

function UMG_ProtectionPetDetailsPanel_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Details, self.ClosePanel)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.ClosePanel)
  self:AddButtonListener(self.GuardBtn.btnLevelUp, self.OnClickBtnGuard)
  self:AddButtonListener(self.changeBtn4.btnLevelUp, self.OnClickBtnCancelGuard)
  self:AddButtonListener(self.RecommendedBtn.btnLevelUp, self.OnRecommendedBtnClick)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  end
  self:RegisterEvent(self, HomeModuleEvent.UpdateGuardDetailPanel, self.UpdatePanelData)
end

function UMG_ProtectionPetDetailsPanel_C:OnRemoveEventListener()
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:UnRegisterEvent(self, PetUIModuleEvent.UpdatePetCollect)
  end
  self:UnRegisterEvent(self, HomeModuleEvent.UpdateGuardDetailPanel)
end

function UMG_ProtectionPetDetailsPanel_C:ClosePanel()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_ProtectionPetDetailsPanel_C:ClosePanel")
  self:PlayAnimation(self.Out)
  if self.lifeCycleCaller and self.lifeCycleCallback then
    self.lifeCycleCallback(self.lifeCycleCaller, 1)
  end
  if self.data.NPCActionOpenGuard and self.data.NPCActionOpenGuard.MoveDetailPanelCamera then
    self.data.NPCActionOpenGuard:MoveDetailPanelCamera(false)
  end
end

function UMG_ProtectionPetDetailsPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
end

function UMG_ProtectionPetDetailsPanel_C:OnClickBtnGuard()
  if self.petInfo then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_ProtectionPetDetailsPanel_C:OnClickBtnGuard")
    if not self.petInfo.isInGuard then
      _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendPlantPetGuardReq, true, self.petInfo.gid)
      _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdOpenPanel, "PlantGuardPetChoosing", false)
    end
  end
end

function UMG_ProtectionPetDetailsPanel_C:OnClickBtnCancelGuard()
  if self.petInfo and self.petInfo.isInGuard then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.SendPlantPetGuardReq, false)
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdOpenPanel, "PlantGuardPetChoosing", false)
  end
end

function UMG_ProtectionPetDetailsPanel_C:OpenPetTips()
  local petData = self.petData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
end

function UMG_ProtectionPetDetailsPanel_C:OnBloodPulse()
  local petData = self.petData
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.HomePlantGuard)
end

function UMG_ProtectionPetDetailsPanel_C:OnCollectBtn()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetCollectPanel, self.petData.gid, self.petData.partner_mark)
end

function UMG_ProtectionPetDetailsPanel_C:UpdateCollect(partner_mark)
  self.petData.partner_mark = partner_mark
  self.UMG_CollectBtn:UpdateInfo(partner_mark)
end

function UMG_ProtectionPetDetailsPanel_C:UpdatePanelData(petInfo)
  if not petInfo then
    petInfo = self.petInfo
    if not petInfo then
      return
    end
  end
  self:SetPetInfo(petInfo)
end

function UMG_ProtectionPetDetailsPanel_C:SetPetInfo(petInfo)
  self:PlayAnimation(self.Change)
  self.petInfo = petInfo
  self.petData = petInfo.data
  self.IconList:ScrollToStart()
  self.textPetName:SetText(self.petData.name or "")
  for gender, genderIcon in ipairs(self.genderIcons) do
    if self.petData.gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.UMG_PetRate:SetText(self.petData, TipEnum.OpenPetTipsType.HomePlantGuard)
  self.textPetLv:SetText(self.petData.level)
  self.CatchHardLv:Clear()
  local PetStarsList = PetUtils.GetPetStarsListByPetGID(self.petData.gid)
  self.CatchHardLv:InitGridView(PetStarsList)
  local typeInfoTable = {}
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  local petType = petBaseConf.unit_type
  if self.Attr1:GetItemCount() >= 1 then
    for i = 1, self.Attr1:GetItemCount() do
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType[i])
      if typeDic then
        table.insert(typeInfoTable, {
          Name = typeDic.short_name,
          Path = typeDic.type_icon
        })
      end
    end
    if typeInfoTable then
      self.Attr1:InitGridView(typeInfoTable)
    end
  end
  local petBloodConf = _G.DataConfigManager:GetPetBloodConf(self.petData.blood_id)
  local bloodInfoTable = {
    {
      Name = petBloodConf.blood_name,
      Path = petBloodConf.icon
    }
  }
  self.Attr:InitGridView(bloodInfoTable)
  self.CommonPetDetails:InitPetBaseInfo(self.petData, petBaseConf)
  if self.CommonPetDetails.SetSpecificOpenPetTipsType then
    self.CommonPetDetails:SetSpecificOpenPetTipsType(TipEnum.OpenPetTipsType.HomePlantGuard)
  end
  self.UMG_CollectBtn:UpdateInfo(self.petData.partner_mark, true)
  if petInfo.isInGuard then
    self.NRCSwitcher_46:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_46:SetActiveWidgetIndex(1)
  end
end

function UMG_ProtectionPetDetailsPanel_C:OnRecommendedBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_ChangePetConfirmPanel_C:OnRecommendedBtnClick")
  _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdOpenDistrictMapGuide, self.petData)
end

return UMG_ProtectionPetDetailsPanel_C
