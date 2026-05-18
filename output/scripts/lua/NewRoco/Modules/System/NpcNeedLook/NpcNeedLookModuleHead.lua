local NpcNeedLookModuleHead = NRCModuleHeadBase:Extend("NpcNeedLookModuleHead")

function NpcNeedLookModuleHead:OnConstruct()
  _G.NpcNeedLookModuleCmd = reload("NewRoco.Modules.System.NpcNeedLook.NpcNeedLookModuleCmd")
  self:BindCmd(_G.NpcNeedLookModuleCmd.RegisterNpc, "RegisterNpc")
  self:BindCmd(_G.NpcNeedLookModuleCmd.UnRegisterNpc, "UnRegisterNpc")
  self:BindCmd(_G.NpcNeedLookModuleCmd.GetLookTarget, "GetLookTarget")
  self:BindCmd(_G.NpcNeedLookModuleCmd.UpdateWatchingTarget, "UpdateWatchingTarget")
  self:BindCmd(_G.NpcNeedLookModuleCmd.Debug, "Debug")
  self:BindCmd(_G.NpcNeedLookModuleCmd.DebugTurnScale, "DebugTurnScale")
end

return NpcNeedLookModuleHead
