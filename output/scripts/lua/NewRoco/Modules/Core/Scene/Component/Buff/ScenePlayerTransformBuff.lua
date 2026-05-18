local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerTransformBuff = Base:Extend("ScenePlayerTransformBuff")

function ScenePlayerTransformBuff:Ctor(owner, ridePet)
  Base.Ctor(self, owner)
end

function ScenePlayerTransformBuff:OnBegin(owner, customParams)
  Log.Debug("ScenePlayerTransformBuff:OnBegin")
  self.owner = owner
  local LoadPriorityLogic = PriorityEnum.Other_Player_Logic
  local LoadPriorityPerform = PriorityEnum.Other_Player_Perform
  if self.owner.isLocal then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseCompass)
    LoadPriorityLogic = PriorityEnum.Local_Player_Logic
    LoadPriorityPerform = PriorityEnum.Local_Player_Perform
  end
  local player = owner
  self.TransformID = customParams.transform_param.transform_cfg_id
  self._isInEndPerform = false
  self._isInStartPerform = false
  self.MagicTransformConf = DataConfigManager:GetMagicTransformConf(self.TransformID)
  self.isCustomPerform = self.MagicTransformConf.use_lique_fx
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
  if not self.isCustomPerform then
    local fxPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Charactor/G6_Scene_PlayerTransform.G6_Scene_PlayerTransform_C"
    _G.NRCResourceManager:LoadResAsync(self, fxPath, LoadPriorityPerform, 0, self.OnFXLoadSucc, nil, nil)
  end
  player.viewObj.CharacterMovement.bEnableMantle = false
  if self.MagicTransformConf.is_pet then
    local emote_str = self.MagicTransformConf.idle_anim
    if nil == emote_str or "" == emote_str then
      emote_str = DataConfigManager:GetRoleGlobalConfig("transform_idleanim").str
    end
    self.emoteList = {}
    for part in string.gmatch(emote_str, "([^;]+)") do
      table.insert(self.emoteList, part)
    end
    self._HasEmoteList = nil
    self._isPlayingEmote = false
    local petID = self.MagicTransformConf.model_id
    local PetConf = DataConfigManager:GetAllRidePet(petID)
    local PetName = PetConf.animation_name
    if self.isCustomPerform then
      local startFxPath = self.MagicTransformConf.lique_start_fx and self.MagicTransformConf.lique_start_fx or "/Game/ArtRes/Effects/G6Skill/SceneEffect/Magic/G6_Magic_Player_Tranform_Liquefy.G6_Magic_Player_Tranform_Liquefy_C"
      _G.NRCResourceManager:LoadResAsync(self, startFxPath, LoadPriorityLogic, 0, self.OnStartFXLoadSucc, nil, nil)
      local endFxPath = self.MagicTransformConf.lique_end_fx and self.MagicTransformConf.lique_end_fx or "/Game/ArtRes/Effects/G6Skill/SceneEffect/Magic/G6_Magic_Player_Tranform_Revert.G6_Magic_Player_Tranform_Revert_C"
      _G.NRCResourceManager:LoadResAsync(self, endFxPath, LoadPriorityLogic, 0, self.OnEndFXLoadSucc, nil, nil)
      self.owner.viewObj.BP_RideComponent.bStartAfterLoad = false
    end
    if nil == PetName then
      Log.Error("\229\143\152\229\189\162\233\133\141\231\189\174\233\148\153\232\175\175")
      return
    end
    local configClassPath = string.format("'/Game/ArtRes/BP/Pets/%s/AC_Scene_%s.AC_Scene_%s_C'", PetName, PetName, PetName)
    self._needInitConfig = false
    _G.NRCResourceManager:LoadResAsync(self, configClassPath, LoadPriorityLogic, 0, self.OnConfigLoadSucc, nil, nil)
    if not self.isCustomPerform then
      self.owner.viewObj.Mesh:SetVisibility(false, false)
      self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = true
      self.owner.viewObj.AvatarComponent:SetDecoratorVisible(false)
    end
    if self.owner.isLocal then
      self.SimRideScenePet = ScenePlayerPet(nil, petID, -ProtoEnum.SceneRideAllCustomGid.SRCG_Transform, player)
      local RideHelper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
      RideHelper:HandleStatus(player, self.SimRideScenePet)
    else
      local statusComp = self.owner.statusComponent
      if statusComp._shouldWaitRecover and not statusComp:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
        local serverInfo = self.owner.serverData.avatar_status
        for index, v in pairs(serverInfo.status_list) do
          if v == ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL then
            statusComp:ApplyStatus(v, serverInfo.sub_status_list[index], ProtoEnum.WPST_OpCode.WPST_OPCODE_RECOVER, serverInfo.avatar_status_params[index])
            return
          end
        end
      end
    end
  else
    local MeshComp = player.viewObj.Mesh
    player.viewObj.OldMesh = MeshComp.SkeletalMesh
    player.viewObj.OldAnimClass = UE.UGameplayStatics.GetObjectClass(MeshComp:GetAnimInstance())
    player.viewObj.OldMaterials = MeshComp:GetMaterials()
    local NPCConf = DataConfigManager:GetModelConf(self.MagicTransformConf.model_id)
    local NameList = string.split(NPCConf.path, "/")
    local NPCName = NameList[6]
    self._NewMesh = nil
    self._NewAnimClass = nil
    local NPCorPEO = "NPC"
    if string.find(NPCConf.path, "PEO") then
      NPCorPEO = "PEO"
    end
    local MeshClassPath = string.format("'/Game/ArtRes/AnimSequence/Human/%s/%s/SKM_%s_Skin.SKM_%s_Skin'", NPCorPEO, NPCName, NPCName, NPCName)
    _G.NRCResourceManager:LoadResAsync(self, MeshClassPath, LoadPriorityLogic, 0, self.OnNpcMeshLoaded, nil, nil)
    local AnimClassPath = string.format("'/Game/ArtRes/BP/Scene/%s/ABP_Scene_%s.ABP_Scene_%s_C'", NPCName, NPCName, NPCName)
    _G.NRCResourceManager:LoadResAsync(self, AnimClassPath, LoadPriorityLogic, 0, self.OnNpcAnimLoaded, nil, nil)
  end
