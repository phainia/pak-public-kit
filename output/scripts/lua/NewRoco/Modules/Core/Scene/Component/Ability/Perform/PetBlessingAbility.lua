local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ResQueue = require("NewRoco.Utils.ResQueue")
local InviteComponent = require("NewRoco.Modules.Core.Scene.Component.RolePlay.InviteComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetBlessingAbility = Base:Extend("PetBlessingAbility")

function PetBlessingAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self.forceDelayDelegate = nil
end

function PetBlessingAbility:Start(OnFinished, custom_params)
  Base.Start(self, OnFinished)
  local player = self.caster
  local status = _G.ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_PET_BLESSING
  Log.Debug("PetBlessingAbility:PreStart", self.caster.serverData.base.actor_id, table.tostring(custom_params and custom_params.player_interact_param))
  if not custom_params then
    Log.Error("PetBlessingAbility:Start Failed!!!!!")
    return
  end
  self.custom_params = custom_params.player_interact_param
  local hasStatus = player.statusComponent:HasStatus(status)
  if not hasStatus then
    return
  end
  self.InviterId = self.custom_params.player_uin1
  self.AcceptId = self.custom_params.player_uin2
  local casterLogicId = player:GetLogicId()
  if player.inputComponent then
    player.inputComponent:SetIgnoreMoveInput(self, true)
  end
  if self.state == ABEnum.AbilityState.Casting then
    Log.Error("\232\191\153\233\135\140\230\156\137\233\151\174\233\162\152\239\188\140\229\144\140\228\184\128\228\184\170\232\131\189\229\138\155\228\184\141\229\186\148\232\175\165\233\135\141\229\164\141\232\167\166\229\143\145\231\154\132")
    self:ExitInteract()
    return
  end
  self.state = ABEnum.AbilityState.Casting
  
  function self.onFinished()
    self:Recover(player)
  end
  
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.isLocal = localPlayer == self.caster
  self:AddConditionType()
  if casterLogicId ~= self.InviterId then
    local InvitePlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.InviterId)
    local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.custom_params.pet_id)
    pet:FaceTo(InvitePlayer)
    pet.AIComponent:ForceLockForReason(true, false, _G.AIDefines.LockReason.PET_BLESSING)
    if localPlayer and self.AcceptId == localPlayer:GetLogicId() then
      if self.forceDelayDelegate then
        _G.DelayManager:CancelDelayById(self.forceDelayDelegate)
      end
      self.forceDelayDelegate = _G.DelayManager:DelaySeconds(12, self.ForceExitInteract, self)
    end
    return
  end
  self.PetId = self.custom_params.pet_id
  self.PetEggId = self.custom_params.pet_egg_id
  if not self.PetId or not self.PetEggId then
    Log.Error("\230\178\161\230\156\137\231\178\190\231\129\181\230\136\150\232\128\133\232\155\139\231\154\132\232\181\144\231\166\143\230\152\175\228\184\141\229\174\140\230\149\180\231\154\132")
    self:ExitInteract()
    return
  end
  local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.PetId)
  if pet and pet.HiddenComponent then
    pet.HiddenComponent:ResetHide()
  end
  self:AddListener()
  self.res_ready = false
  self.eqs_ready = false
  self.inviter_pos = nil
  self.accept_pos = nil
  self.pet_pos = nil
  self.has_pop_reward = false
  Log.Debug("@@@PetBlessingAbility Start", player.viewObj:GetName(), self.caster.serverData.base.actor_id)
  local itemConf = _G.DataConfigManager:GetBagItemConf(self.custom_params.pet_egg_id)
  local petEggConf = _G.DataConfigManager:GetPetEggConf(itemConf.item_behavior[1].ratio[1])
  local model_id = petEggConf and petEggConf.model_id or 0
  local modelConf = _G.DataConfigManager:GetModelConf(model_id)
  local local_logic_id = localPlayer.serverData.base.logic_id
  local priority = _G.PriorityEnum.Passive_3P_Action
  if local_logic_id == self.InviterId or local_logic_id == self.AcceptId then
    priority = _G.PriorityEnum.Active_Player_Action
  end
  self.PetQueue = ResQueue(30, nil, priority)
  self.EqsQueue = ResQueue(30, nil, priority)
  if local_logic_id == self.InviterId then
    self:OnEqsReady()
  end
  self.PetQueue:InsertModel("PetEgg", modelConf and modelConf.id or 0)
  self.PetQueue:StartLoad(self, self.OnResReady)
  if player.isLocal then
    _G.NRCEventCenter:RegisterEvent("PetBlessingAbility", self, SceneEvent.OnTeleportNotify, self.ExitInteract)
    _G.NRCEventCenter:RegisterEvent("PetBlessingAbility", self, SceneEvent.OnNetPlayerDespawn, self.OnNetPlayerDespawn)
  end
