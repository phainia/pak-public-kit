require("UnLuaEx")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local FsmTimelineState = require("NewRoco.Modules.Core.Fsm.FsmTimelineState")
local EUW_FsmActionItem_C = NRCClass()

function EUW_FsmActionItem_C:Tick(MyGeometry, InDeltaTime)
  if not self.action then
    self.Progress:SetPercent(0)
    return
  end
  self.FsmName:SetColorAndOpacity(FsmUtils.GetColor(self.action))
  local State = self.action.state
  if State and State ~= FsmUtils.Dummy then
    if State:InstanceOf(FsmTimelineState) and self.action:GetDuration() > 0 then
      local Size = UE4.USlateBlueprintLibrary.GetLocalSize(MyGeometry)
      local Left = Size.X * (self.action:GetStartTime() / State.totalTime)
      local Right = Size.X * (1 - self.action:GetEndTime() / State.totalTime)
      self:SetOffset(Left, Right)
      self.Progress:SetPercent(self.action:GetRunningPercent())
    else
      self:SetOffset(0, 0)
      self.Progress:SetPercent(self.action:GetTimeoutPercent())
    end
  else
    self.Progress:SetPercent(0)
  end
end

function EUW_FsmActionItem_C:SetOffset(Left, Right)
  local Slot = self.Progress.Slot
  local Offsets = Slot:GetOffsets()
  Offsets.Left = Left + 7
  Offsets.Right = Right + 7
  Slot:SetOffsets(Offsets)
end

function EUW_FsmActionItem_C:SetData(ItemData)
  self.Overridden.SetData(self, ItemData)
  Log.Debug("Setting Action Data from lua")
  self.action = ItemData.data
  self.Parent = ItemData.Parent
  if self.action then
    self.FsmName:SetText(self.action:GetName())
  end
  self.SelectIndicator:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function EUW_FsmActionItem_C:OnItemSelected(selected)
  Log.Debug("item selected...")
  self.SelectIndicator:SetVisibility(selected and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

return EUW_FsmActionItem_C
