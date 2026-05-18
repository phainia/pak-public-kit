local Super = require("NewRoco/Modules/System/BigMap/Res/UMG_IconTempBasic_C")
local UMG_IconNpcTemple_C = Super:Extend("UMG_IconNpcTemple_C")

function UMG_IconNpcTemple_C:OnConstruct()
  self.isShowTraceEffect = false
  self.IsPlayReverse = false
  self.CurrentTime = nil
  self.IsStarCountDown = false
  self.IsCatchPet = false
  self.IsTravelInfo = false
  self.TravelContentId = 0
  self.TravelInfo = nil
end

function UMG_IconNpcTemple_C:OnDestruct()
  self.uiData = nil
  _G.UpdateManager:UnRegister(self)
end

function UMG_IconNpcTemple_C:OnTouchEnded(_MyGeometry, _InTouchEvent)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_IconNpcTemple_C:SetData(_data, worldMap)
  self.uiData = _data
  self.WorldMapConfig = worldMap
  local npcType = 0
  if self.uiData and self.uiData.npcCfg then
    if self.uiData.npcCfg then
      npcType = self.uiData.npcCfg.genre
    else
      local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(worldMap.npc_refresh_ids[1])
      local npcId = refreshConf.npc_id
      local npcCfg = _G.DataConfigManager:GetNpcConf(npcId)
      npcType = npcCfg.genre
    end
    if npcType == _G.Enum.ClientNpcType.CNT_UNLOCKPORT then
    elseif npcType == _G.Enum.ClientNpcType.CNT_TELEPORT then
      self.needMapShowLevel = 2
    elseif npcType == _G.Enum.ClientNpcType.CNT_NORMALFUNC then
      self.needMapShowLevel = 2
    elseif npcType == _G.Enum.ClientNpcType.CNT_PETBOSS then
      self.needMapShowLevel = 2
    else
      self.needMapShowLevel = 2
    end
  elseif self.uiData and self.uiData.next_npc_refresh_time then
    self.needMapShowLevel = 2
  end
  self:UpdateIcon()
  if _data.isNewUnLock then
    _data.isNewUnLock = false
    self:PlayAnimation(self.change_map)
  end
end

function UMG_IconNpcTemple_C:SetShowTime(data)
  if data.npc_remain_time == nil then
    return
  end
  if data.npc_remain_time > 0 then
    self.CurrentTime = data.npc_remain_time - (os.time() - data.CreateTime)
    if self.CurrentTime > 0 then
      _G.UpdateManager:Register(self)
      self.Time:SetVisibility(UE4.ESlateVisibility.Visible)
      self.IsStarCountDown = true
    else
      _G.UpdateManager:UnRegister(self)
      self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.IsStarCountDown = false
    end
  else
    _G.UpdateManager:UnRegister(self)
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IsStarCountDown = false
  end
end

function UMG_IconNpcTemple_C:OnTick(deltaTime)
  if self.IsStarCountDown then
    local Text = self:secondsToTime(self.CurrentTime)
    self.Time:SetText(Text)
    self.CurrentTime = self.CurrentTime - deltaTime
    if self.CurrentTime <= 0 then
      self.IsStarCountDown = false
      _G.UpdateManager:UnRegister(self)
    end
  end
end

function UMG_IconNpcTemple_C:secondsToTime(ts)
  local seconds = math.floor(math.fmod(ts, 60))
  local min = math.floor(ts / 60)
  local hour = math.floor(min / 60)
  local day = math.floor(hour / 24)
  local str
  if tonumber(seconds) >= 0 and tonumber(seconds) < 60 and tonumber(min - hour * 60) >= 0 and tonumber(min - hour * 60) < 60 and tonumber(hour - day * 24) >= 0 and tonumber(hour - day * 60) < 24 then
    str = string.format("%02d:%02d", min - hour * 60, seconds)
  else
    Log.Error(ts, seconds, hour, day, tonumber(seconds) >= 0 and tonumber(seconds) < 60, tonumber(min - hour * 60) >= 0 and tonumber(min - hour * 60) < 60, tonumber(hour - day * 24) >= 0 and tonumber(hour - day * 60) < 24, "\230\151\182\233\151\180\230\141\162\231\174\151\230\156\137\233\151\174\233\162\152\232\175\183\230\163\128\230\159\165")
  end
  return str
