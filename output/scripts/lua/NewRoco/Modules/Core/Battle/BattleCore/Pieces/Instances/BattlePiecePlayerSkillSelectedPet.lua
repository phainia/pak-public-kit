local BattlePiecesBase = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.BattlePiecesBase")
local Base = BattlePiecesBase
local BattlePiecePlayerSkillSelectedPet = Base:Extend("BattlePiecePlayerSkillSelectedPet")

function BattlePiecePlayerSkillSelectedPet:Ctor()
  Base.Ctor(self)
end

return BattlePiecePlayerSkillSelectedPet
