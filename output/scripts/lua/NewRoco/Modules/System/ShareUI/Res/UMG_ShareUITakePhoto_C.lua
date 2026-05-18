local UMG_ShareUITakePhoto_C = _G.NRCPanelBase:Extend("UMG_ShareUITakePhoto_C")

function UMG_ShareUITakePhoto_C:OnActive(data)
  self.data = data
  local texture = UE.UKismetRenderingLibrary.ImportFileAsTexture2D(_G.UE4Helper.GetCurrentWorld(), self.data.photoPath)
  if texture and UE.UObject.IsValid(texture) then
    self.PhotoSub.Photo:SetBrushFromTexture(texture)
  end
  
  local function cb()
    local wndSize = UE4.UWidgetLayoutLibrary.GetViewportSize(_G.UE4Helper.GetCurrentWorld())
    local photoSize = self.PhotoSub.Photo.Slot:GetSize()
    local scaleX = photoSize.X * 1.0 / wndSize.X * 1.0
    local scaleY = photoSize.Y * 1.0 / wndSize.Y * 1.0
    if scaleX > scaleY then
      photoSize.X = wndSize.X * scaleY
    else
      photoSize.Y = wndSize.Y * scaleX
    end
    self.PhotoSub.Photo.Slot:SetSize(photoSize)
  end
  
  self.delayId = _G.DelayManager:DelayFrames(2, cb, self)
end

function UMG_ShareUITakePhoto_C:OnDeactive()
  self:CancelDelayId()
end

function UMG_ShareUITakePhoto_C:CancelDelayId()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

return UMG_ShareUITakePhoto_C
