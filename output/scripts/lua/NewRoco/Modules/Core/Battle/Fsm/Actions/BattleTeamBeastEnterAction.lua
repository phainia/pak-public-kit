local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BeastPlayEnterPerform = require("NewRoco.Modules.Core.Battle.Fsm.Actions.TeamBeastEnter.BeastPlayEnterPerform")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local SkillNameIndex = {
  FourClip = 1,
  CallOut = 2,
  ChangeCameraToBattle = 3
}
local BattleTeamBeastEnterAction = Base:Extend("BattleTeamBeastEnterAction")
FsmUtils.MergeMembers(Base, BattleTeamBeastEnterAction, {})

function BattleTeamBeastEnterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleTeamBeastEnterAction:OnEnter()
  self:SetActionType(BattleActionBase.ActionType.ClientTurnPlayAction)
  self.WillEnterCatch = false
  self.EnterSkillState = 0
  self.IsOpenFourHud = false
  self.playSequenceOver = false
  local battleStartParam = _G.BattleManager.battleRuntimeData.battleStartParam
  if battleStartParam and battleStartParam:CheckInitState(ProtoEnum.BATTLEFIELD_BIT_TYPE.BT_BEAST_REENTRY_CATCH) then
    self.WillEnterCatch = true
    self:Finish()
    return
  end
  self.Boss = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  if self.Boss then
    self.performOver = false
    self.WaitingCamera = false
    self.timeout = 60
    self.resList = BattleConst.TeamBeastEnterSkill
    self.loadedResCount = 0
    BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded, BattleEvent.OnSkillBeforeAsync)
    local sequencePath = BattleManager.battleRuntimeData.battleConfig.show_res
    if string.IsNilOrEmpty(sequencePath) then
      self.playSequenceOver = true
      BattleSkillManager:PreLoadRes(self.resList, true)
    else
      sequencePath = _G.NRCUtils.FormatResPackageNameToFullPath(sequencePath)
      BattleResourceManager:LoadResAsync(self, sequencePath, self.OnLoadSequence, self.OnLoadSequenceFailed)
    end
  else
    Log.Error("zgx No Boss!!!!")
    self:Finish()
  end
end

