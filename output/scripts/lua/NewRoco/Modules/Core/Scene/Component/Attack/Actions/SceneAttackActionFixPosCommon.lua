local Base = require("NewRoco.Modules.Core.Scene.Component.Attack.Actions.SceneAttackActionWater")
local SceneAttackActionFixPosCommon = Base:Extend("SceneAttackActionFire")
local SkillBlueprint_Path = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Perception_common_03.G6_Scene_Perception_common_03_C'"

function SceneAttackActionFixPosCommon:Ctor()
  Base.Ctor(self)
  self.skillPath = SkillBlueprint_Path
end

return SceneAttackActionFixPosCommon
