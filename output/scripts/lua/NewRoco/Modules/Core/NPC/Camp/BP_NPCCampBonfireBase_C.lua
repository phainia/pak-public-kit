require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Delegate = require("Utils.Delegate")
local AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local BP_NPCCampBonfireBase_C = Base:Extend("BP_NPCCampBonfireBase_C")

function BP_NPCCampBonfireBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCCampBonfireBase_C:Init()
  Base.Init(self)
  self.IsActivate = nil
  self.CampLevel = 0
  self.ActivatedPet = {}
  self.BonfireSoundSession = 0
  self.OnActivateFinishDelegate = Delegate()
  self.LuluLoadCallback = {}
  self.LuluAppearCountDown = 2
  self.LuluDisappearTime = 15
  self.LuluDisappearCountDown = self.LuluDisappearTime
  self.LuluTurnAroundCallback = {}
  self.LuluRequest = nil
  self.AppearSkillReq = nil
  self.LuluResLoadFinished = false
  self.LuluAppearSkillLoadFinished = false
end

function BP_NPCCampBonfireBase_C:GetCampLevel()
  if self.sceneCharacter then
    local level = self.sceneCharacter.serverData and self.sceneCharacter.serverData.base.lv
    if level then
      return level
    else
      Log.Error("\231\173\137\231\186\167\230\156\137\233\151\174\233\162\152\239\188\140\230\178\161\230\156\137\230\149\176\230\141\174", self.sceneCharacter:DebugNPCNameAndID())
      return 0
    end
    Log.Error("\230\156\137\228\184\128\228\184\170\230\158\175\230\158\157\230\178\161\230\156\137SceneCharacter\239\188\140\232\191\153\229\190\136\230\156\137\233\151\174\233\162\152", self.sceneCharacter:GetFullName())
  end
  return 0
end

function BP_NPCCampBonfireBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCCampBonfireBase_C:CanEnterThrowInter(Comp)
  if self.NRCSkeletalMesh and self.NRCSkeletalMesh == Comp then
    return true
  end
  if self.NRCStaticMesh and self.NRCStaticMesh == Comp then
    return true
  end
  if self.Capsule and self.Capsule == Comp then
    return true
  end
  return false
end

function BP_NPCCampBonfireBase_C:SwitchToLevel()
  local skillPath
  self.CampLevel = self:GetCampLevel()
  if not self.IsActivate then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Camping/G6_Scene_Camping_Mat01.G6_Scene_Camping_Mat01"
    _G.NRCAudioManager:PlaySound3DWithActorAuto(3036, self, "BonfireInvisible")
  elseif 1 == self.CampLevel then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Camping/G6_Scene_Camping_Mat02.G6_Scene_Camping_Mat02"
  elseif 2 == self.CampLevel then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Camping/G6_Scene_Camping_Mat03.G6_Scene_Camping_Mat03"
  elseif 3 == self.CampLevel then
    skillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Camping/G6_Scene_Camping_Mat04.G6_Scene_Camping_Mat04"
  else
    Log.Error("\233\173\148\229\138\155\228\185\139\230\186\144\231\173\137\231\186\167\230\156\137\233\151\174\233\162\152\239\188\140\231\156\139\229\136\176\232\191\153\230\157\161\230\138\165\233\148\153\232\175\183\228\191\157\231\149\153\231\142\176\229\156\186\231\187\153\229\144\142\229\143\176\230\143\144bug\229\141\149\239\188\140\230\132\159\230\129\169", self.CampLevel)
    Log.Error("\230\156\137\233\151\174\233\162\152\231\154\132\233\173\148\229\138\155\228\185\139\230\186\144actor id\230\152\175: ", self.sceneCharacter and self.sceneCharacter.serverData and self.sceneCharacter.serverData.base.actor_id)
    return
  end
  if self.bChangeMaterial ~= true then
    return
  end
  local SkillProxy = RocoSkillProxy.Create(skillPath, self.RocoSkill, PriorityEnum.Active_Player_Action)
  SkillProxy:SetCaster(self)
  SkillProxy:SetPassive(true)
  SkillProxy:PlaySkill()
