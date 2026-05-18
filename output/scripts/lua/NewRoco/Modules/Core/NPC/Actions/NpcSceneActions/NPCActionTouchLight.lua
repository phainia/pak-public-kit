local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionTouchLight = Base:Extend("NPCActionTouchLight")

function NPCActionTouchLight:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.shouldSync = true
end

function NPCActionTouchLight:Execute(playerId, needSendReq)
  self.needSendReq = needSendReq
  if self.needSendReq == nil then
    self.needSendReq = true
  end
  self.playerId = playerId
  local player = self:GetPlayer()
  if not player then
    Base.Execute(self, playerId, needSendReq)
    return
  end
  player:StopRide(true)
  local animName = self.Config.action_param2
  if string.IsNilOrEmpty(animName) then
    Base.Execute(self, playerId, needSendReq)
  else
    local Rot = player:RotationTo(self:GetOwnerNPC(), true)
    player:SetActorRotation(Rot)
    local animLength = player:PlayAnim(animName, 1, 0, 0.25, 0.25, 1, 0, "Locomotion")
    _G.NRCAudioManager:PlaySound2DAuto(1174, "UI_explore_goods_drop")
    local executeTime = tonumber(self.Config.action_param3) or animLength
    if executeTime > 1.0E-5 then
      if self.Owner then
        self.Owner:LockPlayerAndBattle()
      end
      _G.DelayManager:DelaySeconds(executeTime, self.RealExecute, self)
      _G.DelayManager:DelaySeconds(animLength, function()
        if self.Owner then
          self.Owner:UnLockPlayerAndBattle()
        end
      end, self)
    else
      Base.Execute(self, playerId, needSendReq)
    end
  end
end

function NPCActionTouchLight:RealExecute()
  self:CheckStopAnim()
  Base.Execute(self, self.player_id, self.needSendReq)
end

function NPCActionTouchLight:CheckStopAnim()
  local player = self:GetPlayer()
  local animName = self.Config.action_param2
  local animComp = player and player:GetAnimComponent()
  if animComp then
    if player.movementComponent:IsMoving() then
      player:StopAnim(animName, 0.1, "Locomotion")
    else
      _G.DelayManager:DelaySeconds(0.02, self.CheckStopAnim, self)
    end
  end
end

function NPCActionTouchLight:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:Finish()
end

function NPCActionTouchLight:PostOnCommit(rsp)
  if self.Owner and self.Owner.RestoreRideStateAfterInteract then
    self.Owner:RestoreRideStateAfterInteract()
  end
end

return NPCActionTouchLight
