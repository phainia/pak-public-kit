local VideoModule = NRCModuleBase:Extend("VideoModule")
local VideoModuleEvent = require("NewRoco.Modules.System.MediaPlayer.VideoModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")

function VideoModule:OnConstruct()
  _G.VideoModuleCmd = reload("NewRoco.Modules.System.MediaPlayer.VideoModuleCmd")
  self.testConfig = {}
  self.actors = {}
  self:RegPanel("FullScreenVideo", "/Game/NewRoco/Modules/System/MediaPlayer/UMG_Video", Enum.UILayerType.UI_LAYER_DIALOGUE)
end

function VideoModule:RegPanel(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = path
  registerData.panelLayer = layer or _G.Enum.UILayerType.UI_LAYER_DIALOGUE
  registerData.enablePcEsc = false
  self:RegisterPanel(registerData)
end

function VideoModule:NewConfig(a, b, c, d, e, f)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  return {
    Location = UE4.FVector(a or 0, b or 0, c or 0),
    Rotation = UE4.FRotator(d or 0, e or 0, f or 0)
  }
end

function VideoModule:OnOpenMainPanel(Callback, Caller)
  self:OpenPanel("FullScreenVideo", Callback, Caller)
end

function VideoModule:OnCloseAllPanel()
  self:CloseAllPanel()
end

function VideoModule:OnActive()
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(444709, 668294, 1603.15, 0, 121.56, -179))
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(441809, 668394, 3383, 0, -141.45, -179))
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(440159, 670614, 1963.15, 0, 120, -179))
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(443499, 668534, 2013.15, 0, -170, -179))
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(442339, 670964, 1963.15, 0, -10, -179))
  table.insert(self.testConfig, #self.testConfig + 1, self:NewConfig(443499, 670274, 2013.15, 0, -29, -179))
end

function VideoModule:StartAllVideos()
  Log.Error("start all videos")
  for _, actor in pairs(self.actors) do
    actor:StartVideo()
  end
end

function VideoModule:StopAllVideos()
  for _, actor in pairs(self.actors) do
    actor:StopVideo()
  end
end

function VideoModule:PauseAllVideos()
  for _, actor in pairs(self.actors) do
    actor:PauseVideo()
  end
end

function VideoModule:ResumeAllVideos()
  for _, actor in pairs(self.actors) do
    actor:ResumeVideo()
  end
end

function VideoModule:CreateSingleTestActor(Klass, Location, Rotation, idx)
  local fTransfom = UE4.FTransform()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  fTransfom.Translation = Location
  local actor = UE4Helper.GetCurrentWorld():Abs_SpawnActor(Klass, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, nil)
  actor:K2_SetActorRotation(Rotation, false)
  actor:SetIndex(idx - 1)
  return actor
end

function VideoModule:CreateAllTestActors()
  self:DeleteAllTestActors()
  local testActorClass = UE4.UClass.Load("/Game/NewRoco/Modules/System/MediaPlayer/testVideoScreenActor.testVideoScreenActor")
  for i, item in pairs(self.testConfig) do
    local actor = self:CreateSingleTestActor(testActorClass, item.Location, item.Rotation, i)
    table.insert(self.actors, actor)
  end
end

function VideoModule:DeleteAllTestActors()
  for _, actor in pairs(self.actors) do
    actor:DoDestroy()
  end
end

function VideoModule:OnDestruct()
end

return VideoModule
