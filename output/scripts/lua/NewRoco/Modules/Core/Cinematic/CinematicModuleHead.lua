local CinematicModuleHead = NRCModuleHeadBase:Extend("CinematicModuleHead")

function CinematicModuleHead:OnConstruct()
  _G.CinematicModuleCmd = reload("NewRoco.Modules.Core.Cinematic.CinematicModuleCmd")
  self:BindCmd(_G.CinematicModuleCmd.OpenLoading, "OnOpenLoad")
  self:BindCmd(_G.CinematicModuleCmd.CloseCinematic, "OnCloseCinematic")
  self:BindCmd(_G.CinematicModuleCmd.StartCinematic, "OnStartCinematic")
  self:BindCmd(_G.CinematicModuleCmd.PlayCinematic, "OnPlayCinematic")
  self:BindCmd(_G.CinematicModuleCmd.IsPlaying, "GetIsPlaying")
  self:BindCmd(_G.CinematicModuleCmd.OnSyncCinematic, "OnSyncCinematic")
  self:BindCmd(_G.CinematicModuleCmd.CloseBlackScreen, "OnCloseBlackScreen")
end

return CinematicModuleHead