end

function ScenePlayerTransformBuff:OnFXLoadSucc(req, class)
  self._fxClassRef = UnLua.Ref(class)
  self._fxClass = class
  self:PlaySkill()
end

function ScenePlayerTransformBuff:OnStartFXLoadSucc(req, class)
  self._StartFxClassRef = UnLua.Ref(class)
  self._StartFxClass = class
end

function ScenePlayerTransformBuff:OnEndFXLoadSucc(req, class)
  self._EndFxClassRef = UnLua.Ref(class)
  self._EndFxClass = class
end

function ScenePlayerTransformBuff:PlaySkill()
  if self.isCustomPerform then
    return
  end
  if self.owner.isLocal then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseCompass)
  end
  if not UE.UObject.IsValid(self.owner.viewObj) then
    return
  end
  local skillComponent = self.owner.viewObj.RocoSkill
  local skillObj = skillComponent:FindOrAddSkillObj(self._fxClass)
  if _G.bShutDownSafeReload and not skillObj then
    Log.Error("AbilityBase try reload skill obj ", skillObj and "true" or "false")
  end
  if skillObj or _G.bShutDownSafeReload then
    self._skillObj = skillObj
    self._skillObj.CanBeInterruptedWhatever = true
    skillObj:SetCaster(self.owner.viewObj)
    skillComponent:PlaySkill(skillObj)
  end
end

function ScenePlayerTransformBuff:OnConfigLoadSucc(req, class)
  self._configClassRef = UnLua.Ref(class)
  self._needInitConfig = true
  self._configClass = class
end

function ScenePlayerTransformBuff:GetPetViewobj()
  return self.owner.viewObj.BP_RideComponent.RidePet
end

function ScenePlayerTransformBuff:OnNpcMeshLoaded(req, class)
  self._NewMeshRef = UnLua.Ref(class)
  self._NewMesh = class
  if self._NewAnimClass then
    self:StartNpcTransform()
  end
