local UMG_Having_Nothing_C = _G.NRCViewBase:Extend("UMG_Having_Nothing_C")

function UMG_Having_Nothing_C:OnConstruct()
end

function UMG_Having_Nothing_C:OnDestruct()
end

function UMG_Having_Nothing_C:OnActive(_data)
  self.uiData = _data
end

function UMG_Having_Nothing_C:OnDeactive()
end

function UMG_Having_Nothing_C:OnAddEventListener()
end

return UMG_Having_Nothing_C
