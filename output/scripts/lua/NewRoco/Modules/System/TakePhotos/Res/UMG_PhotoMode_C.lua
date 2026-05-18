local UMG_PhotoMode_C = _G.NRCViewBase:Extend("UMG_PhotoMode_C")

function UMG_PhotoMode_C:OnConstruct()
end

function UMG_PhotoMode_C:OnDestruct()
end

function UMG_PhotoMode_C:OnItemUpdate(_data)
  self.TextTitle:SetText(_data.Title or "")
  self.Image_Icon:SetPath(_data.IconPath or "")
end

function UMG_PhotoMode_C:SetSelected(bSelect)
  if bSelect then
    self:PlayAnimationForward(self.In)
  else
    self:PlayAnimationReverse(self.In)
  end
end

return UMG_PhotoMode_C
