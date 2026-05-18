local RidePerceptionTrigger = NRCClass()
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local TempArray = UE.TArray(UE.AActor)

function RidePerceptionTrigger:Ctor()
  self.overlapped_npc = {}
end

function RidePerceptionTrigger:Init(config, ownerPet)
  self.ownerPet = ownerPet
  self.add_status = {}
  self.npc_id = {}
  self.effectIns = {}
  if config.param_1 then
    self.radius = tonumber(config.param_1)
    self.Sphere:SetSphereRadius(self.radius)
  end
  if config.param_2 then
    local str_add_status = string.split(config.param_2, ";")
    for i, v in ipairs(str_add_status) do
      table.insert(self.add_status, tonumber(v))
    end
  end
  if config.param_3 then
    local str_npc_id = string.split(config.param_3, ";")
    for i, v in ipairs(str_npc_id) do
      table.insert(self.npc_id, tonumber(v))
    end
  end
  self:UpdateOverlappedNpc()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:RegisterEvent(self, NPCModuleEvent.OnViewVisible, function()
    self:UpdateOverlappedNpc()
  end)
end

function RidePerceptionTrigger:UpdateOverlappedNpc()
  self:GetOverlappingActors(TempArray, UE.AActor)
  for idx, actor in tpairs(TempArray) do
    local sceneActor = actor.sceneCharacter
    if self:ShouldTake(sceneActor) then
      local perceptActor = self.overlapped_npc[actor]
      if not perceptActor or perceptActor ~= sceneActor then
        self.overlapped_npc[actor] = sceneActor
        sceneActor:EnsureEventListener(self, NPCModuleEvent.OnInteractionEnableChanged, self.OnInteractionEnableChanged)
        if sceneActor.canTriggerInteraction then
          self:PlayPerceptionEffect(sceneActor, true)
        end
      end
    end
  end
end

function RidePerceptionTrigger:OnInteractionEnableChanged(npc, enable)
  self:PlayPerceptionEffect(npc, enable)
end

function RidePerceptionTrigger:ShouldTake(npc)
  if GlobalConfig.bRidePerceptionAll then
    return true
  end
  if not npc then
    return false
  end
  if not npc.config then
    return false
  end
  local Other = self:GetPetBaseConf(npc)
  if Other then
    local HasCommonType = self:HasCommon(Other.unit_type, self.add_status)
    Log.Debug("RidePerceptionTrigger ShouldTake series", Other.name, HasCommonType and "yes" or "no")
    if HasCommonType then
      local BattleAction = npc.InteractionComponent and npc.InteractionComponent:GetActiveBattleAction()
      if BattleAction then
        return true
      end
    end
    return false
  end
  if not table.contains(self.npc_id, npc.config.id) then
    Log.Debug("RidePerceptionTrigger ShouldTake ID", npc.config.name, "no")
    return false
  end
  Log.Debug("RidePerceptionTrigger ShouldTake", npc.config.name, "yes")
  return true
end

function RidePerceptionTrigger:HasCommon(Part1, Part2)
  if not Part1 or not Part2 then
    return
  end
  for _, Sub1 in ipairs(Part1) do
    for _, Sub2 in ipairs(Part2) do
      if Sub1 == Sub2 then
        return true
      end
    end
  end
  return false
end

function RidePerceptionTrigger:GetPetBaseConf(npc)
  local Comp = npc.PetStatusComponent
  if Comp and Comp.CurrentPetData then
    return _G.DataConfigManager:GetPetbaseConf(Comp.CurrentPetData.base_conf_id)
  end
  if npc.config.traverse_data_type ~= Enum.Traverse_Data_Type.TDT_PETBASE then
    return nil
  end
  local PetBaseConfID = npc.config.traverse_data_param[1]
  return _G.DataConfigManager:GetPetbaseConf(PetBaseConfID)
end

