local PufferObserver = NRCClass()

function PufferObserver:Initialize(Param)
  self.TaskInstance = Param
end

function PufferObserver:Forword(Name, ...)
  if not self.TaskInstance then
    Log.ErrorFormat("PufferObserver:%s,\230\137\190\228\184\141\229\136\176UpdateTask", Name)
    return
  end
  local CallbackFunc = self.TaskInstance[Name]
  if not CallbackFunc then
    Log.ErrorFormat("PufferObserver:%s,\230\137\190\228\184\141\229\136\176UpdateTask:%s", Name, Name)
    return
  end
  CallbackFunc(self.TaskInstance, ...)
end

function PufferObserver:OnInitReturn(IsSuccess, ErrorCode)
  self:Forword("OnInitReturn", IsSuccess, ErrorCode)
end

function PufferObserver:OnInitProgress(Stage, NowSize, TotalSize)
  self:Forword("OnInitProgress", Stage, NowSize, TotalSize)
end

function PufferObserver:OnDownloadReturn(TaskId, FiledId, IsSuccess, ErrorCode)
  self:Forword("OnDownloadReturn", TaskId, FiledId, IsSuccess, ErrorCode)
end

function PufferObserver:OnDownloadProgress(TaskId, NowSize, TotalSize)
  self:Forword("OnDownloadProgress", TaskId, NowSize, TotalSize)
end

function PufferObserver:OnRestoreReturn(IsSuccess, ErrorCode)
  self:Forword("OnRestoreReturn", IsSuccess, ErrorCode)
end

function PufferObserver:OnRestoreProgress(Stage, NowSize, TotalSize)
  self:Forword("OnRestoreProgress", Stage, NowSize, TotalSize)
end

function PufferObserver:OnDownloadBatchReturn(BatchTaskId, FiledId, IsSuccess, ErrorCode, BatchType, StrRet)
  self:Forword("OnDownloadBatchReturn", BatchTaskId, FiledId, IsSuccess, ErrorCode, BatchType, StrRet)
end

function PufferObserver:OnDownloadBatchProgress(BatchTaskId, NowSize, TotalSize)
  self:Forword("OnDownloadBatchProgress", BatchTaskId, NowSize, TotalSize)
end

function PufferObserver:OnDownloadIOSBackgroundDone()
  self:Forword("OnDownloadIOSBackgroundDone")
end

function PufferObserver:OnPufferFileListItem(FileName, St)
  self:Forword("OnPufferFileListItem", FileName, St)
end

return PufferObserver
