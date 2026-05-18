local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePlayAnimBaseAction
local BattlePvpPlayerPerformAction = Base:Extend("BattlePvpPlayerPerformAction")

function BattlePvpPlayerPerformAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePvpPlayerPerformAction:FilterPvpPlayerPerformData(battlePerformInfo)
  if #battlePerformInfo > 0 then
    local result = {}
    for _, performInfo in pairs(battlePerformInfo) do
      if performInfo.pvp_perform then
        table.insert(result, performInfo.pvp_perform)
      end
    end
    if #result > 0 then
      local index = math.random(1, #result)
      return result[index]
    else
      return nil
    end
  end
end

function BattlePvpPlayerPerformAction:GetG6SkillPath(type)
  return BattleConst.PvpPlayerPerform[type]
end

function BattlePvpPlayerPerformAction:OnBattleEvent(event, value)
  if event == BattleEvent.OnSkillResLoaded then
    Log.Debug("BattleMultiPvPEnterAction:OnBattleEvent:", event, value)
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      self:PlaySkill()
    end
  end
end

function BattlePvpPlayerPerformAction:GetSkillClass(resPath)
  if _G.BattleSkillManager:IsResLoaded(resPath) then
    return _G.BattleSkillManager:GetLoadedClass(resPath)
  else
    Log.Error("BattleMultiPvPEnterAction:GetSkillClass resPath not loaded resPath=", resPath)
    self:Finish()
  end
end

function BattlePvpPlayerPerformAction:PlaySkill()
  BattleEventCenter:UnBind(self)
  self.skillClass = self:GetSkillClass(self.skillPath)
  local MyPlayer = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
  local EnemyPlayer = _G.BattleManager.battlePawnManager:GetPlayerEnemyTeam()
  local caster, target
  if MyPlayer.guid == self.pvpPlayerPerformData.uin then
    caster = MyPlayer.model
    target = EnemyPlayer.model
  elseif EnemyPlayer.guid == self.pvpPlayerPerformData.uin then
    caster = EnemyPlayer.model
    target = MyPlayer.model
  else
    self:Finish()
    return
  end
  self.SkillComponent = caster.RocoSkill
  self.SkillComponent:ClearAllPassiveSkillObjs()
  self.Skill = self.SkillComponent:FindOrAddSkillObj(self.skillClass)
  self.Skill:SetCaster(caster)
  self.Skill:SetTargets({target})
  self.Skill:SetPassive(true)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  self.SkillComponent:PlaySkill(self.Skill)
end

function BattlePvpPlayerPerformAction:OnSkillEnd()
  self:Finish()
end

function BattlePvpPlayerPerformAction:OnEnter()
  local battlePerformInfo = _G.BattleManager.battleRuntimeData:GetPvpPlayerPerformData()
  local pvpPlayerPerformData = self:FilterPvpPlayerPerformData(battlePerformInfo)
  local hasLoadSkill = false
  if pvpPlayerPerformData then
    self.pvpPlayerPerformData = pvpPlayerPerformData
    self.skillPath = self:GetG6SkillPath(pvpPlayerPerformData.type)
    if BattleUtils.IsPvp() and self.skillPath then
      self.resList = {
        self.skillPath
      }
      self.loadedResCount = 0
      BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
      hasLoadSkill = true
      _G.BattleSkillManager:PreLoadRes(self.resList, true)
    end
  end
  if not hasLoadSkill then
    self:Finish()
  end
end

return BattlePvpPlayerPerformAction
