local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Travel_Department_C = Base:Extend("UMG_Travel_Department_C")

function UMG_Travel_Department_C:OnConstruct()
end

function UMG_Travel_Department_C:OnDestruct()
end

function UMG_Travel_Department_C:OnItemUpdate(_data, datalist, index)
  local id = _data
  if type(id) == "string" then
    self.Icon:SetPath(id)
  elseif type(id) == "table" then
    self.Icon:SetPath(id.path)
    if _data and _data.ShowOutLine then
      self.Outline:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Outline:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    local conf = _G.DataConfigManager:GetTypeDictionary(id, true)
    local field_res = conf and conf.field_res
    self.Icon:SetPath(field_res)
  end
end

function UMG_Travel_Department_C:OnItemSelected(_bSelected)
end

function UMG_Travel_Department_C:OnDeactive()
end

return UMG_Travel_Department_C
