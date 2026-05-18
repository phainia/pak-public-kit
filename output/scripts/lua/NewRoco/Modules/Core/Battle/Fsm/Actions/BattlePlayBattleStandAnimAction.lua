local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleTeam = require("NewRoco.Modules.Core.Battle.Entity.BattleTeam")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ProtoEnum = require("Data.PB.ProtoEnum")
local Base = BattlePlayAnimBaseAction
local BattlePlayBattleStandAnimAction = Base:Extend("BattlePlayBattleStandAnimAction")
FsmUtils.MergeMembers(Base, BattlePlayBattleStandAnimAction, {})

function BattlePlayBattleStandAnimAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePlayBattleStandAnimAction:OnEnter()
  self.Player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.Target = BattleUtils.GetTraceNpc()
  if not self.Target or not self.Target.npc.viewObj then
    Log.Error("zgx Target is nil!!!!")
    self:Finish()
    return
  end
  if BattleUtils.ContainTaskPerformControl(Enum.TaskBattlePerformanceControl.TBPC_ENTER_SKIP) then
    self:Finish()
    return
  end
  if BattleManager:IsFocusingPet() then
    self:Finish()
    return
  end
  if BattleUtils.IsTerritoryTrialBattle() then
    self:Finish()
    return
  end
  local initInfo = BattleUtils.GetBattleInitInfo()
  if not initInfo then
    self:Finish()
    return
  end
  self.isBack = self:CheckPetStateByBGS(ProtoEnum.BuffGroupSign.BGS_BACKSTAB)
  local enterSkillPath = BattleConst.Define.BattleStandBPCla
  if _G.BattleManager.battleRuntimeData:GetEnterBattleType() == ProtoEnum.BattleEnterType.BET_CONTACT then
    if self.isBack then
      enterSkillPath = BattleConst.Define.BattleStandBackBPCla
    end
  else
    self:CreateCameraPos()
    if self.isBack then
      enterSkillPath = BattleConst.Define.ThrowBackEnterFirst
    else
      enterSkillPath = BattleConst.Define.ThrowFrontEnterFirst
    end
  end
  self:SaveBlackBoardValues()
  Log.Debug("BattlePlayBattleStandAnimAction target type:", self.Target.npc, type(self.Target.npc))
  _G.NRCAudioManager:SetEmitterSwitch("Pet_Switch", "Pet_Battle", self.Target.npc.viewObj)
  self:Play(self.Player, {
    self.Target.npc.viewObj
  }, enterSkillPath, true)
  _G.BattleManager:PlayBattleBGM()
end

function BattlePlayBattleStandAnimAction:OnBeforePlay()
  if self.Target and self.Target.npc then
    self.Target.npc:EnterBattle()
    if self.Target.npc.viewObj and UE.UObject.IsValid(self.Target.npc.viewObj) and self.Target.npc.viewObj.RocoSkill and UE.UObject.IsValid(self.Target.npc.viewObj.RocoSkill) then
      self.Target.npc.viewObj.RocoSkill:StopCurrentSkill()
    end
    self:ProcessMimic()
  end
end

function BattlePlayBattleStandAnimAction:SaveBlackBoardValues()
  local bbValues = {}
  local aiStatus = self:GetEnemyAIStatus()
  if not aiStatus then
    table.insert(bbValues, {"Normal", "True"})
  else
    local isAIStatus, statusString = BattleUtils.IsBattleAIStatus(aiStatus, true)
    if not isAIStatus then
      table.insert(bbValues, {"Normal", "True"})
    else
      local BattleThrowBallEnterFocusPet = require("NewRoco.Modules.Core.Battle.Scene.BattleThrowBallEnterFocusPet")
      local animComponent = self.Target.npc:GetAnimComponent()
      local bSetupSleep = BattleThrowBallEnterFocusPet.TrySetupBBValueForSleep(aiStatus, animComponent, bbValues)
      if bSetupSleep then
      else
        table.insert(bbValues, {statusString, "True"})
      end
    end
  end
  self:SetCacheBlackboardValue(bbValues)
end

function BattlePlayBattleStandAnimAction:ProcessMimic()
  if not self.Target then
    return
  end
  local HidComp = self.Target.npc.HiddenComponent
  if HidComp and HidComp:GetHiddenType() == Enum.WorldHide.WH_MIMIC_OPTION then
    HidComp:UnpinToGround(true)
    HidComp:EndHide(self, function()
    end)
  end
