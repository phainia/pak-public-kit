local VideoModuleHead = NRCModuleHeadBase:Extend("VideoModuleHead")

function VideoModuleHead:OnConstruct()
  _G.VideoModuleCmd = reload("NewRoco.Modules.System.MediaPlayer.VideoModuleCmd")
  self:BindCmd(_G.VideoModuleCmd.OpenMainPanel, "OnOpenMainPanel")
  self:BindCmd(_G.VideoModuleCmd.CloseAllPanel, "OnCloseAllPanel")
  self:BindCmd(_G.VideoModuleCmd.StartAllVideos, "StartAllVideos")
  self:BindCmd(_G.VideoModuleCmd.StopAllVideos, "StopAllVideos")
  self:BindCmd(_G.VideoModuleCmd.PauseAllVideos, "PauseAllVideos")
  self:BindCmd(_G.VideoModuleCmd.ResumeAllVideos, "ResumeAllVideos")
  self:BindCmd(_G.VideoModuleCmd.CreateAllTestActors, "CreateAllTestActors")
  self:BindCmd(_G.VideoModuleCmd.DeleteAllTestActors, "DeleteAllTestActors")
end

return VideoModuleHead
