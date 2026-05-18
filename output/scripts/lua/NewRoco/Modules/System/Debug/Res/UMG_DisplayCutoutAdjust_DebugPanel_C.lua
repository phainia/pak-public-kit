local UMG_DisplayCutoutAdjust_DebugPanel_C = _G.NRCPanelBase:Extend("UMG_DisplayCutoutAdjust_DebugPanel_C")
local AdjustMarginType = {
  Left = 1,
  Top = 2,
  Right = 3,
  Bottom = 4,
  Reset = 5
}
local CurAdjustOffset = 0.5

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnConstruct()
  self.OffsetAdjust.OnTextCommitted:Add(self, self.OnModifyOffsetAdjust)
  self:AddButtonListener(self.BtnClose, self.OnClose)
  self:AddButtonListener(self.BtnCopyDeviceName, self.OnClickCopyDeviceName)
  self:AddButtonListener(self.BtnReduceLeft, self.OnClickReduceLeft)
  self:AddButtonListener(self.BtnAddLeft, self.OnClickAddLeft)
  self:AddButtonListener(self.BtnReduceTop, self.OnClickReduceTop)
  self:AddButtonListener(self.BtnAddTop, self.OnClickAddTop)
  self:AddButtonListener(self.BtnReduceRight, self.OnClickReduceRight)
  self:AddButtonListener(self.BtnAddRight, self.OnClickAddRight)
  self:AddButtonListener(self.BtnReduceBottom, self.OnClickReduceBottom)
  self:AddButtonListener(self.BtnAddBottom, self.OnClickAddBottom)
  self:AddButtonListener(self.BtnReset, self.OnClickReset)
  self.DeviceName:SetText(UE4.UNRCTUIStatics.GetDeviceKeyForOverrideSafeZone())
  self.DeviceOrientation:SetText(tostring(UE4.UBlueprintPlatformLibrary.GetDeviceOrientation()))
  self.OffsetAdjust:SetText(tostring(CurAdjustOffset))
  self:RefreshSafeZoneMargin()
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnDestruct()
  self.OffsetAdjust.OnTextCommitted:Remove(self, self.OnModifyOffsetAdjust)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:RefreshSafeZoneMargin()
  local OverrideMargin = UE4.UNRCTUIStatics.GetOverrideSafeZoneMargin()
  self.LeftValue:SetText(tostring(OverrideMargin.Left))
  self.TopValue:SetText(tostring(OverrideMargin.Top))
  self.RightValue:SetText(tostring(OverrideMargin.Right))
  self.BottomValue:SetText(tostring(OverrideMargin.Bottom))
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:DoAdjustMargin(_type, _offset)
  local OverrideMargin = UE4.UNRCTUIStatics.GetOverrideSafeZoneMargin()
  if _type == AdjustMarginType.Left then
    OverrideMargin.Left = OverrideMargin.Left + _offset
  elseif _type == AdjustMarginType.Top then
    OverrideMargin.Top = OverrideMargin.Top + _offset
  elseif _type == AdjustMarginType.Right then
    OverrideMargin.Right = OverrideMargin.Right + _offset
  elseif _type == AdjustMarginType.Bottom then
    OverrideMargin.Bottom = OverrideMargin.Bottom + _offset
  elseif _type == AdjustMarginType.Reset then
    OverrideMargin.Left = -1
    OverrideMargin.Top = -1
    OverrideMargin.Right = -1
    OverrideMargin.Bottom = -1
  end
  UE4.UNRCTUIStatics.SetOverrideSafeZoneMargin(OverrideMargin)
  self:RefreshSafeZoneMargin()
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnModifyOffsetAdjust(txtContent, commitMethod)
  local InputValue = tonumber(txtContent)
  if nil == InputValue then
    self.OffsetAdjust:SetText(CurAdjustOffset)
  else
    CurAdjustOffset = InputValue
  end
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickCopyDeviceName()
  UE4.UNRCStatics.ClipboardCopy(self.DeviceName:GetText())
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickReduceLeft()
  self:DoAdjustMargin(AdjustMarginType.Left, -CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickAddLeft()
  self:DoAdjustMargin(AdjustMarginType.Left, CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickReduceTop()
  self:DoAdjustMargin(AdjustMarginType.Top, -CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickAddTop()
  self:DoAdjustMargin(AdjustMarginType.Top, CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickReduceRight()
  self:DoAdjustMargin(AdjustMarginType.Right, -CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickAddRight()
  self:DoAdjustMargin(AdjustMarginType.Right, CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickReduceBottom()
  self:DoAdjustMargin(AdjustMarginType.Bottom, -CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickAddBottom()
  self:DoAdjustMargin(AdjustMarginType.Bottom, CurAdjustOffset)
end

function UMG_DisplayCutoutAdjust_DebugPanel_C:OnClickReset()
  self:DoAdjustMargin(AdjustMarginType.Reset)
end

return UMG_DisplayCutoutAdjust_DebugPanel_C
