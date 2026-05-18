local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionTouchLegendarySpot = Base:Extend("NPCActionOpenLegendaryBattle")

function NPCActionTouchLegendarySpot:ExecuteWithModel()
  local player = self:GetPlayer()
  if player then
    local skillComponent = player.viewObj.RocoSkill
    if skillComponent then
      local skillProxy = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/ShenShou/G6_ShenShou_Come.G6_ShenShou_Come", skillComponent, PriorityEnum.Active_Player_Action)
      skillProxy:SetCaster(player.viewObj)
      skillProxy:RegisterEventCallback("End", self, self.EndAction)
      skillProxy:PlaySkill()
    end
  end
end

function NPCActionTouchLegendarySpot:EndAction()
  self:Finish()
end

return NPCActionTouchLegendarySpot
