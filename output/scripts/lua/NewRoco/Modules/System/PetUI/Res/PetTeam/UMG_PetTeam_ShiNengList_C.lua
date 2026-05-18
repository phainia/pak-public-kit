local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetTeam_ShiNengList_C = Base:Extend("UMG_PetTeam_ShiNengList_C")

function UMG_PetTeam_ShiNengList_C:OnConstruct()
end

function UMG_PetTeam_ShiNengList_C:OnDestruct()
end

function UMG_PetTeam_ShiNengList_C:OnItemUpdate(_data, datalist, index)
  if _data.activedNum then
    self.Text:SetText(_data.activedNum)
    self.ShiNeng:SetPath(_data.typeCfg.type_icon)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetTeam_ShiNengList_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.SelectPetDept)
  end
end

function UMG_PetTeam_ShiNengList_C:OnDeactive()
end

return UMG_PetTeam_ShiNengList_C
