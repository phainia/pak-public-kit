local MagicReplayModuleEnum = {}
MagicReplayModuleEnum.ModuleOpType = {
  Other = 0,
  Record = 1,
  Replay = 2,
  Preview = 3,
  Share = 4
}
MagicReplayModuleEnum.FsmStateType = {
  Other = 0,
  RecordPrepare = 1,
  RecordProcess = 2,
  PreviewPrepare = 3,
  PreviewProcess = 4,
  ReplayPrepare = 5,
  ReplayProcess = 6,
  ReplayIdle = 7,
  Share = 8
}
return MagicReplayModuleEnum
