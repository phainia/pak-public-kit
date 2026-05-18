local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FashionSuitData = NRCClass()

function FashionSuitData:Ctor()
  local Empty = ""
  self.Owner = nil
  self.suitConf = nil
  self.bondConfs = {}
  self.HuanChong = Empty
  self.EnemyHuanChong = Empty
  self.PVPOver = Empty
  self.LastHitPetBaseId = -1
  self.LastHitGID = -1
  self.SuitPetBaseIds = {}
end

function FashionSuitData:SetOwner(player)
  self.Owner = player
end

function FashionSuitData:GetHuanChong(petBaseId)
  if table.contains(self.SuitPetBaseIds, petBaseId) then
    if self.Owner.teamEnm == BattleEnum.Team.ENUM_TEAM then
      return self.HuanChong
    else
      return self.EnemyHuanChong
    end
  elseif self.Owner.teamEnm == BattleEnum.Team.ENUM_TEAM then
    return BattleConst.HuanChong
  else
    return BattleConst.EnemyHuanChong
  end
end

function FashionSuitData:GetPVPOver()
  if self.SuitPetBaseIds and table.contains(self.SuitPetBaseIds, self.LastHitPetBaseId) then
    return self.PVPOver, true
  end
  return BattleConst.PVPOver
end

return FashionSuitData
