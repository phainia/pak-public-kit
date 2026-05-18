local UMG_UnderExpansion_C = _G.NRCViewBase:Extend("UMG_UnderExpansion_C")

function UMG_UnderExpansion_C:OnActive()
  Log.Debug("UMG_UnderExpansion_C:OnActive()")
end

function UMG_UnderExpansion_C:OnDeactive()
  Log.Debug("UMG_UnderExpansion_C:OnDeactive()")
end

function UMG_UnderExpansion_C:OnEnable(ParentHeadWidget)
  self.ProgressBar_76:SetFillStartPercent(2.33)
  self.ParentHeadWidget = ParentHeadWidget
  Log.Debug("UMG_UnderExpansion_C:OnEnable()")
  self:OnRefresh()
end

function UMG_UnderExpansion_C:OnDisable()
  Log.Debug("UMG_UnderExpansion_C:OnDisable()")
  if self.RefreshTimer then
    DelayManager:CancelDelayById(self.RefreshTimer)
    self.RefreshTimer = nil
  end
end

function UMG_UnderExpansion_C:OnRefresh()
  local Status, Arg1, Arg2 = HomeIndoorSandbox.Server.WorldData:GetExpansionStatus()
  if Status == HomeIndoorSandbox.Enum.EnmExpandStatus.Expanding then
    local RemainTime = Arg1
    local CostTime = Arg2
    self:RefreshProgress(RemainTime, CostTime)
    self.RefreshTimer = DelayManager:DelaySeconds(1, function()
      self.RefreshTimer = nil
      if self.enableView then
        self:OnRefresh()
        if self.ParentHeadWidget and UE.UObject.IsValid(self.ParentHeadWidget) then
          self.ParentHeadWidget:RequestRedraw()
        end
      end
    end)
  else
    local RoomLevel = HomeIndoorSandbox.Server.WorldData.RoomLevel
    local RoomLevelConf = DataConfigManager:GetRoomConf(RoomLevel)
    local Cost = RoomLevelConf and RoomLevelConf.expend_cost_time or 1
    self:RefreshProgress(0, Cost)
  end
end

function UMG_UnderExpansion_C:RefreshProgress(Remaining, CostTime)
  local InRemaining = Remaining
  Remaining = math.floor(Remaining)
  local Hour = Remaining // 3600
  Remaining = Remaining - Hour * 3600
  local Minus = Remaining // 60
  Remaining = Remaining - Minus * 60
  self.quantity_1:SetText(string.format("%02d:%02d:%02d", Hour, Minus, Remaining))
  local p = (1 - InRemaining / CostTime) * 0.916
  Log.Debug("UMG_UnderExpansion_C:RefreshProgress", Remaining, CostTime, p)
  self.ProgressBar_76:SetFillAmount(math.clamp(p, 0, 1))
end

return UMG_UnderExpansion_C
