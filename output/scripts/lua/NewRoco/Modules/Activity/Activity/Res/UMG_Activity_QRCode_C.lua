local UMG_Activity_QRCode_C = _G.NRCPanelBase:Extend("UMG_Activity_QRCode_C")

function UMG_Activity_QRCode_C:OnConstruct()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtnHandle)
end

function UMG_Activity_QRCode_C:OnDestruct()
end

function UMG_Activity_QRCode_C:OnActive(conf, onCloseCallback, ...)
  if conf then
    self.PopUp.TitleText:SetText(conf.part_name)
    if conf.special == _G.Enum.ActivitySpecialWebSite.ASWS_QRCODE_APPLET then
      local qrTexture = UE.UPlatformImageLibrary.CreateTextureFromBase64Data(...)
      if qrTexture then
        self.Image:SetBrushFromTextureDynamic(qrTexture, false)
      end
    elseif not string.IsNilOrEmpty(conf.special_param1) then
      self.Image:SetPath(conf.special_param1)
    end
    if not string.IsNilOrEmpty(conf.special_param2) then
      self.TextDescribe:SetText(conf.special_param2)
    end
  end
  if onCloseCallback and conf.special ~= _G.Enum.ActivitySpecialWebSite.ASWS_QRCODE_APPLET then
    self.onCloseCallback = onCloseCallback
    self.callbackParam = table.pack(...)
  end
end

function UMG_Activity_QRCode_C:OnClickCloseBtnHandle()
  if self.onCloseCallback then
    self.onCloseCallback(table.unpack(self.callbackParam, 1, self.callbackParam.n))
  end
  self:OnClose()
end

return UMG_Activity_QRCode_C
