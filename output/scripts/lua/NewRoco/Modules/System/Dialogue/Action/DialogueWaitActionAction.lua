local NPCActionEvent = require("NewRoco.Modules.Core.NPC.Actions.NPCActionEvent")
local NPCActionFactory = require("NewRoco.Modules.Core.NPC.Actions.NPCActionFactory")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = DialogueActionBase
local DialogueWaitActionAction = Base:Extend("DialogueWaitActionAction")
FsmUtils.MergeMembers(Base, DialogueWaitActionAction, {
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"},
  {
    name = "ParentModule",
    type = "var"
  },
  {
    name = "ClientAction",
    type = "var"
  },
  {
    name = "ServerAction",
    type = "var"
  }
})

function DialogueWaitActionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueWaitActionAction:OnEnter()
  self:InjectProperties()
  Log.Debug("Will Output Action Info....")
  Log.Dump(self.ServerAction, 3, "Server Action Info")
  Log.Dump(self.DialogueConf.action, 3, "Config Action Info")
  local Action = self.ClientAction
  Action = Action or NPCActionFactory:Get(self.Option, self.DialogueConf.action, self.ServerAction, true)
  if DialogueUtils.IsTeleportAction(self.DialogueConf.action.action_type) then
    self.fsm:SetProperty("PlayerPosSyncBlocker", false)
    local player = DialogueUtils.GetHero()
    if player.movementComponent and player.movementComponent.SetSyncMove then
      player.movementComponent:SetSyncMove(true)
    end
  end
  local IsClientCommit = DialogueUtils.IsClientCommit(self.DialogueConf.action.action_type)
  if self.Action then
    self.Action:Destroy()
    self.Action = nil
  end
  if IsClientCommit and Action then
    if not self.ParentModule:IsInBlackScreen() and Action:IsNeedCloseDialogueUI() then
      self.ParentModule:OnCloseMainPanel()
    end
    if Action.shouldSync then
      Action:SyncAction()
    end
    self.Action = Action
    self.Action.DialogueConf = self.DialogueConf
    self:SetProperty("ClientAction", Action)
    self.Action.SkipSubmit = true
    self.Action:AddEventListener(self, NPCActionEvent.OnFinish, self.OnClientActionFinish)
    self.Action:Execute()
    self.fsm:Pause()
    if self.Action:CanSkipInDialogue() and self.ParentModule and not self.ParentModule:IsButtonSkipVisible() then
      self.ParentModule:ShowButtonSkip(self, self.OnButtonSkip)
    end
  elseif IsClientCommit and not Action then
    self:Commit()
    self:DoNextDialogue(self.DialogueConf.action.success_dialogue)
  elseif not IsClientCommit and Action then
    if not self.ParentModule:IsInBlackScreen() and Action:IsNeedCloseDialogueUI() then
      self.ParentModule:OnCloseMainPanel()
    end
    Action:OnDialogueAction()
    self:TryFinish()
  else
    self:TryFinish()
  end
end

function DialogueWaitActionAction:CheckServerReady()
  local Cleared, Action = self:CheckServerCleared()
  if Cleared then
    self:GoToNextDialogue(Action)
  else
    Log.Debug("Will Wait For Server Action", self.DialogueConf.id)
    self.Received = false
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.ForwardOptionChange, self.OnNPCActionResult)
    self.fsm:Pause()
  end
end

function DialogueWaitActionAction:CheckServerCleared()
  local Found = self.ParentModule:FindAction(self.Option, self.DialogueConf)
  if Found then
    return true, Found
  else
    return false, Found
  end
end

function DialogueWaitActionAction:Commit()
  local NextActReq = ProtoMessage:newZoneSceneNpcNextActReq()
  NextActReq.npc_id = self.Option.owner.serverData.base.actor_id
  NextActReq.option_id = self.Option.optionInfo.option_id
  NextActReq.battle_radius = _G.BattleConst.Define.BattleFieldRange
  NextActReq.cur_dialog_id = self.ConfID
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, NextActReq, self, self.OnCommit, false, false)
end

function DialogueWaitActionAction:OnCommit(rsp)
  self:HandleActionResponse(rsp)
end

function DialogueWaitActionAction:OnClientActionFinish(rsp, success)
  self:HandleActionResponse(rsp)
end

