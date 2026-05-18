local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = FsmAction
local PlayCinematicAction = Base:Extend("PlayCinematicAction")
FsmUtils.MergeMembers(Base, PlayCinematicAction, {})

function PlayCinematicAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function PlayCinematicAction:OnEnter()
  self.timeout = 100
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player:IsInTogetherMove() then
    player:SendEvent(PlayerModuleEvent.ON_SET_LINK_STATE, false, PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
  end
  NRCModeManager:DoCmd(CinematicModuleCmd.PlayCinematic, self, self.Done)
  if not self.finished then
    local cinematic_id = self.fsm:GetProperty("CinematicConfID", 0)
    if player and player:IsInTogetherMove() and not player:IsTogetherMove2P() and cinematic_id > 0 then
      local other_player = player:GetAnotherTogetherMovePlayer()
      if other_player then
        local other_player_id = other_player:GetServerId()
        local req = _G.ProtoMessage:newZoneClientOperationReq()
        req.operation.operator_id = player:GetServerId()
        req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC
        req.operation.aim_info = nil
        req.operation.npc_action_info = nil
        req.operation.catch_info = nil
        req.operation.player_perform_info = nil
        req.operation.cinematic_info.target_npc_id = other_player_id
        req.operation.cinematic_info.cinematic_id = cinematic_id
        req.operation.cinematic_info.sync_type = ProtoEnum.PlayerOperationSyncType.POST_START
        req.operation.movie_info = nil
        Log.Debug("PlayCinematicAction:OnEnter, send client operation start", cinematic_id)
        _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req, self, self.OnSyncReqRsp)
        self.sync_target = other_player_id
      end
    end
  end
end

function PlayCinematicAction:OnSyncReqRsp(rsp)
  Log.Debug("PlayCinematicAction:OnSyncReqRsp, on client operation req rsp", rsp.ret_info.ret_code, rsp.ret_info.ret_msg)
end

function PlayCinematicAction:OnTick(DeltaTime)
  local Duration = self.fsm:GetProperty("Duration")
  if Duration then
    self.timeout = Duration * 2
  end
  Base.OnTick(self)
end

function PlayCinematicAction:Done(Success)
  self.fsm:SetProperty("Result", Success)
  self:Finish()
end

function PlayCinematicAction:OnExit()
end

function PlayCinematicAction:OnFinish()
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player:IsInTogetherMove() then
    player:SendEvent(PlayerModuleEvent.ON_SET_LINK_STATE, true, PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
  end
  if self.sync_target then
    local cinematic_id = self.fsm:GetProperty("CinematicConfID", 0)
    if player and cinematic_id > 0 then
      local req = _G.ProtoMessage:newZoneClientOperationReq()
      req.operation.operator_id = player:GetServerId()
      req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TOGETHER_CINEMATIC
      req.operation.aim_info = nil
      req.operation.npc_action_info = nil
      req.operation.catch_info = nil
      req.operation.player_perform_info = nil
      req.operation.cinematic_info.target_npc_id = self.sync_target
      req.operation.cinematic_info.cinematic_id = cinematic_id
      req.operation.cinematic_info.sync_type = ProtoEnum.PlayerOperationSyncType.POST_END
      req.operation.movie_info = nil
      Log.Debug("PlayCinematicAction:OnFinish, send client operation end", cinematic_id)
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req, self, self.OnSyncReqRsp)
    end
  end
  self.sync_target = nil
end

return PlayCinematicAction
