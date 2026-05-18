local UMG_LobbyMainInnerLeftIcon_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInnerLeftIcon_C")

function UMG_LobbyMainInnerLeftIcon_C:OnActive()
  Log.Debug("UMG_LobbyMainInnerLeftIcon_C:OnActive")
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerIconLoaded, self)
end

function UMG_LobbyMainInnerLeftIcon_C:OnDeactive()
end

function UMG_LobbyMainInnerLeftIcon_C:OnAddEventListener()
end

return UMG_LobbyMainInnerLeftIcon_C
