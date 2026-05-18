local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ShinyWeekendActivityObject = Base:Extend("ShinyWeekendActivityObject")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function ShinyWeekendActivityObject:OnConstruct(_conf)
  self.shinyWeekEndConf = _G.DataConfigManager:GetActivityShinyWeekendConf(self:GetSinglePartId())
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SHINY_PET_DAY_INFO_CHANGE_NTY, self.OnZonePlayerShinyPetDayInfoChangeNty)
end

function ShinyWeekendActivityObject:OnDestruct()
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SHINY_PET_DAY_INFO_CHANGE_NTY, self.OnZonePlayerShinyPetDayInfoChangeNty)
end

function ShinyWeekendActivityObject:IsPreviewActivity()
  return self:GetActivityType() == Enum.ActivityType.ATP_SHINY_WEEKEND_PREVIEW
end

function ShinyWeekendActivityObject:GetActivityNumber()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.activity_number or 0
end

function ShinyWeekendActivityObject:GetPetBaseId()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.petbase_id
end

function ShinyWeekendActivityObject:GetIconRewardId()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.icon_reward_id
end

function ShinyWeekendActivityObject:GetShinyPetSecret()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.shiny_pet_secret
end

function ShinyWeekendActivityObject:GetShinyPetShow()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.shiny_pet_show
end

function ShinyWeekendActivityObject:GetTeaserText()
  local conf = self.shinyWeekEndConf
  if conf then
    return {
      conf.teaser_txt,
      conf.teaser_txt2,
      conf.teaser_txt3
    }
  end
end

function ShinyWeekendActivityObject:GetIconRewardId()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.icon_reward_id
end

function ShinyWeekendActivityObject:GetFlowerSeedId()
  return self.shinyWeekEndConf and self.shinyWeekEndConf.seed_id or 0
end

function ShinyWeekendActivityObject:GetPlayerShinyPetDayInfo()
  return self.playerShinyPetDayInfo
end

function ShinyWeekendActivityObject:GetActivityShinyPetDayData()
  return self.activityShinyPetDayData
end

function ShinyWeekendActivityObject:GetPetBloodId()
  return ActivityUtils.GetPetBloodIdByShinyWeekendConf(self.shinyWeekEndConf)
end

function ShinyWeekendActivityObject:IsShinyWeekendDataShouldClear(id, timeStampNow)
  local shinyWeekEndConf = _G.DataConfigManager:GetActivityShinyWeekendConf(id)
  if shinyWeekEndConf and not string.IsNilOrEmpty(shinyWeekEndConf.clear_time) then
    local clearTimeStamp = ActivityUtils.ToTimestamp(shinyWeekEndConf.clear_time)
    if timeStampNow > clearTimeStamp then
      return true
    end
  end
end

function ShinyWeekendActivityObject:GetActivityEndTime()
  if self:IsPreviewActivity() then
    local weekendEnd = self.shinyWeekEndConf and self.shinyWeekEndConf.shiny_weekend_end
    if not string.IsNilOrEmpty(weekendEnd) then
      return ActivityUtils.ToTimestamp(weekendEnd)
    end
  end
  return Base.GetActivityEndTime(self)
end

function ShinyWeekendActivityObject:OnTryJoinActivity()
  if self:IsPreviewActivity() then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OnOpenMagicManualToFlowerPanel)
end

function ShinyWeekendActivityObject:SyncActivityDataOnAvailable()
  self:ReqGetPlayerActivityData()
  self:SendZoneGetPlayerShinyPetDayInfoReq()
end

function ShinyWeekendActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local _activityData = _updateData
    self.activityShinyPetDayData = _activityData and _activityData.shiny_pet_day_data
    self:SendEvent(ActivityModuleEvent.RefreshActivityShinyPetDayData, self, self:GetActivityId(), self.activityShinyPetDayData)
  end
end

