local UMG_LobbyMainInnerBottomIconList_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInnerBottomIconList_C")

function UMG_LobbyMainInnerBottomIconList_C:OnActive()
  Log.Debug("UMG_LobbyMainInnerBottomIconList_C:OnActive")
end

function UMG_LobbyMainInnerBottomIconList_C:OnDeactive()
end

function UMG_LobbyMainInnerBottomIconList_C:SetData()
  if self.IconList then
    local MoreData = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetMoreInnerBottomList)
    if MoreData then
      self.IconList:InitGridView(MoreData)
    end
  end
end

function UMG_LobbyMainInnerBottomIconList_C:OnFocusLost()
  local IsFocusable = self:GetIsFocusable()
  if IsFocusable then
    _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnMainUIVisibileBottomIconList, false)
  end
end

return UMG_LobbyMainInnerBottomIconList_C
