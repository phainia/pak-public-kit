local UMG_MagicExtractPanel_C = _G.NRCPanelBase:Extend("UMG_MagicExtractPanel_C")

function UMG_MagicExtractPanel_C:OnActive(_PageId)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    self:OnAddEventListener()
    return
  end
  self.data = self.module:GetData("TaskModuleData")
  self.MagicExtractList = self.data.MagicExtractList
  local PageId = self.MagicExtractList[1].id
  if _PageId then
    PageId = _PageId
  end
  for i = 1, #self.MagicExtractList do
    if PageId == self.MagicExtractList[i].id then
      self.PanelIndex = i
      self.PageId = PageId
      self.TaskDone = self.MagicExtractList[i].TaskDone
      self.RewardDone = self.MagicExtractList[i].reward
      break
    end
    if i == #self.MagicExtractList then
      self.PanelIndex = 1
      self.PageId = self.MagicExtractList[1].id
      self.TaskDone = self.MagicExtractList[1].TaskDone
      self.RewardDone = self.MagicExtractList[1].reward
    end
  end
  self.isFirst = true
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetBtnArrow()
  self:SetInfo(self.PageId)
  self:OnAddEventListener()
  UE4Helper.SetDesiredShowCursor(true, "UMG_MagicExtractPanel_C")
end

function UMG_MagicExtractPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  UE4Helper.ReleaseDesiredShowCursor("UMG_MagicExtractPanel_C")
end

function UMG_MagicExtractPanel_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.ClosePanel)
end

