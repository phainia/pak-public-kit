local EventDispatcher = require("Common.EventDispatcher")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local WorldCombatResLoadComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatResLoadComponent")
local WorldCombatActionBase = Class("WorldCombatActionBase")
WorldCombatActionBase.EActionType = {instant = "instant", duration = "duration"}

function WorldCombatActionBase:Ctor(Runner, SkillId, ActionType, ServerInfo)
  EventDispatcher():Attach(self)
  self:InitAttr(Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionBase:InitAttr(Runner, SkillId, ActionType, ServerInfo)
  self.Runner = Runner
  self.SkillId = SkillId
  self.ActionType = ActionType
  self.ServerInfo = ServerInfo
  self.Owner = self.Runner:EnsureComponent(WorldCombatSkillComponent)
  self.skillObj = self.Owner.skillObj
  self.actionType = WorldCombatActionBase.EActionType.instant
  self.actionDuration = 0
  self.needTick = false
  self.finishControlBySelf = false
  self.forceFinshWithSkillEnd = true
  self.enable = true
  self.bossNpcId = self.Runner.serverData.base.actor_id
  if self.Runner.config.genre == _G.Enum.ClientNpcType.CNT_BOSS_SKILL_ITEM then
    self.bossNpcId = self.Runner.serverData.npc_base.src_npc_id
  end
end

function WorldCombatActionBase:ReleaseDataBeforeRecycle()
end

function WorldCombatActionBase:Recycle()
  if not self.bNeedRecycle then
    return
  end
  self:ReleaseDataBeforeRecycle()
  local WorldCombatActionFactory = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionFactory")
  WorldCombatActionFactory:Recycle(self)
end

function WorldCombatActionBase:CanExecute()
  return true
end

function WorldCombatActionBase:Execute(module)
  if not self:CanExecute() then
    return
  end
  self.module = module
  self.module:AddSkillAction(self, self.bossNpcId)
  self:PreExecute()
  self:InternalExecute()
  self:PostExecute()
end

function WorldCombatActionBase:PreExecute()
end

function WorldCombatActionBase:InternalExecute()
  Log.Debug("WorldCombatAction InternalExecute: ", self.name, self.SkillId, self.ActionType)
end

function WorldCombatActionBase:CheckNeedTick()
  return false
end

function WorldCombatActionBase:StopTick()
  _G.UpdateManager:UnRegister(self)
end

function WorldCombatActionBase:PostExecute()
  if self:CheckNeedTick() then
    _G.UpdateManager:Register(self)
  else
    self:OnTick(0.033)
  end
  if self.isFinished then
    return
  end
  if self.actionType == WorldCombatActionBase.EActionType.duration and self.actionDuration > 0 then
    self.DelayHandle = _G.DelayManager:DelaySeconds(self.actionDuration, self.HandleDelay, self)
    return
  end
  if not self.finishControlBySelf and not self:CheckNeedTick() then
    self:Finish()
  else
    self.Runner:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.OnSkillCastEnd)
  end
end

function WorldCombatActionBase:OnTick(DeltaTime)
end

function WorldCombatActionBase:HandleDelay()
  self:StopTick()
  self:Finish()
end

function WorldCombatActionBase:OnSkillCastEnd(skillId)
  if self.Runner then
    self.Runner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.OnSkillCastEnd)
  end
  if self.SkillId == skillId then
    self:Finish()
  end
end

function WorldCombatActionBase:Finish()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
  if self.Runner then
    self.Runner:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.OnSkillCastEnd)
  end
  if self.module then
    self.module:RemoveSkillAction(self, self.bossNpcId)
  end
  self.module = nil
  self.Runner = nil
  self.SkillId = nil
  self.ServerInfo = nil
  self.Owner = nil
  self.skillObj = nil
  self.skillAction = nil
  self.isFinished = true
  self:StopTick()
  self:OnFinish()
end

function WorldCombatActionBase:OnFinish()
  self:Recycle()
end

function WorldCombatActionBase:GetSkillActionByGuid(Guid)
  if self.skillAction then
    return self.skillAction
  end
  if self.Runner.config.genre == _G.Enum.ClientNpcType.CNT_BULLET then
    return self:InternalGetSkillAction(Guid)
  end
  if not self.skillObj or self.skillObj:GetSkillID() ~= self.SkillId then
    local skillConf = _G.DataConfigManager:GetWorldCombatSkillConf(self.SkillId, true)
    if not skillConf or not skillConf.skill_ref then
      return nil
    end
    local WorldCombatResLoadComp = self.Owner.owner:EnsureComponent(WorldCombatResLoadComponent)
    local skillClassPath = NRCUtils.FormatBlueprintAssetPath(skillConf.skill_ref)
    if table.containsKey(WorldCombatResLoadComp.skillObjList, skillClassPath) then
      self.skillObj = WorldCombatResLoadComp.skillObjList[skillClassPath]
    else
      WorldCombatResLoadComp:AddSkillIdToLoad(self.SkillId)
    end
  end
  return self:InternalGetSkillAction(Guid)
end

function WorldCombatActionBase:InternalGetSkillAction(Guid)
  if not self.skillObj then
    return
  end
  local actions = self.skillObj:GetAllActions()
  local targetAction
  for i = 1, actions:Length() do
    local action = actions:Get(i)
    if action.GUID == Guid or action.Guid == Guid then
      targetAction = action
      break
    end
  end
  return targetAction
end

function WorldCombatActionBase:OnSkillActionPrepared(actionGuid)
  if not actionGuid then
    return
  end
  self.skillAction = self:InternalGetSkillAction(actionGuid)
end

function WorldCombatActionBase:GetTargetByServerInfo()
  local target = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.ServerInfo.target_id)
  target = target or _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, self.ServerInfo.target_id)
  return target
end

function WorldCombatActionBase:ProcessPerformOnReConnect(skillId, actionData)
end

return WorldCombatActionBase
