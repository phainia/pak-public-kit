local Base = require("NewRoco.UI.Battle.Settlement.UMG_BattleSettlementSingle_C")
local UMG_BattleSettlementLose_C = Base:Extend("UMG_BattleSettlementLose_C")

function UMG_BattleSettlementLose_C:Destruct()
  if self.BagItemListView then
    self.BagItemListView:Destroy()
  end
end

return UMG_BattleSettlementLose_C
