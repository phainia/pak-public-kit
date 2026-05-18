local AutoIndex = MakeAutoIndex()
local AbilityEvent = {
  ON_ABILITY_CHANGED = AutoIndex(),
  ON_BUFF_LOOP_BEGIN = AutoIndex(),
  ON_BUFF_LOOP_END = AutoIndex(),
  ON_PERCEPTION_BEGIN = AutoIndex(),
  ON_PERCEPTION_END = AutoIndex()
}
return AbilityEvent
