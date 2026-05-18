local AirWallModuleHead = NRCModuleHeadBase:Extend("AirWallModuleHead")

function AirWallModuleHead:OnConstruct()
  _G.AirWallModuleCmd = reload("NewRoco.Modules.System.AirWall.AirWallModuleCmd")
  self:BindCmd(_G.AirWallModuleCmd.CreateWall, "OnCreateWall")
  self:BindCmd(_G.AirWallModuleCmd.DestroyWall, "OnDestroyWall")
  self:BindCmd(_G.AirWallModuleCmd.GetWall, "GetAirWall")
  self:BindCmd(_G.AirWallModuleCmd.DisplayVisualWall, "DisplayVisualWall")
  self:BindCmd(_G.AirWallModuleCmd.HideVisualWall, "HideVisualWall")
  self:BindCmd(_G.AirWallModuleCmd.DeleteVisualWall, "DeleteVisualWall")
  self:BindCmd(_G.AirWallModuleCmd.CreateDebugBlock, "CreateDebugBlock")
  self:BindCmd(_G.AirWallModuleCmd.ServerAirWallChange, "OnServerAirWallChange")
end

return AirWallModuleHead