end

function PetBlessingAbility:OnEqsReady(Queue, Success)
  self.eqs_ready = true
  local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.custom_params.pet_id)
  if not pet then
    Log.Warning("\230\137\190\228\184\141\229\136\176\231\178\190\231\129\181\239\188\140\231\187\136\230\173\162\232\161\168\230\188\148")
    self:ExitInteract()
    return
  end
  self.caster:FaceTo(pet)
  local AcceptPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.AcceptId)
  if AcceptPlayer then
    AcceptPlayer:FaceTo(pet)
  end
  pet:FaceTo(self.caster)
  pet.AIComponent:ForceLockForReason(true, false, _G.AIDefines.LockReason.PET_BLESSING)
  self.EqsQueue:Release()
  self.EqsQueue = nil
  self:SyncStandPoint()
  self:TryTriggerShow()
end

function PetBlessingAbility:OnResReady(Queue, Success)
  self.res_ready = true
  if not self.PetQueue or not Success then
    Log.Warning("\232\181\132\230\186\144\229\138\160\232\189\189Queue\231\188\186\229\164\177\239\188\140\231\187\136\230\173\162\232\161\168\230\188\148")
    self:ExitInteract()
    return
  end
  local ModelObject = self.PetQueue:GetResObject("PetEgg")
  if ModelObject then
    self.PetEggModel = ModelObject.Model
    self.PetEggModel:SetVisibleInternal(false)
    ModelObject.Model = nil
  end
  self.PetQueue:Release()
  self.PetQueue = nil
  self:TryTriggerShow()
end

function PetBlessingAbility:OnG6AbilityAsync(skillProxy, result)
  Base.OnG6AbilityAsync(self, skillProxy, result)
  self.PetEggModel:SetVisibleInternal(true)
  local skillObj = self._skillObj
  if skillObj then
    skillObj.Blackboard:SetValueAsObject("PetEgg", self.PetEggModel)
    self.PetEggModel = nil
  end
end

function PetBlessingAbility:Recover(owner)
  self:RemoveListener()
  if self.caster.inputComponent then
    self.caster.inputComponent:SetIgnoreMoveInput(self, false)
  end
  self.caster:StopAllMontage()
  Log.Debug("@@@PetBlessingAbility End", self.caster.serverData.base.actor_id)
  if self.bPlayG6 then
    Log.Warning("@@@PetBlessingAbility StopG6", owner.viewObj:GetName())
    self:CancelAsyncG6Ability()
    self:FinishG6Ability()
    self.bPlayG6 = false
  else
    self.caster.statusComponent:RemoveStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_PET_BLESSING)
  end
  if UE.UObject.IsValid(self.PetEggModel) then
    self.PetEggModel:K2_DestroyActor()
    self.PetEggModel = nil
  end
  if self.PetId then
    local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.PetId)
    local AIComponent = pet and pet.AIComponent
    if AIComponent then
      AIComponent:ForceLockForReason(false, false, _G.AIDefines.LockReason.PET_BLESSING)
    end
  end
  if self.EqsQueue then
    self.EqsQueue:Release()
    self.EqsQueue = nil
  end
  if self.PetQueue then
    self.PetQueue:Release()
    self.PetQueue = nil
  end
  if self.caster.isLocal then
    _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnTeleportNotify, self.ExitInteract)
    _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnNetPlayerDespawn, self.OnNetPlayerDespawn)
  end
  self:RemoveConditionType()
  if self.forceDelayDelegate then
    _G.DelayManager:CancelDelayById(self.forceDelayDelegate)
    self.forceDelayDelegate = nil
  end
end

function PetBlessingAbility:OnSkillEvent(event)
  Base.OnSkillEvent(self, event)
  if "End" == event or "Interrupt" == event or "LoadFailed" == event or "PreEnd" == event then
    self:ExitInteract()
  elseif "ShowTip" == event then
    self:DoFinishShow()
  end
