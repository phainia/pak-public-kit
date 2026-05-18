local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetReportPetListItem_C = Base:Extend("UMG_PetReportPetListItem_C")

function UMG_PetReportPetListItem_C:OnConstruct()
  self:AddButtonListener(self.PetButton, self.OnClickedPetButton)
  self:AddButtonListener(self.MultiplyingPowerButton, self.OnClickedMultiplyingPowerButton)
end

function UMG_PetReportPetListItem_C:OnDestruct()
  self:RemoveButtonListener(self.PetButton)
  self:RemoveButtonListener(self.MultiplyingPowerButton)
end

function UMG_PetReportPetListItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:InitUI()
end

function UMG_PetReportPetListItem_C:InitUI()
  if self.uiData and self.uiData.pet_brief then
    if self.uiData.pet_brief.base_conf_id and self.uiData.pet_brief.mutation_type and self.uiData.pet_brief.glass_info then
      self.ItemIcon:SetIconPathAndMaterial(self.uiData.pet_brief.base_conf_id, self.uiData.pet_brief.mutation_type, self.uiData.pet_brief.glass_info)
    end
    if self.uiData.pet_brief.name then
      self.NameText:SetText(self.uiData.pet_brief.name)
    end
    if self.uiData.pet_brief.level then
      self.NumText:SetText(string.format("%d", self.uiData.pet_brief.level))
    end
    if self.uiData.pet_brief.is_first_catch then
      self.NewIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.NewIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.uiData and self.uiData.total_coin then
    self.QuantityMoney:SetText(tostring(self.uiData.total_coin))
  end
  if self.uiData and self.uiData.final_ratio then
    local showTip = _G.DataConfigManager:GetLocalizationConf("report_ratio")
    if showTip and showTip.msg then
      if _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsInteger, self.uiData.final_ratio) then
        self.MultiplyingPowerText:SetText(string.format(showTip.msg, tostring(math.floor(self.uiData.final_ratio))))
      else
        self.MultiplyingPowerText:SetText(string.format(showTip.msg, string.format("%.1f", self.uiData.final_ratio)))
      end
    end
    local color
    local report_text_super = _G.DataConfigManager:GetPetGlobalConfig("report_text_super")
    local report_text_hard = _G.DataConfigManager:GetPetGlobalConfig("report_text_hard")
    local report_text_middle = _G.DataConfigManager:GetPetGlobalConfig("report_text_middle")
    local report_text_easy = _G.DataConfigManager:GetPetGlobalConfig("report_text_easy")
    if report_text_super and report_text_hard and report_text_middle and report_text_easy then
      if report_text_hard.num and self.uiData.final_ratio >= report_text_hard.num then
        color = report_text_super.str
      elseif report_text_hard.num and report_text_middle.num and self.uiData.final_ratio >= report_text_middle.num and self.uiData.final_ratio < report_text_hard.num then
        color = report_text_hard.str
      elseif report_text_middle.num and report_text_easy.num and self.uiData.final_ratio >= report_text_easy.num and self.uiData.final_ratio < report_text_middle.num then
        color = report_text_middle.str
      elseif report_text_easy.num and self.uiData.final_ratio > 0 and self.uiData.final_ratio < report_text_easy.num then
        color = report_text_easy.str
      end
    end
    if color then
      self.QualityBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
    end
  end
end

function UMG_PetReportPetListItem_C:OnClickedPetButton()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetReportPetListItem_C:OnClickedPetButton")
  if self.uiData and self.uiData.pet_brief then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.ShowChangePetConfirm, self.uiData.pet_brief)
  end
end

function UMG_PetReportPetListItem_C:OnClickedMultiplyingPowerButton()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetReportPetListItem_C:OnClickedMultiplyingPowerButton")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetReportParticulars, self.uiData.index, true)
end

function UMG_PetReportPetListItem_C:OnDeactive()
end

function UMG_PetReportPetListItem_C:OnAnimationFinished(Anim)
  if Anim == self.Press then
    self:PlayAnimation(self.Up)
  end
end

return UMG_PetReportPetListItem_C