function DialogueWaitActionAction:HandleActionResponse(rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if 0 == ErrorCode then
    self:TryFinish()
  elseif table.contains(ActionUtils.EndDialogueErrorCodes, ErrorCode) then
    self.fsm:Resume()
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
  elseif ErrorCode == ProtoEnum.MOBA_RET.ErrorCode.ERR_COMMON_SYS_FUNC_BANNED or ErrorCode == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_COMMON_BANNED then
    self.fsm:Resume()
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
  else
    self:TryFinish()
  end
end

function DialogueWaitActionAction:TryFinish()
  if self.ParentModule then
    self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.ForwardOptionChange)
  end
  if self:HasPendingBattle() then
    Log.Debug("\230\136\152\230\150\151\232\191\155\232\161\140\228\184\173\239\188\140\229\188\128\229\167\139\231\173\137\229\190\133\230\136\152\230\150\151\231\187\147\230\157\159", self.fsm:GetName())
    self.fsm:Pause()
    self.ParentModule:RegisterEvent(self, DialogueModuleEvent.BattleOver, self.OnBattleOver)
  else
    Log.Debug("\230\178\161\230\156\137\230\136\152\230\150\151\239\188\140\231\155\180\230\142\165\230\142\168\232\191\155", self.fsm:GetName())
    self.fsm:Resume()
    self:Finish()
  end
end

function DialogueWaitActionAction:OnNPCActionResult(option)
  local Found = self.ParentModule:FindAction(option, self.DialogueConf)
  if not Found then
    Log.Warning("\230\178\161\230\156\137\231\173\137\229\136\176\229\175\185\229\186\148\229\175\185\232\175\157\231\154\132\228\191\161\230\129\175", self.DialogueConf.id)
    return
  end
  self:GoToNextDialogue(Found)
end

function DialogueWaitActionAction:GoToNextDialogue(Action)
  Log.Debug("Will Output Action Info.... DialogueWaitActionAction:OnNPCActionResult")
  Log.Dump(Action, 3, "Server Action Info")
  Log.Dump(self.DialogueConf.action, 3, "Config Action Info")
  local Found
  if Action.act_result_type ~= nil then
    local ActionResultConf = _G.DataConfigManager:GetActionResultTypeConf(self.DialogueConf.id, true)
    if ActionResultConf and ActionResultConf.expand_dialogs and #ActionResultConf.expand_dialogs > 0 then
      for _, Expand in ipairs(ActionResultConf.expand_dialogs) do
        if Expand.action_result_type == Action.act_result_type then
          Found = Expand
          break
        end
      end
    elseif self.DialogueConf.expand_dialogs and #self.DialogueConf.expand_dialogs > 0 then
      for _, Expand in ipairs(self.DialogueConf.expand_dialogs) do
        if Expand.action_result_type == Action.act_result_type then
          Found = Expand
          break
        end
      end
    end
  end
  if Found then
    if _G.GlobalConfig.bShowExpandDialogueResult then
      Log.Error("[Dialogue]Found expand dialogue, goto", Found.expand_dialog_id, "Action Result Type is: ", table.getKeyName(_G.Enum.ActionResultType, Action.act_result_type))
    else
      Log.Debug("[Dialogue]Found expand dialogue, goto", Found.expand_dialog_id)
    end
    self:DoNextDialogue(Found.expand_dialog_id)
  elseif Action.act_exec_success then
    Log.Debug("[Dialogue]goto success", self.DialogueConf.action.success_dialogue)
    self:DoNextDialogue(self.DialogueConf.action.success_dialogue)
  else
    Log.Debug("[Dialogue]goto failure", self.DialogueConf.action.failure_dialogue)
    self:DoNextDialogue(self.DialogueConf.action.failure_dialogue)
  end
end

function DialogueWaitActionAction:DoNextDialogue(id)
  Log.Debug("[Fsm]\231\138\182\230\128\129\230\156\186DialogueFlow\229\135\134\229\164\135\230\142\168\232\191\155", self.DialogueConf.id, "->", id)
  self:SetProperty("ConfID", id)
  self:TryFinish()
end

function DialogueWaitActionAction:OnBattleOver()
  Log.Debug("\230\136\152\230\150\151\231\187\147\230\157\159\239\188\129\230\129\162\229\164\141\229\175\185\232\175\157\231\138\182\230\128\129\230\156\186\232\191\144\232\161\140")
  DialogueUtils.ToggleInput(false)
  self.fsm:Resume()
  self:Finish()
end

function DialogueWaitActionAction:HasPendingBattle()
  if _G.BattleManager:IsInBattle() then
    return true
  end
  Log.Debug("There's no battle at all...")
  return false
end

function DialogueWaitActionAction:OnFinish()
  self:SetProperty("ClientAction", nil)
  if self.Action then
    self.Action:RemoveEventListener(self, NPCActionEvent.OnFinish, self.OnClientActionFinish)
  end
  self.ParentModule:UnRegisterEvent(self, DialogueModuleEvent.BattleOver)
end

function DialogueWaitActionAction:OnButtonSkip()
  if self and self.Action then
    self.Action:SkipInDialogue()
  end
  if self.ParentModule then
    self.ParentModule:CloseButtonSkip()
  end
end

return DialogueWaitActionAction
