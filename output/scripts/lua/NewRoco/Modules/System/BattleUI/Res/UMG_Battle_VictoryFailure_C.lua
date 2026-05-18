local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_VictoryFailure_C = _G.NRCPanelBase:Extend("UMG_Battle_VictoryFailure_C")

function UMG_Battle_VictoryFailure_C:OnActive(param, isLocalPlayerExist)
  self:OnAddEventListener()
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  if isLocalPlayerExist then
    self:InitDataByLeaderChallenge()
    self.activityConf = {}
    self.activityConf.activity_type = Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT
    self:ShowLocalPlayerLose()
    self:RefreshUI()
    self:SendStopBossChallenge()
  else
    if not (param and param.settle_info) or not param.settle_info.pve_add_info then
      self:OnClickClose()
      return
    end
    self:InitDataByFinishData(param)
    self:RefreshUI()
  end
end

function UMG_Battle_VictoryFailure_C:OnStopBossRsp()
end

function UMG_Battle_VictoryFailure_C:SendStopBossChallenge()
  local Request = ProtoMessage:newZoneExitChallengeReq()
  Request.stay_dungeon = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_EXIT_CHALLENGE_REQ, Request, self, self.OnStopBossRsp)
end

function UMG_Battle_VictoryFailure_C:InitDataByLeaderChallenge()
  self.BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
    self.challenge_data = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
    self.ActivityData = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
    self.activityId = self.BossChallengeEventActivityObject[1]:GetBossActivityId()
    self.activityConf = _G.DataConfigManager:GetActivityConf(self.activityId)
    self.challenge_level_id = self.ActivityData.last_level_id
  end
end

function UMG_Battle_VictoryFailure_C:InitDataByFinishData(param)
  local pve_add_info = param.settle_info.pve_add_info
  self.challenge_level_id = pve_add_info.challenge_level_id
  self.activityId = pve_add_info.activity_id
  self.activityConf = _G.DataConfigManager:GetActivityConf(self.activityId)
end

function UMG_Battle_VictoryFailure_C:OnDeactive()
  self:OnRemoveEventListener()
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
end

function UMG_Battle_VictoryFailure_C:OnLeaveDungeonEvent()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseNpcBattleFailure)
end

function UMG_Battle_VictoryFailure_C:OnRemoveEventListener()
end

function UMG_Battle_VictoryFailure_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Return.btnLevelUp, self.OnClickClose)
  self:AddButtonListener(self.Btn_ChallengeAgain.btnLevelUp, self.ChallengeAgain)
end

function UMG_Battle_VictoryFailure_C:RefreshUI()
  local targetTable = {}
  local str1 = _G.DataConfigManager:GetLocalizationConf("challenge_text_1").msg
  local str2 = _G.DataConfigManager:GetLocalizationConf("challenge_text_2").msg
  local str3 = _G.DataConfigManager:GetLocalizationConf("challenge_text_3").msg
  if self.activityConf then
    local ChallengeConf
    if self.challenge_level_id and 0 ~= self.challenge_level_id then
      if self.activityConf.activity_type == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
        ChallengeConf = _G.DataConfigManager:GetNpcChallengeConf(self.challenge_level_id)
      elseif self.activityConf.activity_type == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
        ChallengeConf = _G.DataConfigManager:GetBossChallengeConf(self.challenge_level_id)
      end
    end
    if ChallengeConf then
      table.insert(targetTable, {
        des = str1,
        Str = ChallengeConf.level,
        type = 0
      })
      table.insert(targetTable, {
        des = str2,
        Str = ChallengeConf.growth,
        type = 0
      })
      table.insert(targetTable, {
        des = str3,
        Department = ChallengeConf.type,
        type = 1
      })
      self.NRCList:InitGridView(targetTable)
    end
    if self.activityConf.activity_type == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
      self.Btn_Return:SetBtnText(LuaText.challenge_text_5)
    else
      self.Btn_Return:SetBtnText(LuaText.challenge_text_6)
    end
  end
  local randomIndex = math.floor(math.random(1, 3))
  local id = "challenge_tips_" .. randomIndex
  local str4 = _G.DataConfigManager:GetLocalizationConf(id).msg
  self.NRCText_0:SetText(str4)
  self:PlayAnimation(self.In)
end

function UMG_Battle_VictoryFailure_C:ChallengeAgain()
  if self.activityId then
    if self.activityConf.activity_type == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
      _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.SetForbidCloseLoading, true)
      _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.SendZoneChallengeCreateBattleReq, self.activityId, self.challenge_level_id, true)
    else
      _G.NRCModeManager:DoCmd(LevelSelectionModuleCmd.SendZoneChallengeCreateBattleReq, self.activityId, self.challenge_level_id, false)
    end
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseNpcBattleFailure)
    _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
  else
    self:TryExitBossChallenge()
  end
end

function UMG_Battle_VictoryFailure_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:NpcChallengeOutAnimEndClose()
  end
end

