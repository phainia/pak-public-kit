local DelayTaskQueue = require("Profiler.Utils.DelayTaskQueue")
local Base = require("Profiler.PerfCat.Base.BaseAutomation")
local PerfCatCmd = require("Profiler.PerfCat.PerfCatCmd")
local GeneralVfxAutomation = Base:Extend("GeneralVfxAutomation")
local configFileName = "GeneralVfxAutomationConfig"
local CHANNEL = "FxSystemPerf"

function GeneralVfxAutomation:InitializeAutomation()
  self.cacheAssetList = {}
  if self.config.AssetList then
    self.cacheAssetList = self.config.AssetList
  else
    table.insert(self.cacheAssetList, "/Game/ArtRes/Effects/Particle/Scene/WorldCombat/YSQ/NS_Wat_705016_RYBF_zhuti")
    table.insert(self.cacheAssetList, "/Game/ArtRes/Effects/Particle/Scene/WorldCombat/YSQ/NS_Fir_YSQ_HYCF_Zhuti")
    Log.Error("GeneralVfxAutomation:Initialize() AssetList is nil")
  end
  self.duration = self.config.MaxDuration or 5
  self.OnEffectFinishedCallBack = _G.SimpleDelegateFactory:CreateCallback(self, self.OnEffectFinished)
  self.timer = nil
end

function GeneralVfxAutomation:GetConfigName()
  return configFileName
end

function GeneralVfxAutomation:IsPlaying()
  return #self.cacheAssetList > 0
end

function GeneralVfxAutomation:OnAutomationBegin()
  PerfCatCmd.Channel.Start(CHANNEL)
  self:AddTask(3, self.PlayNext)
  self:ProcessTaskQueue()
end

function GeneralVfxAutomation:EnterTestWorld()
  self.local_modules = {
    "FunctionBanModule",
    "CollisionModule"
  }
  Base.EnterTestWorld(self)
end

function GeneralVfxAutomation:PlayNext()
  self:HidePlayer()
  self.player.viewObj:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(0, 0, 0), false, false)
  if #self.cacheAssetList > 0 and self.player.viewObj then
    local asset = self.cacheAssetList[1]
    local effectSystem = LoadObject(asset)
    if effectSystem and effectSystem.GetClass then
      Log.Info("GeneralVfxAutomation:PlayNext() effectSystem:", asset)
      PerfCatCmd.Channel.Begin(string.format("%s %s", CHANNEL, asset))
      if effectSystem:GetClass():GetName() == "NiagaraSystem" then
        local comp = UE4.UNiagaraFunctionLibrary.SpawnSystemAtLocation(self.player.viewObj, effectSystem, self.player.viewObj:Abs_K2_GetActorLocation(), self.player.viewObj:K2_GetActorRotation(), UE4.FVector(1, 1, 1), true, false, UE.ENCPoolMethod.None, true)
        comp.OnSystemFinished:Add(comp, self.OnEffectFinishedCallBack)
        comp:Activate(true)
        self.timer = _G.TimerManager:CreateTimer(self, "OnEffectExceedDuration", self.duration, nil, function()
          self:OnEffectFinished(comp)
        end, 99999)
      elseif effectSystem:GetClass():GetName() == "ParticleSystem" then
        local comp = UE4.UGameplayStatics.SpawnEmitterAtLocation(self.player.viewObj, effectSystem, self.player.viewObj:Abs_K2_GetActorLocation(), self.player.viewObj:K2_GetActorRotation(), UE4.FVector(1, 1, 1), true, UE.ENCPoolMethod.None, false)
        comp.OnSystemFinished:Add(comp, self.OnEffectFinishedCallBack)
        comp:Activate(true)
        self.timer = _G.TimerManager:CreateTimer(self, "OnEffectExceedDuration", self.duration, nil, function()
          self:OnEffectFinished(comp)
        end, 99999)
      else
        Log.Error("GeneralVfxAutomation:PlayNext() effectSystem is not a NiagaraComponent or ParticleSystemComponent")
        self:OnEffectFinished(nil)
      end
    else
      Log.Error("GeneralVfxAutomation:PlayNext() cannot load effectSystem:", asset)
      self:OnEffectFinished(nil)
    end
  else
    self:StopAutomation()
  end
end

function GeneralVfxAutomation:OnEffectFinished(comp)
  Log.Info("GeneralVfxAutomation:OnEffectFinished()")
  if comp and not comp:IsBeingDestroyed() then
    comp.OnSystemFinished:Remove(comp, self.OnEffectFinishedCallBack)
    comp:K2_DestroyComponent(comp)
  end
  if self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
    self.timer = nil
  end
  table.remove(self.cacheAssetList, 1)
  PerfCatCmd.Channel.Pause(string.format("%s", CHANNEL))
  self:AddTask(1, self.PlayNext)
  self:ProcessTaskQueue()
end

function GeneralVfxAutomation:OnAutomationEnd()
  PerfCatCmd.Channel.Stop()
end

return GeneralVfxAutomation
