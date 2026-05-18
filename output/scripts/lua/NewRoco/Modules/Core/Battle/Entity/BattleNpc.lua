local BattleObject = require("NewRoco.Modules.Core.Battle.Entity.BattleObject")
local BattleOnLookerBase = require("NewRoco.Modules.Core.Battle.Entity.BattleOnLookerBase")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local OnLookerCrowdShowComponent = require("NewRoco.Modules.Core.Battle.Entity.Components.Show.OnLookerCrowdShowComponent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleOnLookerBase
local BattleNpc = Base:Extend("BattleNpc")
BattleNpc.Type = {
  SingleOnLooker = 1,
  CrowdOnLooker = 2,
  Max = 3
}
BattleNpc.IndexToAttachPointEnumA = {
  [1] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A1,
  [2] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A2,
  [3] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A3,
  [4] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A4
}
BattleNpc.IndexToAttachPointEnumB = {
  [1] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_B1,
  [2] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_B2,
  [3] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_B3,
  [4] = UE.EBattleFieldOnLookerAttachPoint.Pos_Round_B4
}
BattleNpc.PerformState = {
  WaitingForInit = 0,
  Init = 1,
  Idle = 2,
  PlaySelectStateAnimation = 3,
  AiPerform = 4
}

function BattleNpc:Ctor(type)
  Base.Ctor(self)
  self.isDoingBattlePerform = false
  self.aiPerformAsyncTaskWaitingList = {}
  self.type = type
  self.isInitialized = false
  self.resourceScale = 1
  self.npc_round_tip_scale = 1
  self.performState = BattleNpc.PerformState.WaitingForInit
  self.selectStateAnimationNameList1 = {}
  self.selectStateAnimationNameList2 = {}
  self.selectStateAnimationNameList3 = {}
  self.name = ""
  if self.type == BattleNpc.Type.SingleOnLooker then
    self.BubbleComponent = self:AddComponent(BubbleComponent(self))
  elseif self.type == BattleNpc.Type.CrowdOnLooker then
    self.OnLookerCrowdShowComponent = self:AddComponent(OnLookerCrowdShowComponent(self))
  end
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_SELECT_START, BattleEvent.SWAP_SELECT_START)
end

function BattleNpc:SetBattleOnLookerInfo(npcInfo, attachPointInField, resourceScale, npc_round_tip_scale)
  if self.type == BattleNpc.Type.SingleOnLooker then
    self.npcInfo = npcInfo
    self.battlePawnId = npcInfo.id
    self.attachPoint = self:GetOnLookerAttachPointInField(attachPointInField)
  end
  if resourceScale then
    self.resourceScale = resourceScale
  end
  if npc_round_tip_scale then
    self.npc_round_tip_scale = npc_round_tip_scale
  end
end

function BattleNpc:GetDialogBoxRenderScale()
  local npc_round_tip_scale = self.npc_round_tip_scale or 1
  local FVector2D = UE.FVector2D
  local renderScale = FVector2D(npc_round_tip_scale, npc_round_tip_scale)
  return renderScale
end

function BattleNpc:SetBattleCrowdOnLookerInfo(crowdInfo, resourceScale)
  if self.type == BattleNpc.Type.CrowdOnLooker then
    self.attachPoint = _G.BattleManager.vBattleField.battleFieldActor
    local model = crowdInfo and crowdInfo.crowdNpcModel
    self.model = model
    if model then
      self.name = model:GetName()
    end
  end
  if resourceScale then
    self.resourceScale = resourceScale
  end
end

function BattleNpc:PostInit()
  Base.PostInit(self)
  if self.type == BattleNpc.Type.SingleOnLooker then
    self:CheckAndPrepareMutation()
    local positionOk, errorMessage = self:InitPosition()
    if not positionOk then
      return false, errorMessage
    end
    local status, messageOrResult = a.wait(self:InitOutSceneAsyncTask())
    if not status then
      Log.Error("BattleNpc:Init InitOutScene error", messageOrResult)
    end
    self:CheckAndDoMutation()
    self:LoadBPComponents()
    self:InitAnimationNameList()
    self:ChangePerformState(BattleNpc.PerformState.Idle)
  end
  self:SetModelMeshScaleByPercentage(self.resourceScale)
  return true
end