function BattleTeamBeastEnterAction:OnLoadSequence(leveSequenceRes)
  if not self.Boss or self.finished then
    return
  end
  local Settings = UE4.FMovieSceneSequencePlaybackSettings()
  local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
  Settings.bPauseAtEnd = true
  local levelSequenceActor = {}
  levelSequenceActor, self.levelSequencePlayer = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(battleFieldActor, leveSequenceRes, Settings, levelSequenceActor)
  if self.levelSequencePlayer then
    self:ShowOrHideBattlePawn(false)
    battleFieldActor:SetCacheLSCall(self, self.OnSequenceOver)
    self.levelSequencePlayer.OnFinished:Add(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    levelSequenceActor:ApplyWorldOffsetToSequence()
    local centerActor = levelSequenceActor.DefaultInstanceData and levelSequenceActor.DefaultInstanceData.TransformOriginActor
    if centerActor then
      local meshComponent = centerActor:GetComponentByClass(UE4.UStaticMeshComponent)
      meshComponent:SetMobility(UE4.EComponentMobility.Movable)
      if BattleManager.battleRuntimeData.teamBattleCenterTrans then
        centerActor:Abs_K2_SetActorTransform(BattleManager.battleRuntimeData.teamBattleCenterTrans, false, nil, false)
      else
        centerActor:Abs_K2_SetActorLocation(BattleManager.battleRuntimeData.TeleportBattleCenter, false, nil, false)
      end
    end
    self:SafeDelayFrames("d_CloseTransformLoadingUI", 2, function()
      NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
    end)
    BattleSkillManager:PreLoadRes(self.resList, true)
    self.levelSequencePlayer:Play()
  else
    self:OnLoadSequenceFailed()
  end
end

function BattleTeamBeastEnterAction:OnLoadSequenceFailed()
  self.playSequenceOver = true
  BattleSkillManager:PreLoadRes(self.resList, true)
end

function BattleTeamBeastEnterAction:OnSequenceOver()
  self.playSequenceOver = true
  if self.IsOpenFourHud then
    self:StartEnterSkill()
  end
end

function BattleTeamBeastEnterAction:ShowOrHideBattlePawn(isVisible)
  local pawnManager = _G.BattleManager.battlePawnManager
  for i, v in ipairs(pawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
    if v.player and v.player.model then
      if isVisible then
        v.player:ShowPlayer()
      else
        v.player:HidePlayer()
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:ChangeBuffVisibility(isVisible)
          if isVisible then
            p:ShowPet()
          else
            p:HidePet()
          end
        end
      end
    end
  end
  for i, v in ipairs(pawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    if v.player and v.player.model then
      if isVisible then
        v.player:ShowPlayer()
      else
        v.player:HidePlayer()
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:ChangeBuffVisibility(isVisible)
          if isVisible then
            p:ShowPet()
          else
            p:HidePet()
          end
        end
      end
    end
  end
end

function BattleTeamBeastEnterAction:OnBattleEvent(event, ...)
  if event == BattleEvent.OnSkillResLoaded then
    local value = (...)
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      self:OnSkillLoadOver()
    end
    return true
  elseif event == BattleEvent.OnSkillBeforeAsync then
    local value, skillObject = ...
    for i = 1, #self.resList do
      if value == self.resList[i] then
        local skill = skillObject
        if _G.BattleManager.battlePawnManager.TeamatePlayer then
          skill:SetCaster(_G.BattleManager.battlePawnManager.TeamatePlayer.model)
        end
        if self.Boss then
          skill:SetTargets({
            self.Boss.model
          })
        end
        skill:SetCharacters(BattleManager.battlePawnManager:GetAllPawnActorForSkill())
        if i >= SkillNameIndex.FourClip then
          self:SetBallPath(skillObject)
        end
      end
    end
  end
end

function BattleTeamBeastEnterAction:OnSkillLoadOver()
  BattleEventCenter:UnBind(self)
  self:LoadHud()
end

function BattleTeamBeastEnterAction:LoadHud()
  local hudRes = "/Game/NewRoco/Modules/Core/Battle/FourEnterHud.FourEnterHud_C"
  _G.BattleResourceManager:LoadWidgetAsync(self, hudRes, UE4.UGameplayStatics:GetPlayerController(0), function(caller, widget)
    if self.Boss then
      caller.IsOpenFourHud = true
      caller.FourEnterHud = widget
      caller.FourEnterHudRef = UnLua.Ref(widget)
      caller:StartEnterSkill()
    end
  end, function()
    if self.Boss then
      self.IsOpenFourHud = true
      self:StartEnterSkill()
    end
  end)
end

function BattleTeamBeastEnterAction:StartEnterSkill(name, skill)
  if not self.playSequenceOver then
    return
  end
  if self.EnterSkillState == SkillNameIndex.FourClip - 1 then
    self:SafeDelayFrames("d_CloseTransformLoadingUI", 2, function()
      NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
    end)
    if self.levelSequencePlayer then
      self.levelSequencePlayer:Stop()
      local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
      self.levelSequencePlayer.OnFinished:Remove(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
      self.levelSequencePlayer = nil
      self:ShowOrHideBattlePawn(true)
    end
    self:InitEnterHud()
  end
  if not skill or skill == self.SkillObj then
    self.SkillObj = nil
    self.EnterSkillState = self.EnterSkillState + 1
    if self.EnterSkillState <= #BattleConst.TeamBeastEnterSkill then
      local TeamatePlayer = _G.BattleManager.battlePawnManager.TeamatePlayer
      if not TeamatePlayer.model then
        Log.Warning("There is no model in my player !!!")
        self:StartEnterSkill()
        return
      end
      local skillComponent = TeamatePlayer.model.RocoSkill
      if not skillComponent then
        Log.Warning("There is no RocoSkill in my player !!!")
        self:StartEnterSkill()
        return
      end
      local skillPath = BattleConst.TeamBeastEnterSkill[self.EnterSkillState]
      local MyCastObject = CastSkillObject.FromSkillResID(skillPath)
      if MyCastObject then
        MyCastObject:SetCallbackOwner(self)
        MyCastObject:SetCaster(TeamatePlayer.model)
        if self.EnterSkillState == SkillNameIndex.CallOut then
          MyCastObject:AddBlackStringValue("IsCommon", "IsCommon")
          MyCastObject:SetExtraEvents({
            ActionStart = self.RevertPlayer
          })
        end
        MyCastObject:SetTargetPets({
          self.Boss
        })
        MyCastObject:SetIsPassive(true)
        MyCastObject:SetCharacters(BattleManager.battlePawnManager:GetAllPawnActorForSkill())
        MyCastObject:SetCompleteCallback(self.StartEnterSkill)
        if self.EnterSkillState >= SkillNameIndex.FourClip then
          self:SetBallPathForCast(MyCastObject)
        end
        local _, skill = BattleSkillManager:PrepareSkill(self.Boss, skillComponent, MyCastObject)
        if not skill then
          Log.WarningFormat("Can't find or load skill object %s %s", MyCastObject.ResID)
          self:DefeatSkillFinish()
          return
        end
        if self.IsOpenFourHud and self.EnterSkillState == SkillNameIndex.FourClip then
          self:AdaptFourScreen(skill)
        end
        self.SkillObj = skill
        skillComponent:PlaySkill(skill)
      else
        Log.Error("zgx res is vaild!!", skillPath)
        self:StartEnterSkill()
      end
    else
      self.performOver = true
      self:CheckFinish()
    end
  end
end

function BattleTeamBeastEnterAction:SetBallPath(skill)
  local blackboard = skill:GetBlackboard()
  local pets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  if #pets > 0 then
    local ballAddPath = {
      "None",
      "None",
      "None",
      "None"
    }
    local ballAddLinkActor = {}
    for i = 1, #pets do
      local petData = pets[i].card.petInfo.battle_common_pet_info
      ballAddPath[i] = BattleUtils.GetPetBallPath(petData)
      ballAddLinkActor[i] = pets[i].model
      if blackboard then
        local effectBlackboard = "Normal"
        if petData.ball_id and 0 ~= petData.ball_id then
          local BallConfig = _G.DataConfigManager:GetBallConf(petData.ball_id)
          if BallConfig then
            effectBlackboard = BallConfig.catch_effect_blackboard or "Normal"
          end
        end
        blackboard:SetValueAsString("IsCommon", "IsCommon")
        BattleUtils.SetParticleKeyForSkillObj(pets[i].model, skill, effectBlackboard)
        BattleUtils.SetParticleKeyForSkillObj(pets[i].model, skill, pets[i].card.medalBlackBoard)
        BattleUtils.SetParticleKeyForSkillObj(pets[i].player.model, skill, effectBlackboard)
      end
    end
    skill:SetDynamicData({
      BallPath = "None",
      BallAdditionalPaths = ballAddPath,
      BallAddLinkActors = ballAddLinkActor
    })
  end
end

function BattleTeamBeastEnterAction:SetBallPathForCast(skill)
  local pets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  if #pets > 0 then
    local ballAddPath = {
      "None",
      "None",
      "None",
      "None"
    }
    local ballAddLinkActor = {}
    for i = 1, #pets do
      local petData = pets[i].card.petInfo.battle_common_pet_info
      ballAddPath[i] = BattleUtils.GetPetBallPath(petData)
      ballAddLinkActor[i] = pets[i].model
      local effectBlackboard = "Normal"
      if petData.ball_id and 0 ~= petData.ball_id then
        local BallConfig = _G.DataConfigManager:GetBallConf(petData.ball_id)
        if BallConfig then
          effectBlackboard = BallConfig.catch_effect_blackboard or "Normal"
        end
      end
      BattleUtils.SetParticleKeyForCastSkillObject(pets[i].model, skill, effectBlackboard)
      BattleUtils.SetParticleKeyForCastSkillObject(pets[i].model, skill, pets[i].card.medalBlackBoard)
      BattleUtils.SetParticleKeyForCastSkillObject(pets[i].player.model, skill, effectBlackboard)
    end
    skill:SetDynamicData({
      BallPath = "None",
      BallAdditionalPaths = ballAddPath,
      BallAddLinkActors = ballAddLinkActor
    })
  end
end

function BattleTeamBeastEnterAction:AdaptFourScreen(skill)
  local actions = skill:GetAllActions()
  local index = 1
  for i = 1, actions:Length() do
    local action = actions:Get(i)
    if action:IsA(UE4.URocoCameraCurveAction) and action.SceneCaptureSetting.bUseSceneCapture and action.SceneCaptureSetting.bUseViewportSize then
      action.SceneCaptureSetting.ViewportRTSize.X = self.PlayerWidthRatio[index] or 0.25
      index = index + 1
    end
  end
end

function BattleTeamBeastEnterAction:InitEnterHud()
  if not self.FourEnterHud then
    Log.Error("zgx FourEnter is nil!!")
    return
  end
  local ImageWidth = 580
  local FourImage = {
    self.FourEnterHud.ImageOne,
    self.FourEnterHud.ImageTwo,
    self.FourEnterHud.ImageThree,
    self.FourEnterHud.ImageFour
  }
  self.PlayerWidthRatio = {}
  if self.FourEnterHud then
    for _, v in ipairs(FourImage) do
      ImageWidth = v.Slot.LayoutData.Offsets.Right
      local rtSizeX = BeastPlayEnterPerform.DoGetViewportRTSize(ImageWidth)
      table.insert(self.PlayerWidthRatio, rtSizeX)
    end
  else
    self.PlayerWidthRatio = {
      0.25,
      0.25,
      0.25,
      0.25
    }
  end
  local teams = BattleManager.battlePawnManager.AllPlayerTeam
  local NameText = {
    self.FourEnterHud.TextNameOne,
    self.FourEnterHud.TextNameTwo,
    self.FourEnterHud.TextNameThree,
    self.FourEnterHud.TextNameFour
  }
  for i, v in ipairs(teams) do
    if NameText[i] and NameText[i].SetText then
      NameText[i]:SetText(v.player.roleInfo.base.name)
    else
      Log.Error("zgx NameText is nil!! index", i)
    end
  end
  self.FourEnterHud:AddToViewport()
  self.FourEnterHud:PlayAnimation(self.FourEnterHud.Start)
end

function BattleTeamBeastEnterAction:SaveCamera(name, skill)
  if self.EnterSkillState >= #BattleConst.TeamBeastEnterSkill and BattleManager.vBattleField.battleCraneCamera then
    self.WaitingCamera = true
    BattleManager.vBattleField.battleCraneCamera:ChangeToPlayerPet(0.5, true, nil, nil, nil, true)
    self:SafeDelaySeconds("d_CheckFinish", 0.5, function()
      self.WaitingCamera = false
      self:CheckFinish()
    end, self)
  end
end

function BattleTeamBeastEnterAction:RevertPlayer(name, skill)
  self:CloseFourEnterHud()
  if BattleManager.vBattleField.battleCraneCamera then
    BattleManager.vBattleField.battleCraneCamera:ChangeToPlayerPet(0)
  end
  BattleUtils.ShowAndResetPlayer()
end

function BattleTeamBeastEnterAction:CheckFinish()
  if self.performOver and not self.WaitingCamera then
    self:Finish()
  end
end

function BattleTeamBeastEnterAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function BattleTeamBeastEnterAction:CloseFourEnterHud()
  if self.FourEnterHud then
    self.FourEnterHud:RemoveFromViewport()
    self.FourEnterHud:Destruct()
    self.FourEnterHud = nil
    self.FourEnterHudRef = nil
  end
end

function BattleTeamBeastEnterAction:OnFinish()
  self.Boss = nil
  self.performOver = false
  self.WaitingCamera = false
  BattleEventCenter:UnBind(self)
  if not self.WillEnterCatch then
    NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
  end
  self:CloseFourEnterHud()
end

return BattleTeamBeastEnterAction
