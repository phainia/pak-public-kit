local Delegate = require("Utils.Delegate")
local VisibilityMutex = Class("VisibilityMutex")

function VisibilityMutex:Ctor(Widget, InitVisible)
  if nil == InitVisible then
    InitVisible = false
  end
  self.InitVisible = InitVisible
  self.Widget = Widget
  self.LockReasons = {}
  self.OnVisibilityChanged = Delegate()
  self:SetVisible(InitVisible)
end

function VisibilityMutex:Reset(bClearEvents)
  if bClearEvents then
    self.OnVisibilityChanged:Clear()
  end
end

function VisibilityMutex:Sync()
  self:SetVisible(self:IsWidgetVisible())
end

function VisibilityMutex:SetVisible(bVisible, Reason)
  Reason = Reason or "Default"
  local bOldVisible = self:IsVisible()
  if bVisible then
    self.LockReasons[Reason] = nil
  else
    self.LockReasons[Reason] = true
  end
  local bNewVisible = self:IsVisible()
  if bOldVisible ~= bNewVisible then
    if self.Widget then
      if bNewVisible then
        self.Widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Widget:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
    self.OnVisibilityChanged:Invoke(bNewVisible)
  end
end

function VisibilityMutex:IsVisible()
  return not next(self.LockReasons)
end

function VisibilityMutex:IsWidgetVisible()
  return self.Widget:IsVisible()
end

return VisibilityMutex
