require("UnLuaEx")
local BP_ALSComponent_C = NRCClass()

function BP_ALSComponent_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self.player = self:GetOwner().sceneCharacter
end

function BP_ALSComponent_C:OwnerIsMale()
  self.player = self:GetOwner().sceneCharacter
  if self.player then
    return 1 == self.player.gender
  end
  return true
end

function BP_ALSComponent_C:SetInputEnable(Enable)
  self.player = self:GetOwner().sceneCharacter
  if self.player then
    self.player.inputComponent:SetInputEnable(self, Enable, "ALS")
  end
end

function BP_ALSComponent_C:GetGetUpAnimation(RagdollFaceUp)
  self.player = self:GetOwner().sceneCharacter
  local motage
  if RagdollFaceUp then
    motage = self.player:GetAnimComponent():PrepareMontageByName("GetUpBack")
  else
    motage = self.player:GetAnimComponent():PrepareMontageByName("GetUpFront")
  end
  if motage then
    motage.BlendIn.BlendTime = 0.25
    motage.BlendOut.BlendTime = 0.25
  end
  return motage
end

function BP_ALSComponent_C:EndRagdollOpenInput()
  self.player = self:GetOwner().sceneCharacter
  if self.player.playerAttackedInteractionComponent and self.player.playerAttackedInteractionComponent:IsInRagdoll() then
    return
  end
  self.Overridden.EndRagdollOpenInput(self)
end

return BP_ALSComponent_C
