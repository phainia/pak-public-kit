local UMG_MainUIRoleHPItem_C = _G.NRCPanelBase:Extend("UMG_MainUIRoleHPItem_C")
local TemperatureEnum = require("NewRoco.Modules.Core.Scene.Component.Temperature.TemperatureEnum")

function UMG_MainUIRoleHPItem_C:OnConstruct()
  Log.Debug("UMG_MainUIRoleHPItem_C:OnConstruct")
  self:PlayAnimation(self.open)
  self.state = TemperatureEnum.HPItemState.NORMAL
  self.StateBeforeTemp = TemperatureEnum.HPItemState.NORMAL
  self.half_injure = false
end

function UMG_MainUIRoleHPItem_C:OnDestruct()
  Log.Debug("UMG_MainUIRoleHPItem_C:OnDestruct")
  self:StopAllAnimations()
  self:CancelDelay()
end

function UMG_MainUIRoleHPItem_C:OnActive()
  Log.Debug("UMG_MainUIRoleHPItem_C:OnActive")
end

function UMG_MainUIRoleHPItem_C:OnDeactive()
  Log.Debug("UMG_MainUIRoleHPItem_C:OnDeactive")
end

function UMG_MainUIRoleHPItem_C:OnAnimationFinished(animation)
  if animation == self.cold_broken or animation == self.hot_broken or animation == self.broken then
    self:StopAllAnimations()
    self:PlayAnimation(self.loop)
    self.blue_img_1:SetRenderOpacity(0)
    self.red_img_1:SetRenderOpacity(0)
    self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif animation == self.get or animation == self.heath then
    if self.state == TemperatureEnum.HPItemState.HOT then
      self:PlayAnimation(self.hot_loop, 0, 0)
    elseif self.state == TemperatureEnum.HPItemState.COLD then
      self:PlayAnimation(self.cold_loop, 0, 0)
    else
      self:PlayAnimation(self.loop)
    end
  elseif animation == self.Prepare_finish then
    self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.half_injure = false
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.PlayHalfInjureFinish)
  elseif animation == self.Prepare_re then
    self.half_injure = false
    self.Fx_prepare_del:SetRenderOpacity(0)
    self.Fx_prepare_re:SetRenderOpacity(0)
  end
end

function UMG_MainUIRoleHPItem_C:SetHpState()
  Log.Debug("UMG_MainUIRoleHPItem_C:SetHpState")
  if not self.half_injure then
    self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MainUIRoleHPItem_C:CustomStopAllAnimations()
  Log.Trace("UMG_MainUIRoleHPItem_C:CustomStopAllAnimations")
  self:StopAllAnimations()
end

function UMG_MainUIRoleHPItem_C:SetVisibleState(state, index, oldhp, curhp, oldMaxhp, maxhp, realMaxHp, bTemporal)
  Log.Debug("ccc UMG_MainUIRoleHPItem_C:SetVisibleState state ", self.index, state, self.Visibility, oldhp, curhp, oldMaxhp, realMaxHp)
  if bTemporal then
    self.StateBeforeTemp = self.state
    self:SetState(TemperatureEnum.HPItemState.TEMPORAL)
  elseif self.state == TemperatureEnum.HPItemState.TEMPORAL then
    self:SetState(self.StateBeforeTemp)
  end
  if self.preVisibilityState and self.preVisibilityState == state then
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if self.half_injure and 0 == localPlayer.serverData.attrs.half_injure then
      local endTime = self.Prepare_re:GetEndTime()
      self:PlayAnimationTimeRange(self.Prepare_re, endTime - 0.02, endTime, 1)
    end
    return
  end
  self.preVisibilityState = state
  if state == UE4.ESlateVisibility.Visible then
    if self.Visibility ~= UE4.ESlateVisibility.Visible then
      self:PlayNorAnima(oldhp, oldMaxhp, index, maxhp, bTemporal)
      self.NRCImagebg:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif self.Visibility ~= UE4.ESlateVisibility.Collapsed then
    Log.Debug("TrySetBroken index", index, oldhp, oldMaxhp)
    self:DelaySeconds(0.033 * (oldhp - index), function()
      if self.preVisibilityState == UE4.ESlateVisibility.Visible then
        return
      end
      self:TrySetBroken(curhp)
      if index > realMaxHp then
        self.NRCImagebg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end)
  end
