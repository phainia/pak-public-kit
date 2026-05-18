local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_MagnificentMagic_C = _G.NRCPanelBase:Extend("UMG_MagnificentMagic_C")

function UMG_MagnificentMagic_C:OnConstruct()
  self:SetChildViews(self.PopUp, self.Video)
  self.suitIdList = {}
  self.curPageIndex = 1
  self.totalPageIndex = 1
  self.curSuitConf = nil
  self:SetArrowVisible(self.curPageIndex)
  self.Video:OnConstruct(self)
  self.Video:SetAutoPlay(true)
  self.testChange = false
  self.RecordSuitId = nil
  self.RecordFinishVideoNum = 0
  self.TotalVideoNum = 0
  self.shopId = nil
end

function UMG_MagnificentMagic_C:OnActive(goodsType, itemId, extraData)
  self:LoadAnimation(0)
  self.Video:OnActive()
  self:OnAddEventListener()
  self:SetCommonPopUpInfo()
  if extraData and extraData.shopId then
    self.shopId = extraData.shopId
  end
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  if goodsType == Enum.GoodsType.GT_FASHION_PACKAGE then
    table.copy(_G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetAllSuitsInPackage, itemId), self.suitIdList)
  elseif goodsType == Enum.GoodsType.GT_FASHION_SUITS then
    table.insert(self.suitIdList, itemId)
  end
  self:UpdatePanelInfo()
end

function UMG_MagnificentMagic_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    return
  end
end

function UMG_MagnificentMagic_C:OnAddEventListener()
  self:BindInputAction()
  self:AddButtonListener(self.LeftArrow.btnLevelUp, self.OnLeftArrowClicked)
  self:AddButtonListener(self.RightArrow.btnLevelUp, self.OnRightArrowClicked)
  self:AddButtonListener(self.Play.btnLevelUp, self.OnPlayBtnClicked)
  self:AddButtonListener(self.Pause.btnLevelUp, self.OnPauseBtnClicked)
  self.Video:AddOnEndReached(self, self.MovieDone)
  self.Video:AddOnSeekCompleted(self, self.MovieSeekCompleted)
end

function UMG_MagnificentMagic_C:OnRemoveEventListener()
  self:UnBindInputAction()
  self.Video:RemoveOnEndReached(self, self.MovieDone)
end

function UMG_MagnificentMagic_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:BindAction("IA_PlayMagicVideo", self, "OnVideoPlayOrPause")
  end
end

function UMG_MagnificentMagic_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:UnBindAction("IA_PlayMagicVideo")
  end
end

function UMG_MagnificentMagic_C:MovieDone()
  self.Video:Seek(UE.UKismetMathLibrary.FromSeconds(0))
  Log.Debug("UMG_MagnificentMagic_C:MovieDone", self.RecordSuitId, self.RecordFinishVideoNum, self.TotalVideoNum)
  if self.shopId then
    local shopConf = _G.DataConfigManager:GetShopConf(self.shopId)
    if shopConf and shopConf.shop_type == Enum.ShopType.ST_FASHION_RANDOM then
      self.RecordFinishVideoNum = self.RecordFinishVideoNum + 1
      if self.RecordFinishVideoNum >= self.TotalVideoNum then
        local key = "FashionMagicInteractionLog"
        local roleDataStr = _G.GEMPostManager:GetRoleDataForTLog()
        local value = string.format("%s|%s|%d|%d", key, roleDataStr, self.RecordSuitId, 1)
        Log.Debug("UMG_MagnificentMagic_C:MovieDone", key, value)
        _G.GEMPostManager:SendNRCTLog(key, value)
      end
    end
  end
end

function UMG_MagnificentMagic_C:MovieSeekCompleted()
  self.Video:Pause()
  self:SetBtnVisibility(false)
end

function UMG_MagnificentMagic_C:OnDestruct()
  self:OnRemoveEventListener()
  self.Video:OnDestruct()
end

function UMG_MagnificentMagic_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("popup_fashion_magic").msg
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 2
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtnClicked
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_MagnificentMagic_C:OnCloseBtnClicked()
  self:LoadAnimation(2)
end

