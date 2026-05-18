require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionSoulDimoHowl = Base:Extend("NPCActionSoulDimoHowl")

function NPCActionSoulDimoHowl:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSoulDimoHowl:Execute()
  Log.Debug("NPCActionSoulDimoHowl:Execute")
  Base.Execute(self)
end

function NPCActionSoulDimoHowl:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:StartSkill()
end

function NPCActionSoulDimoHowl:StartSkill(rsp)
  Log.Debug("NPCActionSoulDimoHowl:StartSkill")
  local player = self:GetPlayer()
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_LingJie_Show", skillComp, PriorityEnum.Active_Player_Action)
  if not skill then
    Log.Error("NPCActionSoulDimoHowl:StartSkill \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    Log.Error("NPCActionSoulDimoHowl:StartSkill \230\137\190\228\184\141\229\136\176owner")
    self:Finish(false)
    return
  end
  if owner and owner.AIComponent then
    owner.AIComponent:ForceLockForReason(true, true, AIDefines.LockReason.ACTION_PROCESS)
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(owner.viewObj)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionSoulDimoHowl", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoHowl:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function NPCActionSoulDimoHowl:SkillFailed()
  Log.Error("NPCActionSoulDimoHowl:SkillFailed")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionSoulDimoHowl:SkillComplete(Name, Skill)
  local owner = self:GetOwnerNPC()
  if owner and owner.AIComponent then
    owner.AIComponent:ForceLockForReason(false, true, AIDefines.LockReason.ACTION_PROCESS)
  end
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoHowl:OnInterrupted(Name, Skill)
  Log.Error("NPCActionSoulDimoHowl:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionSoulDimoHowl:OnReconnect()
  Log.Error("NPCActionSoulDimoHowl:OnReconnect need to complete skill!")
  local owner = self:GetOwnerNPC()
  if owner and owner.AIComponent then
    owner.AIComponent:ForceLockForReason(false, true, AIDefines.LockReason.ACTION_PROCESS)
  end
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionSoulDimoHowl
