local Base = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerWalkState")
local PlayerFsmEnum = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.PlayerFsmEnum")
local ScenePlayerGrassState = Base:Extend("ScenePlayerGrassState")

function ScenePlayerGrassState:CanEnter(preState)
  local playerBP = self.Player.viewObj
  if playerBP and playerBP.IsInGrass then
    return true
  end
  return false
end

function ScenePlayerGrassState:OnEnter()
  self:UpdateSubState()
end

function ScenePlayerGrassState:CanExit(nextState)
  if self._isTurning then
    return false
  end
  if not self.Player.viewObj.IsInGrass then
    return true
  end
  return false
end

function ScenePlayerGrassState:OnExit()
end

function ScenePlayerGrassState:OnTick(deltaTime)
  self:HandleInput(deltaTime)
  self:UpdateSubState()
end

function ScenePlayerGrassState:UpdateSubState()
  local playerPawn = self.Player.viewObj
  if playerPawn then
    return
  end
  local speed = playerPawn:GetVelocity():Size()
  local fsmComponent = self.Player.FsmComponent
  if speed <= 0 then
    fsmComponent:SetSubState(PlayerFsmEnum.ScenePlayerStateType.GrassCrouch)
  elseif speed <= 300 then
    fsmComponent:SetSubState(PlayerFsmEnum.ScenePlayerStateType.GrassSneak)
  else
    fsmComponent:SetSubState(PlayerFsmEnum.ScenePlayerStateType.GrassTrek)
  end
end

return ScenePlayerGrassState
