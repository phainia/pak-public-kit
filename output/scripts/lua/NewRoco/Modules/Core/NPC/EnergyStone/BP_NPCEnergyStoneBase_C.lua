local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Delegate = require("Utils.Delegate")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local BP_NPCBox_PetType_C = require("NewRoco.Modules.Core.NPC.Box.BP_NPCBox_PetType_C")
local PotentialEnergyComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PotentialEnergyComponent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = ViewNPCBase
local BP_NPCEnergyStoneBase_C = Base:Extend("BP_NPCEnergyStoneBase_C")

function BP_NPCEnergyStoneBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.OpenFinishDelegate = Delegate()
  self.AuroraActor = false
  self.Runner = false
end

function BP_NPCEnergyStoneBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.Runner = false
  self.AuroraActor = false
end

function BP_NPCEnergyStoneBase_C:FindMainOption(ActionType)
  if not self.sceneCharacter or not self.sceneCharacter.InteractionComponent then
    return
  end
  local selfOption = self.sceneCharacter.InteractionComponent._options
  for _, v in pairs(selfOption) do
    if v.config.pet_action.action_type == ActionType then
      return v
    end
  end
  return nil
end

function BP_NPCEnergyStoneBase_C:Init()
  Base.Init(self)
  self.IsOpened = false
  self.RocoSkill:StopCurrentSkill()
  UE.UNRCStatics.EmptyOverrideMaterials(self.SkeletalMesh)
end

function BP_NPCEnergyStoneBase_C:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  if sceneCharacter then
    self.ActorID = sceneCharacter:GetServerId()
    self.sceneCharacter:EnsureComponent(PotentialEnergyComponent)
  else
    self.ActorID = 0
  end
end

function BP_NPCEnergyStoneBase_C:OnInVisible()
  self:ClearPetType()
  local Actor = self:GetAuroraActor()
  if Actor then
    Actor:ClearPetType()
  end
  Base.OnInVisible(self)
  local meshComp = self:GetComponentByClass(UE.UMeshComponent)
  if meshComp then
    meshComp.KinematicBonesUpdateType = 0
    meshComp.bNRCAlwaysUpdateKinematicBonesToAnim = true
    meshComp.bNRCUseFixedSkelBounds = false
  end
end

function BP_NPCEnergyStoneBase_C:OnVisible()
  Base.OnVisible(self)
  self:SetupView()
end

function BP_NPCEnergyStoneBase_C:SetupView()
  if not self.sceneCharacter then
    return
  end
  if not self.sceneCharacter.luaObj then
    return
  end
  local Comp = self.sceneCharacter.PotentialEnergyComponent
  local action = Comp and Comp.potentialEnergy
  local actionPropertyType = Comp and Comp.propertyType
  if action and action.enabled then
    local PetType1 = BP_NPCBox_PetType_C:ToPetType(action.potential_energy[1])
    local PetType2 = -1
    if PetType2 < 0 then
      self:SetBeamColor(action.potential_energy[1])
    else
      self:SetBeamColor(action.potential_energy[2])
    end
    self:PlayLoopSkill(PetType1, PetType2)
  elseif actionPropertyType and actionPropertyType.property_types and #actionPropertyType.property_types > 0 then
    local PetPropertyType1 = BP_NPCBox_PetType_C:ToPetType(actionPropertyType.property_types[1])
    local PetPropertyType2 = -1
    local Actor = self:GetAuroraActor()
    Actor:SetPetType(PetPropertyType1, PetPropertyType2)
    self:PlayLoopSkill(PetPropertyType1, PetPropertyType2)
  else
    self:ClearPetType()
  end
  self:RefreshBeam()
end

function BP_NPCEnergyStoneBase_C:OnEnterBattle(center, radius, disSqr)
  Base.OnEnterBattle(self, center, radius, disSqr)
  if not self.frameLoaded then
    return
  end
  if not self.resourceLoaded then
    return
  end
  if not self.bActorVisible then
    return
  end
  self.RocoSkill:StopCurrentSkill()
  self:SetupView()
end

function BP_NPCEnergyStoneBase_C:UpdatePotentialEnergy(action, perform)
  self.IsOpened = action.enabled
  if self.IsOpened then
    local PetType1 = BP_NPCBox_PetType_C:ToPetType(action.potential_energy[1])
    local PetType2 = -1
    local Actor = self:GetAuroraActor()
    if Actor then
      if perform then
        self:PlayUpdateSkill(Actor, PetType1, PetType2)
      else
        Actor:SetPetType(PetType1, PetType2)
      end
    else
      Log.Error("Wrong!!")
    end
  else
    self.AuroraComp:SetVisibility(false, true)
    self.AuroraActor = false
    self:ClearPetType()
  end
end

