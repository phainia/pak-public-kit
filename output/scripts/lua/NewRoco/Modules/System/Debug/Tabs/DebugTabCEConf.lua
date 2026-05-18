local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local CurrentConf, InitPetID
local RewardIndex = 0
local DebugTabCEConf = Base:Extend("DebugTabCEConf")

function DebugTabCEConf:Ctor()
  Base.Ctor(self)
end

function DebugTabCEConf:SetupTabs()
  local GM_BUTTON_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_BUTTON_CONF)
  for Index, Conf in pairs(GM_BUTTON_CONF:GetAllDatas()) do
    self:Add(Conf.button_string, function()
      self:Run(Conf)
    end, self)
  end
  self:Add("\230\140\137ID\228\184\128\233\148\174CE", self.RunCEConfWithID, self, nil, nil, nil, nil, nil, "", "RunCEConfWithID", "")
end

function DebugTabCEConf:RunCEConfWithID(Name, Panel, Input)
  if Panel then
    Input = Panel:GetInputNumber(1)
  end
  Input = tonumber(Input)
  Input = Input or 1
  local Conf = _G.DataConfigManager:GetGmButtonConf(Input)
  if Conf then
    self:Run(Conf)
  else
    Log.Error("\230\140\137\231\133\167ID\228\184\128\233\148\174CE\230\151\160\230\179\149\230\137\190\229\136\176\230\140\135\229\174\154\231\154\132\233\133\141\231\189\174", Input)
  end
end

function DebugTabCEConf:Run(Conf)
  CurrentConf = Conf
  _G.GlobalConfig.bDisableStatProtocolFreq = true
  self:AddStoryFlag()
end

function DebugTabCEConf:AddStoryFlag()
  Log.Info("step: AddStoryFlag")
  local Conf = CurrentConf
  if Conf.add_storyflag and 0 ~= #Conf.add_storyflag then
    local Req = ProtoMessage:newZoneGmPlayerStoryFlagModifyReq()
    Req.is_add = true
    Req.extra_story_flags = Conf.add_storyflag
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_PLAYER_STORY_FLAG_MODIFY_REQ, Req, self, self.AcquirePet, true, false)
  else
    self:AcquirePet()
  end
end

function DebugTabCEConf:AcquirePet(rsp)
  if not self:CheckRetValid(rsp, "DeleteStoryFlag failed...") then
    return
  end
  Log.Info("step: AcquirePet")
  local Conf = CurrentConf
  local Pets = Conf.magic_book_pet
  if not Pets or 0 == #Pets then
    self:SetRoleLevel(nil, "")
    return
  end
  local Index = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin % 3 + 1
  Log.Error("Show Index", Index)
  InitPetID = Pets[Index]
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_PET
  opItemReq.item_id = InitPetID
  opItemReq.item_num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self.AcquireMagicBook, true, false)
end

function DebugTabCEConf:AcquireMagicBook(rsp)
  Log.Info("step: AcquireMagicBook")
  if not self:CheckRetValid(rsp, "\229\143\145\233\128\129\229\136\157\229\167\139\231\178\190\231\129\181\229\164\177\232\180\165...") then
    return
  end
  local req = _G.ProtoMessage:newZoneGmSelectAdventurePetReq()
  req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  req.pet_conf_id = InitPetID
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SELECT_ADVENTURE_PET_REQ, req, self, self.SetRoleLevel, true, false)
end

function DebugTabCEConf:SetRoleLevel(rsp)
  Log.Info("step: SetRoleLevel")
  if not self:CheckRetValid(rsp, "\232\167\163\233\148\129\233\173\148\229\138\155\228\185\139\230\186\144\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  if 0 == Conf.role_level then
    self:SetWorldLevel()
    return
  end
  local Req = ProtoMessage:newZoneGmSetPlayerLevelReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.level = Conf.role_level
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PLAYER_LEVEL_REQ, Req, self, self.SetWorldLevel, true, false)
end

