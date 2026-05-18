local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Email_AnnouncementItme_C = Base:Extend("UMG_Email_AnnouncementItme_C")

function UMG_Email_AnnouncementItme_C:OnConstruct()
end

function UMG_Email_AnnouncementItme_C:OnDestruct()
end

function UMG_Email_AnnouncementItme_C:OnItemUpdate(_data, datalist, index)
  if _data.banner == nil or _data.banner == "" then
    self.Banner:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Banner:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local iconPath = _data.banner
    self.Banner:SetPath(iconPath)
  end
  self.Dialogue:SetText(_data.contents)
end

return UMG_Email_AnnouncementItme_C
