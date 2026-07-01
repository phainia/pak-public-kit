local UMG_ViewPhoto_C = _G.NRCPanelBase:Extend("UMG_ViewPhoto_C")

function UMG_ViewPhoto_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_ViewPhoto_C:OnAddEventListener()
  self:AddButtonListener(self.FullScreen_Close, self.OnReqClose)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnReqClose)
end

function UMG_ViewPhoto_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_ViewPhoto_C:OnReqClose")
  self.bPendingClose = true
  self:DoClose()
end

function UMG_ViewPhoto_C:OnActive(DisplayData)
  if not DisplayData then
    return
  end
  local TexturePath = DisplayData.TexturePath
  local FurnitureName = DisplayData.FurnitureName
  local Factor = 0.85
  local CanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ContentPadding)
  CanvasSlot:SetMinimum(UE.FVector2D(1 - Factor, 1 - Factor))
  CanvasSlot:SetMaximum(UE.FVector2D(Factor, Factor))
  local Margin = CanvasSlot:GetOffsets()
  Margin.Left = 0
  Margin.Top = 0
  Margin.Right = 0
  Margin.Bottom = 0
  CanvasSlot:SetOffsets(Margin)
  self:SetTextureByPath(TexturePath)
  self.PhotoName:SetText(FurnitureName or "")
end

function UMG_ViewPhoto_C:OnDeactive()
end

function UMG_ViewPhoto_C:SetTextureByPath(TexturePath)
  if not TexturePath or "" == TexturePath then
    self:LogError("Invalid TexturePath", TexturePath)
    return
  end
  local Paths = string.split(TexturePath, ";")
  local Width = 0
  local Height = 0
  if #Paths > 1 then
    Width = Paths[2] and math.tointeger(Paths[2]) or 0
    Height = Paths[3] and math.tointeger(Paths[3]) or 0
  end
  Log.Debug("UMG_ViewPhoto_C:SetTextureByPath", TexturePath, Width, Height)
  TexturePath = Paths[1]
  if TexturePath ~= self.TexturePath then
    self.TexturePath = TexturePath
    self.Width = _G.DEBUG_VIEWPHOTO_WIDTH or Width
    self.Height = _G.DEBUG_VIEWPHOTO_HEIGHT or Height
    self.TextureFile:SetVisibility(UE.ESlateVisibility.Hidden)
    self:InternalLoadTexture()
  end
end

function UMG_ViewPhoto_C:InternalLoadTexture()
  if self.TextureLoadRequest then
    assert(self.TexturePath)
    self:UnLoadResByPath(self.TexturePath)
    self.TextureLoadRequest = nil
  end
  self.TextureLoadRequest = self:LoadPanelRes(self.TexturePath, 255, self.OnTextureLoaded)
end

function UMG_ViewPhoto_C:OnTextureLoaded(req, Texture)
  if Texture and UE.UObject.IsValid(Texture) then
    self.TextureFile:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.TextureFile:SetTexture(Texture, self.Content.Slot, self.Width, self.Height)
  else
    self:LogError("Invalid Texture")
  end
end

return UMG_ViewPhoto_C
