local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
if not BattleCenterDebugManager then
  BattleCenterDebugManager = Singleton:Extend("BattleCenterDebugManager")
end

function BattleCenterDebugManager:CheckSceneResIdIsSameScene(a, b)
  if a == b then
    return true
  end
  local sceneResConfA = _G.DataConfigManager:GetSceneResConf(a)
  local sceneResConfB = _G.DataConfigManager:GetSceneResConf(b)
  if sceneResConfA and sceneResConfB then
    return sceneResConfA.main_source == sceneResConfB.main_source
  end
  return false
end

function BattleCenterDebugManager.ReloadLocalBattleConfYAML()
  if _G.DataConfigManager.__dataTables[_G.DataConfigManager.ConfigTableId.BATTLE_CONF] == nil then
    Log.Warning("zgx RefreshLocalBattleConfYAML")
    UE.UNRCEditorAssetLibrary.RefreshLocalBattleConfYAML()
  end
end

function BattleCenterDebugManager.StartDebugBattleCenter(battleId)
  if not battleId then
    Log.Error("BattleCenterDebugManager:StartDebugBattleCenter: battleId is nil")
    return
  end
  BattleCenterDebugManager.ReloadLocalBattleConfYAML()
  local BattleConf = _G.DataConfigManager:GetBattleConf(battleId, true)
  if not BattleConf then
    Log.Error("BattleCenterDebugManager:StartDebugBattleCenter: BattleConf is nil", battleId)
    return
  end
  if BattleConf and BattleConf.local_point and #BattleConf.local_point >= 3 then
    if BattleCenterDebugManager.ChangeConfs and BattleCenterDebugManager.ChangeConfs[BattleConf.id] then
      local pos = BattleCenterDebugManager.ChangeConfs[BattleConf.id].pos
      local rot = BattleCenterDebugManager.ChangeConfs[BattleConf.id].rot
      BattleCenterDebugManager.TeleportBattleCenter = UE4.FVector(math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
      BattleCenterDebugManager.ServerBattleRotate = math.floor(rot.Yaw)
    else
      local pos = BattleConf.local_point
      BattleCenterDebugManager.TeleportBattleCenter = UE4.FVector(pos[1], pos[2], pos[3])
      if #pos >= 4 then
        BattleCenterDebugManager.ServerBattleRotate = pos[4]
      end
    end
    do
      local teleportRequest = ProtoMessage.newZoneSceneGmTeleportReq()
      teleportRequest.to_scene_cfg_id = SceneUtils.GetSceneID()
      teleportRequest.to_point.pos.x = BattleCenterDebugManager.TeleportBattleCenter.X
      teleportRequest.to_point.pos.y = BattleCenterDebugManager.TeleportBattleCenter.Y
      teleportRequest.to_point.pos.z = BattleCenterDebugManager.TeleportBattleCenter.Z
      teleportRequest.to_point.dir.x = 0
      teleportRequest.to_point.dir.y = 0
      teleportRequest.to_point.dir.z = BattleCenterDebugManager.ServerBattleRotate or 0
      BattleCenterDebugManager:RegisterTransformEvent()
      if not ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleportRequest, BattleCenterDebugManager, BattleCenterDebugManager.OnTeleportRsp, false) then
        BattleCenterDebugManager:UnRegisterTransformEvent()
        Log.Error("BattleCenterDebugManager:StartDebugBattleCenter: Send ZONE_SCENE_GM_TELEPORT_REQ failed, please Check your network, and try again")
      else
        BattleCenterDebugManager.CurBattleConf = BattleConf
        goto lbl_170
        Log.Error("BattleCenterDebugManager:StartDebugBattleCenter: BattleConf.local_point is not same scene", battleId)
      end
    end
  else
    Log.Error("BattleCenterDebugManager:StartDebugBattleCenter: BattleConf.local_point is nil", battleId)
    return
  end
  ::lbl_170::
end

function BattleCenterDebugManager:OnPlayerTeleportFinish()
  self:UnRegisterTransformEvent()
  if self.CurBattleConf then
    local rotate = UE4.FRotator(0, self.ServerBattleRotate, 0)
    if not self.DebugActor or not UE4.UObject.IsValid(self.DebugActor) then
      local DebugActorUclass = UE4.UObject.Load("Blueprint'/Game/Editor/DebugBattleCenter/DebugBattleCenter.DebugBattleCenter_C'")
      local fTransform = UE4.FTransform(rotate:ToQuat(), self.TeleportBattleCenter)
      self.DebugActor = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(DebugActorUclass, fTransform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
      self.DebugActorRef = UnLua.Ref(self.DebugActor)
    else
      local fTransform = UE4.FTransform(rotate:ToQuat(), self.TeleportBattleCenter)
      self.DebugActor:Abs_K2_SetActorTransform(fTransform, false, false)
    end
    self.DebugActor:SetBattleConf(self.CurBattleConf)
  end
end

function BattleCenterDebugManager:OnTeleportRsp(rsp)
  if rsp and rsp.ret_info and 0 ~= rsp.ret_info.ret_code then
    self:UnRegisterTransformEvent()
  end
end

function BattleCenterDebugManager:ClearBattleCenter()
  if self.DebugActor then
    self.DebugActor:ClearBattleField()
    self.DebugActor:K2_DestroyActor()
    self.DebugActor = nil
  end
  self.DebugActorRef = nil
  self.CurBattleConf = nil
end

function BattleCenterDebugManager.SimulateBattle(battleId)
  if BattleCenterDebugManager.DebugActor then
    BattleCenterDebugManager.DebugActor:DestroyBattleField()
  end
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    Log.Error("BattleCenterDebugManager:SimulateBattle: player is nil")
    return
  end
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
  req.avatar_pt.pos.x = math.floor(PlayerLocation.X)
  req.avatar_pt.pos.y = math.floor(PlayerLocation.Y)
  req.avatar_pt.pos.z = math.floor(PlayerLocation.Z)
  req.npc_pt.pos.x = math.floor(PlayerLocation.X)
  req.npc_pt.pos.y = math.floor(PlayerLocation.Y)
  req.npc_pt.pos.z = math.floor(PlayerLocation.Z)
  req.battle_conf_id = battleId
  req.npc_level = 1
  Log.Dump(req, 2, "Show Enter Battle Req")
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req, BattleCenterDebugManager, BattleCenterDebugManager.OnEnterBattle)
end

function BattleCenterDebugManager:OnEnterBattle(rsp)
  if 0 == rsp.ret_info.ret_code then
    return
  end
  local Context = DialogContext()
  Context:SetTitle("Oops"):SetContent(string.format("\232\191\155\229\133\165\230\136\152\230\150\151\229\164\177\232\180\165:%d", rsp.ret_info.ret_code)):SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function BattleCenterDebugManager:RegisterTransformEvent()
  NRCEventCenter:RegisterEvent("BattleCenterDebugManager", self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnPlayerTeleportFinish)
  NRCEventCenter:RegisterEvent("BattleCenterDebugManager", self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
end

function BattleCenterDebugManager:UnRegisterTransformEvent()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnPlayerTeleportFinish)
end

return BattleCenterDebugManager