end

function UMG_IconNpcTemple_C:SetMapAreaData(_data, worldMap)
  self.uiData = _data
  self.WorldMapConfig = worldMap
  self.needMapShowLevel = 2
  self:UpdateIcon()
  if _data.isNewUnLock then
    _data.isNewUnLock = false
    self:PlayAnimation(self.change_map)
  end
end

function UMG_IconNpcTemple_C:GetData()
  return self.uiData
end

function UMG_IconNpcTemple_C:UpdateIcon()
  if self.uiData and self.WorldMapConfig then
    local model
    if self.uiData.npcCfg then
      model = _G.DataConfigManager:GetModelConf(self.uiData.npcCfg.model_conf)
    else
      local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(self.WorldMapConfig.npc_refresh_ids[1])
      local npcId = refreshConf.npc_id
      local npcCfg = _G.DataConfigManager:GetNpcConf(npcId)
      model = _G.DataConfigManager:GetModelConf(npcCfg.model_conf)
    end
    self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.iconFlag:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.Crown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if not self.WorldMapConfig.dungeon_id or self.WorldMapConfig.dungeon_id > 0 then
    end
    if self.uiData.status then
      if self.uiData.status == _G.ProtoEnum.LockStatus.ENUM.UNLOCKED then
        if self.WorldMapConfig.dungeon_id and self.WorldMapConfig.dungeon_id > 0 then
          self:GetIconPath(self.WorldMapConfig.npcicon_unfinished)
        elseif self.WorldMapConfig.areaicon_explore then
          self:GetIconPath(self.WorldMapConfig.areaicon_explore)
        elseif self.WorldMapConfig.npcicon_unlock then
          if self.uiData.npcCfg.genre == Enum.ClientNpcType.CNT_PETBOSS then
            self.iconFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
            self.Switcher_Boss:SetActiveWidgetIndex(0)
            self:GetPetIconPath(self.WorldMapConfig.npcicon_unlock)
          elseif self.uiData.npcCfg.genre == Enum.ClientNpcType.CNT_LEGENDARY_SPIRIT then
            self.iconFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
            self.Switcher_Boss:SetActiveWidgetIndex(1)
            self:GetPetIconPath(self.WorldMapConfig.npcicon_unlock)
            self.Crown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          elseif #self.WorldMapConfig.npcicon_levelup > 0 then
            for i = 1, #self.WorldMapConfig.npcicon_levelup do
              if self.WorldMapConfig.npcicon_levelup[i].level == self.uiData.npc_level then
                self:GetIconPath(self.WorldMapConfig.npcicon_levelup[i].icon)
              end
            end
          else
            self:GetIconPath(self.WorldMapConfig.npcicon_unlock)
          end
        end
      elseif self.uiData.status == _G.ProtoEnum.LockStatus.ENUM.DUNGEON_FINISH then
        if self.WorldMapConfig.dungeon_id and self.WorldMapConfig.dungeon_id > 0 then
          self:GetIconPath(self.WorldMapConfig.npcicon_unlock)
        end
      elseif self.WorldMapConfig.areaicon_unexplore then
        self:GetIconPath(self.WorldMapConfig.areaicon_unexplore)
      elseif self.WorldMapConfig.npcicon_lock then
        self:GetIconPath(self.WorldMapConfig.npcicon_lock)
      elseif model then
        if self.uiData.npcCfg.genre == Enum.ClientNpcType.CNT_PETBOSS then
          self.iconFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
          self:SetPetPath(model.icon)
        else
          self:SetFlagPath(model.icon)
        end
      end
    else
      self.Pet:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self:SetPetPath(model.icon)
    end
  end
end

