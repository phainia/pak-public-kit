local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local WebSiteActivityObject = Base:Extend("WebSiteActivityObject")

local function IsWebSiteItemCanActive(_partId, _activateParameter)
  local webSiteConf = _G.DataConfigManager:GetActivityWebsitePartConf(_partId)
  if webSiteConf then
    local isMeetRequired = true
    for _, _requiredConf in ipairs(webSiteConf.required_group) do
      if _requiredConf.required_type == Enum.RequiredType.ACTRT_LEVEL then
        if _activateParameter.playerLevel < _requiredConf.required_param then
          isMeetRequired = false
          break
        end
      else
        isMeetRequired = false
        break
      end
    end
    if isMeetRequired then
      local startTime = ActivityUtils.ToTimestamp(webSiteConf.start_time)
      local endTime = ActivityUtils.ToTimestamp(webSiteConf.end_time)
      if startTime > _activateParameter.serverTime or endTime <= _activateParameter.serverTime then
        return false
      end
    end
    return isMeetRequired
  end
  return false
end

local WebSiteItemStatus = {
  Locked = 0,
  Completed = 1,
  Done = 2
}

local function CreateWebSiteItemObject(_owner, _webSiteConf)
  local WebSiteItemObject = Class("WebSiteItemObjet")
  
  function WebSiteItemObject:Ctor(_itemOwner, _conf)
    self.owner = _itemOwner
    self.conf = _conf
    self.status = WebSiteItemStatus.Locked
    self.pendingNotifySvr = nil
  end
  
  function WebSiteItemObject:GetOwner()
    return self.owner
  end
  
  function WebSiteItemObject:GetOwnerId()
    local owner = self.owner
    return owner and owner:GetActivityId() or 0
  end
  
  function WebSiteItemObject:GetWebSiteId()
    return self.conf.id
  end
  
  function WebSiteItemObject:GetWebSiteName()
    return self.conf.part_name
  end
  
  function WebSiteItemObject:GetTimeLeft(_serverTime)
    if string.IsNilOrEmpty(self.conf.end_time) then
      return math.maxinteger
    end
    local endTime = ActivityUtils.ToTimestamp(self.conf.end_time)
    return math.max(endTime - _serverTime, 0)
  end
  
  function WebSiteItemObject:RecoverOptionIfRewardGet()
    return self.conf.option_recover
  end
  
  function WebSiteItemObject:GetInteractiveText()
    if self.conf.if_icon_change ~= Enum.ActivityIconChangeRequired.AICR_NONE then
      if self.status == WebSiteItemStatus.Completed then
        return self.conf.interactive_after_txt
      elseif self.status == WebSiteItemStatus.Done and not self:RecoverOptionIfRewardGet() then
        return ""
      end
    end
    return self.conf.interactive_before_txt
  end
  
  function WebSiteItemObject:GetRewardID()
    if self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_NONE then
      return 0
    end
    return self.conf.reward_id
  end
  
  function WebSiteItemObject:OpenUrl()
    local url = self.conf.website_path
    if not string.IsNilOrEmpty(url) then
      if self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_SUCCESS_CLICK then
        _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.RegisterActivityUrlCloseHandle, self.OnWebViewOptNotify, self)
      elseif self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_RECEIVE_NOTE then
        url = string.format("%s&callback_params=%d-%d", url, self.owner and self.owner:GetActivityId() or 0, self.conf.id)
        if self.conf.callback and self.conf.callback > 0 then
          url = string.format("%s&callback=%d", url, self.conf.callback)
        end
      end
      ActivityUtils.OpenUrl(url, 1, self.conf.ban_login_status)
    else
      Log.Error("website_path is empty. part_id=", self:GetWebSiteId())
    end
  end
  
  function WebSiteItemObject:OnWebViewOptNotify(webViewRet)
    if self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_SUCCESS_CLICK then
      self:NotifySvrCompleted()
    end
  end
  
  function WebSiteItemObject:OnClick()
    ActivityUtils.SendTLogActivityAction(self:GetOwnerId(), self:GetWebSiteId(), ActivityEnum.TLogActionType.Join, self.conf.flag_num_join)
    local continueHandle = false
    local canClick = true
    local skipText = self.conf.unsuccess_skip_txt
    local checkCondition = self.conf.check_app
    if not string.IsNilOrEmpty(skipText) and checkCondition and #checkCondition > 0 then
      for _, _condition in ipairs(checkCondition) do
        if _condition == Enum.NeedfulApp.NAPP_QQ then
          canClick = UE4.ULoginStatics.IsQQInstalled()
        elseif _condition == Enum.NeedfulApp.NAPP_WECHAT then
          canClick = UE4.ULoginStatics.IsVxInstalled()
        end
        if not canClick then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, skipText)
          break
        end
      end
    end
    if canClick then
      if self.conf.special == Enum.ActivitySpecialWebSite.ASWS_NONE then
        self:OpenUrl()
      elseif self.conf.special == Enum.ActivitySpecialWebSite.ASWS_JOIN_QQ_GROUP then
        local args = {}
        if not string.IsNilOrEmpty(self.conf.website_path) then
          for argv in string.gmatch(self.conf.website_path, "[^&]+") do
            table.insert(args, argv)
          end
        end
        if #args >= 3 then
          if RocoEnv.PLATFORM ~= "PLATFORM_WINDOWS" then
            continueHandle = UE.UGCloudUtils.JoinQQGroup(args[1], args[2], args[3])
            if not continueHandle then
              _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.owner and self.owner:GetActivityBanText() or "")
            end
          else
            Log.Error("PC\231\137\136\230\156\172\230\156\170\230\142\165\229\133\165,\232\175\183\228\189\191\231\148\168\230\137\139\230\156\186\231\137\136\230\156\172!")
          end
        else
          Log.Error("wrong args, at least 3 arg: ", self.conf.website_path)
        end
      elseif self.conf.special == Enum.ActivitySpecialWebSite.ASWS_SHOW_QRCODE then
        _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenQCodePanel, self.conf, _G.MakeWeakFunctor(self, self.NotifySvrCompleted))
      else
        Log.Error("not support website. special=", self.conf.special)
      end
    end
    _G.GEMPostManager:SendExitLog(self.conf.special, self.conf.id)
    if continueHandle and self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_SUCCESS_CLICK then
      self:NotifySvrCompleted()
    end
  end
  
  function WebSiteItemObject:SetRewardReceived(_userOperation)
    if self.status == WebSiteItemStatus.Done then
      return
    end
    self.status = WebSiteItemStatus.Done
    if self.owner then
      if self:IsCurShouldDelete() then
        self.owner:DeactivateWebSiteItem(self:GetWebSiteId())
      end
      _userOperation = _userOperation or false
      self.owner:OnWebSiteItemStatusChange(self, _userOperation)
    end
  end
  
  function WebSiteItemObject:SetCompleted(_userOperation)
    if self.status == WebSiteItemStatus.Completed then
      return
    end
    if self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_NONE then
      return
    end
    self.pendingNotifySvr = nil
    self.status = WebSiteItemStatus.Completed
    if self.owner then
      _userOperation = _userOperation or false
      self.owner:OnWebSiteItemStatusChange(self, _userOperation)
    end
  end
  
  function WebSiteItemObject:ResetStatus()
    if self.status ~= WebSiteItemStatus.Locked then
      self.status = WebSiteItemStatus.Locked
      if self.owner then
        self.owner:OnWebSiteItemStatusChange(self, false)
      end
    end
  end
  
  function WebSiteItemObject:GetRewardStatus()
    if self.status == WebSiteItemStatus.Completed then
      return ActivityEnum.RewardStatus.Available
    elseif self.status == WebSiteItemStatus.Done then
      return ActivityEnum.RewardStatus.Received
    end
    return ActivityEnum.RewardStatus.UnAvailable
  end
  
  function WebSiteItemObject:IsCurShouldDelete(_serverTime)
    if _serverTime and self:GetTimeLeft(_serverTime) <= 0 then
      return true
    end
    if self:GetRewardStatus() == ActivityEnum.RewardStatus.Received then
      return self.conf.success_if_disappear
    end
    return false
  end
  
  function WebSiteItemObject:GetRewardRedPointData()
    if self.owner then
      return ActivityEnum.RedPointKey.DetailReward, {
        self.owner:GetActivityId(),
        self:GetWebSiteId()
      }
    end
  end
  
  function WebSiteItemObject:GetNewRedPointData()
    if self.owner then
      return 385, {
        self.owner:GetActivityId(),
        self:GetWebSiteId()
      }
    end
  end
  
  function WebSiteItemObject:NotifySvrCompleted(retryFlag)
    if not self.owner then
      return
    end
    if self.status ~= WebSiteItemStatus.Locked then
      return
    end
    self.pendingNotifySvr = true
    local req = _G.ProtoMessage:newZoneAddPlayerActivityPartRewardReq()
    req.activity_id = self.owner:GetActivityId()
    req.activity_part_id = self:GetWebSiteId()
    ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_ADD_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.OnRspNotifySvrCompleted)
    if not retryFlag and self.conf.if_icon_change == Enum.ActivityIconChangeRequired.AICR_SUCCESS_CLICK then
      ActivityUtils.SendTLogActivityAction(self:GetOwnerId(), self:GetWebSiteId(), ActivityEnum.TLogActionType.Finish, self.conf.flag_num_finish)
    end
  end
  
  function WebSiteItemObject:OnRspNotifySvrCompleted(_protoData, _req)
    if not _protoData or 0 ~= _protoData.ret_info.ret_code then
      return
    end
    if not _req or _req.activity_part_id ~= self:GetWebSiteId() then
      Log.Error("parameter error!")
      return
    end
    self:SetCompleted(true)
  end
  
  function WebSiteItemObject:OnReconnectFinish()
    if self.pendingNotifySvr then
      self:NotifySvrCompleted(true)
    end
  end
  
  return WebSiteItemObject(_owner, _webSiteConf)
