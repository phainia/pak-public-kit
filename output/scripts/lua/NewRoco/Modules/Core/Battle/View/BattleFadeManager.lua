local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleFadeManager = NRCClass()
BattleFadeManager.DefaultOriginalAlpha = 1
BattleFadeManager.DefaultLerpSpeed = 2

function BattleFadeManager:Ctor()
  self.fadeRules = {}
  self.internalTargetFadeInfoMap = {}
  self.fadeRuleMaxId = 0
  self.actorsReachedTargetAlphaLastFrame = {}
  self.targetFadeInfoMap = {}
  self.actorsReachedTargetAlphaThisFrame = {}
  self.lastInternalTargetFadeInfoMap = {}
end

function BattleFadeManager:OnTick(deltaTime)
  table.clear(self.actorsReachedTargetAlphaThisFrame)
  table.clear(self.targetFadeInfoMap)
  table.clear(self.lastInternalTargetFadeInfoMap)
  table.deepCopy(self.internalTargetFadeInfoMap, self.lastInternalTargetFadeInfoMap)
  for id, fadeRuleFn in pairs(self.fadeRules) do
    local fadeContext = {}
    local additionalTargetFadeInfo = fadeRuleFn(fadeContext)
    if additionalTargetFadeInfo then
      for actor, targetFadeInfo in pairs(additionalTargetFadeInfo) do
        if actor:IsA(UE.AActor) then
          self.targetFadeInfoMap[actor] = targetFadeInfo
        end
      end
    end
  end
  for actor, fadeInfoItem in pairs(self.targetFadeInfoMap) do
    if actor then
      local currentAlpha
      if self.internalTargetFadeInfoMap[actor] then
        currentAlpha = self.internalTargetFadeInfoMap[actor].targetAlpha
      elseif fadeInfoItem.originalAlpha ~= nil then
        currentAlpha = fadeInfoItem.originalAlpha
      else
        currentAlpha = BattleFadeManager.DefaultOriginalAlpha
      end
      local lerpSpeed
      if nil ~= fadeInfoItem.lerpSpeed then
        lerpSpeed = fadeInfoItem.lerpSpeed
      else
        lerpSpeed = BattleFadeManager.DefaultLerpSpeed
      end
      self.internalTargetFadeInfoMap[actor] = fadeInfoItem
      self.internalTargetFadeInfoMap[actor].targetAlpha = self:LerpAlpha(currentAlpha, fadeInfoItem.targetAlpha, deltaTime * lerpSpeed)
    end
  end
  local maskRemove = {}
  for actor, fadeInfoItem in pairs(self.internalTargetFadeInfoMap) do
    if self.targetFadeInfoMap[actor] == nil then
      local defaultAlpha = 1
      if nil ~= fadeInfoItem.defaultAlpha then
        defaultAlpha = fadeInfoItem.defaultAlpha
      end
      local lerpSpeed
      if nil ~= fadeInfoItem.lerpSpeed then
        lerpSpeed = fadeInfoItem.lerpSpeed
      else
        lerpSpeed = BattleFadeManager.DefaultLerpSpeed
      end
      self.internalTargetFadeInfoMap[actor].targetAlpha = self:LerpAlpha(fadeInfoItem.targetAlpha, defaultAlpha, deltaTime * lerpSpeed)
      if self.internalTargetFadeInfoMap[actor].targetAlpha == defaultAlpha then
        maskRemove[actor] = true
      end
    end
  end
  for actor, fadeInfoItem in pairs(self.internalTargetFadeInfoMap) do
    if self.lastInternalTargetFadeInfoMap[actor] == nil or self.lastInternalTargetFadeInfoMap[actor].targetAlpha ~= fadeInfoItem.targetAlpha then
      self:SetMeshFade(actor, fadeInfoItem.targetAlpha)
    else
      table.insert(self.actorsReachedTargetAlphaThisFrame, actor)
    end
  end
  for mesh, _ in pairs(maskRemove) do
    self.internalTargetFadeInfoMap[mesh] = nil
  end
  for i, actor in ipairs(self.actorsReachedTargetAlphaThisFrame) do
    if not self:IsFadeObjectReachedLastFrame(actor) then
      _G.BattleEventCenter:Dispatch(BattleEvent.FADE_OBJECT_REACH_TARGET_ALPHA, actor)
    end
  end
  table.clear(self.actorsReachedTargetAlphaLastFrame)
  for i, actor in ipairs(self.actorsReachedTargetAlphaThisFrame) do
    table.insert(self.actorsReachedTargetAlphaLastFrame, actor)
  end
end

function BattleFadeManager:LerpAlpha(currentAlpha, targetAlpha, deltaValue)
  if currentAlpha == targetAlpha then
    return currentAlpha
  end
  if targetAlpha < currentAlpha then
    currentAlpha = currentAlpha - deltaValue
    currentAlpha = math.max(currentAlpha, targetAlpha, 0)
    return currentAlpha
  end
  if targetAlpha > currentAlpha then
    currentAlpha = currentAlpha + deltaValue
    currentAlpha = math.min(currentAlpha, targetAlpha, 1)
    return currentAlpha
  end
end

function BattleFadeManager:SetMeshFade(actor, alpha)
  if not self.internalTargetFadeInfoMap[actor] then
    return
  end
  self.internalTargetFadeInfoMap[actor].targetAlpha = alpha
  if actor.SetFadeAlpha then
    actor:SetFadeAlpha(1 - alpha)
  elseif actor.SetMeshAlpha then
    actor:SetMeshAlpha(1 - alpha)
  end
end

function BattleFadeManager:ApplyFadeRule(fadeRuleFn)
  self.fadeRuleMaxId = self.fadeRuleMaxId + 1
  local id = self.fadeRuleMaxId
  self.fadeRules[id] = fadeRuleFn
  return id
end

function BattleFadeManager:RemoveFadeRule(id)
  if self.fadeRules[id] then
    self.fadeRules[id] = nil
  end
end

function BattleFadeManager:LeaveBattle()
  self.fadeRules = {}
  self.internalTargetFadeInfoMap = {}
end

function BattleFadeManager:IsFadeObjectReachedLastFrame(fadeObject)
  if not UE4.UObject.IsValid(fadeObject) then
    return false
  end
  for i, actor in ipairs(self.actorsReachedTargetAlphaLastFrame) do
    if actor == fadeObject then
      return true
    end
  end
  return false
end

return BattleFadeManager
