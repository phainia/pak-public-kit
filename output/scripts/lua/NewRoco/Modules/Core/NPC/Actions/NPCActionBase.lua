local Class = _G.MakeSimpleClass
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local NPCActionEvent = require("NewRoco.Modules.Core.NPC.Actions.NPCActionEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local EventDispatcher = require("Common.EventDispatcher")
local NavigationComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.NavigationComponent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local UIUtils = require("NewRoco.Utils.UIUtils")
local MinExecuteInterval = 0.3
local VisualDebug = false
local NPCActionBase = Class("NPCActionBase")
NPCActionBase:SetMemberCount(16)
EventDispatcher.BindClass(NPCActionBase)

function NPCActionBase.PostInit(Option, Action, Info, OwnerNpc)
end

function NPCActionBase:PreCtor()
  self.SkipSubmit = false
  self.SkipCommit = false
  self.NeedModal = false
  self.bInteracting = false
  self.LastExecuteTime = -1
  self.playerId = nil
  self.shouldSync = false
  self.DoAction = false
  self.DisableInterval = false
end

function NPCActionBase:Ctor(Owner, Config, Info, View)
  EventDispatcher(2, 2, true):Attach(self)
  self.Owner = Owner
  self.Config = Config
  self.Info = Info
  if self.Owner then
    self.OwnerNpc = self.Owner.owner
  else
    self.OwnerNpc = View
  end
end

function NPCActionBase:NeedsValidation()
  return false
end

function NPCActionBase:GetCreatorID()
  if not self.OwnerNpc then
    return 0
  end
  return self.OwnerNpc:GetCreatorID()
end

function NPCActionBase:GetOwnerActorLocation()
  if not self.OwnerNpc then
    return FVectorZero
  end
  local OwnerNPC = self.OwnerNpc
  if OwnerNPC.viewObj then
    return OwnerNPC:GetActorLocation()
  else
    local Point = OwnerNPC.serverData.base.born_pt.pos
    return UE4.FVector(Point.x, Point.y, Point.z)
  end
end

function NPCActionBase:UpdateInfo(Info, Reconnect, InteractingAvatarID)
  self.Info = Info
end

local function CheckSceneFullyEntered()
  return _G.SceneModuleCmd and _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.CheckSceneFullyEntered) or false
end

