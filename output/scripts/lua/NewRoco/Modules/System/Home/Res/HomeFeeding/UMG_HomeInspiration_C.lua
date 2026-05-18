local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_HomeInspiration_C = _G.NRCPanelBase:Extend("UMG_HomeInspiration_C")
local GuideConfigTypes = require("NewRoco.Modules.System.Guidance.Types.GuideConfigTypes")

function UMG_HomeInspiration_C:OnConstruct()
end

function UMG_HomeInspiration_C:OnEnable(refreshHandle, bInProduce, needTime, startTime, actorId, petGid, outputInfo, bagItemId)
  self.bInProduce = bInProduce
  if nil ~= needTime then
    self.needTime = needTime
  else
    Log.Debug("self.needTime set nil")
    if self.bInProduce then
      self.Quantity:SetText("")
      self.Quantity:ForceLayoutPrepass()
    end
  end
  if nil ~= startTime then
    self.startTime = startTime
  end
  self.ownerActorId = actorId
  self.ownerPetGid = petGid
  self.outputInfo = outputInfo
  if not outputInfo and not self.bInProduce then
    self.Quantity:SetText("")
    self.Quantity:ForceLayoutPrepass()
  end
  if bagItemId then
    local bagItemConf = _G.DataConfigManager:GetHomePetFeedConf(bagItemId)
    if bagItemConf then
      self.totalNeedTime = bagItemConf.need_time * 60 * 1000
    end
  else
    self.totalNeedTime = nil
  end
  self:SwitchCanvas()
  self:OnAddEventListener(refreshHandle)
  self:SetPetTalentBuffOrDeBuffUi()
  self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:RefreshShowTimer()
  if self.bInProduce and self.needTime and not self.timer then
    self.timer = _G.TimerManager:CreateTimer(self, "HomePetProduceTimer" .. self.ownerPetGid, math.maxinteger, self.RefreshShowTimer, self.OnTimerFinished, 10)
    if self.Progress:GetVisibility() ~= UE.ESlateVisibility.SelfHitTestInvisible then
      self.Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.ProgressBG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if (not self.bInProduce or 0 == self.needTime or nil == self.needTime) and self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
    if self.Progress:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
      self.Progress:SetFillAmount(0)
      self.Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.ProgressBG:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    self.startTime = nil
    self.needTime = nil
    self.timer = nil
    self.Quantity:SetText("")
    if self.refreshHandle then
      if not self._isVisible then
        return
      end
      _G.tcall(self, self.refreshHandle, "UMG_HomeInspiration")
    end
  end
  if outputInfo then
    self:UpdateStatus(bInProduce, outputInfo)
  end
  self._isVisible = not _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION)
  if not self._isVisible and self:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_HomeInspiration_C:SetPetTalentBuffOrDeBuffUi()
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.ownerPetGid)
  local IsVisit = _G.DataModelMgr.PlayerDataModel:IsHomeVisitState()
  local bShow = false
  if IsVisit then
    if _G.DataModelMgr.PlayerDataModel:IsHomeVisitOwner() then
      bShow = true
    end
  else
    bShow = true
  end
  if petData and bShow then
    if petData.speciality_id then
      local function ChangeShowType(ShowType, AddType)
        local type = 3
        
        if 3 == ShowType then
          type = AddType
        else
          type = ShowType ~= AddType and 3 or ShowType
        end
        return type
      end
      
      local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
      if PetTalentConf and 3 == PetTalentConf.type and PetTalentConf.icon_visible_switch then
        self.Output:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Output:SetPath(PetTalentConf.icon)
        if PetTalentConf.talent_color and PetTalentConf.talent_color ~= "" then
          self.PetBuffColor = "#" .. PetTalentConf.talent_color
        elseif PetTalentConf.effect_group and #PetTalentConf.effect_group > 0 then
          local effect_group = PetTalentConf.effect_group
          local ShowType = 3
          for i, v in ipairs(effect_group) do
            if v.effect == Enum.PetTalentEffect.PTE_FURNI_PROBABILITY_ADD then
              if v.effect_param > 0 then
                ShowType = ChangeShowType(ShowType, 1)
              else
                if v.effect_param < 0 then
                  ShowType = ChangeShowType(ShowType, 2)
                else
                end
              end
            end
          end
          if 3 == ShowType then
            self.PetBuffColor = "#272727FF"
          elseif 2 == ShowType then
            self.PetBuffColor = "#AE3D3EFF"
          elseif 1 == ShowType then
            self.PetBuffColor = "#5C9F11FF"
          end
        else
          self.PetBuffColor = "#272727FF"
        end
      else
        self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.PetBuffColor = "#272727FF"
      end
    else
      self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.PetBuffColor = "#272727FF"
    end
  else
    self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PetBuffColor = "#272727FF"
  end
