local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionMagicReveal = Base:Extend("NPCActionMagicReveal")

function NPCActionMagicReveal:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionMagicReveal:OnExecute()
  if not self.Runner.LogicStatusComponent:GetStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_TO_BE_REVEALED_BY_MAGIC) then
    return
  end
  local NPCView = self:GetOwnerNPCView()
  if not NPCView then
    self:Finish(false)
    return
  end
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/StarMagic/G6_LightMagic_BOXSmoke", NPCView.RocoSkill, PriorityEnum.Active_Player_Action)
  if not Skill then
    self:Finish(false)
    return
  end
  Skill:SetCaster(NPCView)
  Skill:RegisterEventCallback("PreEnd", self, self.OnFinishSkill)
  Skill:PlaySkill()
end

function NPCActionMagicReveal:OnFinishSkill()
  self:Finish(true)
end

return NPCActionMagicReveal
