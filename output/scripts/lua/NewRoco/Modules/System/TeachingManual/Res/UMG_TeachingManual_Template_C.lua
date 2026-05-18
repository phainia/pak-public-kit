local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TeachingManualModuleEvent = require("NewRoco.Modules.System.TeachingManual.TeachingManualModuleEvent")
local UMG_TeachingManual_Template_C = Base:Extend("UMG_TeachingManual_Template_C")

function UMG_TeachingManual_Template_C:OnConstruct()
end

function UMG_TeachingManual_Template_C:OnDestruct()
  self:CancelDelay()
end

function UMG_TeachingManual_Template_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.icon1:SetPath(self.data.icon1)
  self.icon2:SetPath(self.data.icon2)
  self.NrcRedPoint:SetupKey(219, {
    self.data.type
  })
  self:PlayAnimation(self.normal)
end

function UMG_TeachingManual_Template_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.isSelected = true
    local module = _G.NRCModuleManager:GetModule("TeachingManualModule")
    if self.data and self.data.type then
      module:DispatchEvent(TeachingManualModuleEvent.SelectTeachManualTab, self.data.type)
    end
    self.NRCImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IsPlayLoop = true
    self:StopAllAnimations()
    self:PlayAnimation(self.change1)
  else
    self.isSelected = false
    self.IsPlayLoop = false
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:CancelDelay()
  end
end

function UMG_TeachingManual_Template_C:OnDeactive()
end

function UMG_TeachingManual_Template_C:OnAnimationFinished(Animation)
  if Animation == self.change2 then
    if not self.isSelected then
      self.NRCImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif Animation == self.change1 then
    self:CancelDelay()
    self.delayId = _G.DelayManager:DelaySeconds(3, self.PlayLoop, self)
  elseif Animation == self.select_loop then
    self:CancelDelay()
    self.delayId1 = _G.DelayManager:DelaySeconds(8, self.PlayLoop, self)
  end
end

function UMG_TeachingManual_Template_C:PlayLoop()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if not self.IsPlayLoop then
    return
  end
  self:PlayAnimation(self.select_loop)
end

function UMG_TeachingManual_Template_C:CancelDelay()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
  if self.delayId1 then
    _G.DelayManager:CancelDelayById(self.delayId1)
    self.delayId1 = nil
  end
end

return UMG_TeachingManual_Template_C