end

function PetBlessingAbility:OnNetPlayerDespawn(player)
  if player:GetLogicId() ~= self.TargetUin then
    return
  end
  self:ExitInteract()
end

function PetBlessingAbility:ExitInteract()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local player = self.caster
  if player and player.isLocal and self.InviterId == player:GetLogicId() then
    local inviteComponent = localPlayer:EnsureComponent(InviteComponent)
    inviteComponent:InteractCancel(self.InviterId == self.AcceptId)
    self:DoFinishShow()
    Log.Debug("InteractCancel Done")
  end
end

function PetBlessingAbility:ForceExitInteract()
  self.forceDelayDelegate = nil
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return
  end
  local inviteComponent = localPlayer:EnsureComponent(InviteComponent)
  inviteComponent:InteractCancel(self.InviterId == self.AcceptId)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.interactiontree_cifu_net_error)
end

function PetBlessingAbility:DoFinishShow()
  if self.has_pop_reward then
    return
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local player = self.caster
  if player and player.isLocal and self.InviterId == player:GetLogicId() then
    self.has_pop_reward = true
    local reward = {}
    reward.id = self.custom_params.pet_egg_id
    reward.itemId = self.custom_params.pet_egg_id
    reward.type = _G.ProtoEnum.GoodsType.GT_BAGITEM
    reward.num = 1
    reward.isPreciousPetEgg = true
    reward.bagItemGid = self.custom_params.pet_egg_gid
    _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, {reward}, nil, nil, nil, nil, true, true, nil, true)
  end
end

function PetBlessingAbility:AddListener()
  if self.caster then
    self.caster:AddEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
  end
end

function PetBlessingAbility:RemoveListener()
  if self.caster then
    self.caster:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
  end
end

function PetBlessingAbility:OnStatusRefresh(status, subStatus, opCode, params)
  if status ~= _G.ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_PET_BLESSING then
    return
  end
  self.eqs_ready = true
  self.inviter_pos = params.player_interact_param.inviter_pos
  self.accept_pos = params.player_interact_param.accept_pos
  self.pet_pos = params.player_interact_param.pet_pos
  local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.PetId)
  self:UpdateTransform(pet and pet.viewObj, self.pet_pos)
  local invitePlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.InviterId)
  self:UpdateTransform(invitePlayer and invitePlayer.viewObj, self.inviter_pos)
  local acceptPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.AcceptId)
  self:UpdateTransform(acceptPlayer and acceptPlayer.viewObj, self.accept_pos)
  self:SyncPlayerMove()
  self:TryTriggerShow()
end

function PetBlessingAbility:UpdateTransform(actor, point)
  if point and actor then
    local pos = point.pos
    local rot_z = point.dir.z
    actor:Abs_K2_SetActorLocation(UE4.FVector(pos.x, pos.y, pos.z), false, nil, false)
    local rotation = UE4.FRotator(0, 0, 0)
    rotation.Yaw = rot_z / 10
    actor:K2_SetActorRotation(rotation, false)
  end
end

function PetBlessingAbility:TryTriggerShow()
  if not self.eqs_ready or not self.res_ready then
    Log.Debug("\230\178\161\229\135\134\229\164\135\229\165\189\239\188\140\229\136\171\230\128\165", self.eqs_ready, self.res_ready)
    return
  end
  local AcceptPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.AcceptId)
  if not self.caster then
    Log.Error("Caster is nil")
    self:ExitInteract()
    return
  end
  local AnimPath
  local ID = self.custom_params.interact_id
  if ID then
    local Conf = _G.DataConfigManager:GetRelationtreeAnimConf(ID)
    AnimPath = Conf.accept_key
  end
  if string.IsNilOrEmpty(AnimPath) then
    self:ExitInteract()
    return
  end
  Log.Debug("@@@PetBlessingAbility StartG6", self.caster.serverData.base.actor_id)
  self.bPlayG6 = true
  local characters = {}
  local targets = {}
  if AcceptPlayer and AcceptPlayer ~= self.caster then
    targets[1] = AcceptPlayer.viewObj
  end
  if self.custom_params.pet_id then
    local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.custom_params.pet_id)
    targets[2] = pet and pet.viewObj
  end
  if self.PetEggModel then
    targets[3] = self.PetEggModel
    self.PetEggModel:SetCollisionEnable(false)
  end
  characters[UE.EBattleStaticActorType.Player_1] = self.caster.viewObj
  if AcceptPlayer and AcceptPlayer ~= self.caster then
    characters[UE.EBattleStaticActorType.Player_2] = AcceptPlayer.viewObj
  end
  if self.custom_params.pet_id then
    local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.custom_params.pet_id)
    if pet then
      characters[UE.EBattleStaticActorType.Pet_2_1] = pet.viewObj
    end
  end
  if self.PetEggModel then
    characters[UE.EBattleStaticActorType.Pet_1_1] = self.PetEggModel
    self.PetEggModel:SetCollisionEnable(false)
    self.PetEggModel.bBlockCollision = true
  end
  self:CastG6AbilityAsync(characters, targets, AnimPath)
