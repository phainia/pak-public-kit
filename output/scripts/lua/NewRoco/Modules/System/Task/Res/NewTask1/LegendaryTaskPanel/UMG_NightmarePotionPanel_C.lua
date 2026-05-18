local UMG_NightmarePotionPanel_C = _G.NRCPanelBase:Extend("UMG_NightmarePotionPanel_C")

function UMG_NightmarePotionPanel_C:OnActive(_PageId)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    self:OnAddEventListener()
    return
  end
  self:SetEnableClick(false)
  self:SetBtnArrow()
  self.data = self.module:GetData("TaskModuleData")
  self.NightmareList = self.data.NightmareList
  local PageId = 1
  if _PageId then
    PageId = _PageId
  end
  for i = 1, #self.NightmareList do
    if PageId == self.NightmareList[i].id then
      self.PanelIndex = i
      self.PageId = PageId
      self.TaskDone = self.NightmareList[i].TaskDone
      break
    end
  end
  self:SetInfo()
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(1117, "UMG_NightmarePotionPanel_C:OnActive")
  if self.TaskDone then
    self:PlayAnimation(self.Finish_in)
  else
    self:PlayAnimation(self.Panel_in)
  end
  UE4Helper.SetDesiredShowCursor(true, "UMG_NightmarePotionPanel_C")
end

