local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local TargetTime = 0.5
local UseLerp = true
local WorldCombatActionMissileStopTrace = Base:Extend("WorldCombatActionMissileStopTrace")

function WorldCombatActionMissileStopTrace:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionMissileStopTrace:PreExecute()
  Base.PreExecute(self)
  self.needTick = true
  self.actionType = WorldCombatActionBase.EActionType.duration
  self.actionDuration = TargetTime
end

function WorldCombatActionMissileStopTrace:CheckNeedTick()
  return true
end

function WorldCombatActionMissileStopTrace:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local missile = NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, self.ServerInfo.launch_bullet_id)
  if not missile then
    return
  end
  local nextPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.pt.pos)
  local nextDir = SceneUtils.Point2Rot(self.ServerInfo.pt):ToVector()
  local posDiff = (nextPos - missile:GetActorLocation()):Size()
  if UseLerp and posDiff > 30 then
    self.targetPos = nextPos + nextDir * (missile.missileComp.speed * TargetTime)
    self.startTime = UE4.UNRCStatics.GetTimestampMS()
  else
    missile:SetActorLocation(nextPos)
    missile:SetActorRotation(nextDir:ToRotator())
    missile.missileComp.isStraight = true
  end
end

function WorldCombatActionMissileStopTrace:OnTick(DeltaTime)
  Base.OnTick(self, DeltaTime)
  if not (self.Runner and self.Runner.viewObj and self.targetPos) or not self.startTime then
    return
  end
  local missile = NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, self.ServerInfo.launch_bullet_id)
  if not missile or not missile.missileComp then
    return
  end
  local param = _G.math.min(_G.math.max((UE4.UNRCStatics.GetTimestampMS() - self.startTime) / (TargetTime * 1000), 0), 1)
  local currPos = missile:GetActorLocation()
  missile.missileComp.targetPos = _G.LuaMathUtils.LerpVector(currPos, self.targetPos, param)
  Log.Debug("WorldCombatActionMissileStopTrace:OnTick", self.Runner:DebugNPCNameAndID(), currPos, SceneUtils.ServerPos2ClientPos(self.ServerInfo.pt.pos), missile.missileComp.targetPos, self.targetPos)
end

function WorldCombatActionMissileStopTrace:Finish()
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  local missile = NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, self.ServerInfo.launch_bullet_id)
  if not missile or not missile.missileComp then
    return
  end
  missile:SetActorRotation(SceneUtils.Point2Rot(self.ServerInfo.pt))
  missile.missileComp.logicDir = SceneUtils.Point2Rot(self.ServerInfo.pt):ToVector()
  missile.missileComp.isStraight = true
  Base.Finish(self)
end

return WorldCombatActionMissileStopTrace