function DebugTabCEConf:SetWorldLevel(rsp)
  Log.Info("step: SetWorldLevel")
  if not self:CheckRetValid(rsp, "\232\174\190\231\189\174\233\173\148\230\179\149\231\173\137\231\186\167\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  if 0 == Conf.world_level then
    self:GetRewards()
    return
  end
  local Req = ProtoMessage:newZoneGmSetPlayerWorldLevelReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.world_level = Conf.world_level
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PLAYER_WORLD_LEVEL_REQ, Req, self, self.GetRewards, true, false)
end

function DebugTabCEConf:GetRewards(rsp)
  Log.Info("step: GetRewards")
  if not self:CheckRetValid(rsp, "\232\174\190\231\189\174\231\142\169\229\174\182\230\152\159\233\152\182\231\173\137\231\186\167\229\164\177\232\180\165...") then
    return
  end
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  opItemReq.item_id = CurrentConf.reward_id
  opItemReq.item_num = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self.AcceptTask, true, false)
end

function DebugTabCEConf:AcceptTask(rsp)
  Log.Info("step: AcceptTask")
  if not self:CheckRetValid(rsp, "\233\162\134\229\143\150\229\136\157\229\167\139\231\164\188\229\140\133\229\164\177\232\180\165...") then
    return
  end
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = CurrentConf.task_id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self.UnlockCamp, true, false)
end

function DebugTabCEConf:UnlockCamp(rsp)
  Log.Info("step: UnlockCamp")
  if not self:CheckRetValid(rsp, "\229\143\145\233\128\129\229\136\157\229\167\139\231\178\190\231\129\181\229\164\177\232\180\165...") then
    return
  end
  local Conf = CurrentConf
  local Camps = Conf.unlock_camp
  if not Camps or 0 == #Camps then
    self:AllDone(nil)
    return
  end
  local Req = ProtoMessage:newZoneSceneGmReq()
  Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  Req.gm_type = ProtoEnum.SceneGmType.SGT_ACTIVE_BONFIRE
  Req.gm_op_type = 1
  Req.rpt_params = Camps
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.SkipAllBeginnerGuide, true, false)
end

function DebugTabCEConf:SkipAllBeginnerGuide(rsp)
  Log.Info("step: SkipAllBeginnerGuide")
  if not self:CheckRetValid(rsp, "UnlockCamp failed...") then
    return
  end
  local Conf = CurrentConf
  if Conf.skip_all_beginner_guide then
    _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.CompleteAllGuide)
  end
  self:SkipToMainQuest()
end

function DebugTabCEConf:SkipToMainQuest(rsp)
  Log.Info("step: SkipToMainQuest")
  if not self:CheckRetValid(rsp, "SkipAllBeginnerGuide failed...") then
    return
  end
  local Conf = CurrentConf
  if Conf.skip_to_main_quest then
    local Req = ProtoMessage:newZoneGmTaskAddReq()
    Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
    Req.task_id = Conf.skip_to_main_quest
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, Req, self, self.AcceptTaskArray, true, false)
  else
    self:AcceptTaskArray()
  end
end

function DebugTabCEConf:AcceptTaskArray(rsp)
  Log.Info("step: AcceptTaskArray")
  if not self:CheckRetValid(rsp, "DeleteStoryFlag failed...") then
    return
  end
  local Conf = CurrentConf
  if Conf.accept_task_array and 0 ~= #Conf.accept_task_array then
    local Req = ProtoMessage:newZoneGmTaskAddReq()
    Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
    Req.extra_task_ids = Conf.accept_task_array
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, Req, self, self.FinishTaskArray, true, false)
  else
    self:FinishTaskArray()
  end
end