end

function UMG_MainUIRoleHPItem_C:TrySetBroken(curhp)
  if self.state == TemperatureEnum.HPItemState.HOT then
    _G.NRCAudioManager:PlaySound2DAuto(40008013, "UMG_LevelMain_C:OnSystemIconClicked")
    self:StopAllAnimations()
    if not self.half_injure then
      self:PlayAnimation(self.hot_broken)
    else
      self:PlayAnimation(self.Prepare_finish)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif self.state == TemperatureEnum.HPItemState.COLD then
    self:StopAllAnimations()
    if not self.half_injure then
      _G.NRCAudioManager:PlaySound2DAuto(40008011, "UMG_LevelMain_C:OnSystemIconClicked")
      self:PlayAnimation(self.cold_broken)
    else
      self:PlayAnimation(self.Prepare_finish)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self:StopAllAnimations()
    if not self.half_injure then
      self:PlayAnimation(self.broken)
    else
      self:PlayAnimation(self.Prepare_finish)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:SetState(TemperatureEnum.HPItemState.NORMAL)
end

function UMG_MainUIRoleHPItem_C:IsPlayingRecoverAnm()
  return self:IsAnimationPlaying(self.open) or self:IsAnimationPlaying(self.get) or self:IsAnimationPlaying(self.heath) or self:IsAnimationPlaying(self.loop) or self:IsAnimationPlaying(self.Prepare_finish) or self:IsAnimationPlaying(self.Prepare_re) or self:IsAnimationPlaying(self.Prepare_del)
end