end

function BP_NPCCampBonfireBase_C:OnVisible()
  Base.OnVisible(self)
  if self.SetLeaves then
    self:SetLeaves()
  end
  if self.IsActivate then
    self:ActivateBonfire()
  else
  end
  if self.IsUnlockByJiDian then
    self:DeactivateMagicLock()
  else
    self:ActivateMagicLock()
  end
  self.CampLevel = self:GetCampLevel()
  self:SetBonfireActive(self.IsActivate, true, self.CampLevel)
  self:SwitchToLevel()
  self:PreventOverlap()
end

function BP_NPCCampBonfireBase_C:OnInVisible()
  self:ClearPet()
  Base.OnInVisible(self)
end

function BP_NPCCampBonfireBase_C:ClearPet()
  self.LuluAppearCountDown = 2
  self.LuluResLoadFinished = false
  self.LuluAppearSkillLoadFinished = false
  self.skillClass = nil
  self.skillClassRef = nil
  if self.Lulu then
    self.Lulu:K2_DestroyActor()
    self.Lulu = nil
  end
  self.LuluRef = nil
  if self.LuluRequest then
    _G.NRCResourceManager:UnLoadRes(self.LuluRequest)
    self.LuluRequest = nil
  end
  if self.AppearSkillReq then
    _G.NRCResourceManager:UnLoadRes(self.AppearSkillReq)
    self.AppearSkillReq = nil
  end
end

function BP_NPCCampBonfireBase_C:LoadLockEffect()
end

function BP_NPCCampBonfireBase_C:PlayUnlockEffect(lockNum)
end

function BP_NPCCampBonfireBase_C:PlayActivateEffect(bPlaySkill)
  Log.Debug("BP_NPCCampBonfireBase_C:PlayActivateEffect")
  self.IsActivate = true
  self.CampLevel = self:GetCampLevel()
  if bPlaySkill then
    self.RocoSkill:StopCurrentSkill()
    local SkillClass = UE4.UKismetSystemLibrary.LoadClassAsset_Blocking(self.ActiveSkill)
    if not SkillClass then
      Log.Warning("BP_NPCCampBonfireBase_C:PlayActivateEffect skill not found")
    end
    local Skill = self.RocoSkill:FindOrAddSkillObj(SkillClass)
    if not Skill then
      return
    end
    Skill:SetCaster(self)
    if #self.ActivatedPet > 0 then
      Skill:SetTargets(self.ActivatedPet)
    end
    Skill:RegisterEventCallback("Activated", self, self.OnActivateBonfireFinish)
    Skill:RegisterEventCallback("End", self, self.OnSkillActiveFinish)
    Skill:RegisterEventCallback("TargetFinish", self, self.OnTargetFinish)
    self.sceneCharacter.InteractionComponent:TryDisableInteraction()
    self.RocoSkill:PlaySkill(Skill)
    self:SetBonfireActive(true, false, self.CampLevel)
  else
    self:OnSkillActiveFinish()
    self:SetBonfireActive(true, true, self.CampLevel)
  end
end

function BP_NPCCampBonfireBase_C:OnTargetFinish()
  local IsBattle = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
  if IsBattle then
    return
  end
  if _G.DataModelMgr.PlayerDataModel:IsVisitState() and not _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
    return
  end
  local bInDialogue = _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) or false
  if bInDialogue then
    return
  end
  if BigMapModuleCmd then
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.BonfireFinishNotify)
  else
    Log.Error("BP_NPCCampBonfireBase_C:OnTargetFinish  BigMapModuleCmd is nil")
  end
end

function BP_NPCCampBonfireBase_C:OnSkillActiveFinish()
  self:ActivateBonfire()
  self.OnActivateFinishDelegate:Invoke(self)
  if self.sceneCharacter and self.sceneCharacter.InteractionComponent then
    self.sceneCharacter.InteractionComponent:TryEnableInteraction()
  end
  if #self.ActivatedPet > 0 then
    self:LockActivatedPet(false)
    self.ActivatedPet = {}
  end
