local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local PowerDashActionBase = require("NewRoco.Modules.Core.NPC.Actions.PowerDashAction.PowerDashActionBase")
local Base = PowerDashActionBase
local PowerDashActionBurst = Base:Extend("PowerDashActionBurst")

function PowerDashActionBurst:Ctor(Owner, Conf)
  Base.Ctor(self, Owner, Conf)
end

function PowerDashActionBurst:OnExecute()
  local bornDie = self.Runner:EnsureComponent(BornDieComponent)
  local action = _G.ProtoMessage:newSpaceAct_ActorDieBegin()
  action.die_reason = _G.ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_NONE
  action.skill_or_anim = "/Game/ArtRes/Effects/G6Skill/SceneEffect/StarMagic/G6_StarMagic_Box_01"
  action.is_skill = true
  bornDie:OnBeginDying(action, 0, true)
  self:Submit()
end

return PowerDashActionBurst