function BattleNpc:GetModelPath()
  if self.type == BattleNpc.Type.SingleOnLooker then
    local npc_conf_id = self.npcInfo and self.npcInfo.npc_conf_id
    local npcConf = npc_conf_id and _G.DataConfigManager:GetNpcConf(self.npcInfo.npc_conf_id, true)
    local modelConfig = npcConf and _G.DataConfigManager:GetModelConf(npcConf.model_conf, true)
    local resourcePath = modelConfig and modelConfig.path
    self.name = modelConfig and modelConfig.editor_name or ""
    return resourcePath
  elseif self.type == BattleNpc.Type.CrowdOnLooker then
    local resourcePath = BattleConst.BattleCrowdOnLookerPath
    return resourcePath
  end
  return nil
end

function BattleNpc:GetId()
  return self.npcInfo.id
end

function BattleNpc:InitAnimationNameList()
  local animationNameListString1 = _G.DataConfigManager:GetBattleGlobalConfig("around_npc_animation_name1").str or ""
  local animationNameList1 = string.split(animationNameListString1, ";")
  local animationNameListString2 = _G.DataConfigManager:GetBattleGlobalConfig("around_npc_animation_name2").str or ""
  local animationNameList2 = string.split(animationNameListString2, ";")
  local animationNameListString3 = _G.DataConfigManager:GetBattleGlobalConfig("around_npc_animation_name3").str or ""
  local animationNameList3 = string.split(animationNameListString3, ";")
  local model = self.model
  local animComponent = UE.UObject.IsValid(model) and model:GetAnimComponent()
  for i, name in ipairs(animationNameList1) do
    local hasAnimationWithAnimName = UE.UObject.IsValid(animComponent) and animComponent:HasAnimation(name)
    if hasAnimationWithAnimName then
      table.insert(self.selectStateAnimationNameList1, name)
    end
  end
  for i, name in ipairs(animationNameList2) do
    local hasAnimationWithAnimName = UE.UObject.IsValid(animComponent) and animComponent:HasAnimation(name)
    if hasAnimationWithAnimName then
      table.insert(self.selectStateAnimationNameList2, name)
    end
  end
  for i, name in ipairs(animationNameList3) do
    local hasAnimationWithAnimName = UE.UObject.IsValid(animComponent) and animComponent:HasAnimation(name)
    if hasAnimationWithAnimName then
      table.insert(self.selectStateAnimationNameList3, name)
    end
  end
end

function BattleNpc:PostShowWithFadeAndAnim()
  self:ChangePerformState(BattleNpc.PerformState.Idle)
end

function BattleNpc:UpdateDialogBox(text, type)
  if self.battlePlayerComponents then
    self.battlePlayerComponents:UpdateDialogBoxUI(text, type)
  end
end

function BattleNpc:ShowDialogBox()
  if self.battlePlayerComponents then
    self.battlePlayerComponents:ShowDialogBoxUI()
  end
end

function BattleNpc:GetDialogBoxType()
  if self.battlePlayerComponents then
    return self.battlePlayerComponents:GetDialogBoxUIType()
  end
end

function BattleNpc:HideDialogBox()
  if self.battlePlayerComponents then
    self.battlePlayerComponents:HideDialogBoxUI()
  end
end

function BattleNpc:TryNextAiPerformAsyncTask(aiPerformTask)
  if self.destroyed then
    return
  end
  table.insert(self.aiPerformAsyncTaskWaitingList, aiPerformTask)
  self:ChangePerformState(BattleNpc.PerformState.AiPerform)
  if self.performAsyncTaskListAsyncContext == nil then
    self.performAsyncTaskListAsyncContext = au.Launch(BattleNpc.StartAiPerform(self), function(ok, messageOrResult)
      if not ok then
        Log.Error(messageOrResult)
      else
        Log.Debug("BattleNpc:TryNextAiPerformAsyncTask async operation completed")
      end
      self.performAsyncTaskListAsyncContext = nil
      self.isDoingBattlePerform = false
      self:ChangePerformState(BattleNpc.PerformState.Idle)
    end)
  end
end

