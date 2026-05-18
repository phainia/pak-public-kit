local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MiracleExchange_Item_C = Base:Extend("UMG_MiracleExchange_Item_C")

function UMG_MiracleExchange_Item_C:OnConstruct()
end

function UMG_MiracleExchange_Item_C:OnDestruct()
end

function UMG_MiracleExchange_Item_C:OnItemUpdate(_Petdata)
  self.PetList = _Petdata
  self:SetData()
end

function UMG_MiracleExchange_Item_C:SetData()
  local petList = self.PetList
  self.ItemIcon:SetPath(petList.PetIcon.icon)
  UIUtils.GetPetQuality(self.BGColor, petList.PetBasicProperty)
end

function UMG_MiracleExchange_Item_C:OnDeactive()
end

return UMG_MiracleExchange_Item_C
