local UMG_LobbyMainInner2D_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInner2D_C")

function UMG_LobbyMainInner2D_C:OnActive()
  Log.Debug("UMG_LobbyMainInner2D_C:OnActive")
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerIconLoaded, self)
end

function UMG_LobbyMainInner2D_C:OnDeactive()
end

function UMG_LobbyMainInner2D_C:OnAddEventListener()
end

return UMG_LobbyMainInner2D_C