function DebugTabCEConf:FinishTaskArray(rsp)
  Log.Info("step: FinishTaskArray")
  if not self:CheckRetValid(rsp, "AcceptTaskArray failed...") then
    return
  end
  local Conf = CurrentConf
  if Conf.finish_task_array and 0 ~= #Conf.finish_task_array then
    local Req = ProtoMessage:newZoneGmTaskDoneReq()
    Req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
    Req.extra_task_ids = Conf.finish_task_array
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_DONE_REQ, Req, self, self.DeleteStoryFlag, true, false)
  else
    self:DeleteStoryFlag()
  end
end

function DebugTabCEConf:DeleteStoryFlag(rsp)
  if not self:CheckRetValid(rsp, "FinishTaskArray failed...") then
    return
  end
  Log.Info("step: DeleteStoryFlag")
  local Conf = CurrentConf
  if Conf.delete_storyflag and 0 ~= #Conf.delete_storyflag then
    local Req = ProtoMessage:newZoneGmPlayerStoryFlagModifyReq()
    Req.is_add = false
    Req.extra_story_flags = Conf.delete_storyflag
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_PLAYER_STORY_FLAG_MODIFY_REQ, Req, self, self.Teleport, true, false)
  else
    self:Teleport()
  end
end

function DebugTabCEConf:Teleport(rsp)
  if not self:CheckRetValid(rsp, "FinishTaskArray failed...") then
    return
  end
  Log.Info("step: Teleport")
  local Conf = CurrentConf
  local Req = _G.ProtoMessage:newZoneSceneGmTeleportReq()
  Req.to_scene_cfg_id = SceneUtils.GetSceneID()
  Req.to_point.pos.x = Conf.position[1] or 0
  Req.to_point.pos.y = Conf.position[2] or 0
  Req.to_point.pos.z = Conf.position[3] or 0
  if #Conf.position > 3 then
    Req.to_point.dir.x = Conf.position[4] or 0
    Req.to_point.dir.y = Conf.position[5] or 0
    Req.to_point.dir.z = Conf.position[6] or 0
  end
  self.bGMTeleportRsp = false
  self.bEnterSceneFinishNtyAck = false
  _G.NRCEventCenter:RegisterEvent("DebugTabCEConfg", self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, Req, self, self.OnZoneSceneGmTeleportRsp, true, false)
end

function DebugTabCEConf:OnZoneSceneGmTeleportRsp(rsp)
  Log.Info("OnZoneSceneGmTeleportRsp")
  if not self:CheckRetValid(rsp, "\232\183\179\232\189\172\229\156\186\230\153\175\230\137\167\232\161\140\229\164\177\232\180\165...") then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
    return
  end
  self.bGMTeleportRsp = true
  if self.bGMTeleportRsp and self.bEnterSceneFinishNtyAck then
    self:AllDone()
  end
end

function DebugTabCEConf:OnEnterSceneFinishNtyAck()
  Log.Info("OnEnterSceneFinishNtyAck")
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  self.bEnterSceneFinishNtyAck = true
  if self.bGMTeleportRsp and self.bEnterSceneFinishNtyAck then
    self:AllDone()
  end
end

function DebugTabCEConf:AllDone(rsp)
  Log.Info("AllDone!!")
  if not self:CheckRetValid(rsp, "Teleport \229\164\177\232\180\165...") then
    return
  end
  self:ClosePanel()
  self:ShowTips(string.format("\230\137\167\232\161\140%s\229\174\140\230\136\144\239\188\129", CurrentConf.button_string))
  CurrentConf = nil
  _G.GlobalConfig.bDisableStatProtocolFreq = false
end

function DebugTabCEConf:CheckRetValid(rsp, desc)
  if rsp and rsp.ret_info and 0 ~= rsp.ret_info.ret_code then
    Log.Dump(rsp, 5, "Dump Rsp.............")
    Log.Error(CurrentConf.button_string, rsp.ret_info.ret_code, desc)
    CurrentConf = nil
    self:ClosePanel()
    return false
  end
  return true
end

return DebugTabCEConf
