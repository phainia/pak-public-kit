local MagicReplayModuleEnum = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEnum")
local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicReplayUtils = require("NewRoco.Modules.System.MagicReplay.MagicReplayUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local MagicReplayActionBase = require("NewRoco.Modules.System.MagicReplay.Action.MagicReplayActionBase")
local FunctionBanModuleCmd = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleCmd")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = MagicReplayActionBase
local MagicReplayRecordCountDownAction = Base:Extend("MagicReplayRecordCountDownAction")
local CountDownTime = 3
FsmUtils.MergeMembers(Base, MagicReplayRecordCountDownAction, {
  {
    name = "ParentModule",
    type = "var"
  }
})

function MagicReplayRecordCountDownAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function MagicReplayRecordCountDownAction:OnEnter()
  self:InjectProperties()
  self.ParentModule = self:GetProperty("ParentModule")
  self.ParentModule:DispatchEvent(MagicReplayModuleEvent.PlayCountDownNum)
  self.timeout = 20
  self.delayId = _G.DelayManager:DelaySeconds(3, function()
    if self and self.fsm then
      _G.DelayManager:CancelDelayById(self.delayId)
      _G.NRCEventCenter:DispatchEvent(MagicReplayModuleEvent.StopCountDownNum)
      self:Finish()
    end
  end)
end

function MagicReplayRecordCountDownAction:OnFinish()
end

function MagicReplayRecordCountDownAction:OnExit()
  _G.DelayManager:CancelDelayById(self.delayId)
end

return MagicReplayRecordCountDownAction
