local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ZVelocityModule = require("NewRoco.Modules.Core.NPC.Velocity.ZVelocityModule")
local CylinderModule = require("NewRoco.Modules.Core.NPC.Velocity.CylinderVelocityModule")
local PhysicsAnimConfig = require("NewRoco.Modules.Core.Scene.Common.PhysicsAnimConfig")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LuaActionRandomPos = require("NewRoco.AI.BehaviorTree.Actions.LuaActionRandomPos")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = ViewNPCBase
local Rotator = UE.FRotator(0, 0, 90)
local BP_NPCForceTester = Base:Extend("BP_NPCForceTester")

function BP_NPCForceTester:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  local ZModule = ZVelocityModule(PhysicsAnimConfig.ForceTester.ZVelocityMin, PhysicsAnimConfig.ForceTester.ZVelocityMax)
  local Cylinder = CylinderModule(PhysicsAnimConfig.ForceTester.CylinderMin, PhysicsAnimConfig.ForceTester.CylinderMax)
  self.ActorEmitter:AddForceModule(ZModule)
  self.ActorEmitter:AddForceModule(Cylinder)
  self.ActorEmitter.force = PhysicsAnimConfig.ForceTester.Force
  self.IsPlaying = false
  self.waitChildNum = 0
  self.currChildNum = 0
  self.waitChildNpcs = {}
end

function BP_NPCForceTester:OnVisible()
  Base.OnVisible(self)
  self:SetWeightCondPerform()
  local SceneCharacter = self.sceneCharacter
  local InterComp = SceneCharacter and SceneCharacter.InteractionComponent
  local isUnlock = InterComp and not InterComp:GetMainAction() or false
  if isUnlock then
    self:DoShow()
  end
end

function BP_NPCForceTester:SetWeightCondPerform()
  if not self.sceneCharacter then
    return
  end
  local npcOptionConfig = _G.DataConfigManager:GetNpcOptionConf(self.sceneCharacter.serverData.npc_base.npc_cfg_id)
  if not npcOptionConfig then
    Log.Error("NPCOptionConfig data of BP_NPCForceTester is invalid!!!")
    return
  end
  local petInteractConfigId = tonumber(npcOptionConfig.pet_action.action_param1)
  local weightConfig = _G.DataConfigManager:GetPetInteractionConf(petInteractConfigId)
  if not weightConfig then
    Log.Error("PetInteractConfig data of BP_NPCForceTester is invalid!!!")
    return
  end
  if table.len(weightConfig.interact_cond_group) > 0 and table.len(weightConfig.interact_cond_group[1].interact_cond_param) > 1 then
    self:SetWeightRange(weightConfig.interact_cond_group[1].interact_cond_param[1] * 0.001, weightConfig.interact_cond_group[1].interact_cond_param[2] * 0.001)
  end
  self.currentWeight = 0
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnPetInteractPerform, self.UpdateInteractPerform)
end

function BP_NPCForceTester:UpdateInteractPerform(weightSum, isForcePlay)
  if self.IsPlaying and not isForcePlay then
    return
  end
  if not isForcePlay and 0 == weightSum then
    self.delayId = _G.DelayManager:DelaySeconds(0.3, function()
      if not self.IsPlaying then
        self:UpdateInteractPerform_Internal(weightSum)
      end
    end)
  else
    self:UpdateInteractPerform_Internal(weightSum)
  end
end

function BP_NPCForceTester:UpdateInteractPerform_Internal(weightSum)
  local targetWeight = math.min(100, math.round(weightSum * 0.001))
  self:SetTargetWeight(self.currentWeight, targetWeight)
  self.currentWeight = targetWeight
end

function BP_NPCForceTester:OnLoadResource()
  Base.OnLoadResource(self)
  local SceneCharacter = self.sceneCharacter
  local InterComp = SceneCharacter and SceneCharacter.InteractionComponent
  local isUnlock = InterComp and not InterComp:GetMainAction() or false
  self.isCreatedNPCDone = true
  if isUnlock then
    self:DoShow()
  end
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

function BP_NPCForceTester:UpdateData(ServerData, bIsReconnect)
  Base.UpdateData(self, ServerData, bIsReconnect)
  local SceneCharacter = self.sceneCharacter
  local InterComp = SceneCharacter and SceneCharacter.InteractionComponent
  local isUnlock = InterComp and not InterComp:GetMainAction() or false
  self.currentWeight = 0
  self.isCreatedNPCDone = true
  if isUnlock then
    self:DoShow(false)
  else
    self:SetTargetWeight(self.currentWeight, 0, true)
  end
