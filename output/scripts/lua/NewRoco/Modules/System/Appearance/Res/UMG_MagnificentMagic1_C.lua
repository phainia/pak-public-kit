local UMG_MagnificentMagic1_C = _G.NRCPanelBase:Extend("UMG_MagnificentMagic1_C")

function UMG_MagnificentMagic1_C:OnConstruct()
  self:SetChildViews(self.PopUp, self.Video)
  self.Video:OnConstruct(self)
  self.Video.bAutoPlay = true
end

function UMG_MagnificentMagic1_C:OnActive(context)
  self.context = context
  self:OnAddEventListener()
  if not context then
    Log.Error("\229\176\157\232\175\149\230\137\147\229\188\128\228\184\128\228\184\170\231\169\186\230\179\149\230\157\150\231\154\132\229\188\185\231\170\151")
    return
  end
  self.Video:OnActive()
  if context.bIsWand then
    local wandContext = context.context
    if not wandContext or 0 == wandContext.WandId then
      return
    end
    self.wandConf = _G.DataConfigManager:GetFashionWandConf(wandContext.WandId)
    if not self.wandConf then
      Log.Error(string.format("\229\175\185\229\186\148Wand\231\154\132\232\161\168\230\160\188\230\149\176\230\141\174\230\156\170\229\156\168FASHION_WAND_CONF\229\189\147\228\184\173\230\137\190\229\136\176\239\188\140wand id\228\184\186\239\188\154%s", wandContext.WandId))
      return
    end
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local gender = localPlayer.gender
    self.videoPath = nil
    if 1 == gender then
      self.videoPath = self.wandConf.wand_video_male
    else
      self.videoPath = self.wandConf.wand_video_female
    end
  elseif context.bIsPendanta then
    local pendataContext = context.context
    if not pendataContext or 0 == pendataContext.itemId then
      return
    end
    self.pendantaConf = _G.DataConfigManager:GetFashionBagcharmConf(pendataContext.itemId)
    if not self.pendantaConf then
      Log.Error(string.format("\229\175\185\229\186\148\229\140\133\230\140\130\231\154\132\232\161\168\230\160\188\230\149\176\230\141\174\230\156\170\229\156\168FASHION_BAGCHARM_CONF\229\189\147\228\184\173\230\137\190\229\136\176\239\188\140item id\228\184\186\239\188\154%s", pendataContext.itemId))
      return
    end
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local gender = localPlayer.gender
    self.videoPath = nil
    if 1 == gender then
      self.videoPath = self.pendantaConf.charm_video_male
    else
      self.videoPath = self.pendantaConf.charm_video_female
    end
  end
  self:InitPanel()
end

function UMG_MagnificentMagic1_C:OnDeactive()
end

function UMG_MagnificentMagic1_C:OnDestruct()
  self:OnRemoveEventListener()
  self.Video:OnDestruct()
end

function UMG_MagnificentMagic1_C:SetCommonPopUpInfo()
  local commonPopUpData = _G.NRCCommonPopUpData()
  if self.context.bIsWand then
    commonPopUpData.TitleText = _G.LuaText.popup_magic_wand
  else
    commonPopUpData.TitleText = _G.LuaText.popup_bagcharm_title
  end
  commonPopUpData.Call = self
  commonPopUpData.ClosePanelHandler = self.OnCloseBtnClicked
  self.OnPcCloseHandler = commonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(commonPopUpData)
end

function UMG_MagnificentMagic1_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_MagnificentMagic1_C:OnCloseBtnClicked")
  self.Video:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:LoadAnimation(2)
end

function UMG_MagnificentMagic1_C:OnAddEventListener()
  self:BindInputAction()
  self:AddButtonListener(self.Play.btnLevelUp, self.OnPlayButtonClicked)
  self:AddButtonListener(self.Pause.btnLevelUp, self.OnPauseButtonClicked)
  self.Video:AddOnEndReached(self, self.MovieDone)
  self.Video:AddOnSeekCompleted(self, self.MovieSeekComplete)
  self:AddButtonListener(self.HandHoldingPrivilege, self.OnHandHoldingPrivilegeClicked)
  self:SetCommonPopUpInfo()
end

function UMG_MagnificentMagic1_C:OnRemoveEventListener()
  self:UnBindInputAction()
  self.Video:RemoveOnEndReached(self, self.MovieDone)
end

function UMG_MagnificentMagic1_C:InitPanel()
  self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:LoadAnimation(0)
  if self.videoPath and self.videoPath ~= "" then
    self.Video:OnActive()
    self:SetBtnVisibility(true)
    self.Video:CloseMedia()
    local paramTable = {
      source = self.videoPath,
      needAutoPlay = true,
      isLoop = false
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
  end
  if self.context.bIsWand then
    self.Text1:SetText(self.wandConf.wand_tips_text)
  elseif self.context.bIsPendanta then
    self.Text1:SetText(self.pendantaConf.details_text)
    if self.pendantaConf.charm_kind == _G.Enum.BagCharm.BGC_PETCHARM and 0 ~= self.pendantaConf.privilege_effect then
      self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  end
end

function UMG_MagnificentMagic1_C:OnPlayButtonClicked()
  self:SetBtnVisibility(true)
  self.Video:Play()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic1_C:OnPlayButtonClicked")
end

function UMG_MagnificentMagic1_C:OnPauseButtonClicked()
  self:SetBtnVisibility(false)
  self.Video:Pause()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagnificentMagic1_C:OnPauseButtonClicked")
end

function UMG_MagnificentMagic1_C:MovieDone()
  self.Video:Seek(UE.UKismetMathLibrary.FromSeconds(0))
end

function UMG_MagnificentMagic1_C:MovieSeekComplete()
  self.Video:Pause()
  self:SetBtnVisibility(false)
end

function UMG_MagnificentMagic1_C:SetBtnVisibility(bPlay)
  if bPlay then
    self.Pause:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Play:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Pause:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Play:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagnificentMagic1_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:BindAction("IA_PlayMagicVideo", self, "OnVideoPlayOrPause", UE.ETriggerEvent.Triggered)
  end
end

function UMG_MagnificentMagic1_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:UnBindAction("IA_PlayMagicVideo")
  end
end

function UMG_MagnificentMagic1_C:OnVideoPlayOrPause()
  if self.Video.MediaPlayer:IsPlaying() then
    self:OnPauseButtonClicked()
  else
    self:OnPlayButtonClicked()
  end
end

function UMG_MagnificentMagic1_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_MagnificentMagic1_C:OnHandHoldingPrivilegeClicked()
end

return UMG_MagnificentMagic1_C
