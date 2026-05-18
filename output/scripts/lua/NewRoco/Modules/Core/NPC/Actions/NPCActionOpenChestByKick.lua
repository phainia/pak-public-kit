local NPCActionItemBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionItemBase")
local Base = NPCActionItemBase
local NPCActionOpenChestByKick = Base:Extend("NPCActionOpenChestByKick")

function NPCActionOpenChestByKick:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
end

function NPCActionOpenChestByKick:Execute(playerId, needSendReq)
  self.playerId = playerId
  local model = self:GetOwnerNPCView()
  if model then
    self:PlayOperatingAnimations(playerId, needSendReq)
  else
    Base.Execute(self, playerId, needSendReq)
  end
end

function NPCActionOpenChestByKick:PlayOperatingAnimations(playerId, needSendReq)
  if self.Owner then
    self.Owner:LockPlayerAndBattle()
  end
  local player = self:GetPlayer()
  player:FaceTo(self:GetOwnerNPC())
  player:PlayAnim("KickLotteryChest", 1, nil, 0.2, 0.2, 1)
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
  self.DelayHandle = _G.DelayManager:DelaySeconds(1.2, self.OnOperatingDone, self, playerId, needSendReq)
end

function NPCActionOpenChestByKick:OnOperatingDone(playerId, needSendReq)
  self.DelayHandle = nil
  if self.Owner then
    self.Owner:UnLockPlayerAndBattle()
  end
  Base.Execute(self, playerId, needSendReq)
  local model = self:GetOwnerNPCView()
  if model then
    model:SetBoxOpen()
  end
end

function NPCActionOpenChestByKick:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:Finish()
end

function NPCActionOpenChestByKick:PostOnCommit(rsp)
  if self.Owner and self.Owner.RestoreRideStateAfterInteract then
    self.Owner:RestoreRideStateAfterInteract()
  end
end

return NPCActionOpenChestByKick