function NPCActionBase:OnNpcAction()
  if not self.Owner then
    Log.Error("NPC option Owner\228\184\141\229\173\152\229\156\168\239\188\140\228\184\141\229\186\148\232\175\165\232\176\131\231\148\168\229\136\176OnNpcAction")
    return false
  end
  if self.Owner:NeedStatusNotify() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\231\173\137\229\190\133\229\133\182\228\187\150\228\186\164\228\186\146\229\155\158\229\140\133")
    return false
  end
  if not _G.ZoneServer:IsEnteredCell() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\156\186\230\153\175\231\138\182\230\128\129\228\184\141\229\175\185(\229\186\148\232\175\165\228\184\186EnteredCall)", _G.ZoneServer:GetOnlineState())
    return false
  end
  if not _G.ZoneServer:CanSendNetworkCmd() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\189\147\229\137\141\230\151\160\230\179\149\229\143\145\229\140\133")
    return false
  end
  local SceneReady = CheckSceneFullyEntered()
  if not SceneReady then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\156\186\230\153\175\230\156\170\229\138\160\232\189\189\229\174\140\230\136\144")
    return false
  end
  local IsCinematicPlaying = _G.NRCModuleManager:DoCmd(_G.CinematicModuleCmd.IsPlaying)
  if IsCinematicPlaying then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\173\163\229\156\168Cinematic\228\184\173")
    return false
  end
  if _G.BattleManager:IsInBattle() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\173\163\229\156\168\230\136\152\230\150\151\228\184\173")
    return false
  elseif _G.BattleManager.isSendWaiting then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\173\163\229\156\168\231\148\179\232\175\183\232\191\155\229\133\165\230\136\152\230\150\151\231\173\137\229\190\133\228\184\173")
    return false
  end
  if #_G.BattleManager.battleNetManager.cachedBattleNotify > 0 then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\156\137\229\190\133\229\164\132\231\144\134\231\154\132\230\136\152\230\150\151\229\141\143\232\174\174(\229\143\175\232\131\189\228\188\154\232\191\155\229\133\165\230\136\152\230\150\151)")
    return false
  end
  if _G.NRCPanelManager:GetLoadingPanelCount() > 0 then
    self:LogError("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\156\137\230\173\163\229\156\168\229\138\160\232\189\189\228\184\173\231\154\132\233\157\162\230\157\191")
    return false
  end
  if _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsOpenCamera) then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\176\143\230\184\184\230\136\143\232\191\144\233\149\156\228\184\173")
    return false
  end
  local Now = _G.UpdateManager.Timestamp
  if not self.DisableInterval and Now - self.LastExecuteTime < MinExecuteInterval then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\137\167\232\161\140\232\191\135\228\186\142\233\162\145\231\185\129", self.LastExecuteTime, Now)
    return false
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\151\160\230\179\149\232\142\183\229\143\150SceneLocalPlayer")
    return false
  end
  local HPComp = localPlayer.roleHPComponent
  if HPComp and 0 == HPComp:GetLocalRoleHP() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\231\142\169\229\174\182\232\161\128\233\135\143\228\184\186\233\155\182")
    return false
  end
  local InterComp = localPlayer.interactionComponent
  if InterComp and InterComp:HasInteractingAction() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\156\137\229\143\166\228\184\128\228\184\170Action\229\156\168\230\137\167\232\161\140", InterComp:GetInteractingActionDesc())
    return false
  end
  local IsFighting = localPlayer:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING)
  if IsFighting then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\144\142\229\143\176\232\174\164\228\184\186\231\142\169\229\174\182\232\191\152\229\156\168\230\136\152\230\150\151\228\184\173")
    return false
  end
  local NavComp = localPlayer.NavigationComponent
  if NavComp and NavComp.isLockPlayer then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:NavigationComponent\230\173\163\229\156\168\229\175\187\232\183\175")
    return false
  end
  if _G.DialogueModuleCmd and _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\183\178\231\187\143\229\175\185\232\175\157\228\184\173")
    return false
  end
  local InstanceModule = NRCModuleManager:GetModule("InstanceModule")
  if InstanceModule.bSwitching then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146, \230\173\163\229\156\168\231\173\137\229\190\133\229\137\175\230\156\172\230\181\129\231\168\139")
    return false
  end
  local CD = self.Owner.config.touch_battle_cd
  if CD and CD > 0 then
    CD = CD / 1000
    local LastDialogue = self:DoCmd(DialogueModuleCmd.GetLastDialogueEndTime) or 0
    if Now < LastDialogue + CD then
      self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\175\185\232\175\157\229\136\154\229\136\154\231\187\147\230\157\159", LastDialogue, Now)
      return false
    end
    local LastBattle = self:DoCmd(NPCModuleCmd.GetLastBattleEndTime) or 0
    if Now < LastBattle + CD then
      self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\136\152\230\150\151\229\136\154\229\136\154\231\187\147\230\157\159", LastBattle, Now)
      return false
    end
  end
  local InteractType = self.Owner.config.npc_interact_type
  local NeedMsg = InteractType ~= Enum.InteractType.IT_NONE and InteractType ~= Enum.InteractType.IT_AUTO
  local Ban, _ = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_PLAYER_OPTION, NeedMsg, NeedMsg)
  if Ban then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:PFBT_PLAYER_OPTION\231\166\129\231\148\168\230\137\128\230\156\137\228\186\164\228\186\146")
    return false
  end
  local PartialBan, Msg = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_LOAD_BAN_ACTION_CONF, NeedMsg, false)
  if PartialBan then
    local Conds = _G.FunctionBanManager:GetPlayerConditions()
    for Key, _ in pairs(Conds) do
      local Banned = _G.FunctionBanManager:GetConditionCounter(Key)
      if not Banned then
      else
        local BanActionConf = _G.DataConfigManager:GetBanActionConf(Key, true)
        if not BanActionConf then
        elseif #BanActionConf.banned_cond_list > 0 then
          for _, Val in ipairs(BanActionConf.banned_cond_list) do
            if Val.banned_list == self.Config.action_type then
              self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\229\156\168BAN_ACTION_CONF.banned_cond_list\229\136\151\232\161\168\228\184\173", Key)
              if NeedMsg and not string.IsNilOrEmpty(Msg) then
                _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Msg)
              end
              return false
            end
          end
        elseif #BanActionConf.allow_list > 0 then
          local Found = false
          for _, Val in ipairs(BanActionConf.allow_list) do
            if Val.allowed_list == self.Config.action_type then
              Found = true
            end
          end
          if not Found then
            self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\228\184\141\229\156\168BAN_ACTION_CONF.allow_list\229\136\151\232\161\168\228\184\173", Key)
            if NeedMsg and not string.IsNilOrEmpty(Msg) then
              _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Msg)
            end
            return false
          end
        end
      end
    end
  end
  if self.Owner:CheckOptionIsBan(true) then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:isBan")
    return false
  end
  return self:OnNpcActionCustomized()