end

function BP_NPCForceTester:DoShow(bNeedExplode)
  local animInst = self:GetAnimInstance()
  if not animInst then
    Log.Error("ForceTester cannot find AnimInstance!")
    return false
  end
  animInst.isUnlock = true
  if not self.isCreatedNPCDone then
    return false
  end
  self:SetTargetWeight(self.currentWeight, 0, true)
  UE.UNRCStatics.EnablePrimitiveBoneCollision(self.SkeletalMesh, "Bone_qiuti", false)
  self.isCreatedNPCDone = false
  if false == bNeedExplode then
    return true
  end
  local childNPCs = self.sceneCharacter.luaObj:GetChildrenNPCs()
  local bInvalid = true
  self.waitChildNpcs = {}
  self.waitChildNum = 0
  for _, npc in pairs(childNPCs) do
    if not npc.viewObj then
      table.insert(self.waitChildNpcs, npc)
      self.waitChildNum = self.waitChildNum + 1
      if not npc:HasListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnChildLoad) then
        npc:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnChildLoad)
      end
      bInvalid = false
    end
  end
  if not bInvalid then
    return false
  end
  self.ActorEmitter.startPos = self.SkeletalMesh:Abs_GetSocketLocation("show_reward")
  local actors = self.sceneCharacter.luaObj:GetChildrenNPCViews()
  for _, actor in pairs(actors) do
    if actor and UE.UObject.IsValid(actor) then
      actor:TogglePhysics(true)
      actor:K2_GetRootComponent():SetHiddenInGame(false)
      if actor.BeamComponent then
        actor.BeamComponent:Destroy()
        actor.BeamComponent.showing = false
      end
    end
  end
  self.ActorEmitter:Explode(actors)
  return true
end

function BP_NPCForceTester:OnChildLoad(childNPC)
  if table.contains(self.waitChildNpcs, childNPC) then
    self.currChildNum = self.currChildNum + 1
  end
  if self.waitChildNum > 0 and self.currChildNum >= self.waitChildNum then
    self.waitChildNum = 0
    self.currChildNum = 0
    for _, npc in pairs(self.waitChildNpcs) do
      npc:RemoveEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnChildLoad)
    end
    self.waitChildNpcs = {}
    self.isCreatedNPCDone = true
    self:DoShow()
  end
end

function BP_NPCForceTester:GetExplodeLocation()
  return self.SkeletalMesh:Abs_GetSocketLocation("show_reward")
end

function BP_NPCForceTester:Show()
  self.isCreatedNPCDone = true
  if not self.isRiseHighest then
    return
  end
  self:DoShow()
end

function BP_NPCForceTester:SetChildNPC(npcs)
  for _, npc in ipairs(npcs) do
    local landPos = self:GetNearLandLocation()
    if landPos then
      Log.Debug("landPos x, y, z", landPos.X, landPos.Y, landPos.Z)
      local serverPos = npc.serverData.base.pt.pos
      serverPos.x = landPos.X
      serverPos.y = landPos.Y
      serverPos.z = landPos.Z
      npc.serverPos = UE4.FVector(serverPos.x, serverPos.y, serverPos.z)
      if npc.viewObj then
        npc.viewObj.forbidFixCoord = false
        npc:SetActorLocation(landPos)
        npc.viewObj:K2_SetActorRotation(Rotator, false)
        SceneUtils.CorrectActorPos(npc.viewObj, true)
        npc.viewObj:K2_GetRootComponent():SetHiddenInGame(false)
      end
    else
      Log.Warning("landPos\228\184\141\229\173\152\229\156\168")
    end
  end
end

function BP_NPCForceTester:GetNearLocation()
  local nearPos = LuaActionRandomPos:GetRandomPosInRing(self:Abs_K2_GetActorLocation(), 120.0, 220.0, nil, 360)
  return UE.UNRCStatics.GetPosInNearLand(self, nearPos)
end

function BP_NPCForceTester:GetAnimInstance()
  if not self.SkeletalMesh then
    return nil
  end
  return self.SkeletalMesh:GetAnimInstance()
end

function BP_NPCForceTester:CanEnterThrowInter(Comp)
  return Comp and Comp == self.SkeletalMesh
end

return BP_NPCForceTester
