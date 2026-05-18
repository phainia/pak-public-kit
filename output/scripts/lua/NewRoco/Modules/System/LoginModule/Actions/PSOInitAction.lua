local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local JsonUtils = require("Common.JsonUtils")
local Base = FsmAction
local PSOInitAction = Base:Extend("PSOInitAction")
FsmUtils.MergeMembers(Base, PSOInitAction, {})

function PSOInitAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.TotalCount = 0
  self.bIsPrecompiling = false
  self.TotalCount = 0
  self.RemainCount = 0
end

function PSOInitAction:OnEnter()
  self.bIsPrecompiling = false
  self:OnEnterAndroid()
end

function PSOInitAction:EnablePSO()
  if UE.UNRCStatics.GetCurrentRHIName() == "D3D11" then
    Log.Warning("PSOInitAction:EnablePSO D3D11 \228\184\141\230\148\175\230\140\129\233\162\132\231\131\173PSOCache")
    self:Finish()
    return
  end
  local version = JsonUtils.LoadSaved("PSOVersion", {PSOVersion = ""})
  local PSOFiles = UE.UNRCStatics.ListFiles(UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. "PipelineCaches", "*.upipelinecache")
  local PSOFilesTable = PSOFiles:ToTable()
  self.PSOHash = ""
  for Index, Path in ipairs(PSOFilesTable) do
    local FileName = UE.UBlueprintPathsLibrary.GetBaseFilename(Path, true) .. ".upipelinecache"
    Log.Warning("PSOInitAction:EnablePSO : ", Path, FileName)
    self.PSOHash = UE.UResVerifyConfigStatics.GetFileHashFromResVerifyConfig(FileName)
    if not string.IsNilOrEmpty(self.PSOHash) then
      break
    end
  end
  Log.Warning("GetOSVersion : ", UE4.UNRCStatics.GetOSVersion())
  Log.Warning("PSOHash : ", self.PSOHash)
  self.PSOPrecompilingReason = ""
  if version.PSOVersion ~= _G.AppMain:GetAppVersion() or version.Hash ~= self.PSOHash or version.SystemVersion ~= UE4.UNRCStatics.GetOSVersion() then
    self.PSOPrecompilingReason = string.format(" PSOHash %s -> %s, System_Driven %s -> %s", version.PSOVersion, _G.AppMain:GetAppVersion(), version.SystemVersion, UE4.UNRCStatics.GetOSVersion())
    Log.Warning("PSOInitAction:EnablePSO \231\137\136\230\156\172\228\184\141\229\140\185\233\133\141 \229\136\160\233\153\164\230\156\172\229\156\176Cache\229\185\182\233\135\141\230\150\176\233\162\132\231\131\173:", self.PSOPrecompilingReason)
    UE.UNRCStatics.ExecConsoleCommand("PSO.DeleteCache")
  end
  UE.UNRCStatics.ExecConsoleCommand("r.ShaderPipelineCache.Enabled 1")
  UE.UNRCStatics.ReloadShaderPipelineCache()
  UE.UNRCStatics.ExecConsoleCommand("r.ShaderPipelineCache.BatchTime 100")
  UE.UNRCStatics.ExecConsoleCommand("r.ShaderPipelineCache.BatchSize 1")
  UE.UNRCStatics.ExecConsoleCommand("r.ShaderPipelineCache.SetBatchMode Fast")
  Log.PrintScreenMsg("r.ShaderPipelineCache.SetBatchMode Fast")
end

function PSOInitAction:OnEnterAndroid()
  self.timeout = 20
  _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.ShowCanvas, LoginEnum.CanvasNames.UpdateProgressPanel, true)
  self:ChangeProgress(0, LuaText.psoinitaction_1)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.OnShaderBeginPrecompile, self.OnBeginCompile)
  self.delayHandle = _G.DelayManager:DelaySeconds(1, self.EnablePSO, self)
end

function PSOInitAction:OnBeginCompile(Count)
  self.TotalCount = Count
  local RemainCount = UE.UNRCStatics.GetShaderPrecompileRemainingTasks()
  if 0 == RemainCount then
    Log.Warning("\228\184\141\231\148\168\233\162\132\231\131\173\231\157\128\232\137\178\229\153\168")
    self:Finish()
    return
  end
  self.NumExpiredPSO = UE.UNRCStatics.GetNumExpiredPSO()
  if not _G.RocoEnv.IS_EDITOR then
    local Reason = string.format("%s %s", self.PSOPrecompilingReason, UE.UNRCStatics.GetPrecompilingReason())
    Log.Warning("PSOInitAction:OnBeginCompile Reason : ", Reason)
  end
  JsonUtils.DumpSaved("PSOVersion", {PSOVersion = ""})
  Log.PrintScreenMsg("OnBeginCompile %d", RemainCount)
  self.bIsPrecompiling = true
  self:ChangeProgress(0, LuaText.psoinitaction_2)
  self.timeout = self.TotalCount * 10
  self.RemainCount = self.TotalCount
end

function PSOInitAction:OnTick(DeltaTime)
  if not self.bIsPrecompiling then
    return
  end
  self.RemainCount = UE.UNRCStatics.GetShaderPrecompileRemainingTasks()
  if 0 == self.RemainCount and UE.UNRCStatics.IsRHIShaderPipelineCacheReady() then
    Log.PrintScreenMsg("\233\162\132\231\131\173\231\157\128\232\137\178\229\153\168\229\174\140\230\136\144 %d", self.TotalCount)
    Log.Warning("PSOInitAction:OnTick PSOHash : ", self.PSOHash)
    JsonUtils.DumpSaved("PSOVersion", {
      PSOVersion = _G.AppMain:GetAppVersion(),
      SystemVersion = UE4.UNRCStatics.GetOSVersion(),
      Hash = self.PSOHash
    })
    self:ChangeProgress(1, LuaText.psoinitaction_3)
    self:Finish()
  else
    Log.Debug("\230\173\163\229\156\168\233\162\132\231\131\173\231\157\128\232\137\178\229\153\168", self.RemainCount)
    local RemainPercent = 1 - self.RemainCount / self.TotalCount
    if RemainPercent > 0.99 then
      RemainPercent = 0.99
    end
    local msg = string.format("%s \229\183\178\233\162\132\231\131\173(%d)/\229\164\177\230\149\136(%d)/%d ", LuaText.psoinitaction_2, self.TotalCount - self.RemainCount, self.NumExpiredPSO, self.TotalCount)
    self:ChangeProgress(RemainPercent, msg)
  end
end

function PSOInitAction:ChangeProgress(Percent, Text)
  _G.NRCModuleManager:DoCmd(_G.UpdateUIModuleCmd.SetProgress, math.clamp(Percent, 0, 1), Text)
end

function PSOInitAction:OnFinish()
  UE.UNRCStatics.ExecConsoleCommand("r.ShaderPipelineCache.SetBatchMode Background")
  Log.PrintScreenMsg("r.ShaderPipelineCache.SetBatchMode Background")
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnShaderBeginPrecompile, self.OnBeginCompile)
  self.bIsPrecompiling = false
  if RocoEnv.IOS then
    local Reason = UE.UNRCStatics.GetPrecompilingReason()
    Log.Warning("PSOInitAction:OnBeginCompileFinished Reason : ", Reason)
    _G.NRCSDKManager:CrashSightReportExceptionWithReason(Reason, "PSO Precompiling Finished", "")
  end
  if self.delayHandle then
    _G.DelayManager:CancelDelayById(self.delayHandle)
    self.delayHandle = nil
  end
end

function PSOInitAction:OnExit()
end

return PSOInitAction