end

function WebSiteActivityObject:OnConstruct(_conf)
  self.webSiteItems = {}
  self.webSiteItemMap = _G.MakeWeakTable({}, "v")
  self.removedWebSiteItems = {}
end

function WebSiteActivityObject:GetActiveWebSiteItems(_uniqueData)
  return _uniqueData and ActivityUtils.ShallowCopyElements(self.webSiteItems) or self.webSiteItems
end

function WebSiteActivityObject:ActiveWebSiteItems(_activeItems)
  local hasNewActiveItems = false
  for _, id in ipairs(_activeItems) do
    if not self.webSiteItemMap[id] and not self.removedWebSiteItems[id] then
      local webSiteConf = _G.DataConfigManager:GetActivityWebsitePartConf(id)
      local webSiteObj = webSiteConf and CreateWebSiteItemObject(self, webSiteConf)
      if webSiteObj then
        table.insert(self.webSiteItems, webSiteObj)
        self.webSiteItemMap[id] = webSiteObj
        hasNewActiveItems = true
      end
    end
  end
  if hasNewActiveItems then
    table.sort(self.webSiteItems, function(a, b)
      local timeStamp1 = ActivityUtils.ToTimestamp(a.conf.start_time)
      local timeStamp2 = ActivityUtils.ToTimestamp(b.conf.start_time)
      return timeStamp1 > timeStamp2
    end)
    self:SendEvent(ActivityModuleEvent.RefreshActiveWebSiteItems, self)
  end
