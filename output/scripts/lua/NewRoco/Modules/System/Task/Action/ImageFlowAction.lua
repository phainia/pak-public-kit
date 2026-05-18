local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local TaskModuleCmd = require("NewRoco.Modules.Core.Task.TaskModuleCmd")
local Base = NPCActionBase
local ImageFlowAction = Base:Extend("ImageFlowAction")

function ImageFlowAction:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.StatusChecker = nil
  self.Config = Config
  if self.Config then
    self.ImageFlowID = tonumber(Config.action_param1) or 0
  end
end

function ImageFlowAction:GetChecker()
  if not self.StatusChecker then
    self.StatusChecker = StatusCheckerGroup({
      StatusCheckerEnum.Scene,
      StatusCheckerEnum.Teleport,
      StatusCheckerEnum.Battle,
      StatusCheckerEnum.Dialogue,
      StatusCheckerEnum.MainPanel,
      StatusCheckerEnum.FullScreen,
      StatusCheckerEnum.Cinematic,
      StatusCheckerEnum.FastLoading,
      StatusCheckerEnum.ImageFlow
    }, Log.LOG_LEVEL.ELogDebug)
  end
  return self.StatusChecker
end

function ImageFlowAction:OnNpcAction()
  local Checker = self:GetChecker()
  if Checker and not Checker:CheckPass() then
    self:Log("ImageFlowAction:OnNpcAction, \230\157\161\228\187\182\231\138\182\230\128\129\228\184\141\230\187\161\232\182\179")
    return false
  end
  return Base.OnNpcAction(self)
end

function ImageFlowAction:Execute()
  local IsImageFlow = TaskModuleCmd and NRCModeManager:DoCmd(TaskModuleCmd.IsImageFlowPlaying)
  if IsImageFlow then
    self:Finish(false)
    return
  end
  local Param = {}
  Param.ImageFlowID = self.ImageFlowID
  Param.Caller = self
  Param.Callback = self.OnImageFlowFinish
  Param.Style = 2
  NRCModeManager:DoCmd(TaskModuleCmd.PlayTaskImageFlow, Param)
  Base.Execute(self)
end

function ImageFlowAction:OnSubmit(Rsp)
  Base.OnSubmit(self, Rsp)
end

function ImageFlowAction:OnImageFlowFinish(bSuccess)
  self:Finish(bSuccess)
end

return ImageFlowAction
