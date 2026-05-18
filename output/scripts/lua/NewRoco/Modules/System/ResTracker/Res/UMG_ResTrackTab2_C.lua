local UMG_ResTrackTab2_C = _G.NRCViewBase:Extend("UMG_ResTrackTab2_C")

function UMG_ResTrackTab2_C:OnConstruct()
  self:SetChildViews(self.TrackResults)
  self:AddButtonListener(self.TrackButton, self.TrackAll)
end

function UMG_ResTrackTab2_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_ResTrackTab2_C:Init(TrackPanel)
  self.TrackPanel = TrackPanel
  self.Tracker = TrackPanel.Tracker
  self.Tip = TrackPanel.Tip
  self.TipTime = TrackPanel.TipTime
end

function UMG_ResTrackTab2_C:Release()
end

function UMG_ResTrackTab2_C:OnActive()
  self.TrackResults:OnActive(self)
end

function UMG_ResTrackTab2_C:OnDeactive()
  self.TrackResults:OnDeactive()
end

function UMG_ResTrackTab2_C:TrackAll()
  Log.Debug("Track All Asset Begin")
  local results = self.Tracker:TrackAll()
  self.TrackResults:BindResults(results)
  self.TrackResults:ExportAll()
  Log.Debug("Track All Asset Finish")
end

return UMG_ResTrackTab2_C
