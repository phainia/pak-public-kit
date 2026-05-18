local MarkerModuleHead = NRCModuleHeadBase:Extend("MarkerModuleHead")

function MarkerModuleHead:OnConstruct()
  _G.MarkerModuleCmd = reload("NewRoco.Modules.Core.Marker.MarkerModuleCmd")
  self:BindCmd(_G.MarkerModuleCmd.UpdateNPCBeam, "UpdateNPCBeam")
  self:BindCmd(_G.MarkerModuleCmd.EnterBattle, "OnEnterBattle")
  self:BindCmd(_G.MarkerModuleCmd.LeaveBattle, "OnLeaveBattle")
  self:BindCmd(_G.MarkerModuleCmd.GetTrackers, "GetTrackers")
  self:BindCmd(_G.MarkerModuleCmd.RegisterMarker, "RegisterMarker")
  self:BindCmd(_G.MarkerModuleCmd.UnregisterMarker, "UnregisterMarker")
  self:BindCmd(_G.MarkerModuleCmd.CombineGuideAction, "OnCombineGuideChange")
  self:BindCmd(_G.MarkerModuleCmd.AddPOI, "AddPOI")
end

return MarkerModuleHead