end

function ScenePlayerTransformBuff:OnNpcAnimLoaded(req, class)
  self._NewAnimClassRef = UnLua.Ref(class)
  self._NewAnimClass = class
  if self._NewMesh then
    self:StartNpcTransform()
  end
end

function ScenePlayerTransformBuff:StartNpcTransform()
  local player = self.owner
  if not player or not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM) then
    Log.Error("\229\143\152\229\189\162\229\188\130\230\173\165\229\155\158\232\176\131\230\151\182\229\183\178\232\167\163\233\153\164\229\143\152\229\189\162\231\138\182\230\128\129")
    return
  end
  local MeshComp = player.viewObj.Mesh
  local MaterialNum = MeshComp:GetNumMaterials() - 1
  for i = 0, MaterialNum do
    MeshComp:SetMaterial(i, nil)
  end
  MeshComp:SetSkeletalMesh(self._NewMesh, true)
  MeshComp:SetAnimClass(self._NewAnimClass)
  self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = true
  player.viewObj.AvatarComponent:SetDecoratorVisible(false)
end

function ScenePlayerTransformBuff:OnUpdate(deltaTime)
  if self.MagicTransformConf == nil then
    Log.Error("\229\143\152\229\189\162\233\133\141\231\189\174\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
    return
  end
  if self.MagicTransformConf.is_pet and not self.SimRideScenePet and not self.owner.isLocal then
    self.SimRideScenePet = self.owner.viewObj.BP_RideComponent.ScenePet
  end
  if self.SimRideScenePet then
    self.SimRideScenePet:Update(deltaTime)
    if self.SimRideScenePet:GetStatus() ~= ProtoEnum.WorldPlayerPetStatusType.WPPST_IN_RIDE then
      self:OnLocalTrasnformFailed()
      return
    end
    if self._needInitConfig then
      local RideComponent = self.owner.viewObj.BP_RideComponent
      if RideComponent.CachedMesh and RideComponent.CachedABP and self._StartFxClass then
        self:LiquefyPerformStart()
        self._needInitConfig = false
        return
      end
      local Pet = self:GetPetViewobj()
      if Pet then
        Pet.RocoAnim:SetAnimConfig(self._configClass)
        Pet.RocoAnim:InitAnimInstance()
        self._needInitConfig = false
      end
    end
    if self._isPlayingEmote then
      local Pet = self:GetPetViewobj()
      if not self:CanPlayEmote() or not Pet.RocoAnim:IsAnyAnimPlaying() then
        Pet.RocoAnim:StopAllMontage()
        self._isPlayingEmote = false
        self:SyncEmote(0)
      end
    end
  end
  if self.MagicTransformConf.is_pet and self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag then
    local Mesh = self.owner.viewObj.Mesh
    if Mesh:IsVisible() then
      Mesh:SetVisibility(false, false)
    end
  end
end

function ScenePlayerTransformBuff:Emote()
  local Pet = self:GetPetViewobj()
  if self:CanPlayEmote() and not Pet.RocoAnim:IsAnyAnimPlaying() then
    if self._HasEmoteList == nil then
      self._HasEmoteList = {}
      self.emoteListValueKey = {}
      for index, emote in ipairs(self.emoteList) do
        if Pet.RocoAnim:HasAnimation(emote) then
          table.insert(self._HasEmoteList, emote)
          self.emoteListValueKey[emote] = index
        end
      end
    end
    if 0 == #self._HasEmoteList then
      Log.Error("\232\175\165\231\178\190\231\129\181\230\178\161\230\156\137\229\144\136\230\179\149\231\154\132\232\161\168\230\131\133\229\138\168\228\189\156")
    else
      local randomIndex = math.random(#self._HasEmoteList)
      local randomEmote = self._HasEmoteList[randomIndex]
      Pet.RocoAnim:PlayAnimByName(randomEmote)
      self._isPlayingEmote = true
      self:SyncEmote(self.emoteListValueKey[randomEmote])
    end
  end
end

function ScenePlayerTransformBuff:CanPlayEmote()
  local Pet = self:GetPetViewobj()
  if Pet and Pet.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Walking and UE4.UKismetMathLibrary.Vector_IsZero(Pet.CharacterMovement.Velocity) then
    return true
  end
  return false
end

function ScenePlayerTransformBuff:SyncEmote(Key)
  local Id = ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM
  local customParams = self.owner.statusComponent._statusParams[Id]
  Log.Dump(customParams, 5, "customParams")
  customParams = customParams or ProtoMessage:newPlayerStatusCustomParams()
  customParams.transform_param.emote_id = Key
  self.owner.statusComponent:RefreshStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, customParams)
end

function ScenePlayerTransformBuff:OnLocalTrasnformFailed(FailedReason)
  if self.owner.isLocal and not self._isInEndPerform then
    Log.Debug("ScenePlayerTransformBuff:OnLocalTrasnformFailed")
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM, ProtoEnum.WPST_OpCode.WPST_OPCODE_REMOVE, 1)
    local req = _G.ProtoMessage:newZoneSceneCancelPlayerTransformReq()
    req.cancel_reason = FailedReason or ProtoEnum.PlayerTransformCancelReason.PTCR_STATUS_BAN
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CANCEL_PLAYER_TRANSFORM_REQ, req, self, self.OnLocaleCancelPlayerTransformRSP, false, true)
    if self.owner and self.owner.buffComponent:HasBuff("Transform_Buff") then
      self.owner.buffComponent:RemoveBuff("Transform_Buff")
    end
  end
