local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionCinematic = Base:Extend("NPCActionCinematic")

function NPCActionCinematic:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.StatusChecker = nil
end

function NPCActionCinematic:GetChecker()
  if not self.StatusChecker then
    self.StatusChecker = StatusCheckerGroup({
      StatusCheckerEnum.Scene,
      StatusCheckerEnum.Teleport,
      StatusCheckerEnum.Battle,
      StatusCheckerEnum.Dialogue,
      StatusCheckerEnum.MainPanel,
      StatusCheckerEnum.FullScreen,
      StatusCheckerEnum.Cinematic,
      StatusCheckerEnum.FastLoading
    }, Log.LOG_LEVEL.ELogDebug)
  end
  return self.StatusChecker
end

function NPCActionCinematic:OnNpcAction()
  local bIsPlaying = self:IsPlaying()
  if bIsPlaying then
    return false
  end
  if _G.DialogueModuleCmd and _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    self:LogWarning("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151~NPCActionCinematic:OnNpcAction, \229\183\178\231\187\143\229\156\168\229\175\185\232\175\157\228\184\173\239\188\140\231\166\129\230\173\162\230\146\173\230\148\190Sequence\239\188\129\239\188\129\239\188\129")
    return false
  end
  if self:IsPlaying() then
    self:LogWarning("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151~NPCActionCinematic:OnNpcAction, \229\183\178\231\187\143\229\156\168\229\175\185\232\175\157\228\184\173\239\188\140\231\166\129\230\173\162\233\135\141\229\164\141Sequence\239\188\129\239\188\129\239\188\129")
    return false
  end
  local CinematicModule = _G.NRCModuleManager:GetModule("CinematicModule")
  if not CinematicModule then
    self:LogWarning("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151~NPCActionCinematic:OnNpcAction, CinematicModule\228\184\141\229\173\152\229\156\168")
    return false
  end
  local DeltaTime = _G.UpdateManager.Timestamp - CinematicModule.LastEndTime
  if DeltaTime <= 5.0 then
    self:LogWarning("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151~NPCActionCinematic:OnNpcAction, 5\231\167\146\229\134\133\229\136\154\230\146\173\232\191\135Sequence\239\188\140\231\166\129\230\173\162\233\135\141\229\164\141Sequence\239\188\129\239\188\129\239\188\129", DeltaTime)
    return false
  end
  local Checker = self:GetChecker()
  if Checker and not Checker:CheckPass() then
    self:Log("\232\176\131\232\175\149\231\148\168\230\151\165\229\191\151~NPCActionCinematic:OnNpcAction, \230\157\161\228\187\182\231\138\182\230\128\129\228\184\141\230\187\161\232\182\179")
    return false
  end
  return Base.OnNpcAction(self)
end

function NPCActionCinematic:IsPlaying()
  local bIsPlaying = _G.NRCModeManager:DoCmd(_G.CinematicModuleCmd.IsPlaying)
  return bIsPlaying
end

function NPCActionCinematic:Execute()
  local bIsPlaying = self:IsPlaying()
  if bIsPlaying then
    self:Finish(false)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetLockOpenSubUI, true)
  self:FreezePlayer()
  if self.SkipSubmit then
    self:RunSequence()
  end
  Base.Execute(self)
end

function NPCActionCinematic:RunSequence()
  local SequenceID = tonumber(self.Config.action_param1)
  self:Log("Starting Sequence", SequenceID)
  _G.NRCModeManager:DoCmd(_G.CinematicModuleCmd.StartCinematic, SequenceID, self, self.OnCinematicFinish)
end

function NPCActionCinematic:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 == rsp.ret_info.ret_code then
    self:RunSequence()
  end
end

function NPCActionCinematic:OnCinematicFinish(Success)
  self:Finish(Success)
end

return NPCActionCinematic