function UMG_NightmarePotionPanel_C:SetInfo()
  self:SendZoneSetBookReadedReq()
  self.FrontIndex = self.PanelIndex - 1
  if self.FrontIndex > 0 then
    self.Btn2:ShowOrHideBtnArrow(true)
    self.FrontPageId = self.NightmareList[self.FrontIndex].id
    if self.FrontPageId then
      self.Btn2.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_NIGHTMARE,
        self.FrontPageId
      })
    end
  else
    self.Btn2:ShowOrHideBtnArrow(false)
  end
  self.NextIndex = self.PanelIndex + 1
  if self.NextIndex <= #self.NightmareList then
    self.Btn1:ShowOrHideBtnArrow(true)
    self.NextPageId = self.NightmareList[self.NextIndex].id
    if self.NextPageId then
      self.Btn1.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_NIGHTMARE,
        self.NextPageId
      })
    end
  else
    self.Btn1:ShowOrHideBtnArrow(false)
  end
  local NightMareConf = _G.DataConfigManager:GetTaleNightmareConf(self.PageId)
  self.IconBg:SetPath(NightMareConf.main_res)
  self.PanelTitle:SetText(NightMareConf.title)
  if 1 == #NightMareConf.matl_conf then
    self.SizeBox2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Spacer_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 2 == #NightMareConf.matl_conf then
    self.SizeBox2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Spacer_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SizeBox3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 3 == #NightMareConf.matl_conf then
    self.SizeBox2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Spacer_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  for i, v in ipairs(NightMareConf.matl_conf) do
    if v.matl_num and 0 ~= v.matl_num then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(v.matl_bag_item)
      if BagItemConf then
        self["Title_" .. i]:SetText(BagItemConf.name)
        self["Icon" .. i]:SetPath(BagItemConf.big_icon)
        self["Text_" .. i]:SetText(v.matl_text)
        local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, v.matl_bag_item)
        local num = bagItemData and bagItemData.num or 0
        self["CompletedQuantityBg" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if num >= v.matl_num then
          self["CompletedQuantityBg" .. i]:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#5CA011FF"))
          self["CompletedQuantityCheck" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self["NRCText_Quantity" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        else
          self["CompletedQuantityBg" .. i]:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#62605EFF"))
          self["CompletedQuantityCheck" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self["NRCText_Quantity" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self["NRCText_Quantity" .. i]:SetText(string.format("%d/%d", num, v.matl_num))
        end
      end
    else
      self["CompletedQuantityBg" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self["CompletedQuantityCheck" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self["NRCText_Quantity" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.TaskDone then
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NPC:SetPath(NightMareConf.npc_res)
    self.Task_Desc:SetText(NightMareConf.task_des)
    self.Signet:SetPath(NightMareConf.task_seal)
    for i = 1, 3 do
      self["CompletedQuantityBg" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self["CompletedQuantityCheck" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self["NRCText_Quantity" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_NightmarePotionPanel_C:SetBtnArrow()
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.NextPage
  CommonBtnArrowData1.modeIndex = 4
  self.Btn1:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.FrontPage
  CommonBtnArrowData2.modeIndex = 3
  self.Btn2:SetBtnInfo(CommonBtnArrowData2)
end

function UMG_NightmarePotionPanel_C:SendZoneSetBookReadedReq()
  self.module:SendZoneSetBookReadedReq(ProtoEnum.TaleTaskType.TALE_NIGHTMARE, self.PageId)
end

function UMG_NightmarePotionPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  UE4Helper.ReleaseDesiredShowCursor("UMG_NightmarePotionPanel_C")
end

function UMG_NightmarePotionPanel_C:ClosePanel()
  self:SetEnableClick(false)
  _G.NRCAudioManager:PlaySound2DAuto(1143, "UMG_NightmarePotionPanel_C:ClosePanel")
  self:PlayAnimation(self.Panel_out)
  if self.TaskDone then
    self:PlayAnimation(self.Task_out)
  end
end

function UMG_NightmarePotionPanel_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.ClosePanel)
end

function UMG_NightmarePotionPanel_C:FrontPage()
  if self.PanelIndex - 1 <= 0 then
    local text = "\230\178\161\230\156\137\228\184\138\228\184\128\233\161\181\228\186\134"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, text)
  else
    if self.TaskDone then
      self:PlayAnimation(self.Task_out)
    end
    self.PanelIndex = self.PanelIndex - 1
    self.PageId = self.data.NightmareList[self.PanelIndex].id
    self.TaskDone = self.data.NightmareList[self.PanelIndex].TaskDone
    self:SetEnableClick(false)
    _G.NRCAudioManager:PlaySound2DAuto(1248, "UMG_NightmarePotionPanel_C:FrontPage")
    self:PlayAnimation(self.Word_change)
  end
end

function UMG_NightmarePotionPanel_C:SetEnableClick(CanClick)
  if CanClick then
    self.BtnClose:SetIsEnabled(CanClick)
    self.Btn1.btnLevelUp:SetIsEnabled(CanClick)
    self.Btn2.btnLevelUp:SetIsEnabled(CanClick)
  else
    self.BtnClose:SetIsEnabled(CanClick)
    self.Btn1.btnLevelUp:SetIsEnabled(CanClick)
    self.Btn2.btnLevelUp:SetIsEnabled(CanClick)
  end
end

function UMG_NightmarePotionPanel_C:NextPage()
  if self.PanelIndex + 1 > #self.NightmareList then
    local text = "\230\178\161\230\156\137\228\184\139\228\184\128\233\161\181\228\186\134"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, text)
  else
    if self.TaskDone then
      self:PlayAnimation(self.Task_out)
    end
    self.PanelIndex = self.PanelIndex + 1
    self.PageId = self.data.NightmareList[self.PanelIndex].id
    self.TaskDone = self.data.NightmareList[self.PanelIndex].TaskDone
    self:SetEnableClick(false)
    _G.NRCAudioManager:PlaySound2DAuto(1248, "UMG_NightmarePotionPanel_C:NextPage")
    self:PlayAnimation(self.Word_change)
  end
end

function UMG_NightmarePotionPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Panel_out then
    self:DoClose()
  end
  if Anim == self.Panel_in or Anim == self.Finish_in then
    self:SetEnableClick(true)
  end
  if Anim == self.Word_change then
    self:SetInfo()
    if self.TaskDone then
      self:PlayAnimation(self.Task_in)
    end
    self:PlayAnimation(self.Word_in)
  end
  if Anim == self.Word_in then
    self:SetEnableClick(true)
  end
end

return UMG_NightmarePotionPanel_C