end

function UMG_HomeInspiration_C:OnTimerFinished()
  if self.outputInfo then
    self:UpdateStatus(false, self.outputInfo)
  end
end

function UMG_HomeInspiration_C:RefreshShowTimer()
  if not (self.startTime and self.needTime) or 0 == self.needTime then
    return
  end
  local nowTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  self.costTime = nowTime - self.startTime / 1000
  self.remainTime = self.needTime / 1000
  local remainTimeText = ""
  if self.remainTime <= 0 then
    self.bInProduce = false
    if self.CanvasPanel_74:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SwitchCanvas()
    if self.timer then
      _G.TimerManager:RemoveTimer(self.timer)
      self.timer = nil
      if self.Progress:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
        self.Progress:SetFillAmount(0)
        self.Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.ProgressBG:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
    if self.outputInfo then
      self:UpdateStatus(false, self.outputInfo)
      return
    else
      remainTimeText = string.format(LuaText.home_pet_feed_time_s, 0)
    end
  else
    local remainDay = math.floor(self.remainTime / 86400)
    local remainHour = math.floor((self.remainTime - remainDay * 60 * 60 * 24) / 3600)
    local remainMinute = math.floor((self.remainTime - remainDay * 60 * 60 * 24 - remainHour * 60 * 60) / 60)
    local remainSeconds = math.floor(self.remainTime - remainDay * 60 * 60 * 24 - remainHour * 60 * 60 - remainMinute * 60)
    if remainDay >= 1 then
      remainTimeText = string.format(LuaText.home_pet_feed_time_d, remainDay, remainHour)
    elseif remainHour >= 1 then
      remainTimeText = string.format(LuaText.home_pet_feed_time_h, remainHour, remainMinute)
    elseif remainMinute >= 1 then
      remainTimeText = string.format(LuaText.home_pet_feed_time_m, remainMinute, remainSeconds)
    else
      remainTimeText = string.format(LuaText.home_pet_feed_time_s, remainSeconds)
    end
    if _G.HomeIndoorSandbox:InLocalMasterIndoor() and self.CanvasPanel_74:GetVisibility() ~= UE4.ESlateVisibility.Visible then
      self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  if not string.IsNilOrEmpty(remainTimeText) then
    self.Quantity:SetText(remainTimeText)
    self.Quantity:ForceLayoutPrepass()
  end
  if nil ~= self.totalNeedTime and self.needTime > 0 then
    local percent = math.max(0, math.min(1, (self.totalNeedTime - self.needTime) / self.totalNeedTime))
    if percent < 1 and not self.outputInfo then
      self.Progress:SetFillAmount(percent)
      if self.Progress:GetVisibility() ~= UE.ESlateVisibility.SelfHitTestInvisible then
        self.Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      self.Progress:SetFillAmount(0)
      self.Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.ProgressBG:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if self.refreshHandle then
    if not self._isVisible then
      return
    end
    _G.tcall(self, self.refreshHandle, "UMG_HomeInspiration")
  end
end

function UMG_HomeInspiration_C:OnDeactive()
  if self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
    self.timer = nil
  end
  if self.Progress:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
    self.Progress:SetFillAmount(0)
    self.Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ProgressBG:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_HomeInspiration_C:OnStopCare()
  local petName = ""
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.ownerPetGid)
  if petData then
    petName = petData.name
  end
  local context = DialogContext()
  context:SetTitle(LuaText.TIPS):SetContent(LuaText.home_pet_feed_text_3):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnCancel(true):SetCallbackOkOnly(self, self.ReqCancelFeed)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, context)
end

function UMG_HomeInspiration_C:ReqCancelFeed()
  local req = ProtoMessage:newZoneHomePetFeedCancelReq()
  req.npc_obj_id = self.ownerActorId
  req.pet_gid = self.ownerPetGid
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_FEED_CANCEL_REQ, req, self, self.OnRspCancelFeed)
end

function UMG_HomeInspiration_C:OnRspCancelFeed(rsp)
  Log.Dump(rsp, 3, "ZONE_HOME_PET_FEED_CANCEL_REQ")
end

function UMG_HomeInspiration_C:OnAddEventListener(refreshHandle)
  if not self.AddListener then
    _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_GOODS_REWARD_NOTIFY, self.OnZoneGoodsRewardNotify)
    _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION, self, self.OnFunctionBan)
    self.refreshHandle = refreshHandle
    self.AddListener = true
  end
end

function UMG_HomeInspiration_C:OnRemoveListener()
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_GOODS_REWARD_NOTIFY, self.OnZoneGoodsRewardNotify)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION, self, self.OnFunctionBan)
  self.refreshHandle = nil
  self.AddListener = nil
end

