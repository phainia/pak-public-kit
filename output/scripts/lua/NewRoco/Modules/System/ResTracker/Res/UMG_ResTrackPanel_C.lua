local UMG_ResTrackPanel_C = _G.NRCPanelBase:Extend("UMG_ResTrackPanel_C")

function UMG_ResTrackPanel_C:OnConstruct()
  Log.Debug("TrackPanel Ctor!")
  self.Tracker = UE4.ReferenceTracker()
  self:SetChildViews(self.UMG_ResTrackTab1, self.UMG_ResTrackTab2)
  self.UMG_ResTrackTab1:Init(self)
  self.UMG_ResTrackTab2:Init(self)
  local indexToUmg = self.BP_NRCTab.Index2UMG
  if indexToUmg then
    indexToUmg:Add(1, self.UMG_ResTrackTab1)
    indexToUmg:Add(2, self.UMG_ResTrackTab2)
  end
  self.BP_NRCTab.OnClickChangeTab:Bind(self, self.OnTabChangeCallback)
end

function UMG_ResTrackPanel_C:OnDestruct()
  Log.Debug("TrackPanel OnDestruct!")
  self.UMG_ResTrackTab1:Release()
  self.UMG_ResTrackTab2:Release()
end

function UMG_ResTrackPanel_C:OnActive()
  Log.Debug("TrackPanel OnActive!")
  self:AddButtonListener(self.CloseButton, self.DoClose)
  self:AddButtonListener(self.HideButton, self.Hide)
  self:AddButtonListener(self.ShowButton, self.Show)
  self:AddButtonListener(self.GCLuaButton, self.GCLua)
  self:AddButtonListener(self.GCUEButton, self.GCUE)
  self:Show()
  self:TipTime("")
  self.BP_NRCTab:SetActiveWidgetIndex(1)
  self.ActiveTab = self.BP_NRCTab:GetActiveWidget()
  if self.ActiveTab then
    self.ActiveTab:OnActive(self)
  end
end

function UMG_ResTrackPanel_C:OnDeactive()
  Log.Debug("TrackPanel OnDeactive!")
  if self.ActiveTab and self.ActiveTab.OnDeactive then
    self.ActiveTab:OnDeactive()
  end
  self:RemoveAllButtonListener()
end

function UMG_ResTrackPanel_C:Hide()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_ResTrackPanel_C:Show()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_ResTrackPanel_C:OnTabChangeCallback(index)
  Log.Debug("BP_NRCTabTest_C:OnTabChangeCallback", index)
  if self.ActiveTab then
    self.ActiveTab:OnDeactive()
  end
  self.ActiveTab = self.BP_NRCTab:GetActiveWidget()
  self.ActiveTab:OnActive(self)
end

function UMG_ResTrackPanel_C:Tip(message)
  self.LogText:SetText(message)
end

function UMG_ResTrackPanel_C:TipTime(message)
  self:Tip(os.date("%Y-%m-%d %H:%M:%S") .. "  " .. message)
end

function UMG_ResTrackPanel_C:GCLua()
  collectgarbage("collect")
  self:Tip("\230\137\167\232\161\140 Lua GC")
end

function UMG_ResTrackPanel_C:GCUE()
  UE4.UNRCStatics.ForceGarbageCollection(true)
  self:Tip("\230\137\167\232\161\140 UE GC")
end

return UMG_ResTrackPanel_C
