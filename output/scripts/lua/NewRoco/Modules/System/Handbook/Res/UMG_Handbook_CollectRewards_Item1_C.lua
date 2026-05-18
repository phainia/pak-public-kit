local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local UMG_Handbook_CollectRewards_Item1_C = Base:Extend("UMG_Handbook_CollectRewards_Item1_C")

function UMG_Handbook_CollectRewards_Item1_C:OnConstruct()
end

function UMG_Handbook_CollectRewards_Item1_C:Init(index)
  self.index = index
  self.NRCButton_196.OnClicked:Remove(self, self.ToPage)
  self.NRCButton_196.OnClicked:Add(self, self.ToPage)
end

function UMG_Handbook_CollectRewards_Item1_C:ToPage()
  _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnCollectRewardsToPage, self.index)
end

function UMG_Handbook_CollectRewards_Item1_C:ChangeToPage(index)
  if index ~= self.index then
    self.NRCImage_12:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage_65:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImage_12:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_65:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Handbook_CollectRewards_Item1_C:OnDestruct()
end

function UMG_Handbook_CollectRewards_Item1_C:OnItemUpdate(_data, datalist, index)
end

function UMG_Handbook_CollectRewards_Item1_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_CollectRewards_Item1_C:OnDeactive()
end

return UMG_Handbook_CollectRewards_Item1_C