end

function ScenePlayerTransformBuff:OnLocaleCancelPlayerTransformRSP(rsp)
end

function ScenePlayerTransformBuff:OnFinish(isForce)
  local player = self.owner
  if not UE.UObject.IsValid(self.owner.viewObj) then
    return
  end
  self:PlaySkill()
  player.viewObj.CharacterMovement.bEnableMantle = true
  player.viewObj.BP_RideComponent.bStartAfterLoad = true
  if player.isLocal then
    player.inputComponent:SetInputEnable(self, true, "LiquefyPerform")
  end
  if self.MagicTransformConf.is_pet then
    if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
      player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL, ProtoEnum.WPST_OpCode.WPST_OPCODE_REMOVE)
    end
    self.owner.viewObj.BP_RideComponent:StopRide()
    local buffName = "RideAll_Buff"
    if player.buffComponent:HasBuff(buffName) then
      player.buffComponent:RemoveBuff(buffName)
    end
    player.viewObj.Mesh:SetVisibility(true, false)
    self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = false
    player.viewObj.AvatarComponent:SetDecoratorVisible(true)
  else
    local MeshComp = player.viewObj.Mesh
    local MaterialNum = MeshComp:GetNumMaterials() - 1
    for i = 0, MaterialNum do
      MeshComp:SetMaterial(i, nil)
    end
    MeshComp:SetSkeletalMesh(player.viewObj.OldMesh, true)
    MeshComp:SetAnimClass(player.viewObj.OldAnimClass)
    for i = 1, player.viewObj.OldMaterials:Length() do
      MeshComp:SetMaterial(i - 1, player.viewObj.OldMaterials:Get(i))
    end
    self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = false
    player.viewObj.AvatarComponent:SetDecoratorVisible(true)
    player.viewObj.AnimComponent:InitAnimInstance()
  end
  if self._isInStartPerform or isForce then
    local skillComponent = self.owner.viewObj.RocoSkill
    skillComponent:StopCurrentSkill()
    player.viewObj.Mesh:SetVisibility(true, false)
    self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = false
    player.viewObj.AvatarComponent:SetDecoratorVisible(true)
  end
  player.viewObj:SetActorScale3D(FVectorOne)
  if player and player.Land then
    player:Land()
  end
  local MoveMode = player.viewObj.CharacterMovement.MovementMode
  if MoveMode == UE.EMovementMode.MOVE_None or MoveMode == UE.EMovementMode.MOVE_Walking then
    player.viewObj:GetAnimComponent():GetAnimInstance():SetRootMotionMode(UE.ERootMotionMode.RootMotionFromEverything)
  end
  player.viewObj.OldMesh = nil
  player.viewObj.OldAnimClass = nil
  player.viewObj.OldMaterials = nil
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer and localPlayer.viewObj and localPlayer.viewObj:GetController() then
    local cameraManager = localPlayer.viewObj:GetController().PlayerCameraManager
    if cameraManager then
      cameraManager:ForceUpdateFade(player.viewObj)
    end
  end
  if self._delayHiddenId then
    _G.DelayManager:CancelDelay(self._delayHiddenId)
    self._delayHiddenId = nil
  end
