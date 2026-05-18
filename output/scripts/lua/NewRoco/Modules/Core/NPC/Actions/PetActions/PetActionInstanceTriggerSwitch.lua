local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local Base = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetActionInstanceTriggerSwitch = Base:Extend("PetActionInstanceTriggerSwitch")

function PetActionInstanceTriggerSwitch:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.disableErrorTip = true
end

function PetActionInstanceTriggerSwitch:GetRangeType()
  return Enum.PetReleaseRange.PRR_NONE
end

function PetActionInstanceTriggerSwitch:GetLookAtType()
  return Enum.PetReleaseLookAt.PRLA_PLAYER
end

function PetActionInstanceTriggerSwitch:OnExecute()
  local AI = self.Runner:EnsureComponent(AIComponent)
  self.Runner:SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.AI)
  AI:ForceLockForReason(true, true, AIDefines.LockReason.WAITING)
  self:GetOwnerNPCView().TriggerPet = self.Runner
  local View = self:GetRunnerView()
  if not View then
    self:Submit()
    return
  end
  local Comp = View.CharacterMovement
  Comp.bRunPhysicsWithNoController = true
  Comp.MaxStepHeight = 20
  Comp.MovementMode = UE.EMovementMode.MOVE_Walking
  self:Submit()
end

function PetActionInstanceTriggerSwitch:OnSubmit(rsp)
  if 0 == rsp.ret_info.ret_code then
    local Comp = self.Runner:EnsureComponent(PetStatusComponent)
    if Comp then
      Comp.bInteractingWithSwitch = true
    end
    local view = self:GetRunnerView()
    if view then
      view:SetShouldCheckWaterSurface(true)
    end
    self:GetOwnerNPCView().bControlByServer = true
  end
  Base.OnSubmit(self, rsp)
end

function PetActionInstanceTriggerSwitch:ContinueWhenSuccess()
  return false
end

return PetActionInstanceTriggerSwitch
