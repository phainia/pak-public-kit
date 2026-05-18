local Base = require("NewRoco.UI.Battle.Settlement.UMG_BattleSettlementSingle_C")
local UMG_BattleSettlementWin_C = Base:Extend("UMG_BattleSettlementWin_C")

function UMG_BattleSettlementWin_C:Destruct()
  if self.BagItemListView then
    self.BagItemListView:Destroy()
  end
end

return UMG_BattleSettlementWin_C
