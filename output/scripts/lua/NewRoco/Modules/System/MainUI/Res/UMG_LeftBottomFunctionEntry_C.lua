local UMG_LeftBottomFunctionEntry_C = _G.NRCPanelBase:Extend("UMG_LeftBottomFunctionEntry_C")

function UMG_LeftBottomFunctionEntry_C:OnConstruct()
  self.NumWidths = {153.319031, 271.033325}
end

function UMG_LeftBottomFunctionEntry_C:OnTouchEnded(MyGeometry, InTouchEvent)
  NRCModuleManager:DoCmd(MainUIModuleCmd.CloseLeftBottomFunctionEntry)
  return self.Overridden.OnTouchEnded(self, MyGeometry, InTouchEvent)
end

function UMG_LeftBottomFunctionEntry_C:OnActive()
  _G.NRCEventCenter:RegisterEvent("UMG_LeftBottomFunctionEntry", self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
  local Items = {}
  local isChatBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_CHAT)
  if not isChatBan then
    table.insert(Items, {
      icon = self.chat_icon and self.chat_icon.AssetPathName,
      on_clicked = FPartial(self.OpenChat, self),
      redDotKey = 5
    })
  end
  local isPhotoBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_TAKE_PHOTO or 0)
  if not isPhotoBan then
    table.insert(Items, {
      icon = self.take_photos_icon and self.take_photos_icon.AssetPathName,
      on_clicked = FPartial(self.OpenTakePhotos, self),
      redDotKey = 0
    })
  end
  self.FunctionEntry:InitGridView(Items)
  local Width = self.NumWidths[#Items]
  local ParentSlot = self.NRCImage_Bg.Slot
  if Width and ParentSlot.GetSize then
    local Size = ParentSlot:GetSize()
    Size.X = Width
    ParentSlot:SetSize(Size)
  end
end

function UMG_LeftBottomFunctionEntry_C:OnOpenPanel(PanelData)
  local Name = PanelData.panelName
  if "UMG_LeftBottomFunctionEntry" ~= Name then
    self:DoClose()
  end
end

function UMG_LeftBottomFunctionEntry_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
end

function UMG_LeftBottomFunctionEntry_C:OnAddEventListener()
end

function UMG_LeftBottomFunctionEntry_C:OpenTakePhotos()
  NRCModuleManager:DoCmd(MainUIModuleCmd.TryOpenTakePhotosPanel)
end

function UMG_LeftBottomFunctionEntry_C:OpenChat()
  NRCModuleManager:DoCmd(MainUIModuleCmd.TryOpenChatPanel)
end

return UMG_LeftBottomFunctionEntry_C