function UMG_HomeInspiration_C:OnFunctionBan()
  local isBan = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION)
  if isBan then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self._isVisible = false
  elseif self:GetVisibility() ~= UE4.ESlateVisibility.Visible then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    self._isVisible = true
  end
end

function UMG_HomeInspiration_C:SwitchCanvas()
  if not self.bInProduce and not self.outputInfo then
    if _G.HomeIndoorSandbox and _G.HomeIndoorSandbox:InOtherHomeIndoor() then
      self._isVisible = false
      if self:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      return
    end
    if 0 == self.Switcher_1:GetActiveWidgetIndex() then
      self.Switcher_1:SetActiveWidgetIndex(1)
    end
  else
    if self._isVisible and self:GetVisibility() ~= UE4.ESlateVisibility.Visible then
      self:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if 0 ~= self.Switcher_1:GetActiveWidgetIndex() then
      self.Switcher_1:SetActiveWidgetIndex(0)
    end
  end
  if self.bInProduce then
    self.Hourglass:SetVisibility(UE4.ESlateVisibility.Visible)
    if not HomeIndoorSandbox:InLocalMasterIndoor() then
      self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.Hourglass:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_HomeInspiration_C:OnZoneGoodsRewardNotify(notify)
  if not self._isVisible then
    return
  end
  local rewards = notify.ret_info and notify.ret_info.goods_change_info
  if rewards then
    local changeInfoItem = rewards.changes
    if changeInfoItem then
      for _, itemInfo in ipairs(changeInfoItem) do
        if itemInfo.change_reason == ProtoEnum.FlowReason.FLOW_REASON_HOME_PET_FETCH_AWARD or itemInfo.change_reason == ProtoEnum.FlowReason.FLOW_REASON_HOME_PET_STEAL then
          self.remainOutput = itemInfo.num
        end
      end
    end
  end
end

function UMG_HomeInspiration_C:UpdateStatus(bInProduce, outputInfo)
  self.bInProduce = bInProduce
  self:SwitchCanvas()
  if bInProduce then
    return
  end
  if self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
    self.timer = nil
  end
  if not outputInfo then
    self.Quantity:SetText("")
    self.Quantity:ForceLayoutPrepass()
    return
  end
  if self.Progress:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
    self.Progress:SetFillAmount(0)
    self.Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ProgressBG:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self:SetPetTalentBuffOrDeBuffUi()
  self.CanvasPanel_74:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.outputInfo = outputInfo
  local remainRatio = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_left_steal_max").num / 10000
  for _, goodInfo in ipairs(outputInfo) do
    if goodInfo.goods_id == Enum.VisualItem.VI_FURNITURE_COIN then
      self.remainOutput = goodInfo.goods_num
      local totalOutput = goodInfo.goods_total_num
      if self.remainOutput and totalOutput then
        Log.Debug("UMG_HomeInspiration_C UpdateStatus with remainOutput:" .. self.remainOutput .. ", and totalOutput:" .. totalOutput)
        local richTextStr = self.remainOutput .. "/" .. totalOutput
        if self.PetBuffColor then
          if self.remainOutput <= totalOutput * remainRatio then
            richTextStr = string.format("<span size=\"30\" color=\"%s\" font=\"Font'/Game/NewRoco/Font/244-ShangShouDunDun_Font.244-ShangShouDunDun_Font'\">%s</><span size=\"30\" color=\"%s\" font=\"Font'/Game/NewRoco/Font/244-ShangShouDunDun_Font.244-ShangShouDunDun_Font'\">%s</>", "#AE3D3EFF", self.remainOutput, self.PetBuffColor, "/" .. totalOutput)
          else
            richTextStr = string.format("<span size=\"30\" color=\"%s\" font=\"Font'/Game/NewRoco/Font/244-ShangShouDunDun_Font.244-ShangShouDunDun_Font'\">%s</>", self.PetBuffColor, self.remainOutput .. "/" .. totalOutput)
          end
        elseif self.remainOutput <= totalOutput * remainRatio then
          richTextStr = string.format("<span size=\"30\" color=\"%s\" font=\"Font'/Game/NewRoco/Font/244-ShangShouDunDun_Font.244-ShangShouDunDun_Font'\">%s</>%s", "#AE3D3EFF", self.remainOutput, "/" .. totalOutput)
        end
        self.Quantity:SetText(richTextStr)
        self.Quantity:ForceLayoutPrepass()
      end
    end
  end
end

function UMG_HomeInspiration_C:OnPcStopPetCare()
end

function UMG_HomeInspiration_C:OnDisable()
  self.Quantity:SetText("")
  self.Quantity:ForceLayoutPrepass()
  self._isVisible = false
  self.globalActiveActorId = nil
  self:OnRemoveListener()
end

return UMG_HomeInspiration_C
