local UMG_Video_C = _G.NRCPanelBase:Extend("UMG_Video_C")

function UMG_Video_C:OnConstruct()
  _G.NRCPanelBase.OnConstruct(self)
  self.MediaPlayer.OnEndReached:Add(self, function(self)
    if self.Callback then
      self.Callback(self.Caller)
    end
    self.MediaPlayer:Close()
    self:Disable()
  end)
end

function UMG_Video_C:OnActive(...)
  self:StartVideo(...)
end

function UMG_Video_C:StartVideo(Callback, Caller)
  self.Callback = Callback
  self.Caller = Caller
  self.MediaPlayer:OpenSource(self.Source)
end

function UMG_Video_C:OnDeactive()
end

function UMG_Video_C:OnAddEventListener()
end

return UMG_Video_C
