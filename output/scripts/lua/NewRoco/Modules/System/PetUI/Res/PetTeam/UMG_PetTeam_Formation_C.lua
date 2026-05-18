local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local UMG_PetTeam_Formation_C = Base:Extend("UMG_PetTeam_Formation_C")

function UMG_PetTeam_Formation_C:OnConstruct()
end

function UMG_PetTeam_Formation_C:OnDestruct()
end

function UMG_PetTeam_Formation_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetupUI()
end

function UMG_PetTeam_Formation_C:OnItemSelected(_bSelected)
end

function UMG_PetTeam_Formation_C:OnDeactive()
end

function UMG_PetTeam_Formation_C:SetupUI()
  local uiData = self.uiData
  if uiData.isHasPet == true then
    self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetPath(uiData.petIcon.icon)
    self.NumText:SetText(uiData.level)
  else
    self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetTeam_Formation_C:SetItemBG(isActive)
  self.BGColor:SetVisibility(isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.BGColor_1:SetVisibility(not isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
end

return UMG_PetTeam_Formation_C
