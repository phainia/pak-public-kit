require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionSoulDimoRecycle = Base:Extend("NPCActionSoulDimoRecycle")

function NPCActionSoulDimoRecycle:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionSoulDimoRecycle:Execute()
  Log.Debug("NPCActionSoulDimoRecycle:Execute")
  Base.Execute(self)
end

function NPCActionSoulDimoRecycle:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  self:StartSkill()
end

function NPCActionSoulDimoRecycle:StartSkill()
  Log.Debug("NPCActionSoulDimoRecycle:StartSkill")
  local player = self:GetPlayer()
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_LingJie_DiMo_To_Bag", skillComp, PriorityEnum.Active_Player_Action)
  if not skill then
    Log.Error("NPCActionSoulDimoRecycle:Execute \230\137\190\228\184\141\229\136\176Skill")
    self:Finish(false)
    return
  end
  local owner = self:GetOwnerNPC()
  if nil == owner then
    self:Finish(false)
    return
  else
    owner:SetNotDestroyFlag(true)
    if owner.InteractionComponent then
      owner.InteractionComponent:TryDisableInteraction()
    end
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(player.viewObj)
  skill:SetTargets({
    owner.viewObj
  })
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  _G.NRCEventCenter:RegisterEvent("NPCActionSoulDimoRecycle", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoRecycle:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:SkillFailed()
  end
end

function NPCActionSoulDimoRecycle:SkillFailed()
  self.SkillStarted = false
  self:SkillComplete()
end

function NPCActionSoulDimoRecycle:SkillComplete(Name, Skill)
  if self:GetOwnerNPC() then
    self:GetOwnerNPC():SetNotDestroyFlag(false)
  end
  self.SkillStarted = false
  self:Finish(true)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function NPCActionSoulDimoRecycle:OnInterrupted(Name, Skill)
  self.SkillStarted = false
  Log.Error("NPCActionSoulDimoRecycle:OnInterrupted")
  self:SkillComplete()
end

function NPCActionSoulDimoRecycle:OnReconnect()
  Log.Error("NPCActionSoulDimoRecycle:OnReconnect need to complete skill!")
  if self:GetOwnerNPC() then
    self:GetOwnerNPC():SetNotDestroyFlag(false)
  end
  self.SkillStarted = false
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

return NPCActionSoulDimoRecycle
