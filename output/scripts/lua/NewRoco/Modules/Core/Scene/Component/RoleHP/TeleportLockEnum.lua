local TeleportLockEnum = {}
TeleportLockEnum.LockType = {
  NONE = 1,
  BATTLE = 2,
  DEATH_PERFORM = 3,
  UI = 4,
  DIALOGUE = 5
}
TeleportLockEnum.CallbackStamp = {
  ON_BLACK_SHOWN = 1,
  ON_TELEPORT_UI_SHOWN = 2,
  ON_TELEPORT_UI_CLOSED = 3
}
return TeleportLockEnum
