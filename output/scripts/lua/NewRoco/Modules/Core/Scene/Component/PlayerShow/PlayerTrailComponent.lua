local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TrailAssetPath = "Blueprint'/Game/NewRoco/Modules/Core/NPC/Trail/BP_TrailFX.BP_TrailFX_C'"
local Base = ActorComponent
local PlayerTrailComponent = Base:Extend("PlayerTrailComponent")

function PlayerTrailComponent:Attach(owner)
  Base.Attach(self, owner)
  self:AddEventListener()
  self.Trails = {}
end

function PlayerTrailComponent:DeAttach()
  self:RemoveEventListener()
  Base.DeAttach(self)
end

function PlayerTrailComponent:Destroy()
  self:RemoveEventListener()
  Base.Destroy(self)
end

function PlayerTrailComponent:AddEventListener()
end

function PlayerTrailComponent:RemoveEventListener()
end

function PlayerTrailComponent:PlayTrail(InitTransform, Caller, successCallback, failedCallback)
  self:TryCreateTrailInstance(InitTransform, Caller, successCallback, failedCallback)
end

function PlayerTrailComponent:TryCreateTrailInstance(InitTransform, Caller, successCallback, failedCallback)
  local TrailRequest = NRCResourceManager:LoadResAsync(self, TrailAssetPath, -1, 10, function(caller, req, asset)
    self:TrailGenerateSuccess(req, asset, InitTransform, Caller, successCallback, failedCallback)
  end, function(caller, resRequest, errMsg)
    self:TrailGenerateSuccess(caller, resRequest, errMsg, Caller, failedCallback)
  end, function(caller, resRequest, errMsg)
    self:TrailGenerateSuccess(caller, resRequest, errMsg, Caller, failedCallback)
  end)
  Log.Trace("PlayerTrailComponent:TryCreateTrailInstance", TrailRequest)
end

function PlayerTrailComponent:TrailGenerateSuccess(req, asset, InitTransform, caller, successCallback, failedCallback)
  if not asset or not req then
    failedCallback(caller)
    return
  end
  local Trail = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(asset, InitTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, _G.UE4Helper.GetCurrentWorld())
  successCallback(caller, Trail)
end

function PlayerTrailComponent:TrailGenerateFailed(caller, resRequest, errMsg, Caller, failedCallback)
  Log.Error(errMsg, "Trail Load Failed")
  caller.TrailLoadFinished = true
  failedCallback(Caller)
end

return PlayerTrailComponent
