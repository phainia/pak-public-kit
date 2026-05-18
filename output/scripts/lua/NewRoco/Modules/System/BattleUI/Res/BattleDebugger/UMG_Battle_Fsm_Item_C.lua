local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local UMG_Battle_Fsm_Item_C = _G.NRCPanelBase:Extend("UMG_Battle_Fsm_Item_C")

function UMG_Battle_Fsm_Item_C:OnActive()
end

function UMG_Battle_Fsm_Item_C:OnDeactive()
end

function UMG_Battle_Fsm_Item_C:Tick(MyGeometry, InDeltaTime)
  if not self.Fsm then
    return
  end
  self:SetTextColor()
end

function UMG_Battle_Fsm_Item_C:SetTextColor()
  self.FsmText_1:SetColorAndOpacity(FsmUtils.GetColor(self.Fsm))
end

function UMG_Battle_Fsm_Item_C:SetBtnColor(Color)
  self.NRCButton_38:SetColorAndOpacity(Color)
end

function UMG_Battle_Fsm_Item_C:OnTouchStarted(MyGeometry, InTouchEvent)
  if self.Parent.IsCanMove then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local screenPostion = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  self.localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, screenPostion)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_Item_C:OnTouchMoved(MyGeometry, InTouchEvent)
  if self.Parent.IsCanMove then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local screenPostion = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
  local localPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(self.Parent.FsmMap:GetCachedGeometry(), screenPostion)
  if self.localPos then
    localPos.X = localPos.X - self.localPos.X
    localPos.Y = localPos.Y - self.localPos.Y
    self.Slot:SetPosition(localPos)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_Item_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self.localPos = nil
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Battle_Fsm_Item_C:SetData(FsmData, Parent)
  self.Fsm = FsmData
  self.Size = UE4.FVector2D(0, 0)
  self.Parent = Parent
  self:SetPanelInfo()
  self.NRCButton_55.OnClicked:Add(self, self.CopyPosition)
  self.NRCButton.OnClicked:Add(self, self.Paste)
end

function UMG_Battle_Fsm_Item_C:CopyPosition()
  self.Parent:SetPositionInfo(self.Slot:GetPosition())
end

function UMG_Battle_Fsm_Item_C:Paste()
  self.Slot:SetPosition(self.Parent:GetSavaPosition())
end

function UMG_Battle_Fsm_Item_C:GetSizeInfo()
  local AbsoluteSize = self.NRCButton_38.Slot:GetSize()
  local CanvasPosition = self.Slot:GetPosition()
  self.Size.X = CanvasPosition.X + AbsoluteSize.X
  self.Size.Y = CanvasPosition.Y + AbsoluteSize.Y / 2
  return self.Size
end

function UMG_Battle_Fsm_Item_C:GetPositionInfo()
  return self.Slot:GetPosition().X, self.Slot:GetPosition().Y
end

function UMG_Battle_Fsm_Item_C:SetPanelInfo()
  local Fsm = self.Fsm
  if Fsm then
    self.FsmText_1:SetText(Fsm:GetName())
  end
end

function UMG_Battle_Fsm_Item_C:OnAddEventListener()
end

return UMG_Battle_Fsm_Item_C
