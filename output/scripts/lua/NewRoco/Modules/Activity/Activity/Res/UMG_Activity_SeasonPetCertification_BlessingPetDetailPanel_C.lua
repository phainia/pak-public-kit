local UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C = _G.NRCPanelBase:Extend("UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnConstruct()
  self:SetChildViews(self.CommonPetDetails, self.UMG_PetRate)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnActive(petInfo, parent, closeCallback)
  _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnActive")
  self:OnAddEventListener()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self.NRCSwitcher_46:SetActiveWidgetIndex(1)
  self.parent = parent
  self.closeCallback = closeCallback
  self.petData = petInfo
  self:UpdatePanel(petInfo)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnAddEventListener()
  self:RegisterEvent(self, ActivityModuleEvent.UpdateCertificationDetailPanel, self.UpdatePanel)
  self:AddButtonListener(self.Btn_Details, self.ClosePanel)
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.ClosePanel)
  self:AddButtonListener(self.GuardBtn.btnLevelUp, self.OnClickBtnGuard)
  self:AddButtonListener(self.RecommendedBtn.btnLevelUp, self.OnRecommendedBtnClick)
  self:AddButtonListener(self.BtnRechristen_1, self.OpenPetTips)
  self:AddButtonListener(self.BloodPulse, self.OnBloodPulse)
  self:AddButtonListener(self.UMG_CollectBtn.Button, self.OnCollectBtn)
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:RegisterEvent(self, PetUIModuleEvent.UpdatePetCollect, self.UpdateCollect)
  end
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.UpdateCertificationDetailPanel)
  self:RemoveButtonListener(self.Btn_Details)
  self:RemoveButtonListener(self.UMG_btnClose.btnClose)
  self:RemoveButtonListener(self.GuardBtn.btnLevelUp)
  self:RemoveButtonListener(self.RecommendedBtn.btnLevelUp)
  self:RemoveButtonListener(self.BtnRechristen_1)
  self:RemoveButtonListener(self.BloodPulse)
  self:RemoveButtonListener(self.UMG_CollectBtn.Button)
  local petUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if petUIModule then
    petUIModule:UnRegisterEvent(self, PetUIModuleEvent.UpdatePetCollect)
  end
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:UpdateCollect(partner_mark)
  self.petData.partner_mark = partner_mark
  self.UMG_CollectBtn:UpdateInfo(partner_mark)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnCollectBtn()
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetCollectPanel, self.petData.gid, self.petData.partner_mark)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnBloodPulse()
  local petData = self.petData
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetBloodPulse, petData, TipEnum.OpenPetTipsType.HomePlantGuard)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OpenPetTips()
  local petData = self.petData
  local uidata = {petData = petData}
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, uidata, _G.Enum.GoodsType.GT_PET)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnRecommendedBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnRecommendedBtnClick")
  _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdOpenDistrictMapGuide, self.petData)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:UpdatePanel(petInfo)
  if not petInfo then
    self:DoClose()
    return
  end
  self:PlayAnimation(self.Change)
  self:SetPetInfo(petInfo)
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:SetPetInfo(petInfo)
  self.petData = petInfo
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
  local breakThroughStarsList = PetUtils.GetBreakThroughStarsList(self.petData)
  self.CatchHardLv:InitGridView(breakThroughStarsList)
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
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:ClosePanel")
  self.closeCallback(self.parent, false)
  self:OnClose()
end

function UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnClickBtnGuard()
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C:OnClickBtnGuard")
  self.closeCallback(self.parent, true)
end

return UMG_Activity_SeasonPetCertification_BlessingPetDetailPanel_C
