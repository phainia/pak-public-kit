local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagPetItem_C = Base:Extend("UMG_BagPetItem_C")

function UMG_BagPetItem_C:OnConstruct()
  self.uiData = {}
end

function UMG_BagPetItem_C:SetData(_data)
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_BagPetItem_C:updateItemInfo()
  if not self.uiData.baseID then
    return
  end
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.baseID)
  if not petbaseConf then
    return
  end
  local modelConf = _G.DataConfigManager:GetModelConf(petbaseConf.model_conf)
  if not modelConf then
    return
  end
  self.icon:SetPath(modelConf.icon)
end

function UMG_BagPetItem_C:OnItemClick()
  Log.Debug("UMG_BagPetItem_C:OnItemClick")
end

return UMG_BagPetItem_C
