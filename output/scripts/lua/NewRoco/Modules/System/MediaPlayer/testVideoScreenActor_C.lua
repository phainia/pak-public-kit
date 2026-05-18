require("UnLuaEx")
local testVideoScreenActor_C = NRCClass()

function testVideoScreenActor_C:StartVideo()
  self.MediaPlayer:SetLooping(true)
  self.MediaPlayer:OpenSource(self.videoAsset)
end

function testVideoScreenActor_C:StopVideo()
  self.MediaPlayer:Close()
end

function testVideoScreenActor_C:PauseVideo()
  self.MediaPlayer:Pause()
end

function testVideoScreenActor_C:ResumeVideo()
  self.MediaPlayer:Play()
end

return testVideoScreenActor_C
