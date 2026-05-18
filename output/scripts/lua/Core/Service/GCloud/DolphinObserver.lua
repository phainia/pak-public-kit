local rapidjson = require("rapidjson")
local DolphinObserver = NRCClass()

function DolphinObserver:Initialize(Param)
  self.TaskInstance = Param
end

function DolphinObserver:Forward(Name, ...)
  if not self.TaskInstance then
    Log.ErrorFormat("DolphinObserver:%s,\230\137\190\228\184\141\229\136\176UpdateTask", Name)
    return
  end
  local CallbackFunc = self.TaskInstance[Name]
  if not CallbackFunc then
    Log.ErrorFormat("DolphinObserver:%s,\230\137\190\228\184\141\229\136\176UpdateTask:%s", Name, Name)
    return
  end
  CallbackFunc(self.TaskInstance, ...)
end

function DolphinObserver:OnDolphinVersionInfo(NewVersionInfo)
  self:Forward("OnDolphinVersionInfo", NewVersionInfo)
end

function DolphinObserver:OnDolphinProgress(CurVersionStage, TotalSize, NowSize)
  self:Forward("OnDolphinProgress", CurVersionStage, TotalSize, NowSize)
end

function DolphinObserver:OnDolphinError(CurVersionStage, ErrorCode)
  self:Forward("OnDolphinError", CurVersionStage, ErrorCode)
end

function DolphinObserver:OnDolphinSuccess()
  self:Forward("OnDolphinSuccess")
end

function DolphinObserver:OnDolphinNoticeInstallApk(ApkUrl)
  self:Forward("OnDolphinNoticeInstallApk", ApkUrl)
end

function DolphinObserver:OnDolphinFirstExtractSuccess()
  self:Forward("OnDolphinFirstExtractSuccess")
end

function DolphinObserver:OnActionMsgArrive(Message)
  self:Forward("OnActionMsgArrive", rapidjson.decode(Message))
end

return DolphinObserver
