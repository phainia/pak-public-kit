local BattleInfoTypes = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.BattleInfoTypes")
local BattleInfoContainer = NRCClass("BattleInfoManager")

function BattleInfoContainer:Ctor(matchFlags)
  self.infos = {}
  self.matchFlags = matchFlags
end

function BattleInfoContainer:AddInfo(info)
  if self._IsMatchFlags and not self:_IsMatchFlags(info) then
    Log.Warn("BattleInfoContainer:ModifyPetInfo error, info flag is not Class4")
    return false
  end
  local guid = info:GetGuid()
  if guid == BattleInfoTypes.InvalidGuid then
    Log.Error("BattleInfoContainer:ModifyPetInfo error, info guid is InvalidGuid")
    return false
  end
  self.infos[guid] = info
end

function BattleInfoContainer:RemoveInfo(guid)
  if self.infos[guid] then
    self.infos[guid] = nil
    Log.Debug("BattleInfoContainer:RemovePetInfo success, guid=", guid)
  end
end

function BattleInfoContainer:FindInfo(guid)
  local info = self.infos[guid]
  return info
end

function BattleInfoContainer:GetInfos()
  local infosCopy = table.shallowCopy(self.infos)
  return infosCopy
end

function BattleInfoContainer:ConditionalRemoveInfos(except_guids)
  local delete_ids = {}
  for guid, info in pairs(self.infos) do
    if not table.contains(except_guids, guid) then
      table.insert(delete_ids, guid)
    end
  end
  local deleteNums = #delete_ids
  for i = 1, deleteNums do
    self:RemoveInfo(delete_ids[i])
  end
  return deleteNums
end

function BattleInfoContainer:_IsMatchFlags(info)
  if info then
    return 0 ~= info:GetInfoFlags() & self.matchFlags
  end
  return false
end

return BattleInfoContainer
