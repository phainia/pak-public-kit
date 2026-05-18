require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local LogicStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.LogicStatusComponent")
_G.SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_DungeonWater_C = Base:Extend("BP_DungeonWater_C")
local TempArray = UE4.TArray(UE4.AActor)

function BP_DungeonWater_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.SoundSession = -1
  local GetHasActorBegunPlay = UE.NPCUtils.GetHasActorBegunPlay
  if GetHasActorBegunPlay and GetHasActorBegunPlay(self) then
    self:ReceiveBeginPlay()
  else
    self:ClearTimer()
    self.BeginPlayCheckTimer = _G.TimerManager:CreateTimer(self, "BeginPlayCheckTimer", 60, self.OnTimerUpdate, self.OnTimerComplete, 10)
  end
  Log.Debug("BP_DungeonWater_C:Initialize", UE.UObject.GetFullName(self), tostring(self))
end

function BP_DungeonWater_C:ReceiveBeginPlay()
  if NRCEnv:IsLocalMode() then
    Base.ReceiveBeginPlay(self)
  else
    Log.Debug("BP_DungeonWater_C:ReceiveBeginPlay", self.sceneCharacter and self.sceneCharacter:DebugNPCNameAndID() or "no scene character", UE.UObject.GetFullName(self), self)
    self.collision_disabled = true
    Base.ReceiveBeginPlay(self)
    if self.collision_disabled then
      self:SetActorEnableCollision(false)
    end
  end
  self:ClearTimer()
end

function BP_DungeonWater_C:Ctor()
  Base.Ctor(self)
  self.targetPos = nil
  self.speed = 0
  self.SoundSession = -1
  self.collision_disabled = false
  self.IceBergList = {}
end

function BP_DungeonWater_C:Init()
  Base.Init(self)
  self.bSkipOverlapCheck = true
end

function BP_DungeonWater_C:ReceiveEndPlay()
  UpdateManager:UnRegister(self)
  self:StopMoveSound()
  self.IceBergList = {}
  self:ClearTimer()
  Base.ReceiveEndPlay(self)
end

function BP_DungeonWater_C:OnTimerComplete()
  if not UE.UObject.IsValid(self) then
    return
  end
  Log.Error("BP_DungeonWater_C:OnTimerComplete i didnt receive any begin play!!!!", UE.UObject.GetFullName(self), tostring(self))
  self:ClearTimer()
  self:ReceiveBeginPlay()
  if not RocoEnv.IS_EDITOR then
    local ErrorMessage = string.format("BP_DungeonWater_C\229\156\168Initialize\228\185\139\229\144\142\231\154\13260\231\167\146\229\134\133\230\178\161\230\156\137\230\148\182\229\136\176ReceiveBeginPlay:%s %s", UE.UObject.GetFullName(self), tostring(self))
    _G.NRCSDKManager:CrashSightReportExceptionWithReason("Actor\231\148\159\229\145\189\229\145\168\230\156\159\229\188\130\229\184\184", ErrorMessage, "")
  end
end

function BP_DungeonWater_C:OnTimerUpdate()
  if not self.BeginPlayCheckTimer then
    Log.Error("BP_DungeonWater_C:OnTimerUpdate where does this come from????", UE.UObject.GetFullName(self), tostring(self))
    return
  end
  Log.Debug("BP_DungeonWater_C:OnTimerUpdate wait for begin play", self.BeginPlayCheckTimer.elapsedTime, UE.UObject.GetFullName(self), tostring(self))
end

function BP_DungeonWater_C:ClearTimer()
  if not self.BeginPlayCheckTimer then
    return
  end
  _G.TimerManager:RemoveTimer(self.BeginPlayCheckTimer)
  self.BeginPlayCheckTimer = nil
  Log.Debug("BP_DungeonWater_C:ClearTimer", UE.UObject.GetFullName(self), tostring(self))
end

