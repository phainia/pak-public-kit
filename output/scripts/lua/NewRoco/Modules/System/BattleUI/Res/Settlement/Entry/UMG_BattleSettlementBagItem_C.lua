require("UnLuaEx")
local UMG_BattleSettlementBagItem_C = NRCUmgClass:Extend("")

function UMG_BattleSettlementBagItem_C:SetData(context)
  local data = context.data.data
  context.data.item = self
  self.BagItemIcon:SetData(data.id, data.type, data.num, true)
end

return UMG_BattleSettlementBagItem_C
