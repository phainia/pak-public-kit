local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local Base = MagicReplayActionBase
local MagicReplayRecordMainAction = Base:Extend("MagicReplayRecordMainAction")
FsmUtils.MergeMembers(Base, MagicReplayRecordMainAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "RecordStartPlayerPos",
    type = "var"
  }
})

function MagicReplayRecordMainAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayRecordMainAction:OnEnter()
  self:InjectProperties()
  self.timeout = MagicReplayUtils.GetRecordingMaxTime() + 5
  self.ParentModule = self.fsm:GetProperty("ParentModule")
  self.ParentModule:DispatchEvent(MagicReplayModuleEvent.RefreshRecordPanel, {
    StateName = self.state.name
  })
  self.isInterrupted = false
  self.LeaveMagicReplayArea = false
  self.isRecordPos = false
  _G.NRCEventCenter:RegisterEvent("MagicReplayRecordMainAction", self, MagicReplayModuleEvent.OnRecordTimeOut, self.OnRecordTimeOut)
  _G.NRCEventCenter:RegisterEvent("MagicReplayRecordMainAction", self, MagicReplayModuleEvent.OnManualStopRecord, self.OnManualStopRecord)
  _G.NRCEventCenter:RegisterEvent("MagicReplayRecordMainAction", self, MagicReplayModuleEvent.OnMagicReplayInterrupt, self.OnMagicReplayInterrupt)
  self:TeleportPlayer(true)
  self.ParentModule:UnRegisterEvent(self, MagicReplayModuleEvent.OnReceiveStopRecordNotify)
  self.ParentModule:RegisterEvent(self, MagicReplayModuleEvent.OnReceiveStopRecordNotify, self.Finish)
  self.LeaveMagicReplayArea = false
  self.ParentModule:UnRegisterEvent(self, MagicReplayModuleEvent.OnLeaveMagicReplayArea)
  self.ParentModule:RegisterEvent(self, MagicReplayModuleEvent.OnLeaveMagicReplayArea, self.OnLeaveMagicReplayArea)
  self:OnStartRecordReq()
end

function MagicReplayRecordMainAction:OnStartRecordReq()
  self.fsm:Pause()
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.SendStartRecordReq, self, self.OnStartRecordRsp)
end

function MagicReplayRecordMainAction:OnStartRecordRsp(rsp)
  if not self.fsm then
    return
  end
  self.fsm:Resume()
end

function MagicReplayRecordMainAction:OnTimeout()
  if self.finished then
    return
  end
  self:SendStopRecordReq()
end

function MagicReplayRecordMainAction:OnRecordTimeOut()
  self:SendStopRecordReq("OnRecordTimeOut")
end

function MagicReplayRecordMainAction:OnManualStopRecord()
  if self.execTime < 1 then
    return
  end
  self:SendStopRecordReq("OnManualStopRecord")
end

function MagicReplayRecordMainAction:OnMagicReplayInterrupt()
  self.isInterrupted = true
  self:SendStopRecordReq("OnMagicReplayInterrupt")
end

function MagicReplayRecordMainAction:OnLeaveMagicReplayArea()
  self.LeaveMagicReplayArea = true
  self:SendStopRecordReq("OnLeaveMagicReplayArea")
end

function MagicReplayRecordMainAction:SendStopRecordReq(reason)
  Log.Debug("MagicReplayRecordMainAction:SendStopRecordReq", reason)
  _G.NRCModeManager:DoCmd(_G.MagicReplayModuleCmd.SendStopRecordReq)
end

function MagicReplayRecordMainAction:OnFinish()
  self:Clear()
end

function MagicReplayRecordMainAction:OnExit()
  if self.finished then
    return
  end
  self:Clear()
end

function MagicReplayRecordMainAction:Clear()
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnMagicReplayInterrupt, self.OnMagicReplayInterrupt)
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnManualStopRecord, self.OnManualStopRecord)
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnRecordTimeOut, self.OnRecordTimeOut)
  if not self.ParentModule then
    self.ParentModule = self.fsm:GetProperty("ParentModule")
  end
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, MagicReplayModuleEvent.OnReceiveStopRecordNotify)
    self.ParentModule:UnRegisterEvent(self, MagicReplayModuleEvent.OnLeaveMagicReplayArea)
  end
  self:TeleportPlayer(false)
end

function MagicReplayRecordMainAction:TeleportPlayer(start_or_end)
  if not MagicReplayUtils.IsRecordEndTeleportEnabled() then
    return
  end
  if start_or_end then
    self.isTeleported = false
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if Player then
      local pos = Player:GetActorLocation()
      self.fsm:SetProperty("RecordStartPlayerPos", pos)
      self.isRecordPos = true
    end
  elseif not self.isTeleported and not self.LeaveMagicReplayArea and not self.isInterrupted and self.isRecordPos then
    local RecordStartPlayerPos = self.fsm:GetProperty("RecordStartPlayerPos")
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if Player and RecordStartPlayerPos then
      local newPos = UE4.FVector(RecordStartPlayerPos.X, RecordStartPlayerPos.Y, RecordStartPlayerPos.Z)
      Player:SetActorLocation(newPos)
      _G.NRCEventCenter:DispatchEvent(SceneEvent.PlayerTeleportFinish)
      self.isTeleported = true
    end
  end
end

return MagicReplayRecordMainAction
