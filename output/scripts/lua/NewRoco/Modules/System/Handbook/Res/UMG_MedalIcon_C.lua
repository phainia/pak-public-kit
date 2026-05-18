local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MedalIcon_C = Base:Extend("UMG_MedalIcon_C")

function UMG_MedalIcon_C:OnConstruct()
end

function UMG_MedalIcon_C:OnDestruct()
end

function UMG_MedalIcon_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local medalConf = _G.DataConfigManager:GetMedalConf(self.data.conf_id)
  if medalConf then
    self.MedaIcon:SetPath(medalConf.icon)
  end
end

function UMG_MedalIcon_C:OnItemSelected(_bSelected)
end

function UMG_MedalIcon_C:OnDeactive()
end

return UMG_MedalIcon_C
