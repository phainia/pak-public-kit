local UpdateDataReporter = Class("UpdateDataReporter")
local UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")

function UpdateDataReporter:Init()
  self:ResetValues()
  self:RegisterEvents()
end

function UpdateDataReporter:Uninit()
  self:ResetValues()
end

function UpdateDataReporter:ResetValues()
  self.DownloadStartTime = nil
  self.DownloadFailReason = nil
  self.bTaskFinishStatusCode = nil
  self:ResetDownloadReportParams()
end

function UpdateDataReporter:SendDownloadInfoTLog(ReportType)
  local key = "MultiPackageDownloadFlow"
  local roleDataStr = _G.GEMPostManager:GetGeneralRoleDataForTLog()
  local Network = self:GetNetworkStatusStr() or "nil"
  local OAID = AppMain:GetOAID() or "nil"
  local CAID = AppMain:GetCAID() or "nil"
  local DownloadFailReason = self:GetDownloadFailReason() or "nil"
  local TaskCompleted = self:GetEarlyContentTaskIsComplete() or -1
  local EventID = ReportType or -1
  local DownloadTime = self:GetDownloadTime() or -1
  local DownloadSpeed = self:GetFormatDownloadSpeed() or -1
  local DownloadSize = self:GetFormatDownloadSize() or -1
  local DeviceID = AppMain:GetDeviceId() or "nil"
  local FormatStr = "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s"
  local value = string.format(FormatStr, key, roleDataStr, Network, OAID, CAID, DownloadFailReason, TaskCompleted, EventID, DownloadTime, DownloadSpeed, DownloadSize, DeviceID)
  Log.Debug("[UpdateDataReporter:SendDownloadInfoTLog] ", value)
  Log.Debug(string.format("[UpdateDataReporter:SendDownloadInfoTLog] EventID(%s), DownloadTime(%s), DownloadSpeed(%s), DownloadSize(%s), TaskCompleted:%s", EventID, DownloadTime, DownloadSpeed, DownloadSize, TaskCompleted))
  _G.GEMPostManager:SendNRCTLog(key, value)
end

function UpdateDataReporter:RegisterEvents()
  _G.NRCEventCenter:RegisterEvent("UpdateDataReporter", self, UpdateUIModuleEvent.CheckTaskIsFinished, self.OnCheckTaskIsFinished)
  _G.NRCEventCenter:RegisterEvent("UpdateDataReporter", self, UpdateUIModuleEvent.ReportDownloadBtnClick, self.ReportDownloadBtnClick)
  _G.NRCEventCenter:RegisterEvent("UpdateDataReporter", self, UpdateUIModuleEvent.ReportDownloadBegin, self.ReportDownloadBegin)
  _G.NRCEventCenter:RegisterEvent("UpdateDataReporter", self, UpdateUIModuleEvent.ReportDownloadEnd, self.ReportDownloadEnd)
  _G.NRCEventCenter:RegisterEvent("UpdateDataReporter", self, UpdateUIModuleEvent.ReportDownloadFail, self.ReportDownloadFail)
end

function UpdateDataReporter:UnregisterEvents()
  _G.NRCEventCenter:UnRegisterEvent(self, UpdateUIModuleEvent.CheckTaskIsFinished, self.OnCheckTaskIsFinished)
  _G.NRCEventCenter:UnRegisterEvent(self, UpdateUIModuleEvent.ReportDownloadBtnClick, self.ReportDownloadBtnClick)
  _G.NRCEventCenter:UnRegisterEvent(self, UpdateUIModuleEvent.ReportDownloadBegin, self.ReportDownloadBegin)
  _G.NRCEventCenter:UnRegisterEvent(self, UpdateUIModuleEvent.ReportDownloadEnd, self.ReportDownloadEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, UpdateUIModuleEvent.ReportDownloadFail, self.ReportDownloadFail)
end

function UpdateDataReporter:OnCheckTaskIsFinished(bTaskFinish)
  if nil ~= bTaskFinish then
    self:SetTaskFinishStatusCode(bTaskFinish and 1 or 0)
  else
    self:SetTaskFinishStatusCode(nil)
  end
end

function UpdateDataReporter:ReportDownloadBtnClick(ReportType)
  self:ResetDownloadReportParams()
  self:SendDownloadInfoTLog(ReportType)
end

function UpdateDataReporter:ReportDownloadBegin(ReportType, TaskID)
  self:ResetDownloadReportParams()
  self:SendDownloadInfoTLog(ReportType)
  self:SetDownloadTime(os.time())
  self:SetStartDownloadSize(TaskID)
end

function UpdateDataReporter:ReportDownloadEnd(ReportType, TaskID)
  local BeginTime = self:GetDownloadTime()
  if BeginTime then
    local DownloadTime = os.time() - BeginTime
    self:SetDownloadTime(DownloadTime)
  end
  self:SetDownloadedSize(TaskID)
  self:SendDownloadInfoTLog(ReportType)
  self:ResetDownloadReportParams()
