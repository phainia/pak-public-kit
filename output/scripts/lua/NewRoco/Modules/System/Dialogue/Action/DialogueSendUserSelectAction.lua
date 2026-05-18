local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local DialogueSendUserSelectAction = Base:Extend("DialogueSendUserSelectAction")
FsmUtils.MergeMembers(Base, DialogueSendUserSelectAction, {
  {
    name = "CurrentSelection",
    type = "var"
  },
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"},
  {name = "Action", type = "var"}
})

function DialogueSendUserSelectAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DialogueSendUserSelectAction:OnEnter()
  self:InjectProperties()
  self.CurrentSelection = self.fsm:GetProperty("CurrentSelection")
  if self.CurrentSelection then
    self.fsm:Pause()
    _G.NRCModeManager:DoCmd(_G.DialogueModuleCmd.PlayEndAnimation, self, function(this)
      this:ProceedToNextDialogue()
    end)
  else
    Log.Debug("DialogueSendUserSelectAction:OnEnter, fail to get current selection")
    self:Finish()
  end
end

function DialogueSendUserSelectAction:ProceedToNextDialogue()
  local conf = self.CurrentSelection
  self.fsm:Resume()
  Log.Debug("DialogueSendUserSelectAction:ProceedToNextDialogue", conf and conf.id or "no conf")
  if conf then
    local bInBattle = self:GetProperty("bInBattle")
    if bInBattle then
      self:StartNextRound(conf.select_next_dialogue)
      return
    end
    local Info = DialogueUtils.GetSelectInfoByID(self.Action, conf.id)
    if Info and Info.enabled then
      if Info.remaining_times and 0 ~= Info.remaining_times then
        if conf.select_next_dialogue >= 0 then
          self.ConfID = conf.select_next_dialogue
          self:SendSelectResult(conf)
          return
        end
      elseif conf.notimes_dialogue > 0 then
        self.ConfID = conf.notimes_dialogue
        self:SendSelectResult(conf)
        return
      end
    end
  end
  Log.Debug("[DialogueFlow]\229\135\134\229\164\135\230\142\168\232\191\155", self.DialogueConf.id, "-> \233\128\128\229\135\186")
  self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
end

function DialogueSendUserSelectAction:StartNextRound(id)
  Log.Debug("[DialogueFlow]\229\135\134\229\164\135\230\142\168\232\191\155", self.DialogueConf.id, "->", id)
  self.fsm:Resume()
  self:SetProperty("Options", nil)
  self:SetProperty("ConfID", id)
  self:Finish()
end

function DialogueSendUserSelectAction:PrepareToEnterNextDialogue(conf)
  if not conf then
    Log.Error("DialogueSendUserSelectAction:Prepare to enter next dialogue : conf is empty")
    return
  end
  local bInBattle = self:GetProperty("bInBattle")
  if bInBattle then
    self:StartNextRound(conf.select_next_dialogue)
  else
    self:SendSelectResult(conf)
  end
end

function DialogueSendUserSelectAction:SendSelectResult(conf)
  local req = ProtoMessage:newZoneSceneNpcDialogSelectReq()
  req.option_id = self.Option.config.id
  req.select_id = conf.id
  req.npc_id = self.Option.owner.serverData.base.actor_id
  req.battle_radius = _G.BattleConst.Define.BattleFieldRange
  if self.Option.owner then
    req.npc_pt = self.Option.owner:GetServerPoint()
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
  end
  BattleProfiler:CheckPoint(BattleProfilerCheckPoint.NPCDialog)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_DIALOG_SELECT_REQ, req, self, self.OnSelectResult, true, false)
  if 0 == self.ConfID then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
  end
end

function DialogueSendUserSelectAction:OnSelectResult(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:Finish()
  else
    Log.ErrorFormat("[DialogueFlow] \229\175\185\232\175\157\230\138\165\233\148\153\239\188\140\231\166\187\229\188\128, error code = %d", rsp.ret_info.ret_code)
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
  end
end

function DialogueSendUserSelectAction:OnFinish()
  if self.fsm and self.fsm.SetProperty then
    self.fsm:SetProperty("CurrentSelection", nil)
  end
end

return DialogueSendUserSelectAction
