local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local StartInstantAction = Base:Extend("StartInstantAction")

function StartInstantAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function StartInstantAction:OnEnter()
  self.fsm:Pause()
  _G.BattleManager.battleNetManager:StartHandleNotify("Enter StartInstantAction")
  self.instantFsm = _G.BattleManager.instantFsm
  self.instantFsm.EventDispatcher:AddEventListener(self, BattleEvent.InstantPlayOver, self.InstantPlayOver)
  self.instantFsm:Play()
end

function StartInstantAction:InstantPlayOver()
  self.fsm:Resume()
  self:Finish()
end

function StartInstantAction:OnFinish()
  self.instantFsm.EventDispatcher:RemoveEventListener(self, BattleEvent.InstantPlayOver, self.InstantPlayOver)
  self.instantFsm = nil
end

return StartInstantAction