local function StartAiPerform(self)
  self.isDoingBattlePerform = true
  a.wait(au.DelayFrames(1))
  local delayBeforePerformConfig = _G.DataConfigManager:GetBattleGlobalConfig("around_npc_animation_battle_actime_random_deviation", true)
  local random_deviation = delayBeforePerformConfig and delayBeforePerformConfig.num
  random_deviation = tonumber(random_deviation) or 0
  while #self.aiPerformAsyncTaskWaitingList > 0 do
    local aiPerformAsyncTaskWaitingListCache = {}
    for i, thunk in ipairs(self.aiPerformAsyncTaskWaitingList) do
      table.insert(aiPerformAsyncTaskWaitingListCache, thunk)
    end
    self.aiPerformAsyncTaskWaitingList = {}
    for i, thunk in ipairs(aiPerformAsyncTaskWaitingListCache) do
      local random_deviation_seconds = math.rand(0, random_deviation) / 1000
      a.wait(au.DelaySeconds(random_deviation_seconds))
      a.wait(thunk)
      a.wait(au.DelayFrames(1))
    end
    a.wait(au.DelayFrames(1))
  end
  self.isDoingBattlePerform = false
end

BattleNpc.StartAiPerform = a.sync(StartAiPerform)

local function TryPerformDialogTask(self, str_param)
  self:UpdateDialogBox(str_param)
  self:ShowDialogBox()
  local time = _G.DataConfigManager:GetGlobalConfigNumByKeyType("texbox_show_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 1000) / 1000
  if time > 0 then
    a.wait(au.DelaySeconds(time))
  end
  self:HideDialogBox()
end

function BattleNpc:TryPerformDialog(str_param)
  local task = a.sync(TryPerformDialogTask)
  self:TryNextAiPerformAsyncTask(task(self, str_param))
end

local function PerformActTask(self, type, callback)
  self.BubbleComponent:Play(nil, type, nil, callback)
end

function BattleNpc:TryPerformAct(type)
  if self.type == BattleNpc.Type.SingleOnLooker then
    local aTask = a.wrap(PerformActTask)
    self:TryNextAiPerformAsyncTask(aTask(self, type))
  elseif self.type == BattleNpc.Type.CrowdOnLooker and self.OnLookerCrowdShowComponent then
    self.OnLookerCrowdShowComponent:PlayEmotion(type, nil, function(ok, errorMessage)
      if not ok then
        Log.Error("BattleNpc:TryPerformAct callback error", errorMessage)
      end
    end)
  end
end

function BattleNpc:SetModelMeshScaleByPercentage(percentage)
  if self.model:IsA(UE.ACharacter) then
    UE.UNRCCharacterUtils.SetCharacterMeshScale(self.model, percentage)
    self:PinOnTheGround()
  else
  end
end

function BattleNpc:ChangePerformState(newState)
  local previousState = self.performState
  self:ExitPerformState(previousState)
  self.performState = newState
  self:EnterPerformState(newState)
end

function BattleNpc:EnterPerformState(state)
  if state == BattleNpc.PerformState.PlaySelectStateAnimation then
    self:PlayRoundSelectAnimation()
  elseif state == BattleNpc.PerformState.Idle then
    self:TryStartPlayIdleAnimation()
  elseif state == BattleNpc.PerformState.AiPerform and self.tryNextRoundPlayAnimDelayHandler then
    _G.DelayManager:CancelDelayById(self.tryNextRoundPlayAnimDelayHandler)
    self.tryNextRoundPlayAnimDelayHandler = nil
  end
end

function BattleNpc:ExitPerformState(state)
  if state == BattleNpc.PerformState.Idle then
    if self.waitForIdleAnimCompleteDelayHandler then
      _G.DelayManager:CancelDelayById(self.waitForIdleAnimCompleteDelayHandler)
      self.waitForIdleAnimCompleteDelayHandler = nil
    end
  elseif state == BattleNpc.PerformState.PlaySelectStateAnimation then
    if self.waitForRoundPlayAnimCompleteDelayHandler then
      _G.DelayManager:CancelDelayById(self.waitForRoundPlayAnimCompleteDelayHandler)
      self.waitForRoundPlayAnimCompleteDelayHandler = nil
    end
  elseif state == BattleNpc.PerformState.AiPerform and self.performAsyncTaskListAsyncContext then
    a.kill(self.performAsyncTaskListAsyncContext)
    self.performAsyncTaskListAsyncContext = nil
  end
end

function BattleNpc:TryStartPlayIdleAnimation()
  if not self.performState == BattleNpc.PerformState.Idle then
    return false
  end
  if self:IsPlayingSelectStateAnim() then
    return false
  end
  if self:CanPlayRoundSelectAnimation() then
    self:TryPlaySelectStateAnimation()
    return false
  end
  self:PlayIdleAnimation()
  return true
end

function BattleNpc:PlayIdleAnimation()
  local animName
  if #self.selectStateAnimationNameList3 > 0 then
    local randomIndex = math.random(#self.selectStateAnimationNameList3)
    animName = self.selectStateAnimationNameList3[randomIndex]
  end
  local model = self.model
  local animComponent = UE.UObject.IsValid(model) and model:GetAnimComponent()
  local hasAnimationWithAnimName = UE.UObject.IsValid(animComponent) and animComponent:HasAnimation(animName)
  if animName and not hasAnimationWithAnimName then
    animName = nil
  end
  local delayCompleteSeconds = 0
  if animName then
    self.model.RocoAnim:StopAllMontage()
    delayCompleteSeconds = self.model:PlayAnimByName(animName)
  end
  if self.waitForIdleAnimCompleteDelayHandler ~= nil then
    _G.DelayManager:CancelDelayById(self.waitForIdleAnimCompleteDelayHandler)
    self.waitForIdleAnimCompleteDelayHandler = nil
  end
  if delayCompleteSeconds > 0 then
    self.waitForIdleAnimCompleteDelayHandler = _G.DelayManager:DelaySeconds(delayCompleteSeconds, self.OnIdleAnimationFinished, self)
  else
    self.waitForIdleAnimCompleteDelayHandler = _G.DelayManager:DelayFrames(1, self.OnIdleAnimationFinished, self)
  end
end

function BattleNpc:OnIdleAnimationFinished()
  self.waitForIdleAnimCompleteDelayHandler = nil
  self:TryStartPlayIdleAnimation()
end

function BattleNpc:TryPlaySelectStateAnimation()
  if self:CanPlayRoundSelectAnimation() then
    self:ChangePerformState(BattleNpc.PerformState.PlaySelectStateAnimation)
    return true
  end
  return false
end

function BattleNpc:OnNextPlayRoundSelectAnimationTimer()
  self.tryNextRoundPlayAnimDelayHandler = nil
  self:TryPlaySelectStateAnimation()
end

function BattleNpc:CanPlayRoundSelectAnimation()
  local currentBattleStateName = _G.BattleManager:GetCurrentStateName()
  if currentBattleStateName ~= BattleEnum.StateNames.RoundSelect and currentBattleStateName ~= BattleEnum.StateNames.SwapSelect then
    return false
  end
  if self.tryNextRoundPlayAnimDelayHandler ~= nil then
    return false
  end
  if self.performState == BattleNpc.PerformState.Idle then
    return true
  end
  return false
end

function BattleNpc:GetNextRandomPlayRoundSelectAnimDelaySeconds()
  local showTimeIntervalConfig = _G.DataConfigManager:GetBattleGlobalConfig("npc_show_time interval")
  local showTimeInterval = showTimeIntervalConfig and showTimeIntervalConfig.num or 0
  local showTimeIntervalRandomDeviationConfig = _G.DataConfigManager:GetBattleGlobalConfig("npc_show_time interval_random_deviation")
  local showTimeIntervalRandomDeviation = showTimeIntervalRandomDeviationConfig and showTimeIntervalRandomDeviationConfig.num or 0
  local min = showTimeInterval - showTimeIntervalRandomDeviation
  local max = showTimeInterval + showTimeIntervalRandomDeviation
  local nextPlayDelay = min + math.random() * (max - min)
  return nextPlayDelay
end

function BattleNpc:PlayRoundSelectAnimation()
  if self:IsPlayingSelectStateAnim() then
    _G.DelayManager:CancelDelayById(self.waitForRoundPlayAnimCompleteDelayHandler)
  end
  local animName
  if #self.selectStateAnimationNameList1 > 0 then
    local randomIndex = math.random(#self.selectStateAnimationNameList1)
    animName = self.selectStateAnimationNameList1[randomIndex]
  end
  if not animName and #self.selectStateAnimationNameList2 > 0 then
    local randomIndex = math.random(#self.selectStateAnimationNameList2)
    animName = self.selectStateAnimationNameList2[randomIndex]
  end
  local model = self.model
  local animComponent = UE.UObject.IsValid(model) and model:GetAnimComponent()
  local hasAnimationWithAnimName = UE.UObject.IsValid(animComponent) and animComponent:HasAnimation(animName)
  if animName and not hasAnimationWithAnimName then
    animName = nil
  end
  local delayCompleteSeconds = 0
  if animName and UE.UObject.IsValid(self.model) then
    delayCompleteSeconds = self.model:PlayAnimByName(animName)
  end
  if delayCompleteSeconds > 0 then
    self.waitForRoundPlayAnimCompleteDelayHandler = _G.DelayManager:DelaySeconds(delayCompleteSeconds, self.OnSelectStateAnimationFinished, self)
  else
    self.waitForRoundPlayAnimCompleteDelayHandler = _G.DelayManager:DelayFrames(1, self.OnSelectStateAnimationFinished, self)
  end
  if self.tryNextRoundPlayAnimDelayHandler ~= nil then
    _G.DelayManager:CancelDelayById(self.tryNextRoundPlayAnimDelayHandler)
    self.tryNextRoundPlayAnimDelayHandler = nil
  end
  local nextPlayDelay = self:GetNextRandomPlayRoundSelectAnimDelaySeconds()
  self.tryNextRoundPlayAnimDelayHandler = _G.DelayManager:DelaySeconds(nextPlayDelay, self.OnNextPlayRoundSelectAnimationTimer, self)
end

function BattleNpc:OnSelectStateAnimationFinished()
  self.waitForRoundPlayAnimCompleteDelayHandler = nil
  if self.performState == BattleNpc.PerformState.PlaySelectStateAnimation then
    self:ChangePerformState(BattleNpc.PerformState.Idle)
  end
end

function BattleNpc:IsPlayingSelectStateAnim()
  return self.waitForRoundPlayAnimCompleteDelayHandler ~= nil
end

function BattleNpc:IsPlayingIdleAnim()
  return self.waitForIdleAnimCompleteDelayHandler ~= nil
end

function BattleNpc:GetMutationPetDataFromNPCInfo()
  if self.npcInfo and self.npcInfo.monster then
    local monsterInfo = self.npcInfo.monster
    local mutationPetData = {
      mutation_type = monsterInfo.mutation_type,
      nature = monsterInfo.nature,
      glass_info = monsterInfo.glass_info,
      base_conf_id = monsterInfo.base_conf_id
    }
    return mutationPetData
  end
  return nil
end

function BattleNpc:CheckAndPrepareMutation()
  local mutationPetData = self:GetMutationPetDataFromNPCInfo()
  if mutationPetData and self.model then
    PetMutationUtils.PrepareMutationAssets(self.model, mutationPetData)
  end
end

function BattleNpc:CheckAndDoMutation()
  local mutationPetData = self:GetMutationPetDataFromNPCInfo()
  if self.model and mutationPetData then
    PetMutationUtils.DoMutation(self.model, mutationPetData)
  end
end

function BattleNpc:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_SELECT_START or eventName == BattleEvent.SWAP_SELECT_START then
    self:TryPlaySelectStateAnimation()
  end
end

function BattleNpc:Destroy()
  Log.Info("BattleNpc:Destroy", self.name)
  if self.destroyed then
    return
  end
  _G.BattleEventCenter:UnBind(self)
  if self.performAsyncTaskListAsyncContext then
    a.kill(self.performAsyncTaskListAsyncContext)
    self.performAsyncTaskListAsyncContext = nil
  end
  if self.waitForIdleAnimCompleteDelayHandler then
    _G.DelayManager:CancelDelayById(self.waitForIdleAnimCompleteDelayHandler)
    self.waitForIdleAnimCompleteDelayHandler = nil
  end
  if self.tryNextRoundPlayAnimDelayHandler then
    _G.DelayManager:CancelDelayById(self.tryNextRoundPlayAnimDelayHandler)
    self.tryNextRoundPlayAnimDelayHandler = nil
  end
  if self.waitForRoundPlayAnimCompleteDelayHandler then
    _G.DelayManager:CancelDelayById(self.waitForRoundPlayAnimCompleteDelayHandler)
    self.waitForRoundPlayAnimCompleteDelayHandler = nil
  end
  local shouldDestroyModel = self.type ~= BattleNpc.Type.CrowdOnLooker
  if UE.UObject.IsValid(self.model) and shouldDestroyModel then
    self.model:K2_DestroyActor()
  end
  self.model = nil
  Base.Destroy(self)
end

return BattleNpc
