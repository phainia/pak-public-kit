local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionMagicStar = Base:Extend("NPCActionMagicStar")

function NPCActionMagicStar:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionMagicStar:Execute()
  if self.SkipSubmit then
    self:StartSkill()
  else
    Base.Execute(self)
    self:SetInteracting(true)
  end
end

function NPCActionMagicStar:OnSubmit(rsp)
  self.Owner:SetNeedStatusNotify(false)
  local ErrorCode = rsp.ret_info.ret_code
  if 0 ~= ErrorCode then
    self:Finish()
    return
  end
  self:StartSkill()
end

function NPCActionMagicStar:StartSkill()
  local OwnerView = self:GetOwnerNPCView()
  if not OwnerView then
    self:Finish(false)
    return
  end
  local Player = self:GetPlayer()
  local SkillComp = OwnerView.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Star", SkillComp, PriorityEnum.Active_Player_Action)
  if not Skill then
    self:Finish(false)
    return
  end
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({OwnerView})
  Skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillComplete)
  Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillComplete)
  SkillComp:StopCurrentSkill()
  Skill:PlaySkill()
end

function NPCActionMagicStar:OnSkillComplete()
  self:Finish(true)
end

function NPCActionMagicStar:OnCommit(rsp)
  self:SetInteracting(false)
  Base.OnCommit(self, rsp)
end

return NPCActionMagicStar
