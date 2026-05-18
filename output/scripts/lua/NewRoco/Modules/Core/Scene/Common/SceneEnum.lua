local SceneEnum = {}
SceneEnum.FaceState = {
  CURIOUS = 1,
  ALERT_ESCAPE = 2,
  ALERT_TRACING = 3
}
SceneEnum.PerceptionEffect = {
  HAPPY = 1,
  ALERT = 2,
  CURIOUS = 3,
  SAD = 4,
  WAIT = 5,
  ALERT_CJ = 6,
  CURIOUS_CJ = 7
}
SceneEnum.PerceptionHudType = {
  None = 0,
  Perceive = 1,
  TackAction = 2,
  Lose = 3,
  GroupTarget = 4,
  HardAction = 5
}
SceneEnum.CommandType = {MOVE = 1, CLIMB = 2}
SceneEnum.MoveType = {WALK = 1, CLIMB = 2}
SceneEnum.NpcSightType = {WEAK = 1, STRONG = 2}
SceneEnum.NpcSightAreaType = {RECT = 0, SECTOR = 1}
SceneEnum.MiracleExchangeType = {
  CHANGE_FREE = 0,
  SENDER = 1,
  RECEIVE = 2
}
return SceneEnum
