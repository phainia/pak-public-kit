local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetBagGongming_C = Base:Extend("UMG_PetBagGongming_C")

function UMG_PetBagGongming_C:OnConstruct()
end

function UMG_PetBagGongming_C:OnDestruct()
end

function UMG_PetBagGongming_C:OnItemUpdate(_data, datalist, index)
  if _data.activedNum then
    self.Text:SetText(_data.activedNum)
    self.ShiNeng:SetPath(_data.typeCfg.synchron_petbag_icon)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetBagGongming_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.SelectPetDept)
  end
end

function UMG_PetBagGongming_C:OnDeactive()
end

return UMG_PetBagGongming_C