function UMG_MainUIRoleHPItem_C:SetHpBt(hp, preBt, bt, perAnmTime, bForceUpdate)
  local index = self.index - 1
  local btInHp = math.abs(bt) / 10000 * hp
  if 0 == bt then
    local newState = TemperatureEnum.HPItemState.NORMAL
    if not (self.state == newState or self:IsPlayingRecoverAnm()) or bForceUpdate then
      self:StopAllAnimations()
      self:PlayAnimation(self.loop)
      self.blue_img:SetRenderOpacity(0)
      self.red_img:SetRenderOpacity(0)
      self.blue_img_1:SetRenderOpacity(0)
      self.red_img_1:SetRenderOpacity(0)
    end
    self:SetState(newState)
  elseif bt <= TemperatureEnum.BT.MIN then
    self:SetState(TemperatureEnum.HPItemState.COLD)
    if hp >= self.index and not self:IsAnimationPlaying(self.cold_loop) then
      if not self:IsPlayingRecoverAnm() then
        self:StopAllAnimations()
      end
      self:PlayAnimation(self.cold_loop, 0, 0)
    end
  elseif bt >= TemperatureEnum.BT.MAX then
    self:SetState(TemperatureEnum.HPItemState.HOT)
    if hp >= self.index and not self:IsAnimationPlaying(self.hot_loop) then
      if not self:IsPlayingRecoverAnm() then
        self:StopAllAnimations()
      end
      self:PlayAnimation(self.hot_loop, 0, 0)
    end
  elseif bt < 0 then
    if self:IsAnimationPlaying(self.cold_loop) then
      self:StopAnimation(self.cold_loop)
    end
    if self:IsAnimationPlaying(self.hot) then
      self:StopAnimation(self.hot)
    end
    local anm = self.cold
    local aniTime = anm:GetEndTime() - anm:GetStartTime()
    local speed = aniTime / perAnmTime
    if index < math.floor(btInHp) then
      local newSate = TemperatureEnum.HPItemState.COLD
      if self.state ~= newSate or bForceUpdate then
        local endTime = anm:GetEndTime()
        self:PlayAnimationTimeRange(anm, endTime - 0.01, endTime, 1)
        self:SetState(newSate)
      end
    elseif index == math.floor(btInHp) then
      local newSate = TemperatureEnum.HPItemState.COLD
      if preBt < bt then
        newSate = TemperatureEnum.HPItemState.NORMAL
      end
      if self.state ~= newSate or bForceUpdate then
        if newSate == TemperatureEnum.HPItemState.COLD then
          local pct = btInHp - index
          local beginTime = anm:GetStartTime() + pct * aniTime
          local endTime = anm:GetEndTime()
          self:PlayAnimationTimeRange(anm, beginTime, endTime, 1, UE4.EUMGSequencePlayMode.Forward, speed, false)
        else
          local pct = btInHp - index
          local beginTime = anm:GetEndTime() - aniTime * pct
          local endTime = 0
          self:PlayAnimationTimeRange(anm, beginTime, endTime, 1, UE4.EUMGSequencePlayMode.Reverse, speed, false)
        end
        self:SetState(newSate)
      end
    else
      if self:IsAnimationPlaying(self.cold_loop) then
        self:StopAnimation(self.cold_loop)
      end
      if self:IsAnimationPlaying(self.cold) then
        self:StopAnimation(self.cold)
      end
    end
  elseif bt > 0 then
    if self:IsAnimationPlaying(self.hot_loop) then
      self:StopAnimation(self.hot_loop)
    end
    if self:IsAnimationPlaying(self.cold) then
      self:StopAnimation(self.cold)
    end
    local anm = self.hot
    local aniTime = anm:GetEndTime() - anm:GetStartTime()
    local speed = aniTime / perAnmTime
    if index < math.floor(btInHp) then
      local newSate = TemperatureEnum.HPItemState.HOT
      if self.state ~= newSate or bForceUpdate then
        local endTime = anm:GetEndTime()
        self:PlayAnimationTimeRange(anm, endTime - 0.01, endTime, 1)
        self:SetState(newSate)
      end
    elseif index == math.floor(btInHp) then
      local newSate = TemperatureEnum.HPItemState.HOT
      if bt < preBt then
        newSate = TemperatureEnum.HPItemState.NORMAL
      end
      if self.state ~= newSate or bForceUpdate then
        if newSate == TemperatureEnum.HPItemState.HOT then
          local pct = btInHp - index
          local beginTime = anm:GetStartTime() + pct * aniTime
          local endTime = anm:GetEndTime()
          self:PlayAnimationTimeRange(anm, beginTime, endTime, 1, UE4.EUMGSequencePlayMode.Forward, speed, false)
        else
          local pct = btInHp - index
          local beginTime = anm:GetEndTime() - pct * aniTime
          local endTime = 0
          self:PlayAnimationTimeRange(anm, beginTime, endTime, 1, UE4.EUMGSequencePlayMode.Reverse, speed, false)
        end
        self:SetState(newSate)
      end
    else
      if self:IsAnimationPlaying(self.hot_loop) then
        self:StopAnimation(self.hot_loop)
      end
      if self:IsAnimationPlaying(self.hot) then
        self:StopAnimation(self.hot)
      end
    end
  end
end

function UMG_MainUIRoleHPItem_C:PlayNorAnima(oldhp, oldmaxHp, hpindex, maxHp, bTemporal)
  if oldmaxHp < hpindex or hpindex == maxHp then
    self:DelaySeconds(0.033 * (hpindex - oldhp), function()
      if self.preVisibilityState == UE4.ESlateVisibility.Collapsed then
        return
      end
      self:StopAllAnimations()
      self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Visible)
      if bTemporal then
        if self.half_injure then
          self:PlayAnimation(self.Prepare_re)
        else
          self:PlayAnimation(self.open)
        end
      elseif self.half_injure then
        self:PlayAnimation(self.Prepare_re)
      else
        self:PlayAnimation(self.get)
      end
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1148, "UMG_MainUIRoleHPItem_C:PlayNorAnima get")
    end)
  elseif oldhp < hpindex then
    self:DelaySeconds(0.033 * (hpindex - oldhp), function()
      if self.preVisibilityState == UE4.ESlateVisibility.Collapsed then
        return
      end
      self:StopAllAnimations()
      self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Visible)
      if bTemporal then
        if self.half_injure then
          self:PlayAnimation(self.Prepare_re)
        else
          self:PlayAnimation(self.open)
        end
      elseif self.half_injure then
        self:PlayAnimation(self.Prepare_re)
      else
        self:PlayAnimation(self.heath)
      end
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1146, "UMG_MainUIRoleHPItem_C:PlayNorAnima heath")
    end)
  end
