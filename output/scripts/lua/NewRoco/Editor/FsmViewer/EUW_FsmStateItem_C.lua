require("UnLuaEx")
local FsmTimelineState = require("NewRoco.Modules.Core.Fsm.FsmTimelineState")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local EUW_FsmStateItem_C = NRCClass()

function EUW_FsmStateItem_C:Initialize(Initializer)
  Log.Debug("EUW_FsmStateItem_C:Initialize")
end

function EUW_FsmStateItem_C:Construct()
  Log.Debug("EUW_FsmStateItem_C:Construct")
end

function EUW_FsmStateItem_C:Tick(MyGeometry, InDeltaTime)
  if not self.state then
    return
  end
  self.FsmName:SetColorAndOpacity(FsmUtils.GetColor(self.state))
  if self.state:InstanceOf(FsmTimelineState) then
    local timeline = self.state
    self.Progress:SetPercent(timeline:GetPercent())
  end
end

function EUW_FsmStateItem_C:SetData(ItemData)
  self.state = ItemData.data
  self.Parent = ItemData.Parent
  if self.state then
    self.FsmName:SetText(self.state:GetName())
  end
  self.SelectIndicator:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.state and self.state:InstanceOf(FsmTimelineState) then
    self.Progress:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function EUW_FsmStateItem_C:OnItemSelected(selected)
  self.SelectIndicator:SetVisibility(selected and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

return EUW_FsmStateItem_C