end

function NPCActionBase:GetValidationInfo()
  return true, 0, 0
end

function NPCActionBase:Execute(playerId, needSendReq)
  if self.Owner then
    self.Owner:IncreaseExecuteTimes()
  end
  self.needSendReq = needSendReq
  if self.needSendReq == nil then
    self.needSendReq = true
  end
  self.isFinished = false
  self.playerId = playerId
  self:Log("Execute", needSendReq)
  if VisualDebug and self.OwnerNpc and self.Owner then
    local World = _G.UE4Helper.GetCurrentWorld()
    local Owner = self:GetOwnerNPCView()
    local Color = UE.FLinearColor(0, 1, 0, 1)
    local ColorRed = UE.FLinearColor(1, 0, 0, 1)
    local Location = Owner:K2_GetActorLocation()
    local Player = self:GetPlayer()
    local PlayerLocation = Player.viewObj:K2_GetActorLocation()
    local Dist2D = PlayerLocation:Dist2D(Location)
    local Text = string.format([[
%s
%d=%s]], self.OwnerNpc:DebugNPCNameAndID(), self.Owner.config.id, table.getKeyName(Enum.ActionType, self.Config.action_type))
    UE.UKismetSystemLibrary.DrawDebugString(World, Location, Text, nil, ColorRed, 999)
    UE.UKismetSystemLibrary.DrawDebugSphere(World, Location, Dist2D, 24, Color, 999, 2)
    Log.ErrorFormat("ExecuteAction!NPC=%s,Option=%d,Action=%s", self.OwnerNpc:DebugNPCNameAndID(), self.Owner.config.id, table.getKeyName(Enum.ActionType, self.Config.action_type))
  end
  self:RegisterThisActionToPlayer()
  self.LastExecuteTime = _G.UpdateManager.Timestamp
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.NpcActionExecute, self)
  self:BeforeSubmit()
  self:Submit()
end

function NPCActionBase:Finish(success, data, param)
  self:Log("Finish", success, data, param)
  self.isFinished = true
  if nil == success then
    self.bIsSuccess = true
  else
    self.bIsSuccess = true == success
  end
  self.LastExecuteTime = _G.UpdateManager.Timestamp
  self:Commit(data, param)
end

function NPCActionBase:GetIsFirst()
  return true
end

function NPCActionBase:Submit()
  if self.SkipSubmit then
    return
  end
  if not self.Owner and not self.OwnerNpc then
    self:LogError("NPCActionBase:Submit\231\154\132\230\151\182\229\128\153Owner\230\136\150\232\128\133OwnerNpc\228\184\141\229\173\152\229\156\168\239\188\129")
  end
  if self.OwnerNpc and self.OwnerNpc.Watch then
    self:LogError("Submitting Action")
  end
  self:Log("Submit")
  if self.needSendReq and self.Owner and self.OwnerNpc and not self.OwnerNpc.isLocalOnly then
    local req = ProtoMessage:newZoneSceneNpcNextActReq()
    req.option_id = self.Owner.config.id
    req.npc_id = self.OwnerNpc.serverData.base.actor_id
    req.first_act = self:GetIsFirst()
    req.battle_radius = BattleConst.Define.BattleFieldRange
    self:FillRequest(req)
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, req, self, self.CheckOnSubmit, self.NeedModal, true, nil, self.FailedOnSubmit)
  else
    local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
    rsp.ret_info.ret_code = 0
    self:CheckOnSubmit(rsp)
  end
