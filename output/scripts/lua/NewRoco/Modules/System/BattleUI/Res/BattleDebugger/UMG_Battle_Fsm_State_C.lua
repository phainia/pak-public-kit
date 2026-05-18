local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local UMG_Battle_Fsm_State_C = _G.NRCPanelBase:Extend("UMG_Battle_Fsm_State_C")

function UMG_Battle_Fsm_State_C:OnActive()
end

function UMG_Battle_Fsm_State_C:OnDeactive()
end

function UMG_Battle_Fsm_State_C:OnTouchStarted(MyGeometry, InTouchEvent)
  if self.Parent.IsCanMove then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local screenPostion = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  self.localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, screenPostion)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_State_C:OnTouchMoved(MyGeometry, InTouchEvent)
  if self.Parent.IsCanMove then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local screenPostion = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  local localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(self.Parent.FsmMap:GetCachedGeometry(), screenPostion)
  if self.localPos then
    self.Slot:SetPosition(localPos - self.localPos)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_State_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self.localPos = nil
  if self.Parent.CurrentSelectedState then
    self.Parent.CurrentSelectedState = nil
    self.Parent:SetSelectedStateLine()
  else
    self.Parent.CurrentSelectedState = self.state.name
    self.Parent:SetSelectedStateLine()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_State_C:Tick(MyGeometry, InDeltaTime)
  if not self.state then
    return
  end
  self:SetTextColor()
end

function UMG_Battle_Fsm_State_C:SetTextColor()
  self.FsmText:SetColorAndOpacity(FsmUtils.GetColor(self.state))
end

function UMG_Battle_Fsm_State_C:SetBtnColor(Color)
  self.NRCButton_38:SetColorAndOpacity(Color)
end

function UMG_Battle_Fsm_State_C:SetData(FsmData, Parent)
  self.state = FsmData
  self.Size = UE4.FVector2D(0, 0)
  self.Size_1 = UE4.FVector2D(0, 0)
  self.Parent = Parent
  self:SetPanelInfo()
  self.NRCButton_55.OnClicked:Add(self, self.CopyPosition)
  self.NRCButton.OnClicked:Add(self, self.Paste)
end

function UMG_Battle_Fsm_State_C:CopyPosition()
  self.Parent:SetPositionInfo(self.Slot:GetPosition())
end

function UMG_Battle_Fsm_State_C:Paste()
  self.Slot:SetPosition(self.Parent:GetSavaPosition())
end

function UMG_Battle_Fsm_State_C:GetSizeInfo()
  local AbsoluteSize = self.NRCButton_38.Slot:GetSize()
  local CanvasPosition = self.Slot:GetPosition()
  self.Size.X = CanvasPosition.X
  self.Size.Y = CanvasPosition.Y + AbsoluteSize.Y / 2
  return self.Size
end

function UMG_Battle_Fsm_State_C:GetActionSizeInfo()
  local AbsoluteSize = self.NRCButton_38.Slot:GetSize()
  local CanvasPosition = self.Slot:GetPosition()
  self.Size_1.X = CanvasPosition.X + AbsoluteSize.X
  self.Size_1.Y = CanvasPosition.Y + AbsoluteSize.Y / 2
  return self.Size_1
end

function UMG_Battle_Fsm_State_C:GetPositionInfo()
  return self.Slot:GetPosition().X, self.Slot:GetPosition().Y
end

function UMG_Battle_Fsm_State_C:SetPanelInfo()
  local state = self.state
  if state then
    self.FsmText:SetText(state:GetName())
  end
  self:SetFsmActionList()
end

function UMG_Battle_Fsm_State_C:SetFsmActionList()
  local state = self.state
  local Actions = state.actions
  self.ActionList:InitList(Actions)
end

function UMG_Battle_Fsm_State_C:IsHideActionList(_IsHide)
  if _IsHide then
    self.ActionList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ActionList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Battle_Fsm_State_C:OnAddEventListener()
end

return UMG_Battle_Fsm_State_C
