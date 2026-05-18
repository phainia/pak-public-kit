local UMG_CompItem_C = _G.NRCPanelBase:Extend("UMG_CompItem_C")
local math_abs = math.abs

function UMG_CompItem_C:InitData()
  self:StopAllAnimations()
  self:SetUpOrDown()
  self:SetDistance()
  self:SetTrace(false)
  self.Slot:SetZOrder(0)
end

function UMG_CompItem_C:FinshCatchAnimation()
  return self.IsFinshCatchAnimation
end

function UMG_CompItem_C:SetZOrder()
end

function UMG_CompItem_C:PlayCatchPetEffect(event_info)
  local info = event_info
  local status = info.status
  self.CurCatchState = status
  self:SetIcon()
  if _G.ProtoEnum.SceneEventStatus.SES_SMALLER == status then
    self.icon:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif _G.ProtoEnum.SceneEventStatus.SES_BIGGER == status then
    self.icon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Light2)
    self:PlayAnimationIn()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1379, "UMG_CompItem_C:PlayCatchPetEffect")
    self:DelaySeconds(0.15, function()
      self:PlayAnimationLoop2()
    end)
    self:DelaySeconds(3.35, function()
      self:PlayAnimationOut()
    end)
  elseif _G.ProtoEnum.SceneEventStatus.SES_EQUAL == status then
    self.icon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Light3)
    self:PlayAnimationIn()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1380, "UMG_CompItem_C:PlayCatchPetEffect")
    self:DelaySeconds(0.15, function()
      self:PlayAnimationLoop3()
    end)
    self:DelaySeconds(3.35, function()
      self:PlayAnimationOut()
    end)
  elseif _G.ProtoEnum.SceneEventStatus.SES_BONUS == status then
    self.icon:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimationIn()
    self:PlayAnimation(self.Light4_in)
    self:StopAnimationLoops()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1381, "UMG_CompItem_C:PlayCatchPetEffect")
    self.IsWaitCahtAimEnd = true
    self.GapAim = 0
    self.IsFinshCatchAnimation = true
    self:DelaySeconds(5, function()
      self.IsWaitCahtAimEnd = false
    end)
  end
end

function UMG_CompItem_C:PlayAnimationIn4()
  self:PlayAnimation(self.Light4_in)
  self:StopAnimationLoops()
end

function UMG_CompItem_C:PlayAnimationIn()
  self:PlayAnimation(self.In)
end

function UMG_CompItem_C:PlayAnimationLoop1()
  self:PlayAnimation(self.loop, 0, 0)
  self.UMG_CompItem_Par1:PlayLoop1Animation()
end

function UMG_CompItem_C:PlayAnimationLoop2()
  self:PlayAnimation(self.loop, 0, 0)
  self.UMG_CompItem_Par1:PlayLoop2Animation()
end

function UMG_CompItem_C:PlayAnimationLoop3()
  self:PlayAnimation(self.loop, 0, 0)
  self.UMG_CompItem_Par1:PlayLoop3Animation()
end

function UMG_CompItem_C:PlayAnimationLoop4()
  self:PlayAnimation(self.loop, 0, 0)
  self.UMG_CompItem_Par1:PlayLoop4Animation()
end

function UMG_CompItem_C:StopAnimationLoops()
  self:StopAnimation(self.loop)
  self.UMG_CompItem_Par1:StopLoopAnimations()
end

function UMG_CompItem_C:PlayAnimationOut()
  self:StopAnimationLoops()
  self:PlayAnimation(self.Out)
end

function UMG_CompItem_C:OnTaskClicked()
  self:PlayAnimation(self.flicker)
end

function UMG_CompItem_C:SetTrace(isTrace, isPlayAni)
  if isTrace then
    if isPlayAni then
      self:PlayAnimation(self.open)
    else
      self.CanvasTrack:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:PlayAnimation(self.loop, 0, 0)
    end
  else
    self.CanvasTrack:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:StopAnimation(self.loop)
    if isPlayAni then
      self:PlayAnimation(self.close)
    end
  end
end

