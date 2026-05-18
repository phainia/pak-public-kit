local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local WorldCombatDotsSkillAnimCancel = Base:Extend("WorldCombatDotsSkillAnimCancel")

function WorldCombatDotsSkillAnimCancel:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatDotsSkillAnimCancel:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local pt = self.ServerInfo.anim_cancel_pos
  local cancelPos = SceneUtils.ServerPos2ClientPos(pt.pos)
  local cancelRot = SceneUtils.ServerPos2ClientRotator(pt.dir)
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    local curPos = self.Runner:GetActorLocation()
    if curPos and cancelPos then
      UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), curPos, cancelPos, 5, UE.FLinearColor(1, 0.05, 0, 0), 20, 3)
    end
  end
  local animComp = self.Runner:GetAnimComponent()
  if animComp then
    self.Runner:StopAllMontage(0)
  end
  local endPos = SceneUtils.GetPosInLand(cancelPos, self.Runner:GetScaledHalfHeight(), self.Runner:GetScaledHalfHeight() * 5, self.Runner:GetScaledHalfHeight() * 3, {}, {}, nil, true, false, true)
  self.Runner:SetActorLocation(endPos)
  self.Runner:SetActorRotation(cancelRot)
  local runnerView = self.Runner.viewObj
  if runnerView and UE.UObject.IsValid(runnerView) then
    local moveComp = runnerView:GetComponentByClass(UE4.UCharacterNavMovementComponent)
    moveComp.Velocity = _G.FVectorZero
  end
  self:MarkRootMotionAnimationFinalize()
end

function WorldCombatDotsSkillAnimCancel:MarkRootMotionAnimationFinalize()
  if self.skillObj and UE.UObject.IsValid(self.skillObj) then
    local actions = self.skillObj:GetAllActions()
    for i = 1, actions:Length() do
      local action = actions:Get(i)
      if action:IsA(UE.URocoPlayWorldCombatAnimationByName) then
        action.skipFinalizePosition = true
        self.Runner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
        return
      end
    end
  end
end

return WorldCombatDotsSkillAnimCancel