function UMG_IconNpcTemple_C:UpdateMapShowLevel(_level)
  if not self.needMapShowLevel or _level == self.curMapShowLevel then
    return
  end
  self.curMapShowLevel = _level
  if self.WorldMapConfig.element_show_scale then
    local scaleConf = _G.DataConfigManager:GetWorldMapScaleConf(self.WorldMapConfig.element_show_scale)
    if _level <= scaleConf.max_scale / 100.0 and _level >= scaleConf.min_scale / 100.0 then
      self:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_IconNpcTemple_C:SetOpacity(_alpha)
  self.iconFlag:SetOpacity(_alpha)
end

function UMG_IconNpcTemple_C:PlayTraceEffect(_show)
  if self.isShowTraceEffect ~= _show then
    self.isShowTraceEffect = _show
    if _show then
      self:PlayAnimation(self.TraceStart)
    else
      self:StopAnimation(self.TraceStart)
      self:StopAnimation(self.TraceLoop)
      self:PlayAnimation(self.TraceEnd)
    end
  end
end

function UMG_IconNpcTemple_C:GetIconPath(Icon)
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    self:SetFlagPath(bigMapModule:GetBigMapIconRes(Icon))
  end
end

function UMG_IconNpcTemple_C:GetPetIconPath(Icon)
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if bigMapModule then
    self:SetPetPath(bigMapModule:GetBigMapIconRes(Icon))
  end
end

function UMG_IconNpcTemple_C:GetCathIconPath(Icon)
  local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.iconFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CatchRewardCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if bigMapModule then
    local iconPath = NRCUtils:FormatConfIconPath(Icon, _G.UIIconPath.UIHeadIconPath)
    self:SetIconPath(iconPath)
  end
end

function UMG_IconNpcTemple_C:ShowSelectState()
  self.Ray_Circle:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.DeadTree)
end

function UMG_IconNpcTemple_C:HiddenSelectState()
  self.IsPlayReverse = true
  self:PlayAnimationReverse(self.DeadTree)
end

function UMG_IconNpcTemple_C:SetCathPet()
  self.IsCatchPet = true
  self:GetCathIconPath(self.WorldMapConfig.npcicon_unlock)
end

function UMG_IconNpcTemple_C:ShowCathPetEffect()
  self:PlayAnimation(self.in2)
end

function UMG_IconNpcTemple_C:ShowTravel(npcInfo)
  if npcInfo then
    local travelInfo = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetTravelInfo, npcInfo.npc_refresh_id)
    if travelInfo then
      self.Travel_DuringJourney:SetVisibility(UE4.ESlateVisibility.Visible)
      self.TravelInfo = travelInfo
      self.IsTravelInfo = true
      self.TravelContentId = travelInfo.camp_content_id
      self.Travel_DuringJourney:OnActive(npcInfo)
    end
  else
    self.TravelContentId = 0
    self.IsTravelInfo = false
    self.Travel_DuringJourney:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_IconNpcTemple_C:GetTravelDownTime()
  if self.IsTravelInfo then
    if self.TravelInfo and self.TravelInfo.travel_complete then
      return 0
    end
    return self.Travel_DuringJourney:GetTravelDownTime()
  end
  return 0
end

function UMG_IconNpcTemple_C:PlayInTravel()
  self.Travel_DuringJourney:PlayInAnim()
end

function UMG_IconNpcTemple_C:PlayOutTravel()
  self.Travel_DuringJourney:PlayCloseAnim()
end

function UMG_IconNpcTemple_C:OnAnimationFinished(anim)
  if anim == self.DeadTree and self.IsPlayReverse then
    self.Ray_Circle:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IsPlayReverse = false
  elseif anim == self.in2 then
    self:PlayAnimation(self.loop2, 0, 0)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1384, "UMG_IconNpcTemple_C:OnAnimationFinished")
    self.UMG_CompItem_Par1:PlayLoop1Animation()
  elseif anim == self.TraceStart then
    self:PlayAnimation(self.TraceLoop, 0, 0)
  end
end

return UMG_IconNpcTemple_C