function BP_DungeonWater_C:UpdateState(bInit)
  local CheckPlayerBeneath = false
  local npc = self.sceneCharacter
  if npc then
    local logicStatusComp = npc:EnsureComponent(LogicStatusComponent)
    local state, _, extraData = logicStatusComp:GetStatus(Enum.SpaceActorLogicStatus.SALS_LEVEL_POS_CHANGED)
    if state then
      CheckPlayerBeneath = true
      if extraData and extraData.type == Enum.LogicStatusExtraDataType.LSEDT_LEVEL_POS then
        local pos = extraData.level_pos.pos_info
        local time = extraData.level_pos.time
        if 0 == time then
          time = 1
        end
        self.targetPos = pos and UE.FVector(pos[1], pos[2], pos[3]) or npc.landPos
        if bInit then
          self:Abs_K2_SetActorLocation_WithoutHit(self.targetPos, true)
          Log.PrintScreenMsg("[BP_DungeonWater_C]\231\137\169\228\187\182\228\189\141\231\189\174\229\188\186\229\136\182\230\155\180\230\150\176")
        else
          local selfPos = self:Abs_K2_GetActorLocation()
          local distance = UE.FVector.Dist(selfPos, self.targetPos)
          self.speed = distance / time
          if self.speed <= 1.0E-4 then
            Log.Debug("[BP_DungeonWater_C] \229\183\178\231\187\143\229\156\168\233\162\132\230\156\159\228\189\141\231\189\174")
            return
          end
          UpdateManager:Register(self)
          self:PlayMoveSound()
          _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.Water_Move_For_Trace)
          self.Box:GetOverlappingActors(TempArray)
          for k, v in tpairs(TempArray) do
            if v.sceneCharacter and v.sceneCharacter.SetSwimFxVisible then
              v.sceneCharacter:SetSwimFxVisible(false, "DungeonWaterMove")
            end
            if v.RocoMoveFx and v.RocoMoveFx.PauseMoveFx then
              v.RocoMoveFx:PauseMoveFx()
            end
          end
          Log.PrintScreenMsg("[BP_DungeonWater_C]\231\137\169\228\187\182\231\167\187\229\138\168\228\184\173\239\188\140\233\162\132\232\174\161\230\151\182\233\151\180:%f \232\183\157\231\166\187:%f", time, distance)
          if self.IceBergList then
            for k, v in pairs(self.IceBergList) do
              self:UnregisterIceBerg(v)
              v:RecycleStandingActors()
            end
          end
        end
      else
        self:Abs_K2_SetActorLocation_WithoutHit(npc.landPos, true)
      end
    elseif bInit then
      self:Abs_K2_SetActorLocation_WithoutHit(npc.landPos, false)
    end
  end
  if self.collision_disabled then
    self:SetActorEnableCollision(true)
    self.collision_disabled = false
    SceneUtils.RequestPlayerUpdateEnvInfo()
  end
  Base.UpdateState(self)
end

function BP_DungeonWater_C:OnTick(deltaTime)
  if self.targetPos then
    local selfPos = self:Abs_K2_GetActorLocation()
    local dir = self.targetPos - selfPos
    local dist = dir:Size()
    if dist < 1.0 then
      UpdateManager:UnRegister(self)
      self:Abs_K2_SetActorLocation_WithoutHit(self.targetPos)
      self.targetPos = nil
      self.speed = 0
      self.Box:GetOverlappingActors(TempArray)
      for k, v in tpairs(TempArray) do
        if v.sceneCharacter and v.sceneCharacter.SetSwimFxVisible then
          v.sceneCharacter:SetSwimFxVisible(true, "DungeonWaterMove")
        end
        if v.RocoMoveFx and v.RocoMoveFx.ReStartMoveFx then
          v.RocoMoveFx:ReStartMoveFx()
        end
      end
      _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.Water_Stop_Move_For_Trace)
      Log.Warning("[BP_DungeonWater_C]\231\137\169\228\187\182\231\167\187\229\138\168\231\187\147\230\157\159")
      self:StopMoveSound()
      if self.sceneCharacter then
        self.sceneCharacter.luaObj:SendPosToServer()
        _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, self.sceneCharacter:GetServerId())
      end
      return
    end
    dir:Normalize()
    local ratio = math.min(dist, deltaTime * self.speed)
    dir = dir * ratio
    dir = dir + selfPos
    self:Abs_K2_SetActorLocation_WithoutHit(dir)
    if self.Box then
      self.Box:GetOverlappingActors(TempArray)
      UE.UNRCStatics.RequestEnvInfoUpdate(TempArray)
    end
  else
    UpdateManager:UnRegister(self)
  end
end

function BP_DungeonWater_C:Recycle()
  self:StopMoveSound()
  Base.Recycle(self)
end

function BP_DungeonWater_C:PlayMoveSound()
  self.SoundSession = NRCAudioManager:PlaySound3DWithActor(10020005, self, "BP_DungeonWater", false, false)
end

function BP_DungeonWater_C:StopMoveSound()
  if self.SoundSession > 0 then
    NRCAudioManager:ReleaseSession(self.SoundSession, true, "BP_DungeonWater")
    self.SoundSession = -1
  end
end

function BP_DungeonWater_C:RegisterIceBerg(IceBerg)
  if IceBerg then
    table.insert(self.IceBergList, IceBerg)
  end
end

function BP_DungeonWater_C:UnregisterIceBerg(IceBerg)
  if IceBerg then
    for k, v in pairs(self.IceBergList) do
      if v == IceBerg then
        table.remove(self.IceBergList, k)
        break
      end
    end
  end
end

return BP_DungeonWater_C
