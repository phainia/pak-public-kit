local DelaySafeCaller = require("NewRoco.Modules.Core.Battle.Common.DelaySafeCaller")
local BattlePiecesBase = NRCClass()

function BattlePiecesBase:Ctor(pieceData, node)
  self.delaySafeCaller = DelaySafeCaller()
  self.isRunning = false
  self.pieceData = pieceData
  if node then
    self.performPlayer = node.performPlayer
  elseif _G.BattleManager:GetTurnPlayer() then
    self.performPlayer = _G.BattleManager:GetTurnPlayer().performPlayer
  end
  self.isPausePerformPlayer = false
  self.node = node
end

function BattlePiecesBase:SetInstanceId(instanceId)
  self.instanceId = instanceId
end

function BattlePiecesBase:Play(...)
  self.delaySafeCaller:Reuse()
  if self.OnPlay then
    self:OnPlay(...)
  end
end

function BattlePiecesBase:Complete()
  self.delaySafeCaller:Reset()
  if self.instanceId then
    BattlePiecesManager:OnPieceComplete(self.instanceId)
  end
  if self.OnComplete then
    self:OnComplete()
  end
end

function BattlePiecesBase:IsRunning()
  return self.isRunning
end

function BattlePiecesBase:SafeDelaySeconds(idName, ...)
  self.delaySafeCaller:SafeDelaySeconds(idName, ...)
end

function BattlePiecesBase:SafeDelayFrames(idName, ...)
  self.delaySafeCaller:SafeDelayFrames(idName, ...)
end

function BattlePiecesBase:SafeCancelDelayById(idName)
  self.delaySafeCaller:SafeCancelDelayById(idName)
end

function BattlePiecesBase:SafeFindDelayById(idName)
  return self.delaySafeCaller:SafeFindDelayById(idName)
end

return BattlePiecesBase
