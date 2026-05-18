local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local Base = require("NewRoco.Modules.Core.NPC.ThrowSessionBase")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowLightBallSession = Base:Extend("ThrowLightBallSession")
ThrowLightBallSession.ShowTrajectory = false
ThrowLightBallSession.ActiveLightBallSessions = {}

function ThrowLightBallSession:Ctor()
  Base.Ctor(self)
  self.LightBallNPC = nil
  self.ChargeLevel = 0
  self.Status = ThrowSessionStatusEnum.InHand
  if self.ShowTrajectory then
    _G.UpdateManager:Register(self)
  end
end

function ThrowLightBallSession:OnTick(DeltaTime)
  if not ThrowLightBallSession.ShowTrajectory then
    _G.UpdateManager:UnRegister(self)
    return
  end
  if not self.LightBallNPC then
    _G.UpdateManager:UnRegister(self)
    return
  end
  local CurrentPos
  if self.LightBallNPC and self.LightBallNPC.viewObj then
    CurrentPos = self.LightBallNPC:GetActorLocation()
  end
  if not CurrentPos then
    return
  end
  if not self.PrevPos then
    self.PrevPos = CurrentPos
  end
  local Color = UE4.FLinearColor(1, 1, 1)
  if self.LightBallNPC.viewObj.collisionEnabled then
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), self.PrevPos, CurrentPos, Color, 30, 2)
  elseif self.LightBallNPC.viewObj.throwStarted then
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), self.PrevPos, CurrentPos, UE4.FLinearColor(1, 0, 0), 30, 2)
  else
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), self.PrevPos, CurrentPos, UE4.FLinearColor(0, 0, 0), 30, 2)
  end
  self.PrevPos = CurrentPos
end

function ThrowLightBallSession:Recycle()
  if self.LightBallNPC then
    self.LightBallNPC:Destroy()
    self.LightBallNPC = nil
  end
end

function ThrowLightBallSession:OnHit()
  if not self.CollisionReq then
    self.CollisionReq = _G.ProtoMessage:newZoneSceneThrowCollisionReq()
    self.CollisionReq.throw_id = self.SeqID
    self.CollisionReq.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
    self.CollisionReq.item_conf_id = 0
  end
  UE.UNRCStatics.BatchShakeTrees(_G.UE4Helper.GetCurrentWorld(), self.LightBallNPC.viewObj:K2_GetActorLocation(), self.LightBallNPC.viewObj.BoomRange)
end

function ThrowLightBallSession:CreateLightBall()
  local Session = ThrowLightBallSession()
  table.insert(ThrowLightBallSession.ActiveLightBallSessions, Session)
  return Session
end

function ThrowLightBallSession:OnBeginThrow()
  local Req = ProtoMessage:newZoneSceneBeginThrowReq()
  local ThrowItemInfo = _G.DataModelMgr.PlayerDataModel:GetThrowItemInfo()
  if ThrowItemInfo then
    Req.gid = ThrowItemInfo.cur_selected_magic_item_gid
    Req.item_conf_id = ThrowItemInfo.id or 0
  end
  Req.throw_id = self.SeqID
  Req.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_BEGIN_THROW_REQ, Req, self, self.OnBeginThrowRsp, false, true)
  self.status = ThrowSessionStatusEnum.InAir
  local MinSeqID, MinBall
  local InAirNum = 0
  for _, Ball in ipairs(ThrowLightBallSession.ActiveLightBallSessions) do
    InAirNum = InAirNum + 1
    if not MinSeqID or MinSeqID > Ball.SeqID then
      MinSeqID = Ball.SeqID
      MinBall = Ball
    end
  end
  local MaxConfNum = self.LightBallNPC.viewObj.MagicBaseConfig.maxcount or 10
  if InAirNum > MaxConfNum then
    MinBall:Abandon()
  end
end

function ThrowLightBallSession:OnBeginThrowRsp(Rsp)
  if Rsp and Rsp.ret_info and 0 ~= Rsp.ret_info.ret_code then
    Log.Error("\229\133\137\231\179\187\233\173\148\230\179\149\230\138\149\230\142\183\229\143\145\232\181\183\229\164\177\232\180\165\239\188\140\233\148\153\232\175\175\231\160\129\230\152\175", Rsp.ret_info.ret_code)
  end
end

function ThrowLightBallSession:Abandon()
  if self.status == ThrowSessionStatusEnum.InAir then
    self.status = ThrowSessionStatusEnum.Abandon
  elseif self.status == ThrowSessionStatusEnum.Destroyed then
    return
  else
    self.status = ThrowSessionStatusEnum.Abandon
    return
  end
  self.LightBallNPC.viewObj:SetFlyEnd()
  self.LightBallNPC.viewObj:BreakItself()
end