end

function BattlePlayBattleStandAnimAction:CreateCameraPos()
  self.CameraPos = _G.UE4Helper.GetCurrentWorld():SpawnActor(UE4.AActor, self.Target.npc:GetActorTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  self.CameraPos:AddComponentByClass(UE4.USceneComponent, false, UE4.FTransform(), false)
  local aPos = self.Target.npc:GetActorLocation()
  local bPos = self.Player:GetActorLocation()
  local dir = bPos - aPos
  dir.Z = 0
  self.CameraPos:Abs_K2_SetActorLocation_WithoutHit(aPos)
  self.CameraPos:K2_SetActorRotation(dir:ToRotator(), true)
end

function BattlePlayBattleStandAnimAction:CheckPetStateByBGS(bgs)
  local initInfo = BattleUtils.GetBattleInitInfo()
  for _, v in ipairs(initInfo.enemy_team) do
    for i, pet in ipairs(v.pets or {}) do
      local buffs = pet.battle_inside_pet_info.buffs
      if buffs and BattleUtils.CheckPetStateByBGS(buffs, bgs) then
        return true
      end
    end
  end
  return false
end

function BattlePlayBattleStandAnimAction:GetEnemyAIStatus()
  local initInfo = BattleUtils.GetBattleInitInfo()
  for _, v in ipairs(initInfo.enemy_team) do
    for i, pet in ipairs(v.pets or {}) do
      if BattleUtils.GetInBattle(pet.battle_inside_pet_info) then
        return pet.battle_inside_pet_info.ai_info.ai_status
      end
    end
  end
  return nil
end

function BattlePlayBattleStandAnimAction:OnCameraStart()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
end

function BattlePlayBattleStandAnimAction:OnHidePlayer()
  self:Finish()
end

function BattlePlayBattleStandAnimAction:OnPlayPetAnimEmotion()
  if self.Target and BattleManager.EnterBattleStateBit == BattleEnum.EnterBattleState.Default then
    local animName
    local contactType = _G.BattleManager.battleRuntimeData:GetContactEnterType()
    if contactType == BattleEnum.ContactEnterType.PetHit then
      animName = _G.DataConfigManager:GetBattleGlobalConfig("npc_hit_npc_closeup_animation").str
    elseif contactType == BattleEnum.ContactEnterType.PlayerHit then
      animName = _G.DataConfigManager:GetBattleGlobalConfig("player_hit_npc_closeup_animation").str
    elseif contactType == BattleEnum.ContactEnterType.HitTogether then
      animName = _G.DataConfigManager:GetBattleGlobalConfig("each_hit_npc_closeup_animation").str
    else
      local status = self:GetEnemyAIStatus()
      if BattleUtils.IsBattleAIStatus(status) then
        return
      end
      status = self:GetLastAiStatus(status)
      if status then
        animName = BattleConst.EnterAnimName[status + 1]
      else
        Log.Error("\230\138\149\230\142\183\232\191\155\230\136\152\230\150\151\228\184\173ai_status \228\184\186\231\169\186")
        animName = BattleConst.EnterAnimName[1]
      end
    end
    self.Target.npc:PlayAnim(animName or BattleConst.EnterAnimName[1], 1, 0, 0.25, 0.25, 1, 0)
  end
end

function BattlePlayBattleStandAnimAction:GetLastAiStatus(status)
  if not status or status <= 0 then
    return 0
  end
  local realAIStatus = 0
  local realAIStatusPriority = 0
  local enterBattles = _G.DataConfigManager:GetAllByName("ENTERBATTLE_BUFF_PRIORITY")
  for _, v in pairs(enterBattles) do
    if status & 1 << v.ai_status > 0 and (0 == realAIStatus or realAIStatusPriority < v.buff_priority) then
      realAIStatus = v.ai_status
      realAIStatusPriority = v.buff_priority
    end
  end
  return realAIStatus
end

function BattlePlayBattleStandAnimAction:OnSetCameraMiddle()
  if self.Target and self.Player then
    local Blackboard = self.skillObj:GetBlackboard()
    local KameraSA = Blackboard:GetValueAsObject(BattleConst.BattleStand.CameraID2_SA)
    local Kamera = Blackboard:GetValueAsObject(BattleConst.BattleStand.CameraID2)
    if not KameraSA or not Kamera then
      Log.Error("Camera is nil !!! in BattlePlayBattleStandAnimAction.OnSetCameraMiddle ", BattleConst.BattleStand.CameraID2_SA, BattleConst.BattleStand.CameraID2)
      return
    end
    KameraSA:K2_AttachToActor(self.CameraPos, nil, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
    KameraSA:K2_SetActorRelativeLocation(UE4.FVector(200, 0, 75), false, nil, false)
    local aPos = self.Target.npc:GetActorLocation()
    local bPos = self.Player:GetActorLocation()
    bPos.Z = math.max(bPos.Z + self.Player:GetScaledHalfHeight() * 1.2, aPos.Z)
    local npcHalfHeight = self.Target.npc:GetMeshScaledHalfHeight()
    local scaleValue = 3
    if npcHalfHeight > 100 then
      scaleValue = 1.7
    elseif npcHalfHeight > 60 then
      scaleValue = 2
    end
    local halfPetHeight = npcHalfHeight * scaleValue
    local vectorLength = UE4.UKismetMathLibrary.Vector_Distance2D(aPos - bPos, UE4.FVector(0, 0, 0))
    local vectorDir = aPos - bPos
    vectorDir:Normalize()
    local screenWidth = math.tan(math.rad(Kamera.CameraComponent.FieldOfView / 2)) * vectorLength
    local screenheight = screenWidth / Kamera.CameraComponent.AspectRatio
    local EndCameraRatio = halfPetHeight / screenheight
    self.EndCameraPos = aPos - vectorDir * vectorLength * EndCameraRatio
    KameraSA:Abs_K2_SetActorLocation_WithoutHit(self.EndCameraPos)
    local cameraPos = KameraSA:Abs_K2_GetActorLocation()
    local dir = aPos - cameraPos
    Kamera:K2_SetActorRotation(dir:ToRotator(), true)
    if self.isBack then
      dir = aPos - bPos
      dir.Z = 0
      self.Target.npc:SetActorRotation(dir:ToRotator())
    elseif not BattleUtils.IsBattleAIStatus(self:GetEnemyAIStatus()) then
      dir = bPos - aPos
      dir.Z = 0
      self.Target.npc:SetActorRotation(dir:ToRotator())
    end
  end
end

function BattlePlayBattleStandAnimAction:OnSetCameraEnd()
end

function BattlePlayBattleStandAnimAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function BattlePlayBattleStandAnimAction:OnSaveCamera()
  local Blackboard = self.skillObj:GetBlackboard()
  self:SaveObject(Blackboard, BattleConst.BattleStand.CameraID1)
  self:SaveObject(Blackboard, BattleConst.BattleStand.CameraID1_SA)
  self:SaveObject(Blackboard, BattleConst.BattleStand.CameraID2)
  self:SaveObject(Blackboard, BattleConst.BattleStand.CameraID2_SA)
end

function BattlePlayBattleStandAnimAction:OnFinish()
  Base.OnFinish(self)
  if self.CameraPos then
    self.fsm:SetProperty(BattleConst.BattleStand.CameraRoot, self.CameraPos)
  end
  self:RevertTargetRootMotion()
  if self.Target then
    _G.NRCAudioManager:SetEmitterSwitch("Pet_Switch", "Pet_World", self.Target.npc.viewObj)
  end
  self.Target = nil
  self.Player = nil
end

function BattlePlayBattleStandAnimAction:RevertTargetRootMotion()
  if self.Target then
    self.Target.npc:SetRootMotionMode(UE.ERootMotionMode.RootMotionFromMontagesOnly)
  end
end

function BattlePlayBattleStandAnimAction:SaveObject(bb, name)
  Log.Debug("BattlePlayAnimBaseAction SaveObject:", name, bb:GetValueAsObject(name))
  self.fsm:SetProperty(name, bb:GetValueAsObject(name))
  bb:RemoveObjectValue(name)
end

function BattlePlayBattleStandAnimAction:OnExit()
  self:RevertTargetRootMotion()
  if self.Target then
    _G.NRCAudioManager:SetEmitterSwitch("Pet_Switch", "Pet_World", self.Target.npc.viewObj)
  end
  self.Target = nil
end

return BattlePlayBattleStandAnimAction
