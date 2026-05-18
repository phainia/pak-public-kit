local PreProcessEnterBattleAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.PreProcessEnterBattleAction")
local Base = PreProcessEnterBattleAction
local PreProcessEnterBloodTeamBattleAction = PreProcessEnterBattleAction:Extend("PreProcessEnterBloodTeamBattleAction")

function PreProcessEnterBloodTeamBattleAction:OnEnter()
  self.hasTick = false
  self:OnTick()
end

function PreProcessEnterBloodTeamBattleAction:OnTick(DeltaTime)
  if self.hasTick then
    return
  end
  local skillPath = BattleConst.TeamBloodBossEffect
  local class = BattleResourceManager:GetCacheAssetDirect(skillPath)
  if class then
    BattleUtils.ForceUpdateIndexMap()
    Base.OnEnter(self)
    self.hasTick = true
  end
end

function PreProcessEnterBloodTeamBattleAction:LoadBattleLevel()
  BattleUtils.TeleportEnvActorInZ()
  self:FindLevelBattleCenter()
end

return PreProcessEnterBloodTeamBattleAction
