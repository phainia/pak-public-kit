local Base = require("NewRoco.Modules.Core.Scene.Component.FSM.FSMComponent")
local FSM = require("Common.FSM.FSM")
local EnumType = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.PlayerFsmEnum")
local EventDispatcher = require("Common.EventDispatcher")
local PlayerIdleState = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerIdleState")
local PlayerMoveState = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerWalkState")
local PlayerGrassState = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerGrassState")
local PlayerCastAbilityState = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerCastAbilityState")
local PlayerDialogueState = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerDialogueState")
local ScenePlayerFSMComponent = Base:Extend("PlayerFSMComponent")

function ScenePlayerFSMComponent:Ctor()
  self.fsm = FSM()
  self.inited = false
  EventDispatcher():Attach(self)
  self.fsm:SetState(EnumType.ScenePlayerStateType.Idle, PlayerIdleState())
  self.fsm:SetState(EnumType.ScenePlayerStateType.Walk, PlayerMoveState())
  self.fsm:SetState(EnumType.ScenePlayerStateType.Grass, PlayerGrassState())
  self.fsm:SetState(EnumType.ScenePlayerStateType.CastAbility, PlayerCastAbilityState())
  self.fsm:SetState(EnumType.ScenePlayerStateType.Dialogue, PlayerDialogueState())
end

function ScenePlayerFSMComponent:Attach(owner)
  Base.Attach(self, owner)
  self:Init(owner)
end

function ScenePlayerFSMComponent:OnVisible()
  Base.OnVisible(self)
  self:Init(self.owner)
  self:SetEnable(true)
end

function ScenePlayerFSMComponent:OnInVisible()
  self:SetEnable(false)
end

function ScenePlayerFSMComponent:Init(player)
  if self.inited or not player then
    return
  end
  for _, v in pairs(self.fsm.stateDic) do
    local curState = v
    curState:Init(player)
  end
  self.inited = true
end

function ScenePlayerFSMComponent:GetCurState()
  return self.fsm.state or {}
end

function ScenePlayerFSMComponent:CanEnter(stateID)
  local targetState = self.fsm:GetState(stateID)
  local curState = self.fsm.state
  return targetState and targetState:CanEnter(curState) and (not curState or curState:CanExit(targetState))
end

function ScenePlayerFSMComponent:SetSubState(subStateID)
  if self.fsm.state and self.fsm.state.subStateID ~= subStateID then
    self.fsm.state.subStateID = subStateID
    self:SendEvent(EnumType.ScenePlayerFsmEvent.STATE_CHANGE, subStateID)
  end
end

function ScenePlayerFSMComponent:ChangeState(stateID)
  local preState = self.fsm.state
  self.fsm:ChangeState(stateID)
  local curState = self.fsm.state
  if self.fsm.state and (not preState or curState.stateID ~= preState.stateID) then
    self:SendEvent(EnumType.ScenePlayerFsmEvent.STATE_CHANGE, stateID)
  end
  return curState
end

return ScenePlayerFSMComponent
