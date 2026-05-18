local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local Base = RocoSkillAction
local RocoBattleRuntimeParamsAction = Base:Extend("RocoBattleRuntimeParamsAction")

function RocoBattleRuntimeParamsAction:Ctor()
  Base.Ctor(self)
end

function RocoBattleRuntimeParamsAction:OnActionStart()
  if not _G.BattleManager then
    return
  end
  local battleCameraManager = _G.BattleManager.vBattleField.battleCameraManager
  if battleCameraManager then
    battleCameraManager:SetLockCameraByG6(self.bLockBattleCamera)
  end
end

function RocoBattleRuntimeParamsAction:OnActionEnd()
  if self.bRevertOnActionEnd then
    if not _G.BattleManager then
      return
    end
    local battleCameraManager = _G.BattleManager.vBattleField.battleCameraManager
    if battleCameraManager then
      battleCameraManager:SetLockCameraByG6(false)
    end
  end
end

return RocoBattleRuntimeParamsAction
