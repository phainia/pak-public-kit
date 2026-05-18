local ResTrackerModule = NRCModuleBase:Extend("ResTrackerModule")

function ResTrackerModule:OnConstruct()
  _G.ResTrackerModuleCmd = reload("NewRoco.Modules.System.ResTracker.ResTrackerModuleCmd")
  self.data = self:SetData("ResTrackerModuleData", "NewRoco.Modules.System.ResTracker.ResTrackerModuleData")
  self:RegisterCmd(_G.ResTrackerModuleCmd.OpenTrackerPanel, self.OpenTrackerPanel)
  self:RegisterCmd(_G.ResTrackerModuleCmd.OpenTrackPanel, self.OpenTrackPanel)
  self:RegisterCmd(_G.ResTrackerModuleCmd.OpenTestPanel, self.OpenTestPanel)
  self:RegisterCmd(_G.ResTrackerModuleCmd.OpenStateWatchPanel, self.OpenStateWatchPanel)
  self:RegPanel("ResTrackerPanel", "/Game/NewRoco/Modules/System/ResTracker/Res/UMG_ResTrackerPanel")
  self:RegPanel("ResTrackPanel", "/Game/NewRoco/Modules/System/ResTracker/Res/UMG_ResTrackPanel")
  self:RegPanel("ResTestPanel", "/Game/NewRoco/Modules/System/ResTracker/Res/UMG_ResTestPanel")
  self:RegPanel("StateWatchPanel", "/Game/NewRoco/Modules/System/ResTracker/Res/StateWatch/UMG_StateWatch_MainPanel")
end

function ResTrackerModule:RegPanel(name, path)
  local PanelData = NRCPanelRegisterData()
  PanelData.panelName = name
  PanelData.panelPath = path
  PanelData.panelLayer = _G.Enum.UILayerType.UI_LAYER_DEBUG
  self:RegisterPanel(PanelData)
end

function ResTrackerModule:OnActive()
end

function ResTrackerModule:OnRelogin()
end

function ResTrackerModule:OnDeactive()
end

function ResTrackerModule:OnDestruct()
end

function ResTrackerModule:OpenTestPanel()
  self:OpenPanel("ResTestPanel")
  if _G.AppMain:HasDebug() then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.Open)
  end
end

function ResTrackerModule:OpenTrackPanel()
  self:OpenPanel("ResTrackPanel")
  if _G.AppMain:HasDebug() then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.Open)
  end
end

function ResTrackerModule:OpenTrackerPanel()
  self:OpenPanel("ResTrackerPanel")
  if _G.AppMain:HasDebug() then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.Open)
  end
end

function ResTrackerModule:OpenStateWatchPanel()
  self:OpenPanel("StateWatchPanel")
  if _G.AppMain:HasDebug() then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.Open)
  end
end

return ResTrackerModule