end

function BP_NPCCampBonfireBase_C:ActivateBonfire()
  self.IsActivate = true
end

function BP_NPCCampBonfireBase_C:DeactivateBonfire()
  self.CampLevel = self:GetCampLevel()
  self:SetBonfireActive(false, false, self.CampLevel)
  if 0 ~= self.BonfireSoundSession then
    self.BonfireSoundSession = 0
  end
  self.IsActivate = false
end

function BP_NPCCampBonfireBase_C:OnActivateBonfireFinish()
  if self.sceneCharacter then
    _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, self.sceneCharacter:GetServerId())
  end
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Camp_Light)
end

function BP_NPCCampBonfireBase_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  Base.OnDistanceOptimize(self, distance, viewDotValue, bulkyVisible, distanceRatio)
  local LuluShouldAppear = self:LuluShouldAppear()
  if distance < 640000 and self.LuluRequest == nil and self.IsActivate and LuluShouldAppear then
    self.LuluDisappearCountDown = self.LuluDisappearTime
    if self.LuluAppearCountDown > 0 then
      self.LuluAppearCountDown = self.LuluAppearCountDown - 2
    else
      self.LuluAppearCountDown = 2
      self:TryAppearLulu()
    end
  end
  if self.Lulu and not LuluShouldAppear then
    if self.LuluDisappearCountDown > 0 then
      self.LuluDisappearCountDown = self.LuluDisappearCountDown - 1
    else
      self.LuluDisappearCountDown = self.LuluDisappearTime
      self:ClearPet()
    end
  end
end

function BP_NPCCampBonfireBase_C:LuluShouldAppear()
  local Character = self.sceneCharacter
  local InterComp = Character and Character.InteractionComponent
  local Options = InterComp and InterComp._options
  if _G.DataModelMgr.PlayerDataModel:HasStoryFlag(_G.Enum.PlayerStoryFlagEnum.PSF_FUNC_CAMP_SUBMIT_HIDDEN) then
    return true
  end
  if Options then
    for _, Option in pairs(Options) do
      if Option and Option.optionInfo and (Option.optionInfo.option_id == 60285 or Option.optionInfo.option_id == 13391) and Option.optionInfo.enabled then
        return true
      end
    end
  end
  return false
end

function BP_NPCCampBonfireBase_C:LuluIsLoading()
  return self.LuluRequest ~= nil
end

function BP_NPCCampBonfireBase_C:TryAppearLulu()
  if not self.LuluRequest then
    local ModelConf = DataConfigManager:GetModelConf(10008)
    self.LuluRequest = NRCResourceManager:LoadResAsync(self, ModelConf.path, -1, 10, self.LuluGenerated, function(caller, resRequest, errMsg)
      Log.Error(errMsg, "\233\156\178\232\144\165Load Failed")
      caller.LuluLoadFinished = true
    end, function(caller, resRequest, errMsg)
      Log.Error(errMsg, "\233\156\178\232\144\165Load Failed")
      caller.LuluLoadFinished = true
    end)
    Log.Trace("BP_NPCCampBonfireBase_C:TryAppearLulu", self.LuluRequest)
  end
end

function BP_NPCCampBonfireBase_C:LuluGenerated(req, asset)
  if self.LuluRequest == nil then
    return
  end
  if nil ~= asset then
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
    local transform = UE4.FTransform(UE4.FQuat(), UE4.FVector(player.X + math.random(100, 300), player.Y + math.random(100, 300), player.Z - 1000))
    local params = {}
    params.inBattle = true
    self.Lulu = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(asset, transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, params)
    self.LuluRef = UnLua.Ref(self.Lulu)
    self.Lulu:InitOutSceneAsync(self, self.OnLuluResLoaded)
    self.Lulu:SetActorHiddenInGame(true)
    UE4.UNRCStatics.SetSixLightingChannels(self.Lulu, true, false, true, false, true, false, false)
  end
  self.AppearSkillReq = _G.NRCResourceManager:LoadResAsync(self, "/Game/ArtRes/Effects/G6Skill/Luying/Camping_Pet_Report.Camping_Pet_Report_C", -1, 10, self.AppearSkillLoadSucceed, self.AppearSkillLoadFailed, self.AppearSkillLoadFailed)
