local WorldCombatActionUtils = {}
WorldCombatActionUtils.DotsHitActorType = {
  None = 0,
  Obstacle = 1,
  Player = 2,
  NPC = 3,
  Thrown_PET = 4
}

function WorldCombatActionUtils.ResolveHitResult(hitTarget)
  if not hitTarget then
    return WorldCombatActionUtils.DotsHitActorType.None
  end
  if not hitTarget then
    return WorldCombatActionUtils.DotsHitActorType.Obstacle
  end
  if hitTarget.name == "SceneLocalPlayer" then
    return WorldCombatActionUtils.DotsHitActorType.Player
  elseif hitTarget.IsAThrownPet and hitTarget:IsAThrownPet() then
    return WorldCombatActionUtils.DotsHitActorType.Thrown_PET
  else
    return WorldCombatActionUtils.DotsHitActorType.NPC
  end
end

return WorldCombatActionUtils