end

function NPCActionBase:FailedOnSubmit(CmdID, Msg)
  if CmdID ~= ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ then
    return
  end
  local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
  rsp.ret_info.ret_code = ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_CLINET_ACTION_BATTLE_ERROR
  self:CheckOnSubmit(rsp)
end

function NPCActionBase:FillRequest(req)
  if self.Owner and self.Owner.owner then
    req.npc_pt = self.Owner.owner:GetServerPoint()
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
    local PlayerView = localPlayer.viewObj
    local RideComp = PlayerView and PlayerView.BP_RideComponent
    local Pet = RideComp and RideComp.ScenePet
    if Pet then
      req.ride_id = Pet.gid
    end
  end
  req.data1 = _G.BattleConst.Define.BattleFieldRange
end

function NPCActionBase:CheckOnSubmit(rsp)
  local Conf = _G.DataConfigManager:GetNpcActionConf(self.Config.action_type, true)
  if Conf then
    if Conf.wait_begin_data then
      if self:IsReadyToBeginAction() then
        self:OnSubmit(rsp)
      else
        self.SubMitRsp = rsp
        self.Owner:AddEventListener(self, NpcOptionEvent.NotifyBeginActionParams, self.NotifyBeginActionParams)
      end
    else
      self:OnSubmit(rsp)
    end
  else
    self:OnSubmit(rsp)
  end
end

function NPCActionBase:OnSubmit(rsp)
  self:Log("OnSubmit")
  local ErrorCode = rsp.ret_info.ret_code
  if 0 ~= ErrorCode then
    if table.contains(ActionUtils.ExpectedErrorCodes, ErrorCode) then
      self:ShowTips(ErrorCode)
    elseif self.OnSubmitErrorRetInfo and self:OnSubmitErrorRetInfo(rsp.ret_info, rsp) then
    else
      self:LogError("\229\143\145\233\128\129NextAct:OnSubmit,\229\155\158\229\140\133\231\130\184\229\149\166", _G.LuaText:GetErrorDesc(ErrorCode) or ErrorCode)
    end
    local player = self:GetPlayer()
    player:StopAnim("Walk", 0.25)
    self:RestIsSelectBtnBySubmitError(self.Config.action_type)
  end
  if self.Owner then
    self.Owner:SetNeedStatusNotify(false)
  end
  self:SendEvent(NPCActionEvent.OnExecute, rsp)
end

function NPCActionBase:Commit(data, param)
  self:Log("Commit")
  if not self.SkipCommit and not self.Owner and not self.OwnerNpc then
    self:LogError("NPCActionBase:Commit\231\154\132\230\151\182\229\128\153Owner\230\136\150\232\128\133OwnerNpc\228\184\141\229\173\152\229\156\168\239\188\129")
  end
  if self.OwnerNpc and self.OwnerNpc.Watch then
    self:LogError("Commiting Action", table.getKeyName(Enum.ActionType, self.Config.action_type), self.className)
  end
  if self.needSendReq == nil then
    self.needSendReq = true
  end
  if self.needSendReq and self.OwnerNpc and self.Owner and not self.SkipCommit and DialogueUtils.IsClientCommit(self.Config.action_type) then
    local NextActReq = ProtoMessage:newZoneSceneNpcNextActReq()
    NextActReq.npc_id = self.OwnerNpc.serverData.base.actor_id
    NextActReq.option_id = self.Owner.optionInfo.option_id
    NextActReq.battle_radius = _G.BattleConst.Define.BattleFieldRange
    if data then
      NextActReq.data1 = data
    end
    if param then
      NextActReq.commit_cur_act_params = param
    end
    if self.DialogueConf then
      NextActReq.cur_dialog_id = self.DialogueConf.id
    end
    self.Owner.isWaitingForRsp = true
    self:FillCommit(NextActReq)
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, NextActReq, self, self.OnCommit, self.NeedModal, true, nil, self.FailedOnCommit)
  else
    local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
    rsp.ret_info.ret_code = 0
    self:OnCommit(rsp)
  end
