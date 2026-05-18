local Base = require("Common.FSM.FSMState")
local ScenePlayerStateBase = Base:Extend("ScenePlayerStateBase")
ScenePlayerStateBase.subStateID = nil

function ScenePlayerStateBase:Ctor()
end

function ScenePlayerStateBase:Init(player)
  self.Player = player
end

function ScenePlayerStateBase:CanEnter(preState)
  return true
end

function ScenePlayerStateBase:OnEnter()
  Base.OnEnter(self)
end

function ScenePlayerStateBase:CanExit(nextState)
  return true
end

function ScenePlayerStateBase:OnExit()
  Base.OnExit(self)
end

function ScenePlayerStateBase:OnTick(deltaTime)
  Base.OnTick(self, deltaTime)
end

function ScenePlayerStateBase:HandleInput(inputVector)
end

return ScenePlayerStateBase
