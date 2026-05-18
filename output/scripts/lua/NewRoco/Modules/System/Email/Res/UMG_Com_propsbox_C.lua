local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Com_propsbox_C = Base:Extend("UMG_Com_propsbox_C")

function UMG_Com_propsbox_C:OnConstruct()
end

function UMG_Com_propsbox_C:OnDestruct()
end

function UMG_Com_propsbox_C:OnItemUpdate(_data, datalist, index)
  self.ItemConf = self:GetItemConf(_data.id)
end

function UMG_Com_propsbox_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.ItemConf.id, self.ItemConf.type, false)
  end
end

function UMG_Com_propsbox_C:GetItemConf(itemID)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemID)
  return bagItemConf
end

return UMG_Com_propsbox_C
