local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagScrrenItem_C = Base:Extend("UMG_BagScrrenItem_C")

function UMG_BagScrrenItem_C:OnConstruct()
end

function UMG_BagScrrenItem_C:OnDestruct()
end

function UMG_BagScrrenItem_C:OnItemUpdate(_data, datalist, index)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.base_conf_id)
  if PetBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
    if modelConf then
      self.HeadIcon:SetPath(modelConf.icon)
    end
  end
  self.data = _data
  self.SortText:SetText(_data.name)
  self.Switcher:SetActiveWidgetIndex(1)
  self.PetBaseId = _data.base_conf_id
  self.clickToggle = false
end

function UMG_BagScrrenItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagScrrenItem_C:OnItemSelected")
    self.clickToggle = not self.clickToggle
  end
  _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, -1, self.data.base_conf_id, self.clickToggle)
  if self.clickToggle then
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  self.Switcher:SetActiveWidgetIndex(self.clickToggle and 0 or 1)
end

function UMG_BagScrrenItem_C:OnDeactive()
end

return UMG_BagScrrenItem_C
