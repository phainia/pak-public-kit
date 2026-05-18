require("UnLuaEx")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_StoryDebugCenter_C = NRCPanelBase:Extend("DialoguePanelBase")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")

function UMG_StoryDebugCenter_C:OnActive()
  self:AddButtonListener(self.ShutDownButton, self.ShutDown)
  self:AddButtonListener(self.SkipDialogueButton, self.SwitchSkipDialogue)
  self:AddButtonListener(self.FastDialogueButton, self.SwitchFastDialogue)
  self:AddButtonListener(self.PrepareCE, self._OneKeyCE_AcceptTask)
  self:SwitchSkipDialogue(DialogueUtils.SkipDialogue)
  self:SwitchFastDialogue(DialogueUtils.SkipTyping)
  if _G.GlobalConfig.PrepareForCE then
    Log.Warning("GlobalConfig.PrepareForCE")
    GlobalConfig.SkipCG = true
    GlobalConfig.SkipVideo = true
    NRCEventCenter:RegisterEvent("UMG_StoryDebugCenter", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.PrepareForCEChain)
  end
end

function UMG_StoryDebugCenter_C:PrepareForCEChain()
  NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.PrepareForCEChain)
  if _G.GlobalConfig.PrepareForCE then
    GlobalConfig.FreezeWhenCG = true
    _G.GlobalConfig.DisablePetDamage = not _G.GlobalConfig.DisablePetDamage
    GlobalConfig.DisableTouchBattle = not _G.GlobalConfig.DisableTouchBattle
    self:CESendReward()
    self:DisablePlayerControl()
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "DialogueModule.BlockInputAction")
    DelayManager:DelaySeconds(10, function()
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "DialogueModule.BlockInputAction")
      if self then
        self:EnablePlayerControl()
        self:_OneKeyCE_AcceptTask()
      end
    end)
    self:GetTaskTestPetReward()
    self:CETeleport()
  end
end

function UMG_StoryDebugCenter_C:EnablePlayerControl()
  Log.Warning("\229\188\128\229\167\139\231\142\169\229\174\182\230\147\141\228\189\156")
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetCameraControlEnable(self, true)
  Player.inputComponent:SetInputEnable(self, true)
end

function UMG_StoryDebugCenter_C:DisablePlayerControl()
  Log.Warning("\231\173\137\229\190\133\229\136\157\229\167\139\228\187\187\229\138\161\232\174\190\231\189\174\239\188\140\231\166\129\230\173\162\230\147\141\228\189\156")
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetCameraControlEnable(self, false)
  Player.inputComponent:SetInputEnable(self, false)
  Player:Stop()
end

function UMG_StoryDebugCenter_C:_OperateItem(opType, itemType, itemId, num)
  opType = string.upper(opType)
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  if "ADD" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  elseif "SUB" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_SUB
  elseif "SET" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_SET
  else
    Log.WarningFormat("Operate item failed, invalid opType:%s", opType)
    return
  end
  itemType = string.upper(itemType)
  if "BAGITEM" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_BAGITEM
  elseif "VITEM" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_VITEM
  elseif "REWARD" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  elseif "PET" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_PET
  else
    Log.WarningFormat("Operate item failed, unsupp(or ukn) itemType:%s", itemType)
    return
  end
  opItemReq.item_id = itemId
  opItemReq.item_num = num
  Log.DebugFormat("Operate item, opType:%s, itemType:%s, itemId:%s, num:%s", opType, itemType, itemId, num)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self._OnOperateItemRsp)
end

function UMG_StoryDebugCenter_C:_OnOperateItemRsp()
end

function UMG_StoryDebugCenter_C:GetTaskTestPetReward()
  Log.Warning("\229\143\172\229\148\164\230\151\160\230\149\140\233\184\173\229\144\137\229\144\137")
  self:_OperateItem("ADD", "REWARD", 17095, 1)
end

function UMG_StoryDebugCenter_C:InitTask()
  Log.Warning("Initing task")
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = 70201001
  DelayManager:DelaySeconds(2, function()
    ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnAcceptTaskRsp)
  end)
end

function UMG_StoryDebugCenter_C:_OnAcceptTaskRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Warning("Accept task failed!")
  else
    Log.Warning("Accept task succeed")
    NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, false)
  end
end

function UMG_StoryDebugCenter_C:FinishCurrentTask(Name, Panel)
  local Module = NRCModuleManager:GetModule("TaskModule")
  local AllTasks = Module.data.TaskMap
  local TrackTask
  for _, TaskObject in pairs(AllTasks) do
    if TaskObject.isTrack then
      TrackTask = TaskObject
    end
  end
  if not TrackTask then
    Log.Warning("\231\142\176\229\156\168\230\178\161\230\156\137\229\188\186\232\191\189\232\184\170\228\184\173\231\154\132\228\187\187\229\138\161")
    return
  end
  local MaxValue = 1
  for _, Value in ipairs(TrackTask.Config.task_condition) do
    MaxValue = math.max(Value.count, MaxValue)
  end
  self:ModifyTaskProgressByID(TrackTask.Info.id, MaxValue)
