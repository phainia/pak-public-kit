local Base = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionMagicRevealFailed = Base:Extend("NPCActionMagicRevealFailed")

function NPCActionMagicRevealFailed:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionMagicRevealFailed:OnExecute()
  local NPCView = self:GetOwnerNPCView()
  if not NPCView then
    self:Finish(false)
    return
  end
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/StarMagic/G6_LightMagic_BOXSmokeFail", NPCView.RocoSkill, PriorityEnum.Active_Player_Action)
  if not Skill then
    self:Finish(false)
    return
  end
  Skill:SetCaster(NPCView)
  Skill:RegisterEventCallback("PreEnd", self, self.OnFinishSkill)
  Skill:PlaySkill()
end

function NPCActionMagicRevealFailed:OnFinishSkill()
  self:Finish(true)
end

return NPCActionMagicRevealFailed
