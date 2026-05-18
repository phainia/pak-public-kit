local TaskActionGroupEnum = require("NewRoco.Modules.Core.Task.TaskActionGroupEnum")
local TaskActionFactory = {}
TaskActionFactory.Registry = {
  [ProtoEnum.TaskStateChangeActionType.TSCAT_ADD_MP4] = require("NewRoco.Modules.Core.Task.TaskActionVideo"),
  [ProtoEnum.TaskStateChangeActionType.TSCAT_ADD_SEQUENCE] = require("NewRoco.Modules.Core.Task.TaskActionSequence"),
  [ProtoEnum.TaskStateChangeActionType.TSCAT_GO_CMD] = require("NewRoco.Modules.Core.Task.TaskActionCmd"),
  [ProtoEnum.TaskStateChangeActionType.TSCAT_SLIDE] = require("NewRoco.Modules.Core.Task.Action.TaskActionImageFlow")
}
TaskActionFactory.TKT_Registry = {
  [ProtoEnum.TaskKeyType.TKT_MINI_PACKAGE_DONE] = require("NewRoco.Modules.Core.Task.Action.TaskActionNeedDownload")
}
TaskActionFactory.RegistryList = {}

function TaskActionFactory.TryMakeAction(Task, ActionGroup, ActionIndex, Conf)
  local Type = Conf.type
  local Action = TaskActionFactory.Registry[Type]
  if not Action then
    return nil
  end
  return Action(Task, ActionGroup, ActionIndex, Conf)
end

function TaskActionFactory.TryMakeActionByCond(Task, ActionGroup, ActionIndex, Conf)
  local Type = Conf.type
  local Action = TaskActionFactory.TKT_Registry[Type]
  if not Action then
    return nil
  end
  return Action(Task, ActionGroup, ActionIndex, Conf)
end

return TaskActionFactory
