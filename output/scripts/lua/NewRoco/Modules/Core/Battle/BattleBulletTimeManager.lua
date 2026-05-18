local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleBulletTimeManager = NRCClass()

function BattleBulletTimeManager:Ctor()
end

function BattleBulletTimeManager:EnterBulletTime(Type, WorldChangeType, World, WorldTimeParam, ActorChangeType, AttachActors, ActorTimeParam)
  if not BattleManager:IsInBattle(true) then
    return false
  end
  local Actors = UE.TArray(UE.AActor)
  for i = 1, #AttachActors do
    Actors:Add(AttachActors[i])
  end
  return UE4.UNRCStatics.AddBulletTimeTask(Type, WorldChangeType, World, WorldTimeParam, ActorChangeType, Actors, ActorTimeParam)
end

function BattleBulletTimeManager:LeaveBulletTime(BulletId)
  if not BattleManager:IsInBattle(true) then
    return false
  end
  UE4.UNRCStatics.RemoveBulletTimeTask(BulletId)
end

function BattleBulletTimeManager:ChangeBulletTimeTask(Id, WorldTimeParam, ActorTimeParam)
  if not BattleManager:IsInBattle(true) then
    return false
  end
  UE4.UNRCStatics.ChangeBulletTimeTask(Id, WorldTimeParam or 1, ActorTimeParam or -1)
end

function BattleBulletTimeManager:ClearAll()
  UE4.UNRCStatics.DisableBulletTime()
end

return BattleBulletTimeManager