function UMG_MagnificentMagic_C:OnLeftArrowClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_MagnificentMagic_C:OnLeftArrowClicked")
  self.curPageIndex = self.curPageIndex - 1
  self:SetArrowVisible(self.curPageIndex)
  self:UpdateRightPanelInfo()
end

function UMG_MagnificentMagic_C:OnRightArrowClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_MagnificentMagic_C:OnRightArrowClicked")
  self.curPageIndex = self.curPageIndex + 1
  self:SetArrowVisible(self.curPageIndex)
  self:UpdateRightPanelInfo()
end

function UMG_MagnificentMagic_C:OnPlayBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic_C:OnPlayBtnClicked")
  self:SetBtnVisibility(true)
  self.Video:Play()
end

function UMG_MagnificentMagic_C:OnPauseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic_C:OnPauseBtnClicked")
  self:SetBtnVisibility(false)
  self.Video:Pause()
end

function UMG_MagnificentMagic_C:OnVideoPlayOrPause()
  if self.Video.MediaPlayer:IsPlaying() then
    self:OnPauseBtnClicked()
  else
    self:OnPlayBtnClicked()
  end
end

function UMG_MagnificentMagic_C:UpdatePanelInfo()
  self.TabList:InitGridView(self.suitIdList)
  self:DelayFrames(1, function()
    self.TabList:SelectItemByIndex(0)
  end)
end

function UMG_MagnificentMagic_C:UpdateRightPanelInfo()
  self:SetBtnVisibility(true)
  self:RefreshDots()
  local suitEffectTips = self.curSuitConf.suit_effect_tips
  if suitEffectTips and #suitEffectTips >= self.curPageIndex then
    local effectTip = suitEffectTips[self.curPageIndex].tips_text
    self.Text1:SetText(effectTip)
    self.Video:CloseMedia()
    local videoPath = suitEffectTips[self.curPageIndex].tips_image
    local paramTable = {
      source = videoPath,
      needAutoPlay = true,
      isLoop = false,
      forceStopAudioWhenClose = false,
      bEncryptVideo = true
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
  end
end

function UMG_MagnificentMagic_C:RefreshDots()
  if self.totalPageIndex > 1 then
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Dot_List:InitGridView(self.curSuitConf.suit_effect_tips)
    self.Dot_List:SelectItemByIndex(self.curPageIndex - 1)
  else
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MagnificentMagic_C:OnMagicVideoSuitSelected(suitId)
  self.curSuitConf = _G.DataConfigManager:GetFashionSuitsConf(suitId)
  self.totalPageIndex = #self.curSuitConf.suit_effect_tips
  self.curPageIndex = 1
  self:UpdateRightPanelInfo()
  self:SetArrowVisible(self.curPageIndex)
  self.RecordSuitId = suitId
  self.RecordFinishVideoNum = 0
  self.TotalVideoNum = #self.curSuitConf.suit_effect_tips
end

function UMG_MagnificentMagic_C:SetArrowVisible(curPageIndex)
  if self.totalPageIndex <= 1 then
    self.LeftArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RightArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif curPageIndex <= 1 then
    self.LeftArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RightArrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif curPageIndex >= self.totalPageIndex then
    self.LeftArrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.RightArrow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.LeftArrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.RightArrow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagnificentMagic_C:SetBtnVisibility(bPlay)
  if bPlay then
    self.Pause:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Play:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Pause:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Play:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagnificentMagic_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_MagnificentMagic_C:OnDotItemSelected(index)
  if index == self.curPageIndex then
    return
  end
  self.curPageIndex = index
  self:SetArrowVisible(self.curPageIndex)
  self:SetBtnVisibility(true)
  local suitEffectTips = self.curSuitConf.suit_effect_tips
  if suitEffectTips and #suitEffectTips >= self.curPageIndex then
    local effectTip = suitEffectTips[self.curPageIndex].tips_text
    self.Text1:SetText(effectTip)
    self.Video:CloseMedia()
    local videoPath = suitEffectTips[self.curPageIndex].tips_image
    local paramTable = {
      source = videoPath,
      needAutoPlay = true,
      isLoop = false,
      forceStopAudioWhenClose = false,
      bEncryptVideo = true
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
  end
end

return UMG_MagnificentMagic_C