end

function UpdateDataReporter:ReportDownloadFail(ReportType, FailReason, TaskID)
  local BeginTime = self:GetDownloadTime()
  if BeginTime then
    local DownloadTime = os.time() - BeginTime
    self:SetDownloadTime(DownloadTime)
  end
  self:SetDownloadedSize(TaskID)
  self:SetDownloadFailReason(FailReason)
  self:SendDownloadInfoTLog(ReportType)
  self:ResetDownloadReportParams()
end

function UpdateDataReporter:ResetDownloadReportParams()
  self.StartDownloadSize = nil
  self:SetDownloadSize(nil)
  self:SetDownloadTime(nil)
  self:SetDownloadFailReason(nil)
end

function UpdateDataReporter:GetNetworkStatusStr()
  local RetStr = ""
  local NetworkInfo = UE.UNetworkStatics.GetNetworkDetail()
  if NetworkInfo then
    local State = NetworkInfo:state()
    if 2 == State then
      RetStr = "Wifi"
    elseif 3 == State then
      RetStr = "Other"
    elseif 4 == State then
      RetStr = "WWAN"
    elseif 5 == State then
      RetStr = "2G"
    elseif 6 == State then
      RetStr = "3G"
    elseif 7 == State then
      RetStr = "4G"
    elseif 8 == State then
      RetStr = "5G"
    end
  end
  return RetStr
end

function UpdateDataReporter:SetDownloadFailReason(Reason)
  self.DownloadFailReason = Reason
end

function UpdateDataReporter:GetDownloadFailReason()
  return self.DownloadFailReason
end

function UpdateDataReporter:SetDownloadTime(Time)
  self.DownloadTime = Time
end

function UpdateDataReporter:GetDownloadTime()
  return self.DownloadTime
end

function UpdateDataReporter:SetDownloadSize(Size)
  self.DownloadSize = Size
end

function UpdateDataReporter:GetDownloadSize()
  return self.DownloadSize
end

function UpdateDataReporter:GetFormatDownloadSize()
  local DownloadSize = self:GetDownloadSize()
  if DownloadSize then
    local Bytes = tonumber(DownloadSize)
    if Bytes then
      return math.floor(Bytes / 1024 / 1024)
    end
  end
  return -1
end

function UpdateDataReporter:GetFormatDownloadSpeed()
  local Bytes = self:GetDownloadSize()
  local Time = self:GetDownloadTime()
  if nil == Bytes or nil == Time or 0 == Time then
    return -1
  end
  local Speed = Bytes / 1024 / 1024 / Time
  return math.floor(Speed)
end

function UpdateDataReporter:SetTaskFinishStatusCode(StatusCode)
  self.bTaskFinishStatusCode = StatusCode
end

function UpdateDataReporter:GetEarlyContentTaskIsComplete()
  if self.bTaskFinishStatusCode then
    return self.bTaskFinishStatusCode
  else
    if _G.DataModelMgr.PlayerDataModel then
      local bTaskFinish = _G.DataModelMgr.PlayerDataModel:IsAssignStoryFlags(Enum.PlayerStoryFlagEnum.PSF_FUNC_MINI_PACKAGE_DONE)
      Log.Debug("[UpdateDataReporter:GetEarlyContentTaskIsComplete]bTaskFinish: ", bTaskFinish)
      self.bTaskFinishStatusCode = bTaskFinish and 1 or 0
      return self.bTaskFinishStatusCode
    end
    return -1
  end
end

function UpdateDataReporter:SetStartDownloadSize(TaskID)
  if TaskID then
    local DownloadedSize = _G.PufferUpdateResTask:GetLocalDownloadedSizeByTaskID(TaskID)
    if DownloadedSize then
      self.StartDownloadSize = DownloadedSize
      Log.Debug("[UpdateDataReporter:SetStartDownloadSize]DownloadedSize: ", DownloadedSize)
    else
      Log.Error("[UpdateDataReporter:SetStartDownloadSize]DownloadedSize is nil")
    end
  else
    Log.Error("[UpdateDataReporter:SetStartDownloadSize]TaskID is nil")
  end
end

function UpdateDataReporter:SetDownloadedSize(TaskID)
  if TaskID then
    local DownloadedSize = _G.PufferUpdateResTask:GetLocalDownloadedSizeByTaskID(TaskID)
    if DownloadedSize then
      if self.StartDownloadSize then
        DownloadedSize = DownloadedSize - self.StartDownloadSize
        if DownloadedSize < 0 then
          Log.Debug("[UpdateDataReporter:SetDownloadedSize]Invalid DownloadedSize: ", DownloadedSize)
          DownloadedSize = -2
        end
        self:SetDownloadSize(DownloadedSize)
      else
        Log.Error("[UpdateDataReporter:SetDownloadedSize]StartDownloadSize is nil")
      end
    else
      Log.Error("[UpdateDataReporter:SetDownloadedSize]DownloadedSize is nil")
    end
  end
end

return UpdateDataReporter
