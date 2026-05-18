require("UnLuaEx")
local UMG_BattleSettlementSingle_C = NRCUmgClass:Extend("")

function UMG_BattleSettlementSingle_C:Construct()
  self.Overridden.Construct(self)
  self.petInfoUI = {
    self.PetInfo1,
    self.PetInfo2,
    self.PetInfo3,
    self.PetInfo4,
    self.PetInfo5,
    self.PetInfo6
  }
end

return UMG_BattleSettlementSingle_C