function UMG_Battle_VictoryFailure_C:NpcChallengeOutAnimEndClose()
  if self.activityConf then
    local activity_type = self.activityConf.activity_type
    if activity_type == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
      _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.SetLeveBattleSilhouette)
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1192, "UMG_Battle_VictoryFailure_C:NpcChallengeOutAnimEndClose")
      _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.SetWillOpenLeveSelect)
    end
    self:TryExitBossChallenge()
  else
    self:TryExitBossChallenge()
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
end

function UMG_Battle_VictoryFailure_C:OnLeaveDungeonRsp()
  if self and self.panelData then
    self:DoClose()
  end
end

function UMG_Battle_VictoryFailure_C:TryExitBossChallenge()
  local Request = ProtoMessage:newZoneExitChallengeReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_EXIT_CHALLENGE_REQ, Request, self, self.OnLeaveDungeonRsp)
end

function UMG_Battle_VictoryFailure_C:OnClickClose()
  self:PlayAnimation(self.Out)
end

function UMG_Battle_VictoryFailure_C:OnTick()
end

function UMG_Battle_VictoryFailure_C:OnLogin()
end

function UMG_Battle_VictoryFailure_C:OnConstruct()
end

function UMG_Battle_VictoryFailure_C:OnDestruct()
  self:ReCoverActorHidden()
  if self.camera1 and UE.UObject.IsValid(self.camera1) then
    self.camera1:K2_DestroyActor()
  end
  if self.camera2 and UE.UObject.IsValid(self.camera2) then
    self.camera2:K2_DestroyActor()
  end
  self:DelaySeconds(1, self.ClearPlayerAnim, self)
end

function UMG_Battle_VictoryFailure_C:ClearPlayerAnim()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player then
    Player:GetUEController():ReleaseRocoCamera(0)
    Player.viewObj:GetAnimComponent():StopAnimByName("SadLoop", 0, "Locomotion")
  end
end

function UMG_Battle_VictoryFailure_C:ShowLocalPlayerLose()
  local pvpSkillPath = BattleConst.LeaderChallengeLoseOver
  self.ShakeResRequest = NRCResourceManager:LoadResAsync(self, pvpSkillPath, 255, self.resCacheTime, function(caller, resRequest, asset)
    self:OnPvpClassLoad(asset, pvpPlayerPerformData)
  end)
end

function UMG_Battle_VictoryFailure_C:OnPvpClassLoad(skillClass, pvpPlayerPerformData)
  if not skillClass then
    return
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer or not localPlayer.viewObj then
    return
  end
  local caster = localPlayer.viewObj
  if not caster or not UE.UObject.IsValid(caster) then
    return
  end
  local SkillComponent = caster.RocoSkill
  SkillComponent:ClearAllPassiveSkillObjs()
  local Skill = SkillComponent:FindOrAddSkillObj(skillClass)
  if Skill then
    if localPlayer.viewObj:IsMale() then
      Skill.BattleGenderType = 1
    else
      Skill.BattleGenderType = 0
    end
    local Characters = {}
    Characters[BattleConst.CharacterIndex.Player1] = caster
    Skill:SetCaster(caster)
    Skill:SetCharacters(Characters)
    Skill:RegisterEventCallback("SaveCam", self, self.OnSkillEnd)
    Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
    Skill:RegisterEventCallback("CameraCollision", self, self.CameraLineTraceHiddeObject)
    Skill:SetPassive(true)
    SkillComponent:PlaySkill(Skill)
  end
end

function UMG_Battle_VictoryFailure_C:CameraLineTraceHiddeObject(Event, Skill)
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer or not localPlayer.viewObj then
    return
  end
  local cameraActor = Skill.BlackBoard:GetValueAsObject("camActor_0001")
  if not cameraActor then
    return
  end
  local startPos = cameraActor:Abs_K2_GetActorLocation()
  local endPos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  local actorIgnore = {
    localPlayer.viewObj
  }
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5, UE4.ECollisionChannel.ECC_WorldStatic)
  local OutHit = UE4.FHitResult()
  local Success = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(_G.UE4Helper.GetCurrentWorld(), startPos, endPos, TraceChannel, false, actorIgnore, UE4.EDrawDebugTrace.ForDuration, OutHit, true, UE4.FLinearColor(1, 0, 1, 1), UE4.FLinearColor(1, 1, 0, 1), 30)
  if Success then
    local blockActor = OutHit.Actor
    if blockActor and UE.UObject.IsValid(blockActor) and not blockActor.bHidden then
      blockActor:SetActorHiddenInGame(true)
      self.HideActor = blockActor
    end
  end
end

function UMG_Battle_VictoryFailure_C:ReCoverActorHidden()
  if self.HideActor and UE.UObject.IsValid(self.HideActor) then
    self.HideActor:SetActorHiddenInGame(false)
    self.HideActor = nil
  end
end

function UMG_Battle_VictoryFailure_C:OnSkillEnd(Event, Skill)
  local Blackboard = Skill:GetBlackboard()
  self.camera1 = Blackboard:GetValueAsObject("camActor_0001")
  self.camera2 = Blackboard:GetValueAsObject("camActor_0001_SA")
  Blackboard:RemoveObjectValue("camActor_0001")
  Blackboard:RemoveObjectValue("camActor_0001_SA")
end

return UMG_Battle_VictoryFailure_C