end

function WebSiteActivityObject:GetWebSiteItem(_partId)
  return self.webSiteItemMap[_partId]
end

function WebSiteActivityObject:CreateWebSiteItem(_partId)
  local itemObj = self:GetWebSiteItem(_partId)
  if not itemObj then
    local webSiteConf = _G.DataConfigManager:GetActivityWebsitePartConf(_partId)
    itemObj = webSiteConf and CreateWebSiteItemObject(self, webSiteConf)
  end
  return itemObj
end

function WebSiteActivityObject:OnAttachView(_view)
  self:OnTickWebItemsOnce()
end

function WebSiteActivityObject:OnDetachView()
  if self.DelayTickWebItemsId then
    _G.DelayManager:CancelDelayById(self.DelayTickWebItemsId)
    self.DelayTickWebItemsId = nil
  end
end

function WebSiteActivityObject:IsActivityCompleted()
  return next(self.removedWebSiteItems) and 0 == #self.webSiteItems
end

function WebSiteActivityObject:OnRefreshActivityData(_activateParameter)
  ActivityUtils.RemoveElements(self.webSiteItems, function(_itemObj, _serverTime)
    if _itemObj:IsCurShouldDelete(_serverTime) then
      self.removedWebSiteItems[_itemObj:GetWebSiteId()] = _serverTime
      return true
    end
  end, nil, _activateParameter.serverTime)
end

function WebSiteActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local _activityData = _updateData
    local partData = _activityData.part_data
    if partData then
      local activeItems = {}
      for _, _partDataEntry in ipairs(partData) do
        local _curPartId = _partDataEntry.activity_part_id
        if _partDataEntry.state ~= _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_NONE and _partDataEntry.state ~= _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_CLOSE then
          if _partDataEntry.state ~= _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
            self.removedWebSiteItems[_curPartId] = nil
          end
          if not self:GetWebSiteItem(_curPartId) then
            table.insert(activeItems, _curPartId)
          end
        else
          self:DeactivateWebSiteItem(_curPartId)
        end
      end
      if #activeItems > 0 then
        self:ActiveWebSiteItems(activeItems)
      end
      for _, _partDataEntry in ipairs(partData) do
        local _itemObj = self:GetWebSiteItem(_partDataEntry.activity_part_id)
        if _itemObj then
          if _partDataEntry.state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
            _itemObj:SetCompleted(false)
          elseif _partDataEntry.state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
            _itemObj:SetRewardReceived(false)
          else
            _itemObj:ResetStatus()
          end
        end
      end
    end
  elseif _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_ADD_PLAYER_ACTIVITY_PART_REWARD_NTY then
    local _partId = _updateData
    local itemObj = self:GetWebSiteItem(_partId)
    if itemObj then
      itemObj:SetCompleted(true)
    end
  end
end

function WebSiteActivityObject:OnTryGetReward(_itemObj)
  if _itemObj then
    local rewardStatus = _itemObj:GetRewardStatus()
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      local req = _G.ProtoMessage:newZoneReceivePlayerActivityPartRewardReq()
      req.activity_id = self:GetActivityId()
      req.activity_part_id = _itemObj:GetWebSiteId()
      ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityPartRewardRsp)
    end
    return rewardStatus
  end
end

function WebSiteActivityObject:OnTryJoinActivity(_itemObj)
  if _itemObj then
    if _itemObj:GetTimeLeft(ActivityUtils.GetSvrTimestamp()) <= 0 then
      return ActivityEnum.ActivityJoinStatus.Expired
    end
    _itemObj:OnClick()
    return ActivityEnum.ActivityJoinStatus.Available
  end
  return ActivityEnum.ActivityJoinStatus.Unsatisfied
end

function WebSiteActivityObject:OnReconnectFinish()
  for _, _itemObj in ipairs(self.webSiteItems) do
    _itemObj:OnReconnectFinish()
  end
  return Base.OnReconnectFinish(self)
end

function WebSiteActivityObject:OnWebSiteItemStatusChange(_itemObj, _userOperation)
  if _itemObj then
    self:SendEvent(ActivityModuleEvent.WebSiteItemStatusChange, self, _itemObj, _userOperation)
  end
end

function WebSiteActivityObject:DeactivateWebSiteItem(_partId)
  local index = -1
  for _index, _obj in ipairs(self.webSiteItems) do
    if _obj and _obj:GetWebSiteId() == _partId then
      index = _index
      break
    end
  end
  if index >= 0 then
    table.remove(self.webSiteItems, index)
    self.removedWebSiteItems[_partId] = ActivityUtils.GetSvrTimestamp()
  end
end

function WebSiteActivityObject:OnTickWebItemsOnce()
  self.DelayTickWebItemsId = nil
  local minLeftTime = math.maxinteger
  local serverTimestamp = ActivityUtils.GetSvrTimestamp()
  for _, _itemObj in ipairs(self.webSiteItems) do
    local leftTime = _itemObj:GetTimeLeft(serverTimestamp)
    self:SendEvent(ActivityModuleEvent.RefreshWebSiteItemLeftTime, self, _itemObj, leftTime)
    if leftTime > 0 then
      minLeftTime = math.min(minLeftTime, leftTime)
    end
  end
  if minLeftTime ~= math.maxinteger and minLeftTime > 0 then
    self.DelayTickWebItemsId = _G.DelayManager:DelaySeconds(math.min(minLeftTime, 60), self.OnTickWebItemsOnce, self)
  end
end

function WebSiteActivityObject:OnZoneReceivePlayerActivityPartRewardRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not _req or _req.activity_id ~= self:GetActivityId() then
    Log.Error("parameter error!")
    return
  end
  local itemObj = self:GetWebSiteItem(_req.activity_part_id)
  if itemObj then
    itemObj:SetRewardReceived(true)
  else
    Log.Error("Can not find web item: part_id=", _req.activity_part_id)
  end
end

return WebSiteActivityObject
