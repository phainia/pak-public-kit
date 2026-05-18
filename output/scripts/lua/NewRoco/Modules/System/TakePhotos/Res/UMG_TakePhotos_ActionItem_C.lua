local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TakePhotos_ActionItem_C = Base:Extend("UMG_TakePhotos_ActionItem_C")

function UMG_TakePhotos_ActionItem_C:OnConstruct()
  self.btnLevelUp:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SelectedAtEnd = nil
end

function UMG_TakePhotos_ActionItem_C:OnDestruct()
end

function UMG_TakePhotos_ActionItem_C:OnItemUpdate(_data, datalist, index)
  self.Image_Icon:SetPath(_data.PoseConf.icon or "")
  self.Text_Title:SetText(_data.PoseConf.name or "")
  self.Data = _data
end

function UMG_TakePhotos_ActionItem_C:OnItemSelected(bSelected)
  if bSelected then
    self.Data.OnClicked()
    if not self.SelectedAtEnd then
      self.SelectedAtEnd = true
      self:PlayAnimationForward(self.Selected_in)
    end
  elseif self.SelectedAtEnd then
    self.SelectedAtEnd = false
    self:PlayAnimationReverse(self.Selected_in)
  end
end

return UMG_TakePhotos_ActionItem_C
