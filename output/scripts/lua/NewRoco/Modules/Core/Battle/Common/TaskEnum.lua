local TaskEnum = {}
TaskEnum.OpenToKenType = {operation = 1, Show = 2}
TaskEnum.AddOrRemoveTaskReward = {
  Null = 0,
  Add = 1,
  Remove = 2
}
TaskEnum.ContentType = {Null = 0, Exist = 1}
TaskEnum.ToKenUseType = {
  Equipment = 0,
  DisCharge = 1,
  Replace = 3
}
TaskEnum.TaskTab = {
  All = 0,
  journey = 1,
  Legendary = 2,
  Gleanings = 3
}
TaskEnum.TaskParagraphFinishState = {
  open = 0,
  done = 1,
  notStart = 2
}
TaskEnum.MagicStampTabType = {Lacquer = 0, order = 1}
return TaskEnum