end

function ScenePlayerTransformBuff:OnVitalityOver()
  local Pet = self:GetPetViewobj()
  if Pet and Pet.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Swimming then
    self.owner.roleHPComponent:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_SWIMMING)
  end
end

function ScenePlayerTransformBuff:OnStatusRefresh(status, subStatus, opCode, customParams)
  if self.owner.isLocal or status ~= ProtoEnum.WorldPlayerStatusType.WPST_TRANSFORM then
    return
  end
  local Pet = self:GetPetViewobj()
  local EmoteKey = customParams.transform_param.emote_id
  if 0 == EmoteKey then
    Pet.RocoAnim:StopAllMontage()
  else
    Pet.RocoAnim:PlayAnimByName(self.emoteList[EmoteKey])
  end
end

function ScenePlayerTransformBuff:LiquefyPerformStart()
  local RideComponent = self.owner.viewObj.BP_RideComponent
  if not RideComponent:GetRideSocketAndType(RideComponent.CachedMesh, true) or not RideComponent:SetRelativeTransform() then
    self:OnLocalTrasnformFailed()
    return
  end
  if self.owner.isLocal then
    self.owner.inputComponent:SetInputEnable(self, false, "LiquefyPerform")
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseCompass)
  end
  local skillComponent = self.owner.viewObj.RocoSkill
  local skillObj = skillComponent:FindOrAddSkillObj(self._StartFxClass)
  if _G.bShutDownSafeReload and not skillObj then
    Log.Error("AbilityBase try reload skill obj ", skillObj and "true" or "false")
  end
  if skillObj or _G.bShutDownSafeReload then
    self._skillObj = skillObj
    self._skillObj.CanBeInterruptedWhatever = true
    skillObj:SetCaster(self.owner.viewObj)
    skillObj:SetTargets({
      self.owner.viewObj
    })
    skillObj:RegisterRawCallback(self, self.OnStartSkillEvent)
    local Success = skillComponent:PlaySkill(skillObj)
    self._isInStartPerform = true
    if 0 ~= Success then
      Log.Error("\230\182\178\229\140\150\229\164\177\232\180\165")
      self:OnLocalTrasnformFailed()
      return
    end
  end
end

function ScenePlayerTransformBuff:LiquefyPerformChangeTarget()
  self.owner.viewObj:SetActorScale3D(FVectorOne)
  self.owner.viewObj.Mesh:SetVisibility(false, false)
  self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = true
  self.owner.viewObj.AvatarComponent:SetDecoratorVisible(false)
  self.owner.viewObj.BP_RideComponent:NormalRide()
  local Pet = self:GetPetViewobj()
  if Pet and UE4.UObject.IsValid(Pet) then
    Pet.RocoAnim:SetAnimConfig(self._configClass)
    Pet.RocoAnim:InitAnimInstance()
    Pet:SetActorHiddenInGame(true)
    self._delayHiddenId = DelayManager:DelayFrames(2, function()
      if Pet and UE4.UObject.IsValid(Pet) then
        Pet:SetActorHiddenInGame(false)
      end
      self._delayHiddenId = nil
    end)
  end
  self._skillObj:SetTargets({Pet})
  if self.owner.isLocal then
    NRCModuleManager:DoCmd(PlayerModuleCmd.MarkSendMoveReq)
  end
end

