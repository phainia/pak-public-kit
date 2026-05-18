local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = NPCActionBase
local NPCActionShakeTree = Base:Extend("NPCActionShakeTree")

function NPCActionShakeTree:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
  self.ShakeDoneHandler = nil
end

function NPCActionShakeTree:ExecuteWithModel()
  self:UnLinkHand()
  local player = self:GetPlayer()
  if player then
    player:RecordPlayerPos()
    player:FaceTo(self:GetOwnerNPC())
    if player.inputComponent then
      player.inputComponent:SetInputEnable(self, false)
    end
  end
  if player then
    if player and UE.UObject.IsValid(player.viewObj) then
      local Capsule = player.viewObj:K2_GetRootComponent()
      if Capsule then
        local Config = self:GetOwnerConfig()
        local ProjectPos = self.OwnerNpc.viewObj:GetInterPos(player:GetActorLocation(), Config.enablefix_distance, Config.fix_distance, Config.fix_rotation, Capsule:GetScaledCapsuleRadius())
        local bLanded = player.viewObj.CharacterMovement:Abs_Land(ProjectPos)
      end
    end
    local playerAnimComp = player.viewObj:GetAnimComponent()
    playerAnimComp:PlayAnimByName("WorldHarvestFruit")
  end
  local View = self:GetOwnerNPCView()
  if View then
    View.InteractType = NPCModuleEnum.InteractType.PLAYER
    View.PetBullRush = false
    View.HoldFruit = false
  end
  self.ShakeDoneHandler = _G.DelayManager:DelaySeconds(1.5, self.ShakeDone, self)
end

function NPCActionShakeTree:ShakeDone()
  self.ShakeDoneHandler = nil
  local player = self:GetPlayer()
  if player then
    player:FaceTo(self:GetOwnerNPC())
    if player.inputComponent then
      player.inputComponent:SetInputEnable(self, true)
    end
    player:RecoverPlayerPos()
  end
  self:ReLinkHand()
  self:Finish()
end

function NPCActionShakeTree:PostOnCommit(rsp)
  if self.Owner and self.Owner.RestoreRideStateAfterInteract then
    self.Owner:RestoreRideStateAfterInteract()
  end
  if self.ShakeDoneHandler then
    _G.DelayManager:CancelDelayById(self.ShakeDoneHandler)
    self.ShakeDoneHandler = nil
  end
end

return NPCActionShakeTree