end

function BP_NPCCampBonfireBase_C:OnLuluResLoaded()
  self.Lulu.IkOverride = false
  self.Lulu:SetActorEnableCollision(false)
  self.Lulu.Mesh:SetForcedLOD(1)
  self.LuluResLoadFinished = true
  self:TryDoFinalShow()
end

function BP_NPCCampBonfireBase_C:AppearSkillLoadSucceed(req, asset)
  self.LuluAppearSkillLoadFinished = true
  self.skillClass = asset
  self.skillClassRef = asset and UnLua.Ref(asset)
  self:TryDoFinalShow()
end

function BP_NPCCampBonfireBase_C:AppearSkillLoadFailed(caller, resRequest, errMsg)
  Log.Error(errMsg, "Report Skill Failed")
  caller.LuluAppearSkillLoadFinished = true
  caller:TryDoFinalShow()
end

function BP_NPCCampBonfireBase_C:TryDoFinalShow()
  if self.LuluAppearSkillLoadFinished and self.LuluResLoadFinished then
    self:UpdateLuluVisible()
    if not self.skillClass then
      self:LuluAppearEnd()
      return
    end
    if not self.RocoSkill then
      self:LuluAppearEnd()
      return
    end
    local skillObj = self.RocoSkill:FindOrAddSkillObj(self.skillClass)
    if not skillObj then
      Log.Error("Find Or Add SkillObj Failed!!!!!!!")
      self:LuluAppearEnd()
      return
    end
    skillObj:SetCaster(self)
    skillObj:RegisterEventCallback("PreEnd", self, self.LuluAppearEnd)
    skillObj:RegisterEventCallback("End", self, self.LuluAppearEnd)
    skillObj:SetPassive(true)
    local Characters = {}
    Characters[0] = self
    Characters[12] = self.Lulu
    skillObj:SetCharacters(Characters)
    self.RocoSkill:LoadAndPlaySkill(skillObj)
  end
end

function BP_NPCCampBonfireBase_C:LuluAppearEnd()
  for caller, callback in pairs(self.LuluLoadCallback) do
    callback(caller)
  end
end

function BP_NPCCampBonfireBase_C:RegisterLuluLoadCallback(caller, callback)
  self.LuluLoadCallback[caller] = callback
end

function BP_NPCCampBonfireBase_C:UnRegisterLuluLoadCallback(caller, callback)
  self.LuluLoadCallback[caller] = nil
end

function BP_NPCCampBonfireBase_C:RegisterLuluTurnAroundCallback(caller, callback)
  self.LuluTurnAroundCallback[caller] = callback
end

function BP_NPCCampBonfireBase_C:UnRegisterLuluTurnAroundCallback(caller, callback)
  self.LuluTurnAroundCallback[caller] = nil
end

function BP_NPCCampBonfireBase_C:LuluTurnAroundAuto()
  if not self.Lulu then
    if self:LuluIsLoading() then
      self:RegisterLuluLoadCallback(self, self.LuluTurnAround)
    else
      self:TryAppearLulu()
      self:RegisterLuluLoadCallback(self, self.LuluTurnAround)
    end
  else
    self:LuluTurnAround()
  end
end