end

function NPCActionBase:FailedOnCommit(CmdID, Msg)
  if CmdID ~= ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ then
    return
  end
  local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
  rsp.ret_info.ret_code = ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_CLINET_ACTION_BATTLE_ERROR
  self:OnCommit(rsp)
end

function NPCActionBase:FillCommit(req)
  if self.Owner and self.Owner.owner then
    req.npc_pt = self.Owner.owner:GetServerPoint()
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
    local PlayerView = localPlayer.viewObj
    local RideComp = PlayerView and PlayerView.BP_RideComponent
    local Pet = RideComp and RideComp.ScenePet
    if Pet then
      req.ride_id = Pet.gid
    end
  end
  req.data1 = _G.BattleConst.Define.BattleFieldRange
end

function NPCActionBase:OnCommit(rsp)
  self:Log("OnCommit")
  if self.Owner then
    self.Owner.isWaitingForRsp = false
  end
  local ErrorCode = rsp.ret_info.ret_code
  if 0 ~= ErrorCode then
    if table.contains(ActionUtils.ExpectedErrorCodes, ErrorCode) then
      self:ShowTips(ErrorCode)
    elseif self.OnCommitErrorRetInfo and self:OnCommitErrorRetInfo(rsp.ret_info, rsp) then
    else
      self:LogError("\229\143\145\233\128\129NextAct:OnCommit,\229\155\158\229\140\133\231\130\184\229\149\166", _G.LuaText:GetErrorDesc(ErrorCode) or ErrorCode)
    end
    local player = self:GetPlayer()
    player:StopAnim("Walk", 0.25)
  end
  self:SendEvent(NPCActionEvent.OnFinish, rsp, self.bIsSuccess)
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.NpcActionFinish, self)
  self:UnregisterThisActionToPlayer()
  self:PostOnCommit(rsp)
  self.bIsSuccess = nil
  self.player = nil
end

function NPCActionBase:SetInteracting(Interacting)
  if Interacting == self.bInteracting then
    return
  end
  self.bInteracting = Interacting
  self.Owner:OnPlayerEnterActionArea()
end

function NPCActionBase:OnDialogueAction()
  NRCEventCenter:DispatchEvent(NPCModuleEvent.NpcActionExecute, self)
end

function NPCActionBase:HasLocalPerform()
  return DialogueUtils.IsClientCommit(self.Config.action_type)
end

function NPCActionBase:FreezePlayer()
  local player = self:GetPlayer()
  if player then
    player:Stop()
  end
end

function NPCActionBase:DiffInfo(InfoA, InfoB)
  if InfoA == InfoB then
    return true
  end
  if InfoA and InfoB then
    local Same = InfoA.act_type == InfoB.act_type
    Same = Same and InfoA.bound_dialog_id == InfoB.bound_dialog_id
    Same = Same and InfoA.act_status == InfoB.act_status
    Same = Same and InfoA.btle_cfg_id == InfoB.btle_cfg_id
    Same = Same and InfoA.dialog_id == InfoB.dialog_id
    return Same
  else
    return false
  end
end

function NPCActionBase:GetOwnerNPC()
  return self.OwnerNpc
end

function NPCActionBase:GetOwnerNPCView()
  local NPC = self:GetOwnerNPC()
  return NPC and NPC.viewObj
end

function NPCActionBase:GetPlayer()
  if self.playerId then
    local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, self.playerId)
    return Player
  end
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

function NPCActionBase:IsLocalAction()
  if self.playerId then
    local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    return Player.serverData.base.actor_id == self.playerId
  else
    return true
  end
end

function NPCActionBase:ShowTips(Code)
  local tipForShow
  if 50735 == Code then
    local owner = self:GetOwnerNPC()
    if owner then
      local serverData = owner.serverData
      if serverData then
        local tip, ownerName = UIUtils.GetHighValuePetTipsAndOwnerName(serverData)
        tipForShow = tip
      end
    end
  end
  tipForShow = tipForShow or _G.LuaText[string.format("Error_Code_%d", Code)]
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tipForShow)
end

