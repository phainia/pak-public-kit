local JsonUtils = require("Common.JsonUtils")
local UpdateBaseTask = require("Core.Service.GCloud.Tasks.UpdateBaseTask")
local UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")
local Base = UpdateBaseTask
local RunPSO = true
local UpdateResTask = Base:Extend("UpdateResTask")

function UpdateResTask:Ctor()
  Base.Ctor(self)
  self.UserContinue = false
  self.HadNewVersion = false
  self:SetIfVersionRollback(false)
  self:SetIfVersionUpdate(false)
end

function UpdateResTask:FillInfo(InitInfo, PathInfo)
  InitInfo.updateType = UE.DolphinUpdateInitType.UpdateInitType_SourceCheckAndSync
end

function UpdateResTask:ContinueUpdate(bContinue)
  self.UserContinue = true
  Base.ContinueUpdate(self, bContinue)
end

function UpdateResTask:OnDolphinVersionInfo(NewVersionInfo)
  self.HadNewVersion = NewVersionInfo.isNeedUpdating
  self.UpdateVersion = string.format("%d.%d.%d.%d", NewVersionInfo.versionNumberOne, NewVersionInfo.versionNumberTwo, NewVersionInfo.versionNumberThree, NewVersionInfo.versionNumberFour)
  local ResVersion = _G.AppMain:GetResVersion()
  Log.Error(string.format("[UpdateResTask:OnDolphinVersionInfo] LocalResVer:%s, NewResVer:%s, isNeedUpdating:%s, isForcedUpdating:%s", ResVersion, self.UpdateVersion, tostring(self.HadNewVersion), tostring(NewVersionInfo.isForcedUpdating)))
  if self.HadNewVersion and self:NeedForceDownload() then
    NewVersionInfo.isForcedUpdating = true
  end
  Base.OnDolphinVersionInfo(self, NewVersionInfo)
end

function UpdateResTask:OnDolphinSuccess()
  Log.Debug("OnDolphinSuccess, Had New Version?", self.HadNewVersion, "User Continue?", self.UserContinue)
  if self.HadNewVersion and self.UserContinue then
    local ResVersion = _G.AppMain:GetResVersion()
    if not string.IsNilOrEmpty(ResVersion) and ResVersion ~= self.UpdateVersion then
      if self:CompareVersion(ResVersion, self.UpdateVersion) then
        Log.Warning(string.format("\231\137\136\230\156\172\229\155\158\233\128\128\239\188\140\233\156\128\232\166\129\233\135\141\229\144\175:CurVersion:%s, New Version:%s", ResVersion, self.UpdateVersion))
        self:SetIfVersionRollback(true)
        JsonUtils.DumpSaved("DolphinVersion", {
          ResVersion = self.UpdateVersion
        })
        Log.Debug("[UpdateResTask:OnDolphinSuccess()] Write LocalResVersion:", self.UpdateVersion)
      else
        Log.Debug(string.format("\231\137\136\230\156\172\230\155\180\230\150\176:CurVersion:%s, New Version:%s", ResVersion, self.UpdateVersion))
        self:SetIfVersionUpdate(true)
      end
    end
    _G.AppMain:SetResVersion(self.UpdateVersion)
    _G.NRCEventCenter:DispatchEvent(UpdateUIModuleEvent.UpdateNewResVersion, self.UpdateVersion)
  end
  Base.OnDolphinSuccess(self)
end

function UpdateResTask:ConvertToBaseVersion(Version)
  local Splat = string.Split(Version, ".")
  if #Splat < 4 then
    return "1.0.1.0"
  end
  Splat[4] = "0"
  local NewVersion = table.concat(Splat, ".")
  return NewVersion
end

function UpdateResTask:NeedForceDownload()
  return true
end

function UpdateResTask:GetIfVersionRollback()
  return self.bIfVersionRollback
end

function UpdateResTask:SetIfVersionRollback(Value)
  self.bIfVersionRollback = Value
end

function UpdateResTask:GetIfVersionUpdate()
  return self.bIfVersionUpdate
end

function UpdateResTask:SetIfVersionUpdate(Value)
  self.bIfVersionUpdate = Value
end

return UpdateResTask
