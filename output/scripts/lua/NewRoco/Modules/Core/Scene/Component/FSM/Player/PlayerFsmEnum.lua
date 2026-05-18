local ScenePlayerFsmEnum = {}
ScenePlayerFsmEnum.ScenePlayerStateType = {
  Idle = 0,
  Walk = 1,
  SlowWalk = 2,
  Run = 3,
  Climb = 4,
  Grass = 5,
  GrassTrek = 6,
  GrassSneak = 7,
  GrassCrouch = 8,
  CastAbility = 9,
  Swim = 20,
  Dialogue = 21
}
ScenePlayerFsmEnum.ScenePlayerFsmEvent = {CLICK_WHILE_CLIMBING = 0, STATE_CHANGE = 1}
return ScenePlayerFsmEnum
