require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ExplodeActorComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.ExplodeActorComponent")
local ZVelocityModule = require("NewRoco.Modules.Core.NPC.Velocity.ZVelocityModule")
local CylinderModule = require("NewRoco.Modules.Core.NPC.Velocity.CylinderVelocityModule")
local PhysicsAnimConfig = require("NewRoco.Modules.Core.Scene.Common.PhysicsAnimConfig")
local DebugUtils = require("NewRoco.Modules.Core.Scene.Common.DebugUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local BP_ChestLikeNPCBase = Base:Extend("BP_ChestLikeNPCBase")

function BP_ChestLikeNPCBase:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_ChestLikeNPCBase:InitEmitters()
  self.ActorEmitter = ExplodeActorComponent()
  local ZModule = ZVelocityModule(PhysicsAnimConfig.Chest.ZVelocityMin, PhysicsAnimConfig.Chest.ZVelocityMax)
  local CModule = CylinderModule(PhysicsAnimConfig.Chest.CylinderMin, PhysicsAnimConfig.Chest.CylinderMax)
  self.ActorEmitter:AddForceModule(ZModule)
  self.ActorEmitter:AddForceModule(CModule)
  self.ActorEmitter.force = PhysicsAnimConfig.Chest.Force
end

function BP_ChestLikeNPCBase:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self:InitEmitters()
end

function BP_ChestLikeNPCBase:CheckNavValid()
  if self.showed then
    return
  end
  local selfPos = self:Abs_K2_GetActorLocation()
  local QueryExtent = UE4.FVector(0, 0, 85)
  local ProjectedLocation, resValue = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(UE4Helper.GetCurrentWorld(), selfPos, nil, nil, nil, QueryExtent)
  if resValue then
    Log.Error("\227\128\144\232\135\170\229\138\168\230\163\128\230\159\165\227\128\145\229\174\157\231\174\177\229\145\168\229\155\180\229\175\188\232\136\170\231\150\145\228\188\188\229\173\152\229\156\168\233\151\174\233\162\152\239\188\140\229\143\175\232\131\189\228\188\154\229\175\188\232\135\180\229\188\128\229\174\157\231\174\177\229\141\161\228\189\143", self:GetDebugInfo(), "\n", DebugUtils.GetPosCopyStr(selfPos))
  end
end

function BP_ChestLikeNPCBase:GetInterPos(playerPos, enableFixType, config_distance, config_rotation, playerRadius)
  Log.Debug("BP_ChestLikeNPCBase:GetInterPos", self:GetDebugInfo(), playerPos, enableFixType, config_distance, config_rotation, playerRadius)
  self:CheckNavValid()
  return Base.GetInterPos(self, playerPos, enableFixType, config_distance, config_rotation, playerRadius)
end

function BP_ChestLikeNPCBase:PlayLockLoopEffect()
  local skillObj = RocoSkillProxy.Create(tostring(self.LockSkill), self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not skillObj then
    return
  end
  Log.Debug("BP_ChestLikeNPCBase:PlayLockLoopEffect")
  skillObj:SetCaster(self)
  skillObj:PlaySkill()
end

function BP_ChestLikeNPCBase:PlayUnlockEffect(lockNum)
  Log.Debug("BP_ChestLikeNPCBase:PlayUnlockEffect", self:GetDebugInfo())
  Base.PlayUnlockEffect(self, lockNum)
  if not self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED) then
    return
  end
  if 0 ~= lockNum then
    return
  end
  Log.Debug("Box lock 0")
  self.RocoSkill:StopCurrentSkill()
  local skillObj = RocoSkillProxy.Create(tostring(self.UnLockSkill), self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not skillObj then
    return
  end
  Log.Debug("BP_ChestLikeNPCBase:PlayUnlockEffect")
  skillObj:SetCaster(self)
  skillObj:PlaySkill()
end

function BP_ChestLikeNPCBase:OnInVisible()
  if self.RocoSkill then
    self.RocoSkill:StopCurrentSkill()
  end
  Base.OnInVisible(self)
end

function BP_ChestLikeNPCBase:OnShouldDestroy()
  Log.Debug("BP_ChestLikeNPCBase:OnShouldDestroy", self:GetDebugInfo())
  if self.sceneCharacter then
    self.sceneCharacter.InteractionComponent:OnPlayerLeaveActionArea()
  end
end

function BP_ChestLikeNPCBase:OnOpenedInAnim()
  Log.Debug("BP_ChestLikeNPCBase:OnOpenedInAnim", self:GetDebugInfo())
end

function BP_ChestLikeNPCBase:DestroySelf()
  local serverId = self.sceneCharacter.serverData.base.actor_id
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverId)
end

function BP_ChestLikeNPCBase:PlayDestroyEffect()
  self.RocoSkill:StopCurrentSkill()
  if not self.RocoSkill then
    self:DestroySelf()
    return
  end
  local skillObj = RocoSkillProxy.Create(tostring(self.FadeSkill), self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not skillObj then
    self:DestroySelf()
    return
  end
  Log.Debug("BP_ChestLikeNPCBase:PlayDestroyEffect")
  skillObj:SetCaster(self)
  skillObj:RegisterEventCallback("End", self, self.DestroySelf)
  skillObj:PlaySkill()
end

function BP_ChestLikeNPCBase:OnShootInAnim()
  Log.Debug("BP_ChestLikeNPCBase:OnShootInAnim", self:GetDebugInfo())
  if not self.sceneCharacter then
    return
  end
  local Views = self.sceneCharacter.luaObj:GetChildrenNPCViews()
  if not Views then
    return
  end
  self.ActorEmitter:Explode(Views)
end

function BP_ChestLikeNPCBase:UnlockPlayerInput()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.inputComponent:SetInputEnable(self, true)
  _G.GlobalConfig.DisableBattle = false
end

function BP_ChestLikeNPCBase:Show()
  Log.Debug("BP_ChestLikeNPCBase:Show", self:GetDebugInfo())
  if not self.RocoSkill then
    return
  end
  if not self.sceneCharacter then
    return
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:FaceTo(self.sceneCharacter)
  if self.sceneCharacter.luaObj.createNum > 0 then
    player.inputComponent:SetInputEnable(self, false)
  else
    player.inputComponent:SetInputEnable(self, true)
    _G.GlobalConfig.DisableBattle = false
  end
  self:SetComponentNeedTick(self.SkeletalMesh, true)
  self.SkeletalMesh:SetComponentTickEnabled(true)
  local playerAnimComp = player.viewObj:GetAnimComponent()
  playerAnimComp:PlayAnimByName("WorldLootChest")
  local skillObj = RocoSkillProxy.Create(tostring(self.OpenSkill), self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not skillObj then
    self:OnOpenedInAnim()
    self:OnShootInAnim()
    return
  end
  Log.Debug("BP_ChestLikeNPCBase:PlaySkill")
  skillObj:SetCaster(self)
  skillObj:RegisterEventCallback("Open", self, self.OnOpenedInAnim)
  skillObj:RegisterEventCallback("Shoot", self, self.OnShootInAnim)
  skillObj:PlaySkill()
end

function BP_ChestLikeNPCBase:SetChildNPC(npcs)
  Log.Error("\229\189\147\228\189\160\231\156\139\229\136\176\232\191\153\230\157\161\230\151\165\229\191\151\239\188\140\229\143\175\228\187\165\231\156\139\231\156\139\232\191\153\228\184\170\229\174\157\231\174\177\231\154\132\230\142\137\232\144\189\231\137\169\230\152\175\228\184\141\230\152\175\230\173\163\229\184\184...")
  Base.SetChildNPC(self, npcs)
end

function BP_ChestLikeNPCBase:OnOpenSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    return
  end
  self:OnShootInAnim()
  self:OnOpenedInAnim()
end

function BP_ChestLikeNPCBase:CanThrowInter(throwInfo)
  return false
end

return BP_ChestLikeNPCBase
