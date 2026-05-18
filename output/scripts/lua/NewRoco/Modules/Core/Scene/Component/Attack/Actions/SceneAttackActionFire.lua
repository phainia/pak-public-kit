local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionWater")
local SceneAttackActionFire = Base:Extend("SceneAttackActionFire")
local SkillBlueprint_Path = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Perception_fire_01.G6_Scene_Perception_fire_01_C'"

function SceneAttackActionFire:Ctor()
  Base.Ctor(self)
  self.skillPath = SkillBlueprint_Path
end

return SceneAttackActionFire