function ThrowLightBallSession:OnEndThrow()
  if self.status ~= ThrowSessionStatusEnum.InAir then
    return
  end
  if ThrowLightBallSession.ShowTrajectory then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), self.LightBallNPC.viewObj:Abs_K2_GetActorLocation(), self.LightBallNPC.viewObj.BoomRevealRange, 12, UE4.FLinearColor(0, 1, 0, 1), 15, 5)
  end
  local Req = _G.ProtoMessage:newZoneSceneEndThrowReq()
  Req.throw_type = _G.ProtoEnum.ThrowType.THROW_MAGIC
  local ThrowItemInfo = _G.DataModelMgr.PlayerDataModel:GetThrowItemInfo()
  if ThrowItemInfo then
    Req.gid = ThrowItemInfo.cur_selected_magic_item_gid
    Req.item_conf_id = ThrowItemInfo.id or 0
  end
  Req.throw_id = self.SeqID
  local LightBallView = self.LightBallNPC and self.LightBallNPC.viewObj
  local Range = LightBallView and LightBallView.BoomRevealRange or 0
  Req.throw_effect = ProtoEnum.ThrowEffect.TRIG_MAGIC_INTERACT
  Req.throw_magic_info.strength_level = LightBallView and LightBallView.ChargeLevel or 0
  Req.throw_target_npc_infos = self:CheckRevealNpc(Range)
  if LightBallView and LightBallView.ChargeProcess then
    Req.throw_magic_info.charge_percentage = math.round(LightBallView.ChargeProcess * 10000)
  else
    Req.throw_magic_info.charge_percentage = 0
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, Req, self, self.OnEndThrowRsp, false, true)
end

function ThrowLightBallSession:OnEndThrowRsp(Rsp)
  if 0 == Rsp.ret_info.ret_code then
  end
end

function ThrowLightBallSession:SetStatus(Status)
  if self.status == Status then
    return
  end
  if self.status == ThrowSessionStatusEnum.Destroyed then
    return
  end
  self.status = Status
  if self.status == ThrowSessionStatusEnum.Destroyed then
    self:OnSessionDestroyed()
  end
end

function ThrowLightBallSession:OnSessionDestroyed()
  local Found
  for Index, Session in pairs(ThrowLightBallSession.ActiveLightBallSessions) do
    if Session == self then
      Found = Index
    end
  end
  if Found then
    table.remove(ThrowLightBallSession.ActiveLightBallSessions, Found)
  end
end

function ThrowLightBallSession:OnFlyPathReveal()
  local Req = _G.ProtoMessage:newZoneSceneProcessThrowReq()
  Req.throw_type = _G.ProtoEnum.ThrowType.THROW_MAGIC
  local ThrowItemInfo = _G.DataModelMgr.PlayerDataModel:GetThrowItemInfo()
  if ThrowItemInfo then
    Req.gid = ThrowItemInfo.cur_selected_magic_item_gid
    Req.item_conf_id = ThrowItemInfo.id or 0
  end
  Req.throw_id = self.SeqID
  local LightBallView = self.LightBallNPC and self.LightBallNPC.viewObj
  local Range = LightBallView and LightBallView.RevealRange or 0
  local TargetNpcInfos = self:CheckRevealNpc(Range)
  if not table.isNil(TargetNpcInfos) then
    Req.throw_target_npc_infos = TargetNpcInfos
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PROCESS_THROW_REQ, Req, self, self.OnFlyPathRevealRsp, false, true)
  end
end

function ThrowLightBallSession:OnFlyPathRevealRsp()
end

function ThrowLightBallSession:CheckRevealNpc(Range)
  local LightBallView = self.LightBallNPC and self.LightBallNPC.viewObj
  local RelativeLocation = LightBallView:K2_GetActorLocation()
  local ChargeLevel = LightBallView.ChargeLevel
  local MagicID = LightBallView.MagicID
  local ObjectTypes = {
    UE.EObjectTypeQuery.WorldDynamic,
    UE.EObjectTypeQuery.Pawn,
    UE.EObjectTypeQuery.WorldStatic
  }
  local CachedResults = UE4.TArray(UE.AActor)
  local Success = UE.UNRCStatics.SphereOverlapActors(_G.UE4Helper.GetCurrentWorld(), RelativeLocation, Range, ObjectTypes, {LightBallView}, CachedResults)
  if not Success then
    CachedResults:Clear()
  end
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  if not SceneModule then
    return
  end
  local TargetInfos = {}
  local CharacterCheckedMap = {}
  for _, Actor in tpairs(CachedResults) do
    local Character = Actor.sceneCharacter
    if not Character or CharacterCheckedMap[Character] then
      goto lbl_137
    else
      CharacterCheckedMap[Character] = true
    end
    if not SceneModule:CheckIsNpc(Character:GetServerId()) then
    else
      local InterComp = Character and Character.InteractionComponent
      local Options = InterComp and InterComp._options
      if Options then
        for _, Option in pairs(Options) do
          local ValidOption
          local MagicActions = Option:EnsureMagicActions()
          for _, Action in pairs(MagicActions) do
            if Action:CanExecute(Character, ChargeLevel, MagicID, RelativeLocation) then
              Action:Execute(Character)
              ValidOption = Option
            end
          end
          if ValidOption then
            local TargetInfo = _G.ProtoMessage:newThrowTargetNpcInfo()
            TargetInfo.npc_id = Character.serverData.base.actor_id
            TargetInfo.option_id = Option.optionInfo.option_id
            Character:GetServerPosition(TargetInfo.npc_pos)
            table.insert(TargetInfos, TargetInfo)
          end
        end
      end
    end
    ::lbl_137::
  end
  CachedResults:Clear()
  return TargetInfos
end

return ThrowLightBallSession
