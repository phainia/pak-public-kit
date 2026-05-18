local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_Envelope1_C = _G.NRCViewBase:Extend("UMG_Envelope1_C")

function UMG_Envelope1_C:OnConstruct()
  self.IsSelect = false
  self:SetChildViews(self.UMG_Envelope1_xinfeng, self.UMG_Envelope1_light)
end

function UMG_Envelope1_C:OnDestruct()
end

function UMG_Envelope1_C:OnActive()
end

function UMG_Envelope1_C:SetEnvelopeInfo(TaskId)
  self.TaskId = TaskId
  self.UMG_Envelope1_xinfeng:SetEnvelopeInfo(TaskId)
end

function UMG_Envelope1_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self:SelectItem()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Envelope1_C:SelectItem()
  self.IsSelect = true
  self:DispatchEvent(TaskModuleEvent.EnvelopeSelect, self.TaskId)
  self:PlaySelect()
end

function UMG_Envelope1_C:PlaySelect()
  self:PlayAnimation(self.Select)
end

function UMG_Envelope1_C:PlayUnSelect()
  if self.IsSelect then
    self.IsSelect = false
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_Envelope1_C:OnDeactive()
end

function UMG_Envelope1_C:OnAddEventListener()
end

return UMG_Envelope1_C