end

function UMG_StoryDebugCenter_C:CETeleport()
  local _DCM = DataConfigManager
  local cfgKey = "special_role_born_point"
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local ptList = _DCM:GetGlobalConfigByKeyType(cfgKey, cfgTableId).numList
  local GroundPos = SceneUtils.GetPosInNearLand(UE4.FVector(ptList[1], ptList[2], ptList[3]), 1000)
  Log.Warning("ce teleport to,", GroundPos, ptList[1], ptList[2], ptList[3])
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player:SetActorLocation(UE4.FVector(ptList[1], ptList[2], ptList[3]))
end

function UMG_StoryDebugCenter_C:CESendReward()
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local rewardId = _DCM:GetGlobalConfigByKeyType("special_role_reward", cfgTableId).num
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  opItemReq.item_id = rewardId
  opItemReq.item_num = 1
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self._OnOneKeyCE_SendRewardRsp, true, true)
end

function UMG_StoryDebugCenter_C:_OnOneKeyCE_SendRewardRsp(rsp)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLoc = player.viewObj:Abs_K2_GetActorLocation()
  local promptTxt = string.format("\228\184\128\233\148\174CE\230\137\167\232\161\140\230\136\144\229\138\159!\n\n" .. "\230\130\168\229\189\147\229\137\141\230\137\128\229\156\168\229\156\186\230\153\175:%d\n\228\189\141\231\189\174:(%.0f, %.0f, %.0f)", SceneUtils.GetSceneID(), playerLoc.X, playerLoc.Y, playerLoc.Z)
  UE4.UNRCStatics.ClipboardCopy(string.format("(X=%.0f,Y=%.0f,Z=%.0f)", playerLoc.X, playerLoc.Y, playerLoc.Z))
  self:_ShowOKMsgBox(promptTxt)
end

function UMG_StoryDebugCenter_C:_OneKeyCE_AcceptTask()
  local _DCM = DataConfigManager
  local cfgTableId = _DCM.ConfigTableId.ROLE_GLOBAL_CONFIG
  local specTaskId = _DCM:GetGlobalConfigByKeyType("special_role_task", cfgTableId).num
  Log.Warning("ce", specTaskId)
  local acceptTaskReq = ProtoMessage.newZoneGmTaskAddReq()
  acceptTaskReq.uin = DataModelMgr.PlayerDataModel:GetPlayerUin()
  acceptTaskReq.task_id = specTaskId
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_TASK_ADD_REQ, acceptTaskReq, self, self._OnOneKeyCE_AcceptTaskRsp, true, true)
end

function UMG_StoryDebugCenter_C:_OnOneKeyCE_AcceptTaskRsp(rsp)
  NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, false)
end

function UMG_StoryDebugCenter_C:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

function UMG_StoryDebugCenter_C:ShutDown()
  NRCModuleManager:DoCmd(DialogueModuleCmd.ShowStoryDebugCenter, false)
end

function UMG_StoryDebugCenter_C:OnReceiveSwitchSkipDialogueEvent(bTurnOn)
  if bTurnOn then
    self.SkipDialogueText:SetText("\232\183\179\232\191\135\229\175\185\232\175\157\239\188\154\229\188\128\229\144\175")
    _G.UserSettingManager:SetDialogueAutoPlay(false)
    DialogueUtils.SkipDialogue = true
  else
    self.SkipDialogueText:SetText("\232\183\179\232\191\135\229\175\185\232\175\157\239\188\154\229\133\179\233\151\173")
    DialogueUtils.SkipDialogue = false
  end
end

function UMG_StoryDebugCenter_C:OnDisable()
end

function UMG_StoryDebugCenter_C:SwitchSkipDialogue(bTurnOn)
  if nil == bTurnOn then
    bTurnOn = not DialogueUtils.SkipDialogue
  end
  if bTurnOn then
    self.SkipDialogueText:SetText("\232\183\179\232\191\135\229\175\185\232\175\157\239\188\154\229\188\128\229\144\175")
    DialogueUtils.SkipDialogue = true
  else
    self.SkipDialogueText:SetText("\232\183\179\232\191\135\229\175\185\232\175\157\239\188\154\229\133\179\233\151\173")
    DialogueUtils.SkipDialogue = false
  end
end

function UMG_StoryDebugCenter_C:SwitchFastDialogue(bTurnOn)
  if nil == bTurnOn then
    bTurnOn = not DialogueUtils.SkipTyping
  end
  if bTurnOn then
    self.FastDialogueText:SetText("\229\191\171\233\128\159\229\175\185\232\175\157\239\188\154\229\188\128\229\144\175")
    DialogueUtils.SkipTyping = true
    _G.UserSettingManager:SetDialogueAutoPlay(false)
  else
    self.FastDialogueText:SetText("\229\191\171\233\128\159\229\175\185\232\175\157\239\188\154\229\133\179\233\151\173")
    DialogueUtils.SkipTyping = false
  end
end

return UMG_StoryDebugCenter_C
