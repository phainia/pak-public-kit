local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local async = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local BattleClientBranchActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleClientBranchActionBase")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local Base = BattleClientBranchActionBase
local BattleLeaderChallengeShowResultUI = Base:Extend("BattleLeaderChallengeShowResultUI")

function BattleLeaderChallengeShowResultUI:OnEnter()
  if not BattleUtils.IsLeaderChallenge() and not BattleUtils.IsNpcChallenge() then
    self:Finish()
    return
  end
  self.skillOver = false
  self.BattleManager = _G.BattleManager
  self.fsm:Pause()
  local pets = _G.BattleManager.battlePawnManager:GetAllPets()
  for _, v in pairs(pets) do
    v:HidePet()
  end
  for i, battleNpc in ipairs(_G.BattleManager.battlePawnManager.battleNpcList) do
    battleNpc:HideNpc()
  end
  self.ShowPlayer = self.BattleManager.battlePawnManager.TeamatePlayer
  local skillPath
  if self.BattleManager.battleRuntimeData.battleSettleData:BattleIsWin() then
    skillPath = BattleConst.LeaderChallengeWinOver
  else
    skillPath = BattleConst.LeaderChallengeLoseOver
  end
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBuffInfo)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ClosePVPValueNumberPanel)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OnShowBatleResult)
  if BattleUtils.IsLeaderChallenge() or BattleUtils.IsNpcChallenge() then
    if self.BattleManager.battleRuntimeData.battleSettleData:BattleIsWin() then
      _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattlePVPResultPanel, self.BattleManager.battleRuntimeData.battleSettleData.data)
    else
      _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenNpcBattleFailure, self.BattleManager.battleRuntimeData.battleSettleData.data)
    end
  end
  _G.BattleEventCenter:Bind(self, BattleEvent.CLICKED_Result_Close, BattleEvent.OnSkillResLoaded)
  self.SkillComponent = self.BattleManager.vBattleField.battleFieldActor.Skill
  self.skillResList = {skillPath}
  self.loadedSkillResCount = 0
  self:LaunchAsyncTask(function(noUncheckedError, msgOrResult)
  end)
end

function BattleLeaderChallengeShowResultUI:AsyncTask()
  async.wait(BattleLeaderChallengeShowResultUI.LoadSkillTask(self))
  self.loadSkillTaskCallback = nil
  local status, messageOrEvent, skill = async.wait(BattleLeaderChallengeShowResultUI.PlayOverSkillTask(self))
  assert(status, messageOrEvent)
  local event = messageOrEvent
  self:OnSkillEnd(event, skill)
  if BattleUtils.IsReplayMode() then
    async.wait(au.DelaySeconds(3))
    _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
  end
end

local function LoadSkillTask(self, callback)
  self.loadSkillTaskCallback = callback
  _G.BattleSkillManager:PreLoadRes(self.skillResList, true)
end

BattleLeaderChallengeShowResultUI.LoadSkillTask = async.wrap(LoadSkillTask)

local function PlayOverSkillTask(self, callback)
  if not self.ShowPlayer then
    callback(false, "ShowPlayer is nil")
    return
  end
  local skillPath = self.skillResList[1]
  local skillClass = _G.BattleSkillManager:GetLoadedClass(skillPath)
  if not skillClass then
    callback(false, string.format("Failed to load skill class %s", skillPath))
    return
  end
  self.ShowPlayer:ShowPlayer()
  local skill = self.SkillComponent:FindOrAddSkillObj(skillClass)
  local Characters = {}
  Characters[BattleConst.CharacterIndex.Player1] = self.ShowPlayer.model
  skill:RegisterEventCallback("End", nil, function(event, internalSkill)
    callback(true, event, internalSkill)
  end)
  skill:RegisterEventCallback("PreEnd", nil, function(event, internalSkill)
    callback(true, event, internalSkill)
  end)
  skill:RegisterEventCallback("Start", self, self.SkillStart)
  local blackboard = skill:GetBlackboard()
  if blackboard and UE.UObject.IsValid(blackboard) then
    if self.ShowPlayer.roleInfo.base.sex == _G.ProtoEnum.ESexValue.SEX_MALE then
      blackboard:SetValueAsString("PC1", "PC1")
    else
      blackboard:SetValueAsString("PC2", "PC2")
    end
  end
  skill:SetCharacters(Characters)
  skill.BattleGenderType = self.ShowPlayer.roleInfo.base.sex
  skill:SetCaster(self.ShowPlayer.model)
  self.SkillComponent:PlaySkill(skill)
end

BattleLeaderChallengeShowResultUI.PlayOverSkillTask = async.wrap(PlayOverSkillTask)

function BattleLeaderChallengeShowResultUI:SkillStart(Event, Skill)
  if self.finished then
    Log.Debug("yukahe BattleLeaderChallengeShowResultUI is finished")
    return
  end
  self:AdjustPlayer()
end

function BattleLeaderChallengeShowResultUI:AdjustPlayer()
  local player = self.ShowPlayer.model
  if player and player.GetHalfHeight then
    local HalfHeight = player:GetHalfHeight()
    local pos = player:Abs_K2_GetActorLocation()
    if pos then
      local groundPoint = LineTraceUtils.GetPointValidLocationByLine(pos, HalfHeight) or pos
      local newLocation = UE4.FVector(groundPoint.X, groundPoint.Y, groundPoint.Z + HalfHeight)
      player:Abs_K2_SetActorLocation_WithoutHit(newLocation)
    end
  end
end

function BattleLeaderChallengeShowResultUI:OnSkillEnd(Event, Skill)
  if self.finished then
    Log.Debug("yukahe BattleLeaderChallengeShowResultUI is finished")
    return
  end
  self.skillOver = true
  local Blackboard = Skill:GetBlackboard()
  self:SaveBlackboard(Blackboard, "camActor_0001")
  self:SaveBlackboard(Blackboard, "camActor_0001_SA")
end

function BattleLeaderChallengeShowResultUI:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function BattleLeaderChallengeShowResultUI:CloseResult()
  self.fsm:Resume()
  self:Finish()
end

function BattleLeaderChallengeShowResultUI:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseBattlePVPResultPanel)
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseNpcBattleFailure)
  self.BattleManager = nil
  self.SkillComponent = nil
  self.loadSkillTaskCallback = nil
end

function BattleLeaderChallengeShowResultUI:OnSkillResLoaded(eventName, resPath)
  for i = 1, #self.skillResList do
    if resPath == self.skillResList[i] then
      self.loadedSkillResCount = self.loadedSkillResCount + 1
    end
  end
  if self.loadedSkillResCount == #self.skillResList and self.loadSkillTaskCallback then
    self.loadSkillTaskCallback()
  end
end

function BattleLeaderChallengeShowResultUI:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.CLICKED_Result_Close then
    self:CloseResult()
    return true
  end
  if eventName == BattleEvent.OnSkillResLoaded then
    self:OnSkillResLoaded(eventName, ...)
    return true
  end
end

return BattleLeaderChallengeShowResultUI
