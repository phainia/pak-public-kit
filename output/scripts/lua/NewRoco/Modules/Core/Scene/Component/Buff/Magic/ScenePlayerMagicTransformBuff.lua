local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.Magic.ScenePlayerMagicBaseBuff")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SceneAIUtils = require("NewRoco.AI.SceneAIUtils")
local ScenePlayerMagicTransformBuff = Base:Extend("ScenePlayerMagicTransformBuff")

function ScenePlayerMagicTransformBuff:OnBegin(owner, MagicInfo)
  Base.OnBegin(self, owner, MagicInfo)
  local WandData = owner:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_LIQUEFY)
  self.magicInfo.mozhangBP.DisappearFx = WandData.NS_Magic_Transform_Disappead
  self.CastSelf = false
  self.CastPlayerId = -1
  self.TickTime = 0.1
  self.LockedPlayer = nil
  self.LockedScore = 0
end

function ScenePlayerMagicTransformBuff:OnUpdate(deltaTime)
  Base.OnUpdate(self, deltaTime)
  if not self.owner.isLocal or not UE4.UObject.IsValid(self.owner.viewObj) then
    return
  end
  if self.waitCasting then
    return
  end
  self.TickTime = self.TickTime - deltaTime
  local maxDis = _G.DataConfigManager:GetGlobalConfig("aim_player_max_distance").num or 2000
  local PlayerLocation = self.owner.viewObj:K2_GetActorLocation()
  local PlayerForward = UE.UKismetMathLibrary.GetForwardVector(self.owner:GetUEController().PlayerCameraManager:GetCameraRotation())
  if self.TickTime > 0 then
    local Score = self:GetPlayerScore(self.LockedPlayer, PlayerLocation, PlayerForward, maxDis)
    if Score > 0 then
      return
    end
  end
  self.TickTime = 0.3
  self.LockedPlayer = nil
  self.LockedScore = 0
  local PlayerList = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_ALL_PLAYER)
  if PlayerList then
    for _, Player in pairs(PlayerList) do
      local Score = self:GetPlayerScore(Player, PlayerLocation, PlayerForward, maxDis)
      if Score > self.LockedScore then
        local OtherPlayerLocation = Player.viewObj:K2_GetActorLocation()
        local ignoreActors = UE4.TArray(UE.AActor)
        ignoreActors:Add(self.owner.viewObj)
        local Hit, Success = UE.UKismetSystemLibrary.LineTraceSingle(self.owner.viewObj, PlayerLocation, OtherPlayerLocation, UE.ETraceTypeQuery.Visibility, false, ignoreActors, 0, nil, true)
        if not (Success and Hit.Actor) or Hit.Actor == Player.viewObj or Player.viewObj == Hit.Actor.Rider then
          self.LockedPlayer = Player
          self.LockedScore = Score
        end
      end
    end
  end
  if self.LockedPlayer then
    self.CastPlayerId = self.LockedPlayer.serverData.base.actor_id
  else
    self.CastPlayerId = nil
  end
end

function ScenePlayerMagicTransformBuff:GetPlayerScore(Player, PlayerLocation, PlayerForward, maxDis)
  if Player and Player.IsMagicReplayActor and Player:IsMagicReplayActor() then
    return -1
  end
  if Player and Player.viewObj and Player.viewObj:WasRecentlyRendered(0.2) and Player ~= self.owner then
    local OtherPlayerLocation = Player.viewObj:K2_GetActorLocation()
    local Dir = {
      X = OtherPlayerLocation.X - PlayerLocation.X,
      Y = OtherPlayerLocation.Y - PlayerLocation.Y,
      Z = OtherPlayerLocation.Z - PlayerLocation.Z
    }
    local DotDir = Dir.X * PlayerForward.X + Dir.Y * PlayerForward.Y + Dir.Z * PlayerForward.Z
    if DotDir > 0 then
      local Distance = math.sqrt(Dir.X * Dir.X + Dir.Y * Dir.Y + Dir.Z * Dir.Z)
      if maxDis >= Distance then
        local Dot = DotDir / Distance
        return Dot
      end
    end
  end
  return -1
end

function ScenePlayerMagicTransformBuff:OnCastMagic()
  if self.waitCasting then
    return
  end
  if not (self.LockedPlayer and self.LockedPlayer.viewObj) or not self.LockedPlayer.viewObj:IsValid() then
    self.CastPlayerId = nil
  end
  if SceneUtils.GetAutoHoming() then
    self.CastSelf = true
  end
  if self.CastSelf then
    self.CastPlayerId = self.owner.serverData.base.actor_id
  end
  if self.magicInfo.mozhangBP and UE4.UObject.IsValid(self.magicInfo.mozhangBP) then
    self.magicInfo.mozhangBP:PlayFX(self.magicInfo.mozhangBP.MagicTransform_Ball_Boom, false)
  else
    Log.Error("\233\173\148\230\157\150\230\151\160\230\149\136")
    return
  end
  Base.OnCastMagic(self)
end

function ScenePlayerMagicTransformBuff:SetDisableReason(Reason)
  self.DisableReason = Reason
end

return ScenePlayerMagicTransformBuff
