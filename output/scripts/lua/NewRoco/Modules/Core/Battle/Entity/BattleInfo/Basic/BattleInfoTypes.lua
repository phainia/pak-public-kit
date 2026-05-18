require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.TableTools")
local BattleInfoTypes = {}
BattleInfoTypes.InvalidGuid = -1
BattleInfoTypes.EFlags = {
  Undefined = 0,
  NetRole_Server = 1,
  NetRole_Autonomous = 2,
  NetRole_Simulated = 4,
  Entity_Player = 16,
  Entity_Pet = 32,
  Combat_InBattle = 256,
  Combat_NotInBattle = 512
}
BattleInfoTypes.EFlags.NetRole_All = 15
BattleInfoTypes.EFlags.Entity_All = 240
BattleInfoTypes.EFlags.Combat_All = 3840
BattleInfoTypes.EFlags.Class1 = BattleInfoTypes.EFlags.NetRole_Server
BattleInfoTypes.EFlags.Class2 = BattleInfoTypes.EFlags.NetRole_Autonomous
BattleInfoTypes.EFlags.Class3 = BattleInfoTypes.EFlags.NetRole_Simulated | BattleInfoTypes.EFlags.Entity_All | BattleInfoTypes.EFlags.Combat_InBattle
BattleInfoTypes.EFlags.Class4 = BattleInfoTypes.EFlags.NetRole_Simulated | BattleInfoTypes.EFlags.Entity_Pet | BattleInfoTypes.EFlags.Combat_NotInBattle
table.makeReadOnly(BattleInfoTypes)
return BattleInfoTypes
