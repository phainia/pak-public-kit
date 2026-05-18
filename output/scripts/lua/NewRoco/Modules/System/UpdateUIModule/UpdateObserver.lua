local UpdateObserver = NRCClass("UpdateObserver")
local MAX_AUTO_DOWNLOAD_RETRY_TIMES = 3

function UpdateObserver:Init()
  Log.Debug("UpdateObserver:Init")
  self.UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")
  self:RegistEvents()
  self.AutoDownloadRetryTimes = 0
end

function UpdateObserver:RegistEvents()
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.OnPSOWarmUpProgress, self.OnPSOWarmUpProgress)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.OnPSOWarmUpEnd, self.OnPSOWarmUpEnd)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.PufferInitProgress, self.ChangeProgress)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.PufferDownloadBatchProgress, self.ChangeProgress)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.PufferDownloadFinish, self.PufferDownloadFinish)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.PopWindow, self.OnPopWindow)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, self.UpdateUIModuleEvent.CloseWindow, self.OnCloseWindow)
  _G.NRCEventCenter:RegisterEvent("UpdateObserver", self, NRCGlobalEvent.OnAutoDownloadFinish, self.OnAutoDownloadFinish)
end

function UpdateObserver:UnregistEvents()
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.OnPSOWarmUpProgress, self.OnPSOWarmUpProgress)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.OnPSOWarmUpEnd, self.OnPSOWarmUpEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.PufferInitProgress, self.ChangeProgress)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.PufferDownloadBatchProgress, self.ChangeProgress)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.PufferDownloadFinish, self.PufferDownloadFinish)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.PopWindow, self.OnPopWindow)
  _G.NRCEventCenter:UnRegisterEvent(self, self.UpdateUIModuleEvent.CloseWindow, self.OnCloseWindow)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnAutoDownloadFinish, self.OnAutoDownloadFinish)
end

function UpdateObserver:Uninit()
  Log.Debug("UpdateObserver:Uninit")
  self:UnregistEvents()
end

function UpdateObserver:OnPSOWarmUpProgress(Progress, Msg)
  self.bPSOWarmingUp = true
  if self.bIsPufferDownloadEnd then
    self:ChangeProgress(Progress, Msg)
  else
    self:ChangeProgress(Progress, nil, nil, nil, nil, Msg)
  end
end

function UpdateObserver:OnPSOWarmUpEnd()
  Log.Debug("UpdateObserver:OnPSOWarmUpEnd")
  self.bIsPSOWarmUpEnd = true
  self.bPSOWarmingUp = false
  self:ClearPSOAppendMsgCache()
  self:PlayLoginVideo()
  self:CheckIsAllProgressEnd()
  if _G.NRCAutoDownloadManager:HasTask() then
    local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
    local UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")
    local PufferDownloadTag = require("NewRoco.Modules.System.Download.PufferDownloadTag")
    local TaskID = _G.NRCAutoDownloadManager:GetTaskID(PufferDownloadTag.Base)
    _G.NRCEventCenter:DispatchEvent(UpdateUIModuleEvent.ReportDownloadFail, LoginEnum.DownloadReportType.BaseDownloadFail, "PSO WarmUp End", TaskID)
    _G.NRCAutoDownloadManager:RemoveAllDownloadTasks()
  end
end

function UpdateObserver:PlayLoginVideo()
  _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.StartPlayVideoList)
end

function UpdateObserver:PufferDownloadFinish()
  Log.Debug("UpdateObserver:PufferDownloadFinish")
  self.bIsPufferDownloadEnd = true
  self:ClearPSOAppendMsgCache()
  self:CheckIsAllProgressEnd()
  if not self.bIsPSOWarmUpEnd then
    _G.NRCAutoDownloadManager:StartDownloadBasePaks()
  end
  if self.bPausePSOWarmUp then
    Log.Error("PSO\233\148\153\232\175\175\230\154\130\229\129\156\239\188\140\233\156\128\232\166\129\230\163\128\230\159\165\233\128\187\232\190\145")
    self:ResumePSOWarmUp()
  end
end

function UpdateObserver:OnAutoDownloadFinish(bSuccess, TaskTag)
  Log.Debug(string.format("[UpdateObserver:OnAutoDownloadFinish] bSuccess: %s, TaskTag: %s", bSuccess, TaskTag))
  if not bSuccess and not self.bIsPSOWarmUpEnd then
    if self.AutoDownloadRetryTimes < MAX_AUTO_DOWNLOAD_RETRY_TIMES then
      self:AutoRetryDownloadBasePaks()
    else
      Log.Debug("[UpdateObserver:OnAutoDownloadFinish] AutoDownloadRetryTimes is max")
    end
  end
end

function UpdateObserver:AutoRetryDownloadBasePaks()
  self.AutoDownloadRetryTimes = self.AutoDownloadRetryTimes + 1
  Log.Debug("[UpdateObserver:AutoRetryDownloadBasePaks] times:", self.AutoDownloadRetryTimes)
  _G.NRCAutoDownloadManager:StartDownloadBasePaks()
end

function UpdateObserver:ClearPSOAppendMsgCache()
  self:ChangeProgress(1)
end

function UpdateObserver:IsAllProgressEnd()
  return self.bIsPSOWarmUpEnd and self.bIsPufferDownloadEnd
end

function UpdateObserver:CheckIsAllProgressEnd()
  if self:IsAllProgressEnd() then
    self:Uninit()
    _G.NRCEventCenter:DispatchEvent(self.UpdateUIModuleEvent.AllUpdateProgressEnd)
  end
end

function UpdateObserver:ChangeProgress(...)
  _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.SetProgress, ...)
end

function UpdateObserver:OnPopWindow()
  if self.bPSOWarmingUp then
    self:PausePSOWarmUp()
  end
end

function UpdateObserver:OnCloseWindow()
  if self.bPausePSOWarmUp then
    self:ResumePSOWarmUp()
  end
end

function UpdateObserver:PausePSOWarmUp()
  Log.Debug("UpdateObserver:PausePSOWarmUp")
  self.bPausePSOWarmUp = true
  UE.UNRCStatics.PausePSOWarmUp()
end

function UpdateObserver:ResumePSOWarmUp()
  Log.Debug("UpdateObserver:ResumePSOWarmUp")
  self.bPausePSOWarmUp = false
  UE.UNRCStatics.ResumePSOWarmUp()
end

return UpdateObserver
