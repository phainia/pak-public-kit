local MiniGameModuleHead = NRCModuleHeadBase:Extend("MiniGameModuleHead")

function MiniGameModuleHead:OnConstruct()
  _G.MiniGameModuleCmd = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleCmd")
  self:BindCmd(_G.MiniGameModuleCmd.OnMinigameNotify, "OnMinigameNotify")
  self:BindCmd(_G.MiniGameModuleCmd.AddClock, "AddClockByDist")
  self:BindCmd(_G.MiniGameModuleCmd.GetSettings, "GetSettings")
  self:BindCmd(_G.MiniGameModuleCmd.GetState, "GetState")
  self:BindCmd(_G.MiniGameModuleCmd.IsPlaying, "IsPlaying")
  self:BindCmd(_G.MiniGameModuleCmd.LocalIsPlaying, "LocalIsPlaying")
  self:BindCmd(_G.MiniGameModuleCmd.IsOpenCamera, "IsOpenCamera")
  self:BindCmd(_G.MiniGameModuleCmd.OnReady, "OnRdy")
  self:BindCmd(_G.MiniGameModuleCmd.AddNPC, "AddNPC")
  self:BindCmd(_G.MiniGameModuleCmd.IsInNightmare, "IsInNightmare")
  self:BindCmd(_G.MiniGameModuleCmd.SetPlayNightmareAction, "SetPlayNightmareAction")
  self:BindCmd(_G.MiniGameModuleCmd.NeedPlayNightmareAction, "NeedPlayNightmareAction")
  self:BindCmd(_G.MiniGameModuleCmd.IsOpenNightmareFinish, "IsOpenNightmareFinish")
  self:BindCmd(_G.MiniGameModuleCmd.SetOpenNightmareFinish, "SetOpenNightmareFinish")
  self:BindCmd(_G.MiniGameModuleCmd.SetPlayNightmareCleanAction, "SetPlayNightmareCleanAction")
  self:BindCmd(_G.MiniGameModuleCmd.NeedFinishGameByCleanAction, "NeedFinishGameByCleanAction")
  self:BindCmd(_G.MiniGameModuleCmd.GetMiniGameStage, "GetMiniGameStage")
end

return MiniGameModuleHead
