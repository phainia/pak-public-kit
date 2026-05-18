local NavigationDefines = {}
NavigationDefines.AreaFlag = {
  flag0 = 1,
  flag1 = 2,
  flag2 = 4,
  flag3 = 8,
  flag4 = 16,
  flag5 = 32,
  flag6 = 64,
  flag7 = 128,
  flag8 = 256,
  flag9 = 512,
  flag10 = 1024,
  flag11 = 2048,
  flag12 = 4096,
  flag13 = 8192,
  flag14 = 16384,
  flag15 = 32768
}
NavigationDefines.Area = {
  Default = NavigationDefines.AreaFlag.flag0,
  SafeArea = NavigationDefines.AreaFlag.flag1,
  Water = NavigationDefines.AreaFlag.flag2,
  GrassRegion = NavigationDefines.AreaFlag.flag3,
  HomeDoor = NavigationDefines.AreaFlag.flag8
}
NavigationDefines.FlagId = {
  Default = 0,
  SafeArea = 1,
  Water = 2,
  GrassRegion = 3,
  HomeDoor = 8,
  HomeObstacle = 9
}
return NavigationDefines
