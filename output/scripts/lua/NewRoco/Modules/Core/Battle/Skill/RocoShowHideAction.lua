local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local RocoShowHideAction = RocoSkillAction:Extend("RocoShowHideAction")

function RocoShowHideAction:OnActionStart()
  self.m_HideDecorator = false
  if self.m_Advanced then
    local targetComp = self.TargetSceneComponent
    if targetComp and targetComp:IsChildOf(UE4.UStaticMeshComponent) then
      local targetActor = UE4.UNRCStatics.GetDefaultExecuteActor(self)
      if targetActor and targetActor:IsA(UE4.ARocoPlayerBase) then
        if not self.m_Additional then
          self.m_Advanced = false
        else
          self.m_AdditionalIncludeCaster = false
        end
      end
    end
  end
  self.Overridden.OnActionStart(self)
end

function RocoShowHideAction:ShowHideSelfFx(Target, IsShow)
  if not self.bUpdateSelfFx then
    return
  end
  if Target.FxIDs then
    for i, v in pairs(Target.FxIDs) do
      Target.RocoFX:ShowHideFxByID(v, IsShow)
    end
  end
  if not IsShow then
    Target.needHideSelf = true
  end
end

return RocoShowHideAction
