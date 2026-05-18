local InstanceModuleHead = NRCModuleHeadBase:Extend("InstanceModuleHead")

function InstanceModuleHead:OnConstruct()
  _G.InstanceModuleCmd = reload("NewRoco.Modules.Core.Instance.InstanceModuleCmd")
  self:BindCmd(_G.InstanceModuleCmd.OpenEnterPanel, "OnOpenEnterPanel")
  self:BindCmd(_G.InstanceModuleCmd.CloseEnterPanel, "CmdCloseEnterPanel")
  self:BindCmd(_G.InstanceModuleCmd.OpenLeavePanel, "OnOpenLeavePanel")
  self:BindCmd(_G.InstanceModuleCmd.GetDungeonConf, "GetDungeonConf")
  self:BindCmd(_G.InstanceModuleCmd.GetDungeonInfo, "GetDungeonInfo")
  self:BindCmd(_G.InstanceModuleCmd.IsInDungeon, "IsInDungeon")
  self:BindCmd(_G.InstanceModuleCmd.GetCurrentDungeon, "GetCurrentDungeon")
  self:BindCmd(_G.InstanceModuleCmd.GetDungeonStageDone, "GetDungeonStageDone")
  self:BindCmd(_G.InstanceModuleCmd.SetPlayerDungeonStatus, "SetPlayerDungeonStatus")
end

return InstanceModuleHead