function NPCActionBase:SetViewObjOption()
  if not self.OwnerNpc then
    return
  end
  local viewObj = self.OwnerNpc.viewObj
  if viewObj and viewObj.SetOptionCfg then
    viewObj:SetOptionCfg(self.Owner.config)
  end
end

function NPCActionBase:DoCmd(...)
  return _G.NRCModeManager:DoCmd(...)
end

function NPCActionBase:GetDesc(Level)
  Level = Level or Log.LOG_LEVEL.ELogDebug
  if Level <= Log.GetLogLevel() then
    return "[NpcAction]"
  end
  local OwnerNpcInfo = self.OwnerNpc and self.OwnerNpc:DebugNPCNameAndID() or "Unknown"
  local OwnerConf = self.Owner and self.Owner.config
  local OwnerID = OwnerConf and OwnerConf.id or -1
  local ActionType = self.Config and self.Config.action_type or 0
  local ActionTypeName = ActionType >= 0 and table.getKeyName(Enum.ActionType, ActionType) or "Unknown"
  return string.format("[NpcAction][%s]NPC=%s,Option=%d,Action=%s", self.name, OwnerNpcInfo, OwnerID, ActionTypeName)
end

function NPCActionBase:Log(...)
  Log.Debug(self:GetDesc(Log.LOG_LEVEL.ELogDebug), ...)
end

function NPCActionBase:LogWarning(...)
  Log.Warning(self:GetDesc(Log.LOG_LEVEL.ELogWarn), ...)
end

function NPCActionBase:LogError(...)
  Log.Error(self:GetDesc(Log.LOG_LEVEL.ELogError), ...)
end

function NPCActionBase:RegisterThisActionToPlayer()
  if not self:HasLocalPerform() then
    return
  end
  if not self:IsLocalAction() then
    return
  end
  if self.SkipSubmit then
    return
  end
  local Player = self:GetPlayer()
  if Player then
    Player.interactionComponent:SetInteractingAction(self)
  else
    self:LogError("NPCActionBase:RegisterThisActionToPlayer  Player is nil")
  end
end

function NPCActionBase:UnregisterThisActionToPlayer()
  if not self:HasLocalPerform() then
    return
  end
  if not self:IsLocalAction() then
    return
  end
  if self.SkipSubmit then
    return
  end
  local Player = self:GetPlayer()
  Player.interactionComponent:ClearInteractingAction(self)
end

function NPCActionBase:Destroy()
  EventDispatcher.Detach(self)
end

function NPCActionBase:IsNeedCloseDialogueUI()
  return true
end

function NPCActionBase:RestIsSelectBtnBySubmitError(actionType)
  local panelName = "LobbyMain"
  local moduleName = "MainUIModule"
  local touchReasonType
  if actionType == ProtoEnum.ActionType.ACT_TRIG_MINIGAME then
    touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, panelName).MINIGAME
  elseif actionType == ProtoEnum.ActionType.ACT_DIALOG then
    touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, panelName).DIALOG
  elseif actionType == ProtoEnum.ActionType.ACT_OPEN_TEAM_BATTLE_UI then
    touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, panelName).TEAMBATTLE
  end
  if touchReasonType then
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, moduleName, panelName, touchReasonType)
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetLockOpenSubUI, false)
  end
end

function NPCActionBase:IsReadyToBeginAction()
  if not self.Owner then
    return true
  end
  local Params = self.Owner:GetBeginActionParams(self.Config.action_type)
  if Params then
    self:BeforeBeginAction(Params)
    return true
  else
    return false
  end
end

function NPCActionBase:NotifyBeginActionParams(Option, Action)
  if Option == self.Owner then
    local Params = self.Owner:GetBeginActionParams(self.Config.action_type)
    if Params then
      self:BeforeBeginAction(Params)
      if self.SubMitRsp then
        self:OnSubmit(self.SubMitRsp)
        self.SubMitRsp = nil
      end
    else
      self:LogError("amonsu:NPCActionBase:NotifyBeginActionParams \230\178\161\230\156\137\231\173\137\229\136\176\233\156\128\232\166\129\231\154\132\229\137\141\231\189\174\230\149\176\230\141\174!!!")
    end
    self.Owner:RemoveEventListener(self, NpcOptionEvent.NotifyBeginActionParams, self.NotifyBeginActionParams)
  end
