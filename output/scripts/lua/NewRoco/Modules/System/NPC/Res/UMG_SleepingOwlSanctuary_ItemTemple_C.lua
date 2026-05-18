local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SleepingOwlSanctuary_ItemTemple_C = Base:Extend("UMG_SleepingOwlSanctuary_ItemTemple_C")

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnConstruct()
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnDestruct()
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self.Level:SetText(tostring(self.uiData.reward_level))
  self:BGVisiblePlayerLevel(self.uiData.State)
  Log.Dump(self.uiData, 6, "UMG_SleepingOwlSanctuary_ItemTemple_C:OnItemUpdate")
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.ParentView:ScrollToIndex(self.index - 2, false)
  else
  end
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:BGVisiblePlayerLevel(state)
  if "" == state then
    self.widget:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.widget:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Switcher:SetActiveWidgetByWidgetName(state)
  end
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OpenBox(Caller, Callback)
  if self.bIsOpening then
    Log.Warning("Already opening")
    return
  end
  self.Caller = Caller
  self.Callback = Callback
  self.bIsOpening = true
  self:PlayAnimation(self.boxopen)
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnAnimationFinished(Animation)
  if Animation == self.boxopen then
    if self.Callback then
      self.Callback(self.Caller, self)
      self.Callback = nil
      self.Caller = nil
    end
    self.bIsOpening = false
    self.Switcher:SetActiveWidgetByWidgetName("Opened")
    self.uiData.State = "Opened"
  end
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:UpdateView(InState)
  self.Switcher:SetActiveWidgetByWidgetName(InState)
end

function UMG_SleepingOwlSanctuary_ItemTemple_C:OnDeactive()
end

return UMG_SleepingOwlSanctuary_ItemTemple_C