function UMG_MagicExtractPanel_C:SetInfo()
  self:SendZoneSetBookReadedReq()
  self.FrontIndex = self.PanelIndex - 1
  if self.FrontIndex > 0 then
    self.Btn2:ShowOrHideBtnArrow(true)
    self.FrontPageId = self.MagicExtractList[self.FrontIndex].id
    if self.FrontPageId then
      self.Btn2.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_BLOOD_MAGIC,
        self.FrontPageId
      })
    end
    local BloodMagicConf = _G.DataConfigManager:GetTaleBloodMagicConf(self.FrontPageId)
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(BloodMagicConf.unlock_item)
    self.Btn2:SetBtnIcon(3, BagItemConf.icon)
  else
    self.Btn2:ShowOrHideBtnArrow(false)
  end
  self.NextIndex = self.PanelIndex + 1
  if self.NextIndex <= #self.MagicExtractList then
    self.Btn1:ShowOrHideBtnArrow(true)
    self.NextPageId = self.MagicExtractList[self.NextIndex].id
    if self.NextPageId then
      self.Btn1.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_BLOOD_MAGIC,
        self.NextPageId
      })
    end
    local BloodMagicConf = _G.DataConfigManager:GetTaleBloodMagicConf(self.NextPageId)
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(BloodMagicConf.unlock_item)
    self.Btn1:SetBtnIcon(3, BagItemConf.icon)
  else
    self.Btn1:ShowOrHideBtnArrow(false)
  end
  self:SetFigureTitleIcon()
  local BloodMagicConf = _G.DataConfigManager:GetTaleBloodMagicConf(self.PageId)
  self.BloodMagicConf = BloodMagicConf
  for i, v in ipairs(BloodMagicConf.text_conf) do
    if i <= 2 then
      self["Title" .. i]:SetText(v.title)
      self["Text" .. i]:SetText(v.text1)
      if not v.text2 then
        self["TextDes" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self["TextDes" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self["TextDes" .. i]:SetText(v.text2)
      end
    end
  end
  self.Icon:SetPath(BloodMagicConf.unlock_res)
  if BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
    self:LoadPanelRes("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask1/Textures/img_MagicExtract_Bg1.img_MagicExtract_Bg1'", -1, self.LoadingBgSucceed, nil, nil)
  else
    self:LoadPanelRes("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask1/Textures/img_MagicExtract_Bg0.img_MagicExtract_Bg0'", -1, self.LoadingBgSucceed, nil, nil)
  end
  self:LoadPanelRes(BloodMagicConf.unlock_res, -1, self.LoadSucceed, nil, nil)
  self:LoadPanelRes(BloodMagicConf.lock_res, -1, self.LoadSucceed1, nil, nil)
  if self.TaskDone then
    self.TextDone:SetText(BloodMagicConf.done_text)
  else
    self.TextDone:SetText(BloodMagicConf.prog_text)
  end
end

function UMG_MagicExtractPanel_C:LoadingBgSucceed(resRequest, asset)
  local CurrentBrush = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(asset)
  CurrentBrush.DrawAs = UE4.ESlateBrushDrawType.Box
  local Padding = UE4.FMargin()
  Padding.Left = 0.9
  Padding.Top = 0
  Padding.Right = 0.1
  Padding.Bottom = 0
  CurrentBrush.Margin = Padding
  self.Bg:SetBrush(CurrentBrush)
end

function UMG_MagicExtractPanel_C:SetFigureTitleIcon()
  if self.PageId then
    local IconPath = "PaperSprite'/Game/NewRoco/Modules/System/Task/Raw/NewTask1/Frames/"
    local icon = "img_MagicExtract_Pattern" .. self.PageId .. "_png"
    self.Figure:SetPath(IconPath .. icon .. "." .. icon .. "'")
  end
end

function UMG_MagicExtractPanel_C:SendZoneSetBookReadedReq()
  self.module:SendZoneSetBookReadedReq(ProtoEnum.TaleTaskType.TALE_BLOOD_MAGIC, self.PageId)
end

function UMG_MagicExtractPanel_C:LoadSucceed1(resRequest, asset)
  if asset then
    local Material1
    if self.BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
      Material1 = self.Black_IconMask:GetDynamicMaterial()
    else
      Material1 = self.IconMask:GetDynamicMaterial()
    end
    Material1:SetTextureParameterValue("Maintex", asset)
  end
end

function UMG_MagicExtractPanel_C:LoadSucceed(resRequest, asset)
  if asset then
    local Material
    if self.BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
      Material = self.Black_icon_light:GetDynamicMaterial()
    else
      Material = self.icon_light:GetDynamicMaterial()
    end
    Material:SetTextureParameterValue("Maintex", asset)
  end
  if self.isFirst then
    _G.NRCAudioManager:PlaySound2DAuto(1117, "UMG_TaskMainPanel_C:OnLacquerBtn1")
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In)
    self.isFirst = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(1248, "UMG_TaskMainPanel_C:OnLacquerBtn1")
    self:PlayAnimation(self.Change_icon)
    self:PlayAnimation(self.Change_word)
  end
  if self.TaskDone and not self.RewardDone then
    _G.NRCAudioManager:PlaySound2DAuto(1202, "UMG_TaskMainPanel_C:OnLacquerBtn1")
    if self.BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
      self:PlayAnimation(self.Unlock_BlackMagic)
    else
      self:PlayAnimation(self.Unlock)
    end
  elseif self.TaskDone then
    self:PlayAnimation(self.Ribbon_in)
    if self.BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
      self:PlayAnimation(self.Blackicon_unlock)
    else
      self:PlayAnimation(self.Icon_unlock)
    end
  elseif not self.TaskDone then
    self:PlayAnimation(self.Ribbon_in)
    if self.BloodMagicConf.template_type == Enum.BloodMagicTempType.BMT_BLACK_MAGIC then
      self:PlayAnimation(self.Blackicon_lock)
    else
      self:PlayAnimation(self.Icon_lock)
    end
  end
end

function UMG_MagicExtractPanel_C:SendZoneSetBookRewardReq()
  self.RewardDone = true
  self.module:SendZoneSetBookRewardReq(ProtoEnum.TaleTaskType.TALE_BLOOD_MAGIC, self.PageId)
end

function UMG_MagicExtractPanel_C:SetBtnArrow()
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.NextPage
  CommonBtnArrowData1.modeIndex = 2
  self.Btn1:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.FrontPage
  CommonBtnArrowData2.modeIndex = 1
  self.Btn2:SetBtnInfo(CommonBtnArrowData2)
end

function UMG_MagicExtractPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
  if Anim == self.Unlock or Anim == self.Unlock_BlackMagic then
    self:SendZoneSetBookRewardReq()
  end
  if Anim == self.Change_word then
    self:SetButtonClick(true)
  end
end

function UMG_MagicExtractPanel_C:OnAnimationStarted(Anim)
  if Anim == self.Unlock or Anim == self.Unlock_BlackMagic then
    self:DelaySeconds(0.4, function()
      self:PlayAnimation(self.Ribbon_in)
    end)
  end
end

function UMG_MagicExtractPanel_C:ClosePanel()
  self:SetButtonClick(false)
  _G.NRCAudioManager:PlaySound2DAuto(1143, "UMG_TaskMainPanel_C:OnLacquerBtn1")
  self:PlayAnimation(self.Out)
end

function UMG_MagicExtractPanel_C:FrontPage()
  if self.PanelIndex - 1 <= 0 then
    local text = "\230\178\161\230\156\137\228\184\138\228\184\128\233\161\181\228\186\134"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, text)
  else
    self:SetButtonClick(false)
    self.PanelIndex = self.PanelIndex - 1
    if self.MagicExtractList[self.PanelIndex] then
      self.PageId = self.MagicExtractList[self.PanelIndex].id
      self.TaskDone = self.MagicExtractList[self.PanelIndex].TaskDone
      self.RewardDone = self.MagicExtractList[self.PanelIndex].reward
      self:SetInfo()
    end
  end
end

function UMG_MagicExtractPanel_C:NextPage()
  if self.PanelIndex + 1 > #self.MagicExtractList then
    local text = "\230\178\161\230\156\137\228\184\139\228\184\128\233\161\181\228\186\134"
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, text)
  else
    self:SetButtonClick(false)
    self.PanelIndex = self.PanelIndex + 1
    if self.MagicExtractList[self.PanelIndex] then
      self.PageId = self.MagicExtractList[self.PanelIndex].id
      self.TaskDone = self.MagicExtractList[self.PanelIndex].TaskDone
      self.RewardDone = self.MagicExtractList[self.PanelIndex].reward
      self:SetInfo()
    end
  end
end

function UMG_MagicExtractPanel_C:SetButtonClick(CanClick)
  self.BtnClose:SetIsEnabled(CanClick)
  self.Btn1.btnLevelUp:SetIsEnabled(CanClick)
  self.Btn2.btnLevelUp:SetIsEnabled(CanClick)
end

return UMG_MagicExtractPanel_C
