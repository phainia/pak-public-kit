local FarmModuleEnum = {}
FarmModuleEnum.GrowCheckResult = {
  Other = -1,
  Pass = 0,
  Locked = 1,
  Occupied = 2
}
FarmModuleEnum.OptionType = {
  None = 0,
  Sowing = 1,
  Harvesting = 2,
  Watering = 3,
  Fertilizing = 4,
  Stealing = 5,
  Removing = 6
}
FarmModuleEnum.NPCType = {
  None = 0,
  Land = 1,
  Board = 2,
  Crop = 3,
  Entrance = 4,
  Exit = 5
}
return FarmModuleEnum
