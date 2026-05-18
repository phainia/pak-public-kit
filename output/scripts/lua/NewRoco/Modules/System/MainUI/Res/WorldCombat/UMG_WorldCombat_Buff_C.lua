local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_WorldCombat_Buff_C = Base:Extend("UMG_WorldCombat_Buff_C")

function UMG_WorldCombat_Buff_C:OnConstruct()
end

function UMG_WorldCombat_Buff_C:OnDestruct()
end

function UMG_WorldCombat_Buff_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_WorldCombat_Buff_C:SetInfo()
  local data = self.data
  local BuffConf = _G.DataConfigManager:GetBuffConf(data.buff_id)
  if 0 ~= data.stack then
    self.BuffStackText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BuffStackText:SetText(data.stack)
  end
  self.Buff:SetPath(BuffConf.icon)
  self.BuffStackText:SetText(data.stack)
end

function UMG_WorldCombat_Buff_C:OnItemSelected(_bSelected)
end

function UMG_WorldCombat_Buff_C:OnDeactive()
end

return UMG_WorldCombat_Buff_C
