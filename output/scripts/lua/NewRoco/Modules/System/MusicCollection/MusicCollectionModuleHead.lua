local MusicCollectionModuleHead = NRCModuleHeadBase:Extend("MusicCollectionModuleHead")

function MusicCollectionModuleHead:OnConstruct()
  _G.MusicCollectionModuleCmd = reload("NewRoco.Modules.System.MusicCollection.MusicCollectionModuleCmd")
  self:BindCmd(_G.MusicCollectionModuleCmd.OnOpenMainPanel, "OnCmdOpenMainPanel")
  self:BindCmd(_G.MusicCollectionModuleCmd.IsPauseUiBgm, "IsPauseUiBgm")
  self:BindCmd(_G.MusicCollectionModuleCmd.EnableMainPanel, "EnableMainPanel")
  self:BindCmd(_G.MusicCollectionModuleCmd.PreLoadMainPanel, "PreLoadMainPanel")
  self:BindCmd(_G.MusicCollectionModuleCmd.OnOpenMusicSettingPanel, "OnCmdMusicSettingPanel")
  self:BindCmd(_G.MusicCollectionModuleCmd.SetMusicToPanel, "CmdSetMusicToPanel")
  self:BindCmd(_G.MusicCollectionModuleCmd.MusicUnlockNotify, "OnMusicUnlockNotify")
  self:BindCmd(_G.MusicCollectionModuleCmd.MusicUPanelPause, "OnCmdMusicUPanelPause")
  self:BindCmd(_G.MusicCollectionModuleCmd.MusicUPanelPlay, "OnCmdMusicUPanelPlay")
end

return MusicCollectionModuleHead
