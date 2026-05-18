require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstanceDestructibleBox_C = Base:Extend("BP_NPCInstanceDestructibleBox_C")

function BP_NPCInstanceDestructibleBox_C:CanEnterThrowInter(Comp)
  if not Comp then
    return false
  end
  return Comp == self.Wall or Comp == self.BoxMid or Comp == self.BoxDown
end

function BP_NPCInstanceDestructibleBox_C:GetHalfHeight()
  return 150
end

function BP_NPCInstanceDestructibleBox_C:ApplyPhysicsHit(hitPos, hitVec)
  if self.Fracture and type(self.Fracture) == "function" then
    self:Fracture(hitPos, hitVec)
  end
end

return BP_NPCInstanceDestructibleBox_C
