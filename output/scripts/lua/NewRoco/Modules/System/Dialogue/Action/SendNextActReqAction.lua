local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase
local SendNextActReqAction = Base:Extend("SendNextActReqAction")
FsmUtils.MergeMembers(Base, SendNextActReqAction, {
  {name = "TargetNPC", type = "var"},
  {name = "Option", type = "var"},
  {name = "ConfID", type = "var"},
  {
    name = "DialogueConf",
    type = "var"
  },
  {
    name = "ParentModule",
    type = "var"
  }
})

function SendNextActReqAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function SendNextActReqAction:OnEnter()
  self:InjectProperties()
  if 0 == self.ConfID then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  if not self:CheckConfValid(self.DialogueConf) then
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  local Found = self.ParentModule:FindAction(self.Option, self.DialogueConf.id, ProtoEnum.SpaceEnum_NpcActionStatus.ENUM.Commited)
  if Found then
    Log.DebugFormat("[DialogueFlow]SendNextActReqAction:OnEnter, Dialogue %d has been committed by server, Next Dialogue:%d", self.DialogueConf.id, Found.next_dialog_id)
    if 0 == Found.next_dialog_id then
      self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
      return
    end
    self:SetProperty("ConfID", Found.next_dialog_id)
    self.fsm:SendEvent(DialogueModuleEvent.EnterNextState, self)
    return
  end
  local NextActReq = ProtoMessage:newZoneSceneNpcNextActReq()
  NextActReq.npc_id = self.Option.owner.serverData.base.actor_id
  NextActReq.option_id = self.Option.optionInfo.option_id
  NextActReq.battle_radius = _G.BattleConst.Define.BattleFieldRange
  NextActReq.cur_dialog_id = self.DialogueConf.id
  if self.Option.owner then
    NextActReq.npc_pt = self.Option.owner:GetServerPoint()
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    NextActReq.avatar_pt = localPlayer:GetServerPoint()
  end
  BattleProfiler:CheckPoint(BattleProfilerCheckPoint.NPCTalk)
  local bIsSent = _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, NextActReq, self, self.OnRsp, false, true)
  if bIsSent then
    return
  end
  Log.ErrorFormat("[DialogueFlow] Failed to send ZoneSceneNpcNextActReq, connection is lost, %d", self.DialogueConf.id)
  self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
end

function SendNextActReqAction:OnRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    local ret_code = rsp.ret_info.ret_code
    if ret_code == ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_FUNC_BANNED_TRANSFORM then
      local Key = string.format("Error_Code_%d", ret_code)
      local ErrorText = _G.DataConfigManager:GetLocalizationConf(Key, true)
      ErrorText = ErrorText and ErrorText.msg
      if nil == ErrorText then
        local notCfgDes = string.format("%s(%d)", _G.LocalText.NetErrorDefault, ret_code)
        if RocoEnv.IS_SHIPPING or not RocoEnv.IS_EDITOR then
          ErrorText = notCfgDes
        else
          local ErrorCodeDesc = require("Data.PB.ErrorCodeDesc")
          ErrorText = ErrorCodeDesc[ret_code] or notCfgDes
        end
      end
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, ErrorText)
    end
    Log.ErrorFormat("[DialogueFlow]SendNextActReqAction:OnRsp ErrorCode:%d, DialogueID:%d", rsp.ret_info.ret_code, self.DialogueConf.id)
    self.fsm:SendEvent(DialogueModuleEvent.EnterEndState, self)
    return
  end
  Log.Debug("[DialogueFlow]SendNextActReqAction:OnRsp", self.DialogueConf.id)
  self:Finish()
end

function SendNextActReqAction:CheckConfValid(Conf)
  if not Conf then
    return false
  end
  if not string.IsNilOrEmpty(Conf.text) then
    return true
  end
  if 0 ~= Conf.next_dialog_id then
    return true
  end
  if Conf.select_ids and #Conf.select_ids > 0 then
    return true
  end
  if DialogueUtils.HasValidAction(Conf) then
    return true
  end
  return false
end

return SendNextActReqAction