function BP_NPCEnergyStoneBase_C:ShowPotentialEnergy(action)
  self.IsOpened = action.enabled
  if not self.IsOpened then
    return
  end
  local Actor = self:GetAuroraActor()
  if not Actor then
    return
  end
  local PetType1 = BP_NPCBox_PetType_C:ToPetType(action.potential_energy[1])
  local PetType2 = -1
  Actor:SetPetType(PetType1, PetType2)
  self:PlayOpenSkill(Actor, PetType1, PetType2)
end

function BP_NPCEnergyStoneBase_C:HidePotentialEnergy()
  self.RocoSkill:StopCurrentSkill()
  self.IsOpened = false
  self.AuroraComp:SetVisibility(false, true)
  self.AuroraActor = false
  self:ClearPetType()
end

function BP_NPCEnergyStoneBase_C:UpdatePropertyType(action, perform)
  self.IsOpened = action.property_types and #action.property_types > 0
  if self.IsOpened then
    local PetPropertyType1 = BP_NPCBox_PetType_C:ToPetType(action.property_types[1])
    local PetPropertyType2 = -1
    local Actor = self:GetAuroraActor()
    if Actor then
      if perform then
        self:PlayUpdateSkill(Actor, PetPropertyType1, PetPropertyType2)
      else
        Actor:SetPetType(PetPropertyType1, PetPropertyType2)
      end
    else
      Log.Error("Wrong!!")
    end
  else
    self.AuroraComp:SetVisibility(false, true)
    self.AuroraActor = false
    self:ClearPetType()
  end
end

function BP_NPCEnergyStoneBase_C:ShowPropertyType(action)
  self.IsOpened = action.property_types and #action.property_types > 0
  if not self.IsOpened then
    return
  end
  local Actor = self:GetAuroraActor()
  if not Actor then
    return
  end
  local PetPropertyType1 = BP_NPCBox_PetType_C:ToPetType(action.property_types[1])
  local PetPropertyType2 = -1
  self:PlayOpenSkill(Actor, PetPropertyType1, PetPropertyType2)
end

function BP_NPCEnergyStoneBase_C:HidePropertyType()
  self.RocoSkill:StopCurrentSkill()
  self.IsOpened = false
  self.AuroraComp:SetVisibility(false, true)
  self.AuroraActor = false
  self.Beam:SetActive(false)
  self:ClearPetType()
end

function BP_NPCEnergyStoneBase_C:PlayLoopSkill(Type1, Type2)
  self.RocoSkill:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneStonePillar/G6_Scene_StoneLoop", self.RocoSkill, PriorityEnum.Active_Player_Action)
  Skill:SetCaster(self)
  Skill:SetAdditions("Type1", Type1)
  Skill:SetAdditions("Type2", Type2)
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupColor)
  Skill:PlaySkill()
end

function BP_NPCEnergyStoneBase_C:OnSetupColor(Name, Skill)
  if not Skill then
    return
  end
  local Type1 = Skill:GetAddition("Type1")
  local Type2 = Skill:GetAddition("Type2")
  local Actor = Skill:GetAddition("Aurora")
  if not Actor then
    return
  end
  local Blackboard = Skill:GetBlackboard()
  Blackboard:SetValueAsVector("PetTypeColor1", self:GetColor(Actor, Type1))
  if Type2 < 0 then
    Blackboard:SetValueAsVector("PetTypeColor2", self:GetColor(Actor, Type1))
  else
    Blackboard:SetValueAsVector("PetTypeColor2", self:GetColor(Actor, Type2))
  end
end

function BP_NPCEnergyStoneBase_C:PlayOpenSkill(Actor, Type1, Type2)
  Log.Debug("BP_NPCEnergyStoneBase_C:PlayOpenSkill")
  if not UE4.UObject.IsValid(Actor) then
    self.OpenFinishDelegate:Invoke(false)
    return
  end
  Actor:UnlockOnce(true)
  self.RocoSkill:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneStonePillar/G6_Scene_StoneUnseal", self.RocoSkill, PriorityEnum.Active_Player_Action)
  Skill:SetCaster(self)
  if self.Runner then
    Skill:SetTargets({
      self.Runner.viewObj
    })
  end
  Skill:SetAdditions("Type1", Type1)
  Skill:SetAdditions("Type2", Type2)
  Skill:SetAdditions("Aurora", Actor)
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupOpenSkill)
  Skill:RegisterEventCallback("Unlock", self, self.OnUpdateType)
  Skill:RegisterEventCallback("End", self, self.OnSkillFinish)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillFinish)
  Skill:RegisterEventCallback("Interrupt", self, self.OnSkillFinish)
  Skill:SetStartFailedAsEnd(false)
  Skill:PlaySkill(self, self.OnStartResult)
end

function BP_NPCEnergyStoneBase_C:OnSetupOpenSkill(Name, Skill)
  Skill.CleanupMaterials = false
  local Type1 = Skill:GetAddition("Type1")
  local Type2 = Skill:GetAddition("Type2")
  local Actor = Skill:GetAddition("Aurora")
  if not Actor then
    return
  end
  local Blackboard = Skill:GetBlackboard()
  Blackboard:SetValueAsVector("PetTypeColor1", self:GetColor(Actor, Type1))
  if Type2 < 0 then
    Blackboard:SetValueAsVector("PetTypeColor2", self:GetColor(Actor, Type1))
  else
    Blackboard:SetValueAsVector("PetTypeColor2", self:GetColor(Actor, Type2))
  end
