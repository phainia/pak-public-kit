local BattlePiecesBase = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.BattlePiecesBase")
local Base = BattlePiecesBase
local BattlePieceNPCThinking = Base:Extend("BattlePieceNPCThinking")

function BattlePieceNPCThinking:Play(isPause)
  self.performPlayer:Pause()
end

function BattlePieceNPCThinking:OnComplete()
  self.performPlayer:Resume()
end

return BattlePieceNPCThinking