function RidePerceptionTrigger:ReceiveActorBeginOverlap(OtherActor)
  if OtherActor.sceneCharacter and self:ShouldTake(OtherActor.sceneCharacter) then
    local perceptActor = self.overlapped_npc[OtherActor]
    if not perceptActor or perceptActor ~= OtherActor.sceneCharacter then
      self.overlapped_npc[OtherActor] = OtherActor.sceneCharacter
      OtherActor.sceneCharacter:EnsureEventListener(self, NPCModuleEvent.OnInteractionEnableChanged, self.OnInteractionEnableChanged)
      if OtherActor.sceneCharacter.canTriggerInteraction then
        self:PlayPerceptionEffect(OtherActor.sceneCharacter, true)
      end
    end
  end
end

function RidePerceptionTrigger:ReceiveActorEndOverlap(OtherActor)
  if OtherActor and OtherActor.sceneCharacter and self.overlapped_npc then
    local dist = OtherActor:K2_GetActorLocation():Dist(self:K2_GetActorLocation())
    local radius = self.radius or 0
    if dist > radius then
      self.overlapped_npc[OtherActor] = nil
      OtherActor.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnInteractionEnableChanged, self.OnInteractionEnableChanged)
      self:PlayPerceptionEffect(OtherActor.sceneCharacter, false)
    else
      Log.DebugFormat("RidePerceptionTrigger:ReceiveActorEndOverlap dist invalid")
    end
  end
end

function RidePerceptionTrigger:OnDestroy()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule:UnRegisterEvent(self, NPCModuleEvent.OnViewVisible)
  for k, v in pairs(self.overlapped_npc) do
    v:RemoveEventListener(self, NPCModuleEvent.OnInteractionEnableChanged, self.OnInteractionEnableChanged)
    self:PlayPerceptionEffect(v, false)
  end
  self.overlapped_npc = {}
end

function RidePerceptionTrigger:ReceiveEndPlay(EndPlayReason)
  self:OnDestroy()
end

local Enum_SACF_DISABLE_PET_GANZHI = Enum.SceneAiControlFlags.SACF_DISABLE_PET_GANZHI

function RidePerceptionTrigger:PlayPerceptionEffect(target, start)
  if not target then
    Log.Error("RidePerceptionTrigger:PlayPerceptionEffect target is nil")
    return
  end
  local started = target.marked_in_perception_trigger
  target.marked_in_perception_trigger = start
  if start then
    if started then
      Log.Error("\233\135\141\229\164\141\232\167\166\229\143\145PlayPerceptionEffect\239\188\140\230\139\166\230\136\170\228\184\139\230\157\165")
      return
    end
    local AIComp = target.AIComponent
    if AIComp then
      if not target.marked_in_perception_trigger_callback then
        target:AddEventListener(self, NPCModuleEvent.OnAiControlFlagChanged, self.OnAiControlFlagChanged)
        target.marked_in_perception_trigger_callback = true
      end
      if AIComp:HasControlFlags(Enum_SACF_DISABLE_PET_GANZHI) then
        return
      end
    end
    self:PlayPerceptionEffectInternal(target, start)
  else
    if target.marked_in_perception_trigger_callback then
      target:RemoveEventListener(self, NPCModuleEvent.OnAiControlFlagChanged, self.OnAiControlFlagChanged)
      target.marked_in_perception_trigger_callback = false
    end
    self:PlayPerceptionEffectInternal(target, false)
  end
end

function RidePerceptionTrigger:PlayPerceptionEffectInternal(target, start)
  if not (target and target.viewObj and self.ownerPet) or not self.ownerPet.viewObj then
    Log.Debug("RidePerceptionTrigger:PlayPerceptionEffect Failed")
    return
  end
  local mat = self.ownerPet.viewObj.PerceptionMat
  target:MarkPerception(start)
  UE4.UNewRocoHelperLibrary.SetPerceptionEffectActive(target.viewObj, mat, start)
  local customDepth = start and 20 or nil
  if target.SetCustomDepth then
    target:SetCustomDepth(customDepth)
  end
end

function RidePerceptionTrigger:OnAiControlFlagChanged(newFlag, prevFlag, owner)
  local changed = (newFlag ~ prevFlag) & 1 << Enum_SACF_DISABLE_PET_GANZHI > 0
  if not changed then
    return
  end
  local disabled = 0 ~= newFlag & 1 << Enum_SACF_DISABLE_PET_GANZHI
  self:PlayPerceptionEffectInternal(owner, not disabled)
end

return RidePerceptionTrigger