end

function NPCActionBase:BeforeBeginAction(Action)
  if self.Owner then
    self.Owner:RemoveBeginActionParams(self.Config.action_type)
  end
end

function NPCActionBase:BeforeSubmit()
  local ActionType = self.Config.action_type
  local Conf = _G.DataConfigManager:GetNpcActionConf(ActionType, true)
  if not Conf then
    return
  end
  if not Conf.wait_begin_data then
    return
  end
  local Params = self.Owner:GetBeginActionParams(ActionType)
  if Params then
    self:BeforeBeginAction(Params)
  else
    self:LogWarning("amonsu:NPCActionBase:BeforeSubmit \230\178\161\230\156\137\230\139\191\229\136\176\233\156\128\232\166\129\231\154\132\229\137\141\231\189\174\230\149\176\230\141\174!!!")
  end
end

function NPCActionBase:PostOnCommit(rsp)
  if self and self.Owner then
    self.Owner:ClearRideRestoreState()
  end
end

function NPCActionBase:OnPlayerLeaveActionArea()
end

function NPCActionBase:IfActionNeedStatusNotify()
  if self.OwnerNpc.isLocalOnly then
    return false
  end
  return true
end

function NPCActionBase:OnNpcActionCustomized()
  return true
end

function NPCActionBase:CacheSyncInfo(npcInfo)
  self.npcSyncInfo = npcInfo
end

function NPCActionBase:GetOwnerConfig()
  if self.Owner and self.Owner.config then
    return self.Owner.config
  end
  if self.npcSyncInfo and self.npcSyncInfo.option_id then
    return _G.DataConfigManager:GetNpcOptionConf(self.npcSyncInfo.option_id)
  end
end

function NPCActionBase:SkipInDialogue()
  if not self.isFinished then
    self:OnSkipInDialogue()
  else
    self:LogWarning("NPCActionBase:SkipInDialogue  self.isFinished is true")
  end
end

function NPCActionBase:OnSkipInDialogue()
end

function NPCActionBase:CanSkipInDialogue()
  return false
end

function NPCActionBase:ReLinkHand()
  local player = self:GetPlayer()
  if not player then
    return
  end
  player:ReLinkHand(PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
end

function NPCActionBase:UnLinkHand()
  local player = self:GetPlayer()
  if not player then
    return
  end
  player:UnLinkHand(PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
end

function NPCActionBase:SyncAction()
  local owner = self:GetOwnerNPC()
  if not owner then
    return
  end
  local option_conf = self:GetOwnerConfig()
  if not option_conf then
    return
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local req = _G.ProtoMessage:newZoneClientOperationReq()
  local playerData = localPlayer and localPlayer.serverData
  local base = playerData and playerData.base
  local player_id = base and base.actor_id
  if not player_id then
    return
  end
  req.operation.operator_id = player_id
  req.operation.aim_info = nil
  req.operation.pet_action_info = nil
  req.operation.operator_type = 2
  req.operation.npc_action_info.operation_target_id = owner.serverData.base.actor_id
  req.operation.npc_action_info.option_id = option_conf.id
  req.operation.npc_action_info.operation_type = self.Config.action_type
  req.operation.npc_action_info.action_status = NPCModuleEnum.ActionStatus.Begin
  if self.Info then
    req.operation.npc_action_info.act_exec_success = self.Info.act_exec_success
  end
  local Position = localPlayer:GetActorLocation()
  req.operation.npc_action_info.operator_location.pos.x = math.floor(Position.X)
  req.operation.npc_action_info.operator_location.pos.y = math.floor(Position.Y)
  req.operation.npc_action_info.operator_location.pos.z = math.floor(Position.Z)
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req)
end

function NPCActionBase:Preload()
  self:OnPreload()
end

function NPCActionBase:OnPreload()
end

return NPCActionBase
