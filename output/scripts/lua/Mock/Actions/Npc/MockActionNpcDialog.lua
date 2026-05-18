local MockActionNextActReq = require("Mock.Actions.Npc.MockActionNextActReq")
local Base = MockActionNextActReq
local MockActionNpcDialog = Base:Extend("MockActionNpcDialog")

function MockActionNextActReq:ShouldDoMock()
  return false
end

function MockActionNextActReq:DoMock()
  local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
  rsp.ret_info.ret_code = -1
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.Request.npc_id)
  if nil ~= npc and nil ~= localPlayer then
    local dialogId = tonumber(self.OptionConf.action.action_param1)
    local NpcOptionInfoChange = _G.ProtoMessage:newSpaceAct_NpcOptionInfoChange()
    NpcOptionInfoChange.npc_id = self.Request.npc_id
    NpcOptionInfoChange.enabled = true
    NpcOptionInfoChange.enable_opt_gid = 0
    NpcOptionInfoChange.option_id = self.Request.option_id
    NpcOptionInfoChange.ineteracting_avatar_id = localPlayer.serverData.base.owner_id
    NpcOptionInfoChange.succ_exec_times = 1
    NpcOptionInfoChange.executable_times = -1
    NpcOptionInfoChange.first_dialog_id = dialogId
    NpcOptionInfoChange.act_info.act_exec_success = true
    NpcOptionInfoChange.act_info.act_result_type = _G.ProtoEnum.ActionResultType.ART_NONE
    NpcOptionInfoChange.act_info.act_status = _G.ProtoEnum.SpaceEnum_NpcActionStatus.ENUM.Executing
    NpcOptionInfoChange.act_info.act_type = self.OptionConf.action.action_type
    NpcOptionInfoChange.act_info.bound_dialog_id = 0
    NpcOptionInfoChange.act_info.btle_cfg_id = 0
    NpcOptionInfoChange.act_info.dialog_id = dialogId
    NpcOptionInfoChange.act_info.next_dialog_id = 0
    local BaseData = _G.ProtoMessage:newSpaceBaseData()
    BaseData.operator_obj_id = localPlayer.serverData.base.actor_id
    BaseData.space_time_ms = UE4.UNRCStatics.GetTimestampMicroseconds()
    npc.InteractionComponent:OnOptionsChange(NpcOptionInfoChange, nil, BaseData)
    rsp.ret_info.ret_code = 0
  end
  return rsp
end

return MockActionNpcDialog
