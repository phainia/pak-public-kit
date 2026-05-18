require("UnLuaEx")
local Delegate = require("Utils.Delegate")
local CinematicModuleEvent = require("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local Base = require("NewRoco/Modules/Core/Cinematic/BP_CinematicPlayer_C")
local BP_LoginLevelSequenceActor_C = Base:Extend("BP_LoginLevelSequenceActor_C")

function BP_LoginLevelSequenceActor_C:Ctor()
  self.FinishDelegate = Delegate()
end

function BP_LoginLevelSequenceActor_C:ReceiveBeginPlay()
  self.SequencePlayer.OnPlay:Add(self, self.OnSequencePlay)
  self.SequencePlayer.OnFinished:Add(self, self.OnSequenceEnd)
end

function BP_LoginLevelSequenceActor_C:ReceiveEndPlay(EndPlayReason)
  self:OnSequenceEnd()
end

function BP_LoginLevelSequenceActor_C:BindDelegateToSequence(event, caller, callback)
  self.FinishDelegate:Add(caller, callback)
  event:Add(self, self.OnSequenceFinished)
end

function BP_LoginLevelSequenceActor_C:UnbindDelegateToSequence(caller, callback)
  self.FinishDelegate:Remove(caller, callback)
end

function BP_LoginLevelSequenceActor_C:OnSequenceFinished()
  self.FinishDelegate:Invoke()
end

function BP_LoginLevelSequenceActor_C:OnSequencePlay()
  _G.NRCEventCenter:DispatchEvent(CinematicModuleEvent.OpenCinematicBar, true)
end

function BP_LoginLevelSequenceActor_C:OnSequenceEnd()
  _G.NRCEventCenter:DispatchEvent(CinematicModuleEvent.CloseCinematicBar)
end

return BP_LoginLevelSequenceActor_C
