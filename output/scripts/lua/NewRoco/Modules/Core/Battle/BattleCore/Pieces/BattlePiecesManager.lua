local BattlePiecesManager = NRCClass()
local _instanceId = 0

local function GetInstanceId()
  _instanceId = _instanceId + 1
  return _instanceId
end

function BattlePiecesManager:Init(performPlayer)
  self.battlePerformPlayer = performPlayer
  self.piecesDict = {}
end

function BattlePiecesManager:Play(BattlePieceUrl, ...)
  if not self.piecesDict then
    self.piecesDict = {}
  end
  local piece = reload(BattlePieceUrl)
  local pieceInstance = piece()
  local instanceId = GetInstanceId()
  pieceInstance:Play(...)
  pieceInstance:SetInstanceId(instanceId)
  if self.piecesDict then
    self.piecesDict[instanceId] = pieceInstance
  end
  return pieceInstance
end

function BattlePiecesManager:OnPieceComplete(instanceId)
  if instanceId and self.piecesDict then
    self.piecesDict[instanceId] = nil
  end
end

return BattlePiecesManager
