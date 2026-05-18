local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_CommonPicture_C = Base:Extend("UMG_Activity_CommonPicture_C")

function UMG_Activity_CommonPicture_C:OnItemUpdate(_data, datalist, index)
  self.Image_35:SetPath(_data)
  local pictureCustomData = self:GetParentCustomData()
  if pictureCustomData and pictureCustomData.controlByPageController then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_Activity_CommonPicture_C:OnItemSelected(_bSelected)
end

function UMG_Activity_CommonPicture_C:OnDeactive()
end

return UMG_Activity_CommonPicture_C