function ScenePlayerTransformBuff:LiquefyPerformStartFinish()
  self._isInStartPerform = false
  self.owner.viewObj:SetActorScale3D(FVectorOne)
  if self.owner.isLocal then
    self.owner.inputComponent:SetInputEnable(self, true, "LiquefyPerform")
    NRCModuleManager:DoCmd(PlayerModuleCmd.MarkSendMoveReq)
  end
end

function ScenePlayerTransformBuff:EnableInput()
  if self.owner.isLocal then
    self.owner.inputComponent:SetInputEnable(self, true, "LiquefyPerform")
  end
end

function ScenePlayerTransformBuff:OnStartSkillEvent(event)
  if "ChangeTarget" == event then
    self:LiquefyPerformChangeTarget()
  end
  if "End" == event then
    self:LiquefyPerformStartFinish()
  end
  if "Interrupt" == event then
    self:OnLocalTrasnformFailed()
  end
  if "EnableInput" == event then
    self:EnableInput()
  end
end

function ScenePlayerTransformBuff:LiquefyPerformEnd()
  self._isInEndPerform = true
  local skillComponent = self.owner.viewObj.RocoSkill
  local Pet = self:GetPetViewobj()
  if not (self._EndFxClass and Pet) or not Pet:IsValid() then
    if self._isInStartPerform then
      skillComponent:StopCurrentSkill()
    end
    self.owner.buffComponent:RemoveBuff("Transform_Buff")
    return
  end
  if self.owner.isLocal then
    self.owner.inputComponent:SetInputEnable(self, false, "LiquefyPerform")
  end
  local skillObj = skillComponent:FindOrAddSkillObj(self._EndFxClass)
  if _G.bShutDownSafeReload and not skillObj then
    Log.Error("AbilityBase try reload skill obj ", skillObj and "true" or "false")
  end
  if skillObj or _G.bShutDownSafeReload then
    self._skillObj = skillObj
    self._skillObj.CanBeInterruptedWhatever = true
    skillObj:SetCaster(self.owner.viewObj)
    skillObj:SetTargets({Pet})
    skillObj:RegisterRawCallback(self, self.OnEndSkillEvent)
    local Success = skillComponent:PlaySkill(skillObj)
    if 0 ~= Success then
      self.owner.buffComponent:RemoveBuff("Transform_Buff")
    end
    self._endCachePet = Pet
  end
end

function ScenePlayerTransformBuff:OnEndSkillEvent(event)
  if "ChangeTarget" == event then
    self:EndLiquefyPerformChangeTarget()
  end
  if "End" == event then
    self:EndLiquefyPerformStartFinish()
  end
  if "Interrupt" == event then
    self:EndLiquefyPerformStartFinish()
  end
  if "EnableInput" == event then
    self:EnableInput()
  end
end

function ScenePlayerTransformBuff:EndLiquefyPerformChangeTarget()
  local player = self.owner
  local Pet = self:GetPetViewobj()
  if Pet then
    Pet:SetActorScale3D(FVectorOne)
  end
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL, ProtoEnum.WPST_OpCode.WPST_OPCODE_REMOVE)
  end
  self.owner.viewObj.BP_RideComponent:StopRide()
  local buffName = "RideAll_Buff"
  if player.buffComponent:HasBuff(buffName) then
    player.buffComponent:RemoveBuff(buffName)
  end
  player.viewObj.Mesh:SetVisibility(true, false)
  self.owner.viewObj.AvatarComponent.ForceHideAvatarFlag = true
  player.viewObj.AvatarComponent:SetDecoratorVisible(true)
  player.viewObj:SetActorScale3D(FVectorOne)
  if self._endCachePet:IsValid() then
    self.owner.buffComponent:RemoveBuff("Transform_Buff")
    self._endCachePet:K2_DestroyActor()
    self._endCachePet = nil
    return
  end
  self._skillObj:SetTargets({
    player.viewObj
  })
end

function ScenePlayerTransformBuff:EndLiquefyPerformStartFinish()
  self.owner.buffComponent:RemoveBuff("Transform_Buff")
  if self.owner.isLocal then
    NRCModuleManager:DoCmd(PlayerModuleCmd.MarkSendMoveReq)
  end
end

return ScenePlayerTransformBuff
