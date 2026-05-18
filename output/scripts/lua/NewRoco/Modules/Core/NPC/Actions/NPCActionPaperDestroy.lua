require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionPaperDestroy = Base:Extend("NPCActionPaperDestroy")

function NPCActionPaperDestroy:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPaperDestroy:Execute()
  Log.Debug("NPCActionPaperDestroy:Execute")
  Base.Execute(self)
  local Player = self:GetPlayer()
  local SkillComp = Player.viewObj.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_MagicPaper", SkillComp, PriorityEnum.Active_Player_Action)
  if not Skill then
    Log.Error("NPCActionPaperDestroy:Execute \230\137\190\228\184\141\229\136\176Skill")
    return
  end
  Skill:SetWithLoadAndPlay(true)
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    self:GetOwnerNPCView()
  })
  Skill:RegisterEventCallback("PaperDestroy", self, self.DestroyFinish)
  Skill:PlaySkill(self, self.OnSkillCallBack)
end

function NPCActionPaperDestroy:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionPaperDestroy failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionPaperDestroy:SkillFailed()
  self:Finish(false)
end

function NPCActionPaperDestroy:DestroyFinish()
  self:Finish(true)
end

return NPCActionPaperDestroy