function ShinyWeekendActivityObject:OnSvrUpdateActivityHistoryData(_activityData)
  local timeNow = ActivityUtils.GetSvrTimestamp()
  ActivityUtils.RemoveElements(_activityData, function(_dataItem)
    if not _dataItem.shiny_pet_day_data or not _dataItem.expired then
      return true
    end
    if self:IsShinyWeekendDataShouldClear(_dataItem.shiny_pet_day_data.activity_sub_id, timeNow) then
      return true
    end
  end)
  if _activityData then
    table.sort(_activityData, function(a, b)
      return a.shiny_pet_day_data.activity_sub_id < b.shiny_pet_day_data.activity_sub_id
    end)
  end
  self:SendEvent(ActivityModuleEvent.RefreshShinyHistoryData, self)
end

function ShinyWeekendActivityObject:SendZoneGetPlayerShinyPetDayInfoReq()
  if self:GetSvrStatus() ~= ActivityEnum.ActivitySvrStatus.Available then
    return
  end
  local req = _G.ProtoMessage:newZoneGetPlayerShinyPetDayInfoReq()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_SHINY_PET_DAY_INFO_REQ, req, self, self.OnZoneGetPlayerShinyPetDayInfoRsp)
end

function ShinyWeekendActivityObject:SendZoneReceivePlayerActivityShinyPetDayPetalReq()
  if not self.playerShinyPetDayInfo or not self.playerShinyPetDayInfo.has_petal then
    return
  end
  local req = _G.ProtoMessage:newZoneReceivePlayerActivityShinyPetDayPetalReq()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_SHINY_PET_DAY_PETAL_REQ, req, self, self.OnZoneReceivePlayerActivityShinyPetDayPetalRsp)
end

function ShinyWeekendActivityObject:SendZoneReceivePlayerActivityShinyPetDayRewardReq(_activityId)
  if not _activityId then
    return
  end
  local req = _G.ProtoMessage:newZoneReceivePlayerActivityShinyPetDayRewardReq()
  req.activity_id = _activityId
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_SHINY_PET_DAY_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityShinyPetDayRewardRsp)
end

function ShinyWeekendActivityObject:OnZoneGetPlayerShinyPetDayInfoRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  self.playerShinyPetDayInfo = _protoData.info
  self:SendEvent(ActivityModuleEvent.RefreshPlayerShinyPetDayDataInfo, self)
end

function ShinyWeekendActivityObject:OnZonePlayerShinyPetDayInfoChangeNty(_protoData)
  if not _protoData then
    return
  end
  self.playerShinyPetDayInfo = _protoData.info
  self:SendEvent(ActivityModuleEvent.RefreshPlayerShinyPetDayDataInfo, self)
end

function ShinyWeekendActivityObject:OnZoneReceivePlayerActivityShinyPetDayPetalRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not self.playerShinyPetDayInfo then
    self.playerShinyPetDayInfo = {}
  end
  self.playerShinyPetDayInfo.has_petal = false
  self:SendEvent(ActivityModuleEvent.RefreshPlayerShinyPetDayDataInfo, self)
end

function ShinyWeekendActivityObject:OnZoneReceivePlayerActivityShinyPetDayRewardRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if _req then
    if _req.activity_id == self:GetActivityId() then
      if not self.activityShinyPetDayData then
        self.activityShinyPetDayData = {}
      end
      self.activityShinyPetDayData.received_reward = 2
      self:SendEvent(ActivityModuleEvent.RefreshActivityShinyPetDayData, self, _req.activity_id, self.activityShinyPetDayData)
      self:SendEvent(ActivityModuleEvent.ShinyWeekendActivityRewardReceived, self, _req.activity_id, self.activityShinyPetDayData)
      ActivityUtils.ShowRewardGetTips(nil, _protoData.ret_info)
    else
      local historyData = self:GetActivityHistoryData()
      if historyData then
        for _, _item in ipairs(historyData) do
          if _item.activity_id == _req.activity_id then
            if _item.shiny_pet_day_data then
              _item.shiny_pet_day_data.received_reward = 2
              self:SendEvent(ActivityModuleEvent.RefreshActivityShinyPetDayData, self, _item.activity_id, _item.shiny_pet_day_data)
              self:SendEvent(ActivityModuleEvent.ShinyWeekendActivityRewardReceived, self, _item.activity_id, _item.shiny_pet_day_data)
              ActivityUtils.ShowRewardGetTips(nil, _protoData.ret_info)
            end
            break
          end
        end
      end
    end
  end
end

return ShinyWeekendActivityObject
