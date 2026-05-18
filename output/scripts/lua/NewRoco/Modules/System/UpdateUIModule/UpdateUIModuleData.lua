local UpdateUIModuleData = _G.NRCData:Extend("UpdateUIModuleData")

function UpdateUIModuleData:Ctor()
  NRCData.Ctor(self)
  self:ResetDownloadingTaskId()
  self:ResetDownloadingPufferTaskType()
end

function UpdateUIModuleData:ResetDownloadingTaskId()
  self.CurrentDownloadingPufferTaskId = nil
end

function UpdateUIModuleData:SetDownloadingTaskId(TaskId)
  self.CurrentDownloadingPufferTaskId = TaskId
end

function UpdateUIModuleData:GetDownloadingTaskId()
  return self.CurrentDownloadingPufferTaskId
end

function UpdateUIModuleData:ResetDownloadingPufferTaskType()
  self.CurrentDownloadingPufferTaskType = nil
end

function UpdateUIModuleData:SetDownloadingPufferTaskType(Type)
  self.CurrentDownloadingPufferTaskType = Type
end

function UpdateUIModuleData:GetDownloadingPufferTaskType()
  return self.CurrentDownloadingPufferTaskType
end

function UpdateUIModuleData:SetEnablePreDownloadBasePaks(bEnable)
  self.bEnablePreDownloadBasePaks = bEnable
end

function UpdateUIModuleData:GetEnablePreDownloadBasePaks()
  return self.bEnablePreDownloadBasePaks
end

function UpdateUIModuleData:SetEnableBackgroundDownload(bEnable)
  self.bEnableBackgroundDownload = bEnable
end

function UpdateUIModuleData:GetEnableBackgroundDownload()
  return self.bEnableBackgroundDownload
end

function UpdateUIModuleData:SetReloadLuaNeedToRestartApp(value)
  self.bReloadLuaNeedToRestartApp = value
end

function UpdateUIModuleData:GetReloadLuaNeedToRestartApp()
  return self.bReloadLuaNeedToRestartApp
end

return UpdateUIModuleData