function UMG_CompItem_C:OnAnimationFinished(Animation)
  if Animation == self.open then
    if self.uiData.IsTrace then
      self:SetTrace(self.uiData.IsTrace)
    end
  elseif Animation == self.close then
    self:PlayAnimation(self.close, 0)
    self:PauseAnimation(self.close)
    if self.uiData.CurState == self.uiData.MapAreaState.CHANGE_TO_NPC then
      self:PlayAnimation(self.change_map)
      self:SetIcon()
    elseif self.uiData.CurState == self.uiData.MapAreaState.PET_SENSE then
      self.uiData:OpenPetSense()
    elseif self.uiData.CurState == self.uiData.MapAreaState.CLOSEING_PET_SENSE then
      self.uiData.CurState = self.uiData.MapAreaState.CLOSE_PET_SENSE
      self.uiData:SetIsShow(false)
    else
      self.uiData:CircleSelf()
    end
  elseif Animation == self.change_enlarge then
    self:PlayChangeSizeAni(true)
  elseif Animation == self.change_zoomout then
    if self.uiData.CurState == self.uiData.MapAreaState.CLOSEING_PET_SENSE then
      self:PlayAnimation(self.close)
    elseif self.uiData.CurState == self.uiData.MapAreaState.PET_SENSE then
      self.uiData:OpenPetSense()
    else
      self:PlayChangeSizeAni(true)
    end
  elseif Animation == self.change_map then
    self.uiData.CurState = self.uiData.MapAreaState.MAP_NPC
  elseif Animation == self.Light4_in then
    self:PlayAnimation(self.Light4_out)
  elseif Animation == self.Light4_out then
    self:PlayAnimation(self.Light4_loop, 0, 0)
    self:PlayAnimationLoop4()
  end
end

function UMG_CompItem_C:SetDistance(distance)
  if not self.Distance then
    return
  end
  if distance then
    distance = math.max(1, distance)
    if math_abs(self.lastDistance - distance) < 0.01 then
      return
    end
    self.lastDistance = distance
    self.Distance:SetText(math.round(distance))
    self.MeterText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local needSetAlpha = self.uiData:IsCathPet() and not self.IsWaitCahtAimEnd and self.uiData.WorldMapConfig
    if needSetAlpha then
      local alpha = 50 / distance
      if alpha < 0.5 then
        alpha = 0.5
      end
      self.icon:SetColorAndOpacity(UE4.FLinearColor(1, 1, 1, alpha))
    end
  else
    self.Distance:SetText("")
    self.MeterText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.lastDistance = 0
  end
end

function UMG_CompItem_C:SetIcon()
  local model
  local MapAreaState = self.uiData.MapAreaState
  if self.uiData.NpcConfig then
    model = _G.DataConfigManager:GetModelConf(self.uiData.NpcConfig.model_conf)
  end
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetSense:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchRewardCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCIcon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Up:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Down:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if self.uiData.IsUnLock and not self.uiData.IsFinish then
    if self.uiData.WorldMapConfig.dungeon_id and self.uiData.WorldMapConfig.dungeon_id > 0 then
      self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.npcicon_unfinished))
    elseif self.uiData.WorldMapConfig.areaicon_explore and self.uiData.CurState == MapAreaState.MAP_AREA then
      self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.areaicon_explore))
    elseif self.uiData.WorldMapConfig.npcicon_unlock and (self.uiData.CurState == MapAreaState.MAP_NPC or self.uiData.CurState == MapAreaState.CHANGE_TO_NPC) then
      if #self.uiData.WorldMapConfig.npcicon_levelup > 0 then
        for i = 1, #self.uiData.WorldMapConfig.npcicon_levelup do
          if self.uiData.WorldMapConfig.npcicon_levelup[i].level == self.uiData.NPC_level then
            self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.npcicon_levelup[i].icon))
          end
        end
      else
        self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.npcicon_unlock))
      end
    elseif model then
      self:SetNpcIconPath(NRCUtils:FormatConfIconPath(model.ui_icon, _G.UIIconPath.UIHeadIconPath))
    else
      Log.Error("zgx comp icon set nil WorldMapConfig ", self.uiData.WorldMapConfig.id)
    end
  elseif self.uiData.IsFinish then
    if self.uiData.WorldMapConfig.dungeon_id and self.uiData.WorldMapConfig.dungeon_id > 0 then
      self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.npcicon_unlock))
    end
  elseif self.uiData.WorldMapConfig.areaicon_unexplore and self.uiData.CurState == MapAreaState.MAP_AREA then
    self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.areaicon_unexplore))
  elseif self.uiData.WorldMapConfig.npcicon_lock and (self.uiData.CurState == MapAreaState.MAP_NPC or self.uiData.CurState == MapAreaState.CHANGE_TO_NPC) then
    self:SetNpcIconPath(self:GetNpcIconPath(self.uiData.WorldMapConfig.npcicon_lock))
  elseif model then
    self:SetNpcIconPath(NRCUtils:FormatConfIconPath(model.ui_icon, _G.UIIconPath.UIHeadIconPath))
  else
    Log.Error("zgx comp icon set nil WorldMapConfig ", self.uiData.WorldMapConfig.id)
  end
