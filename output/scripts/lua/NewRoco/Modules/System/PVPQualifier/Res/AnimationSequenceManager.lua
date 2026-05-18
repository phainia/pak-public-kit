local Base = NRCClass
local AnimationSequenceManager = Base:Extend("AnimationSequenceManager")

function AnimationSequenceManager:Ctor(ownerPanel)
  Base.Ctor(self)
  self.ownerPanel = ownerPanel
  self.animationSequence = {}
  self.currentAnimationIndex = 0
  self.isSequencePlaying = false
  self.sequenceCompleteCallback = nil
end

function AnimationSequenceManager:OnDestruct()
  self:StopAnimationSequence()
end

function AnimationSequenceManager:PlayAnimationSequence(animations, onComplete)
  if not animations or 0 == #animations then
    Log.Warning("AnimationSequenceManager:PlayAnimationSequence - animations is empty")
    if onComplete then
      onComplete()
    end
    return
  end
  if self.isSequencePlaying then
    self:StopAnimationSequence()
  end
  self.animationSequence = animations
  self.currentAnimationIndex = 0
  self.isSequencePlaying = true
  self.sequenceCompleteCallback = onComplete
  self:PlayNextAnimationInSequence()
end

function AnimationSequenceManager:PlayNextAnimationInSequence()
  if not self.isSequencePlaying then
    return
  end
  self.currentAnimationIndex = self.currentAnimationIndex + 1
  if self.currentAnimationIndex > #self.animationSequence then
    self:OnAnimationSequenceComplete()
    return
  end
  local currentAnimConfig = self.animationSequence[self.currentAnimationIndex]
  if currentAnimConfig then
    local animationName, isLoop
    if type(currentAnimConfig) == "string" then
      animationName = currentAnimConfig
      isLoop = false
    elseif type(currentAnimConfig) == "table" then
      animationName = currentAnimConfig.animation
      isLoop = currentAnimConfig.loop or false
    else
      Log.Error(string.format("AnimationSequenceManager:Invalid animation config at index %d", self.currentAnimationIndex))
      self:PlayNextAnimationInSequence()
      return
    end
    Log.Debug(string.format("AnimationSequenceManager:Playing animation %d/%d: %s (loop: %s)", self.currentAnimationIndex, #self.animationSequence, animationName, tostring(isLoop)))
    local animObj = self.ownerPanel[animationName]
    if not animObj then
      Log.Error(string.format("AnimationSequenceManager:Animation object '%s' not found on panel", animationName))
      self:PlayNextAnimationInSequence()
      return
    end
    if isLoop then
      self.ownerPanel:PlayAnimation(animObj, 0, 0)
    else
      self.ownerPanel:PlayAnimation(animObj)
    end
  else
    Log.Error(string.format("AnimationSequenceManager:Invalid animation at index %d", self.currentAnimationIndex))
    self:PlayNextAnimationInSequence()
  end
end

function AnimationSequenceManager:OnAnimationSequenceComplete()
  Log.Debug("AnimationSequenceManager:Animation sequence completed")
  self.isSequencePlaying = false
  self.currentAnimationIndex = 0
  self.animationSequence = {}
  if self.sequenceCompleteCallback then
    local callback = self.sequenceCompleteCallback
    self.sequenceCompleteCallback = nil
    callback()
  end
end

function AnimationSequenceManager:StopAnimationSequence()
  if self.isSequencePlaying then
    Log.Debug("AnimationSequenceManager:Stopping animation sequence")
    self:StopCurrentAnimation()
    self.isSequencePlaying = false
    self.currentAnimationIndex = 0
    self.animationSequence = {}
    self.sequenceCompleteCallback = nil
  end
end

function AnimationSequenceManager:StopCurrentAnimation()
  if not self.isSequencePlaying or 0 == self.currentAnimationIndex or self.currentAnimationIndex > #self.animationSequence then
    return
  end
  local currentAnimConfig = self.animationSequence[self.currentAnimationIndex]
  local currentAnimName = currentAnimConfig
  if type(currentAnimConfig) == "table" then
    currentAnimName = currentAnimConfig.animation
  elseif type(currentAnimConfig) ~= "string" then
    Log.Error(string.format("AnimationSequenceManager:Invalid animation config at index %d", self.currentAnimationIndex))
    return
  end
  local animObj = self.ownerPanel[currentAnimName]
  if animObj then
    self.ownerPanel:StopAnimation(animObj)
    Log.Debug(string.format("AnimationSequenceManager:Stopped current animation '%s'", currentAnimName))
  else
    Log.Error(string.format("AnimationSequenceManager:Animation object '%s' not found on panel", currentAnimName))
  end
end

function AnimationSequenceManager:IsPlayingAnimationSequence()
  return self.isSequencePlaying
end

function AnimationSequenceManager:GetAnimationSequenceInfo()
  return {
    isPlaying = self.isSequencePlaying,
    currentIndex = self.currentAnimationIndex,
    totalCount = #self.animationSequence,
    remainingCount = self.isSequencePlaying and #self.animationSequence - self.currentAnimationIndex or 0
  }
end

function AnimationSequenceManager:GetCurrentAnimationInfo()
  if not self.isSequencePlaying or 0 == self.currentAnimationIndex or self.currentAnimationIndex > #self.animationSequence then
    return nil
  end
  local currentAnimConfig = self.animationSequence[self.currentAnimationIndex]
  if type(currentAnimConfig) == "table" then
    return currentAnimConfig.animation
  elseif type(currentAnimConfig) == "string" then
    return currentAnimConfig
  else
    return nil
  end
end

function AnimationSequenceManager:SkipCurrentAnimation()
  if self.isSequencePlaying then
    Log.Debug("AnimationSequenceManager:Skipping current animation")
    self:PlayNextAnimationInSequence()
  end
end

function AnimationSequenceManager:InsertAnimationAfterCurrent(animation)
  if not self.isSequencePlaying then
    Log.Warning("AnimationSequenceManager:Cannot insert animation when sequence is not playing")
    return
  end
  local insertIndex = self.currentAnimationIndex + 1
  table.insert(self.animationSequence, insertIndex, animation)
  local animName = animation
  if "table" == type(animation) then
    animName = animation.animation
  end
  Log.Debug(string.format("AnimationSequenceManager:Inserted animation '%s' at index %d", animName, insertIndex))
end

function AnimationSequenceManager:InsertAnimationAtEnd(animation)
  table.insert(self.animationSequence, animation)
  local animName = animation
  if "table" == type(animation) then
    animName = animation.animation
  end
  Log.Debug(string.format("AnimationSequenceManager:Appended animation '%s' to sequence end", animName))
end

function AnimationSequenceManager:OnAnimationFinished(animObj)
  if not self.isSequencePlaying or 0 == self.currentAnimationIndex or self.currentAnimationIndex > #self.animationSequence then
    return
  end
  if not animObj then
    return
  end
  local currentAnimConfig = self.animationSequence[self.currentAnimationIndex]
  local currentAnimName = currentAnimConfig
  if type(currentAnimConfig) == "table" then
    currentAnimName = currentAnimConfig.animation
  elseif type(currentAnimConfig) ~= "string" then
    Log.Error(string.format("AnimationSequenceManager:Invalid animation config at index %d", self.currentAnimationIndex))
    return
  end
  local curAnimObj = self.ownerPanel[currentAnimName]
  if animObj ~= curAnimObj then
    return
  end
  local isLoop = false
  if type(currentAnimConfig) == "table" then
    isLoop = currentAnimConfig.loop or false
  end
  if isLoop then
    Log.Debug(string.format("AnimationSequenceManager:Loop animation '%s' finished, but not playing next", currentAnimName))
    return
  end
  Log.Debug(string.format("AnimationSequenceManager:Animation '%s' finished, playing next", currentAnimName))
  self:PlayNextAnimationInSequence()
end

function AnimationSequenceManager:PauseAnimationSequence()
  if self.isSequencePlaying then
    Log.Debug("AnimationSequenceManager:Animation sequence paused (note: actual pause requires external implementation)")
  end
end

function AnimationSequenceManager:ResumeAnimationSequence()
  if self.isSequencePlaying then
    Log.Debug("AnimationSequenceManager:Animation sequence resumed")
  end
end

return AnimationSequenceManager
