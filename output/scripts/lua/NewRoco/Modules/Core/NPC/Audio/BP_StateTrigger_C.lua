local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local BP_StateTrigger_C = Class()

function BP_StateTrigger_C:Ctor()
end

function BP_StateTrigger_C:ReceiveBeginPlay()
  self:TriggerCollisionCheck()
  _G.NRCEventCenter:RegisterEvent("BP_StateTrigger_C", self, SceneEvent.PlayerBornFinish, self.OnPlayerBornFinish)
end

function BP_StateTrigger_C:ReceiveEndPlay(EndPlayReason)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.OnPlayerBornFinish)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end

function BP_StateTrigger_C:OnPlayerBornFinish()
  self:TriggerCollisionCheck()
end

return BP_StateTrigger_C