end

function UMG_CompItem_C:GetNpcIconPath(Icon)
  local iconPath
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    if Icon and string.find(Icon, "/Game/NewRoco") then
      iconPath = Icon
    else
      iconPath = bigMapModule:GetBigMapIconRes(Icon)
    end
  end
  return iconPath
end

function UMG_CompItem_C:SetNpcIconPath(IconPath)
  if self.uiData.NpcConfig and self.uiData.NpcConfig.genre == Enum.ClientNpcType.CNT_PETBOSS then
    self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Crown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_Boss:SetActiveWidgetIndex(0)
    self.NRCpetIcon:SetPath(IconPath)
  elseif self.uiData.NpcConfig and self.uiData.NpcConfig.genre == Enum.ClientNpcType.CNT_LEGENDARY_SPIRIT then
    self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Switcher_Boss:SetActiveWidgetIndex(1)
    self.Crown:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCpetIcon:SetPath(IconPath)
  else
    self.NRCIcon:SetPath(IconPath)
  end
end

function UMG_CompItem_C:GetCathPetIconPath(Icon)
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    self.icon:SetPath(NRCUtils:FormatConfIconPath(Icon, _G.UIIconPath.UIHeadIconPath))
  end
end

function UMG_CompItem_C:SetPetSenseIcon(iconPath)
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetSense:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if not string.IsNilOrEmpty(iconPath) then
    self.PetSense:SetPath(iconPath)
  end
end

function UMG_CompItem_C:SetCatchPetIcon()
  self.CanvasTrack_2:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasTrack:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasTrack_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetSense:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchRewardCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.uiData and self.uiData.WorldMapConfig then
    self:GetCathPetIconPath(self.uiData.WorldMapConfig.npcicon_unlock)
  end
end

function UMG_CompItem_C:SetTaskIcon(path)
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetSense:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCIcon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NRCIcon:SetPath(path)
end

function UMG_CompItem_C:SetMarkIcon(markNum)
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetSense:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mark:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.MarkNum:SetText(tostring(markNum))
end

function UMG_CompItem_C:SetUpOrDown(param)
  if self.Up then
    if 1 == param then
      self.Up:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    Log.Error("zgx SetUpOrDown Up is nil!!!")
  end
  if self.Down then
    if 2 == param then
      self.Down:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self.Down:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    Log.Error("zgx SetUpOrDown Down is nil!!!")
  end
end

function UMG_CompItem_C:SetIsShow(isShow)
  if isShow then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CompItem_C:DoCircle()
  self:SetDistance()
end

function UMG_CompItem_C:PlayChangeSizeAni(isForce)
  if not isForce and (self:IsAnimationPlaying(self.change_zoomout) or self:IsAnimationPlaying(self.change_enlarge)) then
    return
  end
  if self.uiData.IsBig ~= self.IsPlayBig then
    self.IsPlayBig = self.uiData.IsBig
    if self.uiData.IsBig then
      self:PlayAnimation(self.change_enlarge)
    else
      self:PlayAnimation(self.change_zoomout)
    end
  end
end

function UMG_CompItem_C:SetPosByCamera()
  local gap = self.uiData.Gap
  if self.uiData:IsCathPet() and self.IsWaitCahtAimEnd then
    gap = self.GapAim
  end
  self.Slot:SetPosition(UE4.FVector2D(gap * self.uiData.SpacePerAngle, 53))
end

function UMG_CompItem_C:GetOccupyAngle()
  if self.uiData.IsBig then
    return self.NRCIcon.Slot:GetOffsets().Right / self.uiData.SpacePerAngle
  else
    return 0.8 * self.NRCIcon.Slot:GetOffsets().Right / self.uiData.SpacePerAngle
  end
end

function UMG_CompItem_C:OnDestruct()
end

return UMG_CompItem_C
