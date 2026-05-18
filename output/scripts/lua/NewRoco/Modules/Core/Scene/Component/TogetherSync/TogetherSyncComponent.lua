local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local TogetherSyncComponent = Base:Extend("TogetherSyncComponent")

function TogetherSyncComponent:Ctor()
  self.StatusChecker = nil
  self.MsgStack = {}
end

function TogetherSyncComponent:Attach(owner)
  Base.Attach(self, owner)
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RELATION_INTERACT_NOTIFY, self.OnRelationNotify)
end

function TogetherSyncComponent:DeAttach()
  _G.ZoneServer:RemoveProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RELATION_INTERACT_NOTIFY, self.OnRelationNotify)
  if self.StatusChecker then
    self.StatusChecker:Reset()
    self.StatusChecker = nil
  end
  Base.DeAttach(self)
end

function TogetherSyncComponent:GetChecker()
  if not self.StatusChecker then
    self.StatusChecker = StatusCheckerGroup({
      StatusCheckerEnum.MainPanel,
      StatusCheckerEnum.FullScreen,
      StatusCheckerEnum.Cinematic,
      StatusCheckerEnum.FastLoading,
      StatusCheckerEnum.Catch
    }, Log.LOG_LEVEL.ELogDebug, "TogetherSyncComponent")
  end
  return self.StatusChecker
end

function TogetherSyncComponent:OnSync(msg)
  if #self.MsgStack > 0 or self:IsMsgNeedStatusCheck(msg) then
    self:AddSyncMsgToStack(msg)
    local checker = self:GetChecker()
    checker:Check(self, self.ApplyPendingSync)
    return
  end
  self:ApplyPendingSyncMsg(msg)
end

function TogetherSyncComponent:AddSyncMsgToStack(msg)
  if msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC and msg.operation.cinematic_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_END or msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_MOVIE and msg.operation.movie_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_END or msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_DIALOGUE and msg.operation.dialogue_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_END then
    for i = #self.MsgStack, 1, -1 do
      local msg_i = self.MsgStack[i].msg
      if msg_i.operation.operator_type == msg.operation.operator_type then
        table.remove(self.MsgStack, i)
      end
    end
  end
  table.insert(self.MsgStack, {
    msg = msg,
    time = _G.ZoneServer:GetServerTime() / 1000.0
  })
end

function TogetherSyncComponent:IsMsgNeedStatusCheck(msg)
  if msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC and msg.operation.cinematic_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_START or msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_MOVIE and msg.operation.movie_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_START or msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_DIALOGUE and msg.operation.dialogue_info.sync_type == ProtoEnum.PlayerOperationSyncType.POST_START then
    return true
  end
  return false
end

function TogetherSyncComponent:ApplyPendingSync()
  for _, pending_msg in ipairs(self.MsgStack) do
    local cur_time = _G.ZoneServer:GetServerTime() / 1000.0
    if cur_time - pending_msg.time < 3.0 then
      self:ApplyPendingSyncMsg(pending_msg.msg)
    end
  end
  table.clear(self.MsgStack)
end

function TogetherSyncComponent:ApplyPendingSyncMsg(msg)
  if msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC then
    _G.NRCModuleManager:DoCmd(_G.CinematicModuleCmd.OnSyncCinematic, msg)
  elseif msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_MOVIE then
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.OnSyncVideo, msg)
  elseif msg.operation.operator_type == ProtoEnum.ClientOperationType.COT_TOGETHER_DIALOGUE then
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.OnSyncDialogue, msg.operation.dialogue_info)
  end
end

function TogetherSyncComponent:OnRelationNotify(nty)
  local notify_type = nty.notify_type
  local target_uin = nty.target_uin
  if notify_type == ProtoEnum.RELATION_INTERACT_NOTIFY_TYPE.RINT_END then
    self.otherUin = nil
    self._interactType = nil
    if nty.interact_type == ProtoEnum.InteractInviteType.IIT_INVITE_TOGETHER or nty.interact_type == ProtoEnum.InteractInviteType.IIT_REQUEST_TOGETHER then
      local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player then
        local req = _G.ProtoMessage:newSpaceAct_ClientOperation()
        req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TOGETHER_DIALOGUE
        req.operation.dialogue_info.target_npc_id = player:GetServerId()
        req.operation.dialogue_info.dialogue_id = 0
        req.operation.dialogue_info.dialogue_npc_id = 0
        req.operation.dialogue_info.sync_type = ProtoEnum.PlayerOperationSyncType.POST_END
        self:ApplyPendingSyncMsg(req)
        req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC
        req.operation.cinematic_info.target_npc_id = player:GetServerId()
        req.operation.cinematic_info.cinematic_id = 0
        req.operation.cinematic_info.sync_type = ProtoEnum.PlayerOperationSyncType.POST_END
        self:ApplyPendingSyncMsg(req)
        req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TOGETHER_MOVIE
        req.operation.movie_info.target_npc_id = player:GetServerId()
        req.operation.movie_info.movie_id = 0
        req.operation.movie_info.sync_type = ProtoEnum.PlayerOperationSyncType.POST_END
        self:ApplyPendingSyncMsg(req)
      end
    end
  end
end

return TogetherSyncComponent
