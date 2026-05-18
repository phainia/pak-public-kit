local UMG_MinimapTemplate_C = _G.NRCPanelBase:Extend("UMG_MinimapTemplate_C")

function UMG_MinimapTemplate_C:OnConstruct()
end

function UMG_MinimapTemplate_C:OnDestruct()
end

function UMG_MinimapTemplate_C:OnActive()
end

function UMG_MinimapTemplate_C:OnDeactive()
end

function UMG_MinimapTemplate_C:UpdateMiniMapNpcInfo(npcInfos)
  self.UMG_MinimapMain:UpdateNpcInfo(npcInfos)
end

function UMG_MinimapTemplate_C:UpdateMiniMapTraceNpcState(npcId, trace)
  self.UMG_MinimapMain:PlayNpcTraceEffect(npcId, trace)
end

function UMG_MinimapTemplate_C:UpdateMinimapChangeEntriesInfo(entryInfos)
  self.UMG_MinimapMain:UpdateMinimapChangeEntriesInfo(entryInfos)
end

function UMG_MinimapTemplate_C:UpdateMinimapDeleteEntriesInfo(entryId)
  self.UMG_MinimapMain:UpdateMinimapDeleteEntriesInfo(entryId)
end

function UMG_MinimapTemplate_C:SetMinimapTransparent(bool)
  self.UMG_MinimapMain:SetMinimapTransparent(bool)
end

function UMG_MinimapTemplate_C:OnRelogin()
  self.UMG_MinimapMain:OnRelogin()
end

return UMG_MinimapTemplate_C