end

function PetBlessingAbility:SyncStandPoint()
  local statusId = _G.ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_PET_BLESSING
  local statusComponent = self.caster and self.caster.statusComponent
  local custom_params = statusComponent._statusParams[statusId]
  custom_params = custom_params or _G.ProtoMessage:newPlayerStatusCustomParams()
  custom_params.player_interact_param = self.custom_params
  local inviter_player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.InviterId)
  local accept_player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.AcceptId)
  local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.PetId)
  self.inviter_pos = self:GetPoint(inviter_player and inviter_player.viewObj)
  self.accept_pos = self:GetPoint(accept_player and accept_player.viewObj)
  self.pet_pos = self:GetPoint(pet and pet.viewObj)
  custom_params.player_interact_param.inviter_pos = self.inviter_pos
  custom_params.player_interact_param.accept_pos = self.accept_pos
  custom_params.player_interact_param.pet_pos = self.pet_pos
  statusComponent:RefreshStatus(statusId, 1, _G.ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, custom_params)
  self:SyncPlayerMove()
end

function PetBlessingAbility:GetPoint(actor)
  local Point = _G.ProtoMessage:newPoint()
  if not UE.UObject.IsValid(actor) then
    return Point
  end
  local x, y, z = actor:Abs_K2_GetActorLocation_XYZ()
  local rotation = actor:K2_GetActorRotation()
  local rot_z = (rotation.Yaw or 0) * 10
  Point.pos.x = math.floor(x)
  Point.pos.y = math.floor(y)
  Point.pos.z = math.floor(z)
  Point.dir.x = 0
  Point.dir.y = 0
  Point.dir.z = math.floor(rot_z)
  return Point
end

function PetBlessingAbility:SyncPlayerMove()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local serverData = localPlayer and localPlayer.serverData
  local serverBase = serverData and serverData.base
  local local_logic_id = serverBase and serverBase.logic_id
  if local_logic_id == self.InviterId or local_logic_id == self.AcceptId then
    localPlayer:ForceSendMoveReq()
  end
end

function PetBlessingAbility:AddConditionType()
  if self.isLocal then
    Log.Debug("PetBlessingAbility:AddConditionType")
    _G.FunctionBanManager:AddPlayerConditionType(_G.Enum.PlayerConditionType.PCT_PET_BLESSING_PERFORM, "PetBlessing")
  end
  local GuardSphereRes = _G.NRCBigWorldPreloader:Get("GuardSphere")
  local CurrentWorld = UE4Helper.GetCurrentWorld()
  if not (GuardSphereRes and self.caster.viewObj) or not CurrentWorld then
    return
  end
  self.guardSphere = CurrentWorld:Abs_SpawnActor(GuardSphereRes, self.caster.viewObj:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, CurrentWorld)
  if not self.guardSphere then
    return
  end
  self.guardSphere:K2_AttachToActor(self.caster.viewObj, nil, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
end

function PetBlessingAbility:RemoveConditionType()
  if self.isLocal then
    Log.Debug("PetBlessingAbility:RemoveConditionType")
    _G.FunctionBanManager:RemovePlayerConditionType(_G.Enum.PlayerConditionType.PCT_PET_BLESSING_PERFORM, "PetBlessing")
  end
  if self.guardSphere and UE.UObject.IsValid(self.guardSphere) then
    self.guardSphere:K2_DestroyActor()
  end
end

return PetBlessingAbility
