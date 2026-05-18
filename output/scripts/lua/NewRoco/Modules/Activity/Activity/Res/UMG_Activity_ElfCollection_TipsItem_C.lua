local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_ElfCollection_TipsItem_C = Base:Extend("UMG_Activity_ElfCollection_TipsItem_C")

function UMG_Activity_ElfCollection_TipsItem_C:OnItemUpdate(_data, datalist, index)
  self.Name:SetText(_data)
  self.sortText:SetText(index)
end

function UMG_Activity_ElfCollection_TipsItem_C:HideLine()
  self.NRCImage_63:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

return UMG_Activity_ElfCollection_TipsItem_C
