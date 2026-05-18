require("UnLuaEx")
local UMG_LobbyPropTipsHint_C = NRCViewBase:Extend("UMG_LobbyPropTipsHint_C")

function UMG_LobbyPropTipsHint_C:OnConstruct()
end

function UMG_LobbyPropTipsHint_C:OnDestruct()
end

function UMG_LobbyPropTipsHint_C:SetText(text)
  self.AcquireText:SetText(text)
end

return UMG_LobbyPropTipsHint_C
