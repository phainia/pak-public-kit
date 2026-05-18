local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetActionFactory = require("NewRoco.Modules.Core.NPC.Actions.PetActionFactory")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local CatchPetComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.CatchPetComponent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local SyncPetActionComponent = Base:Extend("SyncPetActionComponent")

function SyncPetActionComponent:Attach(owner)
  Log.Error("SyncPetActionComponent:Attach")
  Base.Attach(self, owner)
end

function SyncPetActionComponent:OnSetViewObj()
  Base.OnSetViewObj(self)
end

function SyncPetActionComponent:PreResourceUnload()
end

function SyncPetActionComponent:OnResourceLoaded()
end

function SyncPetActionComponent:AddCachedClientOperation(Operation)
  if not self.CachedSyncClientOperations then
    self.CachedSyncClientOperations = {}
  end
  table.insert(self.CachedSyncClientOperations, Operation)
end

function SyncPetActionComponent:ExecuteCachedClientOperation()
  if not self.CachedSyncClientOperations then
    return
  end
  for k, Operation in ipairs(self.CachedSyncClientOperations) do
    table.remove(self.CachedSyncClientOperations, k)
    self:DealClientOperation(Operation)
  end
end

function SyncPetActionComponent:OnClientBornBegin()
end

function SyncPetActionComponent:OnClientBornEnd()
  self:ExecuteCachedClientOperation()
end

function SyncPetActionComponent:DealClientOperation(Operation)
  Log.Debug("SyncPetActionComponent:DealClientOperation", self.owner:DebugNPCNameAndID())
  Log.Dump(Operation, 2, "[SyncPetActionComponent]DealClientOperation")
  if not self:IsValidToDealClientOperation() then
    self:AddCachedClientOperation(Operation)
    return
  end
  local PetActionInfo = Operation.pet_action_info
  if PetActionInfo then
    self:DealPetAction(Operation)
  end
end

function SyncPetActionComponent:IsValidToDealClientOperation()
  local bornDie = self.owner:EnsureComponent(BornDieComponent)
  if bornDie and bornDie:IsSpawning() then
    Log.Warning("SyncPetActionComponent:IsValidToDealClientOperation fail reason: Owner is currently in spawn state")
    return false
  end
  return true
end

function SyncPetActionComponent:DealPetAction(Operation)
  local PetActionInfo = Operation.pet_action_info
  if not PetActionInfo then
    Log.Error("not getting any pet action info")
    return
  end
  local Pet = self:GetNPC(Operation.operator_id)
  if not Pet then
    Log.Error("\231\178\190\231\129\181\231\148\154\232\135\179\233\131\189\229\183\178\231\187\143\228\184\141\229\173\152\229\156\168\228\186\134\227\128\130\227\128\130\227\128\130\231\165\158\229\165\135", Operation.operator_id)
    return
  end
  if Pet:IsControlledByPlayer() then
    Log.Error("\231\130\184\228\186\134\227\128\130\227\128\130\227\128\130\232\191\153\233\135\140\228\184\141\229\186\148\232\175\165\230\148\182\229\136\176\232\135\170\229\183\177\231\154\132\231\178\190\231\129\181\231\154\132\230\182\136\230\129\175...")
    return
  end
  if PetActionInfo.action_status == NPCModuleEnum.ActionStatus.End then
    Pet.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.INTERACT)
    return
  end
  local ActionInst
  if 0 == PetActionInfo.operation_target_id then
    ActionInst = PetActionFactory:MakeWithType(PetActionInfo.operation_type)
  else
    local Target = self:GetNPC(PetActionInfo.operation_target_id)
    if not Target then
      Log.Error("\230\137\190\228\184\141\229\136\176Target NPC", PetActionInfo.operation_target_id)
      return
    end
    local TargetInterComp = Target.InteractionComponent
    local Option = TargetInterComp:GetOptionByID(PetActionInfo.option_id)
    if not ActionInst then
      Log.Debug("Failed to get pet action, recreate one")
      local ActionConf = self:GetActionConf(PetActionInfo)
      ActionInst = PetActionFactory:GetAction(Option, ActionConf)
      if not ActionInst then
        Log.Error("Can't find action with given param")
        return
      end
    end
  end
  Pet.AIComponent:ForceLockForReason(true, true, AIDefines.LockReason.INTERACT)
  self.CurrentRunningAction = ActionInst
  ActionInst:AddEventListener(self, PetActionEvent.OnFinish, self.OnActionFinished)
  ActionInst:Execute(Pet)
end

function SyncPetActionComponent:OnActionFinished(Action)
  if self.CurrentRunningAction == Action then
    self.CurrentRunningAction = nil
    Log.Debug("Running action success")
  else
    Log.Error("Failed to run action")
  end
end

function SyncPetActionComponent:DeAttach()
  Base.DeAttach(self)
end

function SyncPetActionComponent:Destroy()
  Base.Destroy(self)
end

function SyncPetActionComponent:GetNPC(ID)
  return _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
end

function SyncPetActionComponent:GetActionConf(Operation)
  if not Operation then
    return
  end
  local ConfType = Operation.conf_type
  if ConfType == ProtoEnum.ClientOperationConfType.COCT_NPC_OPTION_CONF then
    local OptionConf = _G.DataConfigManager:GetNpcOptionConf(Operation.conf_id)
    return OptionConf and OptionConf.pet_action
  elseif ConfType == ProtoEnum.ClientOperationConfType.COCT_NPC_WILD_OPTION_CONF then
    local OptionConf = _G.DataConfigManager:GetNpcOptionConf(Operation.conf_id)
    return OptionConf and OptionConf.wild_action
  elseif ConfType == ProtoEnum.ClientOperationConfType.COCT_PET_INTERACTION_CONF then
    return _G.DataConfigManager:GetPetInteractionConf(Operation.conf_id)
  else
    return nil
  end
end

return SyncPetActionComponent