function BP_NPCCampBonfireBase_C:LuluTurnAround()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ActorDirection = localPlayer.viewObj:Abs_K2_GetActorLocation() - self.Lulu:Abs_K2_GetActorLocation()
  local npcForward = self.Lulu:K2_GetActorRotation():ToVector()
  local dot = UE4.FVector.Dot(npcForward, ActorDirection)
  if dot > 0 then
    self:OnLuluTurnAroundEnd()
    return
  end
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/Camping_Pet_ReportTurnAround.Camping_Pet_ReportTurnAround"
  local skillProxy = RocoSkillProxy.Create(skillPath, self.RocoSkill, PriorityEnum.Passive_NPC_BornDie)
  skillProxy:SetCaster(self)
  skillProxy:RegisterEventCallback("PreEnd", self, self.OnLuluTurnAroundEnd)
  skillProxy:RegisterEventCallback("End", self, self.OnLuluTurnAroundEnd)
  skillProxy:SetPassive(true)
  local Characters = {}
  Characters[UE4.EBattleStaticActorType.Player_1] = self
  Characters[UE4.EBattleStaticActorType.Player_1_2] = localPlayer.viewObj
  Characters[UE4.EBattleStaticActorType.Pet_2_1] = self.Lulu
  skillProxy:SetCharacters(Characters)
  skillProxy:PlaySkill()
end

function BP_NPCCampBonfireBase_C:OnLuluTurnAroundEnd()
  for caller, callback in pairs(self.LuluTurnAroundCallback) do
    callback(caller)
  end
end

function BP_NPCCampBonfireBase_C:SetVisibleInternal(flag)
  Base.SetVisibleInternal(self, flag)
  self:UpdateLuluVisible()
end

function BP_NPCCampBonfireBase_C:UpdateLuluVisible()
  if self.Lulu then
    self.Lulu:SetActorHiddenInGame(self.bHidden)
    self.Lulu:SetActorEnableCollision(not self.bHidden)
  end
end

local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")

function BP_NPCCampBonfireBase_C:SetCustomDepth(Depth)
  local Comps = self:K2_GetComponentsByClass(UE.UMeshComponent)
  for _, Comp in tpairs(Comps) do
    if not Comp:IsA(UE.UWidgetComponent) and (self.IsActivate or self.NRCStaticMesh ~= Comp) then
      NPCLuaUtils.SetCompCustomDepth(Comp, Depth)
    end
  end
end

function BP_NPCCampBonfireBase_C:SetActivatedPet(ActivatedPet)
  table.insert(self.ActivatedPet, ActivatedPet)
  self:LockActivatedPet(true)
end

function BP_NPCCampBonfireBase_C:LockActivatedPet(lock)
  for i, ActivatedPet in pairs(self.ActivatedPet) do
    local sceneCharacter = ActivatedPet.sceneCharacter
    if sceneCharacter then
      local AIComp = sceneCharacter:EnsureComponent(AIComponent)
      if AIComp then
        AIComp:ForceLockForReason(lock, true, _G.AIDefines.LockReason.UNLOCK_BONFIRE)
      end
    end
  end
end

function BP_NPCCampBonfireBase_C:PlayUnlockJiDianEffect()
  Log.Debug("BP_NPCCampBonfireBase_C:PlayUnlockJiDianEffect", self:GetDebugInfo())
  local effectActor = self.NRCChildActor:GetChildActor()
  if not effectActor or not UE.UObject.IsValid(effectActor) then
    return
  end
  if effectActor.UnlockOnce then
    Log.Debug("BP_NPCCampBonfireBase_C:PlayUnlockJiDianEffect true ", self:GetDebugInfo())
    effectActor:UnlockOnce()
  end
end

function BP_NPCCampBonfireBase_C:ActivateMagicLock()
  Log.Debug("BP_NPCCampBonfireBase_C:ActivateMagicLock", self:GetDebugInfo())
  local effectActor = self.NRCChildActor:GetChildActor()
  if not effectActor or not UE.UObject.IsValid(effectActor) then
    return
  end
  if effectActor.ActivateFx then
    effectActor:ActivateFx()
  end
end

function BP_NPCCampBonfireBase_C:DeactivateMagicLock()
  Log.Debug("BP_NPCCampBonfireBase_C:DeactivateMagicLock", self:GetDebugInfo())
  local effectActor = self.NRCChildActor:GetChildActor()
  if not effectActor or not UE.UObject.IsValid(effectActor) then
    return
  end
  if effectActor.DeactivateFx then
    effectActor:DeactivateFx()
  end
end

return BP_NPCCampBonfireBase_C
