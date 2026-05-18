WorldCombatState = {}
WorldCombatState.BaseState = {
  Peace = "BaseState.Peace",
  Battle = "BaseState.Battle"
}
WorldCombatState.MotionState = {
  Idle = "MotionState.Idle",
  Walk = "MotionState.Walk",
  CastSkill = "MotionState.CastSkill",
  Dizzy = "MotionState.Dizzy",
  BeatOff = "MotionState.BeatOff"
}
WorldCombatState.SpaceState = {
  Air = "SpaceState.Air",
  Land = "SpaceState.Air",
  OnWater = "SpaceState.OnWater",
  InWater = "SpaceState.InWater"
}
return WorldCombatState
