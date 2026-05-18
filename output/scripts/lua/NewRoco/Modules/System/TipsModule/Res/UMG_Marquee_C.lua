local UMG_Marquee_C = _G.NRCPanelBase:Extend("UMG_Marquee_C")

function UMG_Marquee_C:OnActive(data)
  self.marquee_queue = {}
  self.current_data = nil
  self.DeltaTime = 0
  self.is_playing = false
  self:SetPanelInfo(data)
  _G.UpdateManager:Register(self)
end

local function sort_by_priority(queue)
  table.sort(queue, function(a, b)
    return a.priority > b.priority
  end)
end

function UMG_Marquee_C:SetPanelInfo(data)
  if not data then
    return
  end
  self.marquee_queue[#self.marquee_queue + 1] = data
  sort_by_priority(self.marquee_queue)
  if not self.is_playing then
    self:PlayNextMarquee()
  end
end

function UMG_Marquee_C:PlayNextMarquee()
  if 0 == #self.marquee_queue then
    self.is_playing = false
    self.current_data = nil
    return
  end
  self.current_data = table.remove(self.marquee_queue, 1)
  self.DeltaTime = 0
  self.is_playing = true
  self.ContentText:SetText(self.current_data.content)
end

function UMG_Marquee_C:OnTick(InDeltaTime)
  if not self.is_playing or not self.current_data then
    return
  end
  self.DeltaTime = self.DeltaTime + InDeltaTime
  if self.DeltaTime >= self.current_data.stop_time then
    self:PlayNextMarquee()
    if not self.is_playing then
      _G.UpdateManager:UnRegister(self)
      self:DoClose()
    end
  end
end

function UMG_Marquee_C:OnDeactive()
  self.marquee_queue = {}
  self.current_data = nil
  self.is_playing = false
end

function UMG_Marquee_C:OnAddEventListener()
end

return UMG_Marquee_C
