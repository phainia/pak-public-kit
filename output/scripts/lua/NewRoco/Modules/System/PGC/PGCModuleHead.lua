local PGCModuleHead = NRCModuleHeadBase:Extend("PGCModuleHead")

function PGCModuleHead:OnConstruct()
  _G.PGCModuleCmd = reload("NewRoco.Modules.System.PGC.PGCModuleCmd")
  _G.PGCModuleEnum = reload("NewRoco.Modules.System.PGC.PGCModuleEnum")
  _G.PGCModuleData = reload("NewRoco.Modules.System.PGC.PGCModuleData")
  self:BindCmd(_G.PGCModuleCmd.OpenMainView, "OnOpenMainView")
  self:BindCmd(_G.PGCModuleCmd.CloseMainView, "OnCloseMainView")
  self:BindCmd(_G.PGCModuleCmd.LoadDataList, "OnLoadDataList")
  self:BindCmd(_G.PGCModuleCmd.ShowDataDetail, "OnShowDataDetail")
  self:BindCmd(_G.PGCModuleCmd.AddDataItem, "OnAddDataItem")
  self:BindCmd(_G.PGCModuleCmd.RemoveDataItem, "OnRemoveDataItem")
  self:BindCmd(_G.PGCModuleCmd.ModifyDataItem, "OnModifyDataItem")
  self:BindCmd(_G.PGCModuleCmd.SimulateServerNPCEnter, "OnSimulateServerNPCEnter")
  self:BindCmd(_G.PGCModuleCmd.SimulateServerNPCLeave, "OnSimulateServerNPCLeave")
  self:BindCmd(_G.PGCModuleCmd.SimulateServerNextAction, "OnSimulateServerNextAction")
end

return PGCModuleHead
