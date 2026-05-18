local UMG_PetReport_Particulars_Share_C = _G.NRCPanelBase:Extend("UMG_PetReport_Particulars_Share_C")

function UMG_PetReport_Particulars_Share_C:OnActive()
end

function UMG_PetReport_Particulars_Share_C:OnDeactive()
end

function UMG_PetReport_Particulars_Share_C:OnAddEventListener()
end

function UMG_PetReport_Particulars_Share_C:InitUI(uiData)
  self.uiData = uiData
  self.PetImage:SetUILocation()
  self:InitPetBaseUI()
  self:InitPetRatioUI()
end

function UMG_PetReport_Particulars_Share_C:InitPetBaseUI()
  if self.uiData and self.uiData.pet_brief then
    if self.uiData.pet_brief.name then
      local name = self.uiData.pet_brief.name
      self.NameText:SetText(name)
    end
    self:SetPetIcon(self.uiData.pet_brief.base_conf_id, self.uiData.pet_brief.mutation_type, self.uiData.pet_brief.glass_info)
    self.Heterochrome:SetMutationIcon(self.uiData.pet_brief)
  end
end

function UMG_PetReport_Particulars_Share_C:SetPetIcon(baseConfID, mutation_type, glass_info)
  if self.uiData.bSpecial then
    self.BgSwitcher:SetActiveWidgetIndex(1)
  else
    self.BgSwitcher:SetActiveWidgetIndex(0)
  end
  self.PetImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PetImage:SetPetIcon(true, baseConfID, mutation_type, glass_info)
end

function UMG_PetReport_Particulars_Share_C:InitPetRatioUI()
  if self.uiData and self.uiData.report_infos and self.uiData.final_ratio and self.uiData.total_coin then
    self.Number_1:SetText(tostring(self.uiData.total_coin))
    if self.uiData.final_ratio then
      local final_ratio = self.uiData.final_ratio / 10000
      if _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsInteger, final_ratio) then
        self.MultiplyingPowerText:SetText(string.format("x%d", math.floor(final_ratio)))
      else
        self.MultiplyingPowerText:SetText(string.format("x%.1f", final_ratio))
      end
      local color
      local report_text_super = _G.DataConfigManager:GetPetGlobalConfig("report_text_super")
      local report_text_hard = _G.DataConfigManager:GetPetGlobalConfig("report_text_hard")
      local report_text_middle = _G.DataConfigManager:GetPetGlobalConfig("report_text_middle")
      local report_text_easy = _G.DataConfigManager:GetPetGlobalConfig("report_text_easy")
      if report_text_super and report_text_hard and report_text_middle and report_text_easy then
        if report_text_hard.num and final_ratio >= report_text_hard.num then
          color = report_text_super.str
        elseif report_text_hard.num and report_text_middle.num and final_ratio >= report_text_middle.num and final_ratio < report_text_hard.num then
          color = report_text_hard.str
        elseif report_text_middle.num and report_text_easy.num and final_ratio >= report_text_easy.num and final_ratio < report_text_middle.num then
          color = report_text_middle.str
        elseif report_text_easy.num and final_ratio > 0 and final_ratio < report_text_easy.num then
          color = report_text_easy.str
        end
      end
      if color then
        self.QualityBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
      end
    end
    local ratioList = {}
    local index = -1
    local needToHide = false
    local talentText = _G.DataConfigManager:GetLocalizationConf("report_ratio_talent_text")
    for _, info in pairs(self.uiData.report_infos or {}) do
      local id = info.id
      if id then
        local ratioConf = _G.DataConfigManager:GetReportCoinRatioConf(id)
        if ratioConf then
          local ratioInfo = {}
          ratioInfo.enum_name = ratioConf.enum_name
          ratioInfo.param_name = ratioConf.param_name
          ratioInfo.ratio = info.ratio / 10000
          ratioInfo.id = id
          table.insert(ratioList, ratioInfo)
          if talentText and talentText.msg then
            if -1 == index and talentText.msg == ratioInfo.enum_name then
              index = #ratioList
            end
            if ratioInfo.ratio > 1 and talentText.msg ~= ratioInfo.enum_name then
              needToHide = true
            end
          end
        end
      end
    end
    if #ratioList > 1 and index > 0 and ratioList[index] and 1 == ratioList[index].ratio and needToHide then
      table.remove(ratioList, index)
    end
    table.sort(ratioList, function(a, b)
      return a.id < b.id
    end)
    self.List:InitGridView(ratioList)
  end
  for i = 1, self.List:GetItemCount() do
    local item = self.List:GetItemByIndex(i - 1)
    if item then
      item.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

return UMG_PetReport_Particulars_Share_C
