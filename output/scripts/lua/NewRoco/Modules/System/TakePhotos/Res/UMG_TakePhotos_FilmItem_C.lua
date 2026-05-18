local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TakePhotos_FilmItem_C = Base:Extend("UMG_TakePhotos_FilmItem_C")

function UMG_TakePhotos_FilmItem_C:OnConstruct()
end

function UMG_TakePhotos_FilmItem_C:OnDestruct()
  if self._data and self._data.PhotoData then
    self._data.PhotoData:RemoveTextureReadyDelegate(self, self.OnTextureReady)
  end
end

function UMG_TakePhotos_FilmItem_C:OnTextureReady(Data)
  if self._data and self._data.PhotoData == Data then
    local Texture = Data:GetThumbnailTexture(self._index)
    if Texture then
      self:RefreshTexture(Texture)
    end
  end
end

function UMG_TakePhotos_FilmItem_C:RefreshTexture(Texture)
  local DesiredWidth, DesiredHeight = self._data:GetDesiredThumbnailSize()
  local ThumbnailWidth = Texture:Blueprint_GetSizeX()
  local ThumbnailHeight = Texture:Blueprint_GetSizeY()
  local ScaleToViewWidth = DesiredWidth / ThumbnailWidth
  local ScaleToViewHeight = DesiredHeight / ThumbnailHeight
  local MaxiScale = math.max(ScaleToViewWidth, ScaleToViewHeight)
  DesiredWidth = MaxiScale * ThumbnailWidth
  DesiredHeight = MaxiScale * ThumbnailHeight
  self.Photograph:SetBrush(UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(Texture, math.floor(DesiredWidth), math.floor(DesiredHeight)))
  self.Switcher:SetActiveWidgetIndex(0)
end

function UMG_TakePhotos_FilmItem_C:OnItemUpdate(_data, datalist, index)
  if self._data and _data ~= self._data and self._data.PhotoData then
    self._data.PhotoData:RemoveTextureReadyDelegate(self, self.OnTextureReady)
  end
  self._data = _data
  if _data.SerialId then
    local Texture = _data.PhotoData:GetThumbnailTexture(self._index)
    if Texture then
      self:RefreshTexture(Texture)
    else
      self.Switcher:SetActiveWidgetIndex(1)
      _data.PhotoData:AddTextureReadyDelegate(self, self.OnTextureReady)
    end
    if _data.bRemoveMode then
      self.Check:SetVisibility(UE.ESlateVisibility.Visible)
      if _data.bSelected then
        self.Select:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        self.NRCImage_1:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      else
        self.Select:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.NRCImage_1:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    else
      self.Check:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
  if _data.CreateDateText then
    self.Time:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Time:SetText(_data.CreateDateText)
  else
    self.Time:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_TakePhotos_FilmItem_C:OnItemSelected(_bSelected)
  if _bSelected and self._data.DoSelectDelegate and self._data.DoSelectDelegate() then
    if self._data.bSelected then
      self.Select:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.NRCImage_1:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    else
      self.Select:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.NRCImage_1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_TakePhotos_FilmItem_C:OnDeactive()
end

return UMG_TakePhotos_FilmItem_C