end

function UMG_MainUIRoleHPItem_C:StopColdHotLoopAnimation()
  if self:IsAnimationPlaying(self.hot_loop) then
    self:StopAnimation(self.hot_loop)
  end
  if self:IsAnimationPlaying(self.cold_loop) then
    self:StopAnimation(self.cold_loop)
  end
end

function UMG_MainUIRoleHPItem_C:SetIndex(i)
  self.index = i
  Log.Debug("UMG_MainUIRoleHPItem_C:SetIndex", i)
end

function UMG_MainUIRoleHPItem_C:SetState(State)
  self.state = State
  if State == TemperatureEnum.HPItemState.TEMPORAL then
    self.NRCImage_30:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.yellow_img:SetVisibility(UE4.ESlateVisibility.Visible)
    self.red_img:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.blue_img:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif State == TemperatureEnum.HPItemState.NORMAL or State == TemperatureEnum.HPItemState.HEALTH then
    self.NRCImage_30:SetVisibility(UE4.ESlateVisibility.Visible)
    self.yellow_img:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.red_img:SetVisibility(UE4.ESlateVisibility.Visible)
    self.blue_img:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif State == TemperatureEnum.HPItemState.HOT or TemperatureEnum.HPItemState.HOT_BROKEN or State == TemperatureEnum.HPItemState.HOT_LOOP then
    self.NRCImage_30:SetVisibility(UE4.ESlateVisibility.Visible)
    self.yellow_img:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.red_img:SetVisibility(UE4.ESlateVisibility.Visible)
    self.blue_img:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif State == TemperatureEnum.HPItemState.COLD or State == TemperatureEnum.HPItemState.COLD_LOOP or State == TemperatureEnum.HPItemState.COLD_BROKEN then
    self.NRCImage_30:SetVisibility(UE4.ESlateVisibility.Visible)
    self.yellow_img:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.red_img:SetVisibility(UE4.ESlateVisibility.Visible)
    self.blue_img:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MainUIRoleHPItem_C:UpdateState(bt)
  if not bt then
    return
  end
  if bt <= TemperatureEnum.BT.MIN then
    if self.state ~= TemperatureEnum.HPItemState.COLD then
      self:SetState(TemperatureEnum.HPItemState.COLD)
    end
  elseif bt >= TemperatureEnum.BT.MAX then
    if self.state ~= TemperatureEnum.HPItemState.HOT then
      self:SetState(TemperatureEnum.HPItemState.HOT)
    end
  elseif self.state ~= TemperatureEnum.HPItemState.TEMPORAL then
    self:SetState(TemperatureEnum.HPItemState.TEMPORAL)
  end
end

function UMG_MainUIRoleHPItem_C:PlayHalfBredAnim(IsPlay)
  Log.Debug(IsPlay, self.half_injure, "UMG_MainUIRoleHPItem_C:PlayHalfBredAnim")
  self:StopAllAnimations()
  if IsPlay then
    if self.half_injure then
      self:PlayAnimation(self.Prepare_finish)
      self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:PlayAnimation(self.Prepare_del)
      self.half_injure = true
    end
  end
end

function UMG_MainUIRoleHPItem_C:GetHalfInjure()
  return self.half_injure
end

return UMG_MainUIRoleHPItem_C
