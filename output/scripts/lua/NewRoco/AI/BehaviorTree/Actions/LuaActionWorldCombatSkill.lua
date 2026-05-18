local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionWorldCombatSkill = Base:Extend("LuaActionWorldCombatSkill")

function LuaActionWorldCombatSkill:Ctor(LuaBTNodeBase)
  Base.Ctor(self, LuaBTNodeBase)
end

function LuaActionWorldCombatSkill:OnStart(AIController, ...)
  local owner = AIController
  self.owner = owner
  self.interrupted = false
  self.SkillComp = self.owner.Npc:EnsureComponent(WorldCombatSkillComponent)
  if self.SkillComp == nil then
    Log.Error("[MFBT:LuaActionWorldCombatSkill] Get WorldCombatSkillComponent failed")
    self:Finish(false)
  end
  local TargetEntity, TargetPos
  local TargetType = self.Target:GetType(self.owner)
  if TargetType == LuaParamType.Object then
    TargetEntity = self.Target:GetValue(self.owner)
  elseif TargetType == LuaParamType.Vector then
    TargetPos = self.Target:GetValue(self.owner)
  end
  self:RegisterEvent()
  self.SkillComp:TryCastSkill(self.SkillId:GetValue(self.owner), TargetEntity, TargetPos, self.InterruptOther:GetValue(self.owner))
end

function LuaActionWorldCombatSkill:OnInterrupt(AIController)
  self.interrupted = true
  self.SkillComp:ForceStopCurrentSkill()
end

function LuaActionWorldCombatSkill:SkillSuccess(SkillID)
  self:UnRegisterEvent()
  self.owner = nil
  self.SkillComp = nil
  if not self.interrupted then
    self:Finish(true)
  end
end

function LuaActionWorldCombatSkill:SkillFailed(SkillID)
  self:UnRegisterEvent()
  self.owner = nil
  self.SkillComp = nil
  if not self.interrupted then
    self:Finish(false)
  end
end

function LuaActionWorldCombatSkill:RegisterEvent()
  self.owner.Npc:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_SUCCESS, self.SkillSuccess)
  self.owner.Npc:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.SkillSuccess)
  self.owner.Npc:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_FAIL, self.SkillFailed)
end

function LuaActionWorldCombatSkill:UnRegisterEvent()
  self.owner.Npc:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_SUCCESS, self.SkillSuccess)
  self.owner.Npc:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.SkillSuccess)
  self.owner.Npc:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_FAIL, self.SkillFailed)
end

return LuaActionWorldCombatSkill
