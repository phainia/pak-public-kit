local UMG_SeasonalActivities_C = _G.NRCPanelBase:Extend("UMG_SeasonalActivities_C")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")

function UMG_SeasonalActivities_C:OnActive(seasonId)
  self.seasonId = seasonId
  self.currentPageIndex = 1
  self.focusGroupData = {}
  if self.seasonId then
    local seasonConf = _G.DataConfigManager:GetSeasonConf(self.seasonId)
    if seasonConf and seasonConf.focus_group and #seasonConf.focus_group > 0 then
      self.focusGroupData = seasonConf.focus_group
    else
      Log.Error("UMG_SeasonalActivities_C:OnActive focus_group is nil or empty season_id = ", self.seasonId)
    end
  else
    Log.Error("UMG_SeasonalActivities_C:OnActive seasonId is nil")
  end
  self:OnAddEventListener()
  self:InitUI()
  self:PlayAnimation(self.In)
end

function UMG_SeasonalActivities_C:OnDeactive()
  Log.Info("UMG_SeasonalActivities_C:OnDeactive")
end

function UMG_SeasonalActivities_C:OnAddEventListener()
  self:AddButtonListener(self.NextPageBtn.btnLevelUp, self.OnClickNextPageBtn)
end

function UMG_SeasonalActivities_C:InitUI()
  self.btnClose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.OnClickNextBtn
  CommonBtnArrowData1.modeIndex = 4
  self.Btn1:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.OnClickPrevBtn
  CommonBtnArrowData2.modeIndex = 3
  self.Btn2:SetBtnInfo(CommonBtnArrowData2)
  self:UpdatePage()
end

function UMG_SeasonalActivities_C:UpdatePage()
  if not self.focusGroupData or 0 == #self.focusGroupData then
    Log.Error("UMG_SeasonalActivities_C:UpdatePage focusGroupData is empty")
    return
  end
  local currentPageData = self.focusGroupData[self.currentPageIndex]
  if not currentPageData then
    Log.Error("UMG_SeasonalActivities_C:UpdatePage currentPageData is nil at index = ", self.currentPageIndex)
    return
  end
  if currentPageData.focus_img_path and currentPageData.focus_img_path ~= "" then
    self.NRCImage_Activities:SetPath(currentPageData.focus_img_path)
    self.NRCImage_Activities:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCImage_Activities:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.currentPageIndex > 1 then
    self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.currentPageIndex < #self.focusGroupData then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.NextPageBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if currentPageData.option_name and "" ~= currentPageData.option_name then
    self.NextPageBtn:SetBtnText(currentPageData.option_name)
  end
end

function UMG_SeasonalActivities_C:OnClickNextBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_SeasonalActivities_C:OnClickNextBtn")
  if self.currentPageIndex < #self.focusGroupData then
    self.currentPageIndex = self.currentPageIndex + 1
    self:UpdatePage()
  end
end

function UMG_SeasonalActivities_C:OnClickPrevBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_SeasonalActivities_C:OnClickNextBtn")
  if self.currentPageIndex > 1 then
    self.currentPageIndex = self.currentPageIndex - 1
    self:UpdatePage()
  end
end

function UMG_SeasonalActivities_C:OnClickNextPageBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_SeasonalActivities_C:OnClickNextPageBtn")
  local currentPageData = self.focusGroupData[self.currentPageIndex]
  if not currentPageData then
    Log.Error("UMG_SeasonalActivities_C:OnClickNextPageBtn currentPageData is nil at index = ", self.currentPageIndex)
    return
  end
  if 1 == currentPageData.option_skip_type then
    self.currentPageIndex = self.currentPageIndex + 1
    self:UpdatePage()
  elseif 2 == currentPageData.option_skip_type then
    self:HandleGotoChoice()
  else
    Log.Error("UMG_SeasonalActivities_C:OnClickNextPageBtn unknown option_skip_type = ", currentPageData.option_skip_type)
  end
end

function UMG_SeasonalActivities_C:HandleGotoChoice()
  Log.Info("UMG_SeasonalActivities_C:HandleGotoChoice")
  local currentPageData = self.focusGroupData[self.currentPageIndex]
  if not currentPageData then
    Log.Error("UMG_SeasonalActivities_C:HandleGotoChoice currentPageData is nil")
    return
  end
  _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.SendZoneSetSeasonFirstPopReq, ProtoEnum.SeasonPagePlayType.SPPT_POP_WINDOWS)
  if 2 == currentPageData.option_skip_type and currentPageData.jump_param and currentPageData.jump_param ~= "" then
    if currentPageData.jump_param then
      local param1 = currentPageData.param1 or ""
      local param2 = currentPageData.param2 or ""
      local param3 = currentPageData.param3 or ""
      if "" ~= param1 and tonumber(param1) then
        param1 = tonumber(param1)
      end
      if "" ~= param2 and tonumber(param2) then
        param2 = tonumber(param2)
      end
      if "" ~= param3 and tonumber(param3) then
        param3 = tonumber(param3)
      end
      _G.NRCModuleManager:DoCmd(currentPageData.jump_param, param1, param2, param3)
    else
      Log.Error("UMG_SeasonalActivities_C:HandleGotoChoice currentPageData.jump_param is nil jump_param = ", currentPageData.jump_param)
    end
  end
  local seasonInfo = table.deepCopy(_G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo))
  if seasonInfo then
    for i = 1, #seasonInfo.part_info do
      if 101 == seasonInfo.part_info[i].part_id then
        local item_id = seasonInfo.part_info[i].item_id
        _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPoint, 442, {101, item_id})
      end
    end
  end
  self:DoClose()
end

function UMG_SeasonalActivities_C:OnClickCloseBtn()
  Log.Info("UMG_SeasonalActivities_C:OnClickCloseBtn")
  _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.SendZoneSetSeasonFirstPopReq, ProtoEnum.SeasonPagePlayType.SPPT_POP_WINDOWS)
  self:DoClose()
end

return UMG_SeasonalActivities_C