end

function BP_NPCEnergyStoneBase_C:OnStartResult(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    return
  end
  self.OpenFinishDelegate:Invoke(false)
end

function BP_NPCEnergyStoneBase_C:PlayUpdateSkill(Actor, Type1, Type2)
  Log.Debug("BP_NPCEnergyStoneBase_C:PlayUpdateSkill")
  if not Actor then
    self.OpenFinishDelegate:Invoke(false)
    return
  end
  Actor:UnlockOnce(false)
  self.RocoSkill:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneStonePillar/G6_Scene_StoneTrigger01", self.RocoSkill, PriorityEnum.Active_Player_Action)
  Skill:SetCaster(self)
  if self.Runner then
    Skill:SetTargets({
      self.Runner.viewObj
    })
  end
  Skill:SetAdditions("Type1", Type1)
  Skill:SetAdditions("Type2", Type2)
  Skill:SetAdditions("Aurora", Actor)
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupOpenSkill)
  Skill:RegisterEventCallback("End", self, self.OnSkillFinish)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillFinish)
  Skill:RegisterEventCallback("UpdateType", self, self.OnUpdateType)
  Skill:RegisterEventCallback("Interrupt", self, self.OnSkillFinish)
  Skill:SetStartFailedAsEnd(false)
  Skill:PlaySkill(self, self.OnStartResult)
end

function BP_NPCEnergyStoneBase_C:OnUpdateType(Name, Skill)
  local PetType1 = Skill:GetAddition("Type1")
  local PetType2 = Skill:GetAddition("Type2")
  local Actor = Skill:GetAddition("Aurora")
  if UE4.UObject.IsValid(Actor) then
    Actor:SetPetType(PetType1, PetType2)
  end
end

function BP_NPCEnergyStoneBase_C:OnSkillFinish(Name, Skill)
  self.OpenFinishDelegate:Invoke(true)
  self:ProcessNotify()
end

function BP_NPCEnergyStoneBase_C:GetAuroraActor()
  if self.AuroraActor and UE4.UObject.IsValid(self.AuroraActor) then
    return self.AuroraActor
  end
  self.AuroraComp:SetVisibility(true, false)
  self.AuroraActor = self.AuroraComp:GetChildActor()
  return self.AuroraActor
end

function BP_NPCEnergyStoneBase_C:SetBeamColor(SkillDamageType)
end

function BP_NPCEnergyStoneBase_C:RefreshBeam()
  if not self.Lock then
    return
  end
  local NewOption = self:FindMainOption(Enum.ActionType.ACT_PET_ADD_PROPERTY_TYPE)
  local OldOption = self.Option
  if NewOption ~= OldOption then
    if OldOption then
      OldOption:RemoveEventListener(self, NpcOptionEvent.OptionChange, self.RefreshBeam)
    end
    if NewOption then
      NewOption:AddEventListener(self, NpcOptionEvent.OptionChange, self.RefreshBeam)
    end
  end
  self.Option = NewOption
  local Show = false
  if NewOption and not NewOption:IsOptionEnable() then
    Show = true
  end
  self.Lock:SetForceSolo(true)
  self.Lock:SetComponentTickEnabled(Show)
  self.Lock:SetActive(Show, true)
  self.Lock:SetHiddenInGame(not Show, true)
  if Show and self.LockCircleIn then
    self:LockCircleIn()
  end
end

function BP_NPCEnergyStoneBase_C:ProcessNotify()
  _G.NRCModuleManager:DoCmd(SceneModuleCmd.ConsumeCachedActorTag, self.ActorID)
  self:RefreshBeam()
end

function BP_NPCEnergyStoneBase_C:CanEnterThrowInter(Comp)
  return Comp and (Comp == self.SkeletalMesh or Comp == self.ActionArea)
end

function BP_NPCEnergyStoneBase_C:Recycle()
  self.ActorID = 0
  self.AuroraActor = false
  self.Runner = false
  self.OpenFinishDelegate:Clear()
  if self.Option then
    self.Option:RemoveEventListener(self, NpcOptionEvent.OptionChange, self.RefreshBeam)
  end
  self.Option = false
  self.RocoSkill:StopCurrentSkill()
  UE.UNRCStatics.EmptyOverrideMaterials(self.SkeletalMesh)
  self.AuroraComp:SetVisibility(false, true)
  Base.Recycle(self)
end

function BP_NPCEnergyStoneBase_C:GetColor(Actor, Type)
  if not Actor then
    return
  end
  local Color = Actor:GetColor(Type)
  return UE.FVector(Color.R, Color.G, Color.B)
end

return BP_NPCEnergyStoneBase_C
