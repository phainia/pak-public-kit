local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleSetupBattleEnvAction = Base:Extend("BattleSetupBattleEnvAction")

function BattleSetupBattleEnvAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleSetupBattleEnvAction:OnEnter()
  if not BattleEnv.isInit then
    local tArray = UE4.UGameplayStatics.GetAllActorsOfClass(UE4Helper.GetCurrentWorld(), UE4.ARecastNavMesh)
    for i, v in tpairs(tArray) do
      Log.Debug("tarray i:", v:GetName())
      if v:GetName() == "RecastNavMesh-BattleField" then
        BattleEnv.RecastNavMesh_BattleField = v
        Log.Debug("BattleSetupBattleEnvAction RecastNavMesh-BattleField")
      elseif v:GetName() == "RecastNavMesh-Default" then
        BattleEnv.RecastNavMesh_Default = v
        Log.Debug("BattleSetupBattleEnvAction RecastNavMesh-Default")
      end
    end
    if not BattleEnv.RecastNavMesh_BattleField then
      Log.Error("BattleSetupBattleEnvAction OnEnter BattleEnv.RecastNavMesh_BattleField is nil!!!")
    end
    if not BattleEnv.RecastNavMesh_Default then
      Log.Error("BattleSetupBattleEnvAction OnEnter BattleEnv.RecastNavMesh_Default is nil!!!")
    end
    BattleEnv.isInit = true
  else
  end
  self:Finish()
end

function BattleSetupBattleEnvAction:OnExit()
end

return BattleSetupBattleEnvAction
