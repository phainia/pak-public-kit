local Class = _G.MakeSimpleClass
local LoopAudioPlayer = Class("LoopAudioPlayer")

function LoopAudioPlayer:Ctor(soundId)
  self.soundId = soundId
  self.session = -1
  self.playing = false
end

function LoopAudioPlayer:Play()
  if not self.playing then
    self.playing = true
    self:InnerPlay()
  end
end

function LoopAudioPlayer:InnerPlay()
  self.session = _G.NRCAudioManager:PlaySound2DAuto(self.soundId, "LoopAudioPlayer:Play")
  _G.NRCAudioManager:AddSessionFinishCallback(self.session, self, self.OnAudioStopped)
end

function LoopAudioPlayer:OnAudioStopped()
  if self.playing then
    Log.Debug("LoopAudioPlayer:OnAudioStopped \231\167\189\229\156\159\232\189\172\231\148\159!", self.soundId)
    self:InnerPlay()
  end
end

function LoopAudioPlayer:Stop()
  self.playing = false
  _G.NRCAudioManager:ReleaseSession(self.session, true, "LoopAudioPlayer:Stop")
  self.session = -1
end

return LoopAudioPlayer
