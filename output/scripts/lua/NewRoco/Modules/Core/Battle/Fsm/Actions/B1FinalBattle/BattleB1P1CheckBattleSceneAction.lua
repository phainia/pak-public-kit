local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local Base = BattleActionBase
local BattleB1P1CheckBattleSceneAction = Base:Extend("BattleB1P1CheckBattleSceneAction")
local MaxCheckTime = 20
local MaxFindTime = 20
FsmUtils.MergeMembers(Base, BattleB1P1CheckBattleSceneAction, {})

function BattleB1P1CheckBattleSceneAction:OnEnter()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, false)
  _G.BattleManager:InitBattleField()
  self.waitTime = 0
  self:FindLevelBattleCenter()
end

function BattleB1P1CheckBattleSceneAction:FindLevelBattleCenter()
  local BattleCenterTable = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(_G.UE4Helper.GetCurrentWorld(), UE4.AActor, "LevelBattleCenter"):ToTable()
  if BattleCenterTable and #BattleCenterTable > 0 then
    if #BattleCenterTable > 1 then
      Log.Error("ZGX \230\136\152\229\156\186\228\188\160\233\128\129\228\184\173\230\137\190\229\136\176\229\164\154\228\184\170LevelBattleCenter\239\188\129\239\188\129\239\188\129 \232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\231\154\132\233\128\137\231\130\185\230\152\175\229\144\166\230\173\163\231\161\174!!!")
    end
    local BattleCenter = BattleCenterTable[1]
    self.npcPos = BattleCenter:Abs_K2_GetActorLocation()
    _G.BattleManager.battleRuntimeData.TeleportBattleCenter = self.npcPos
    _G.BattleManager.battleRuntimeData.ServerBattleRotate = BattleCenter:K2_GetActorRotation().Yaw
    self:CheckGround()
  else
    self.npcPos = FVectorZero
    if self.waitTime > MaxFindTime then
      Log.Error("ZGX \230\136\152\229\156\186\228\188\160\233\128\129\228\184\173\230\178\161\230\156\137\230\137\190\229\136\176\230\136\152\229\156\186\228\184\173\229\191\131\231\130\185")
      self.waitTime = 0
      self:CheckGround()
    end
  end
end

function BattleB1P1CheckBattleSceneAction:CheckGround()
  if self.waitTime > MaxCheckTime or self:FindPointAtGround(self.npcPos, true) then
    if self.waitTime > MaxCheckTime then
      Log.Error("ZGX \230\136\152\229\156\186\228\188\160\233\128\129\228\184\173\230\178\161\230\156\137\230\137\190\229\136\176\229\156\176\233\157\162\239\188\129\239\188\129\239\188\129 \232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\231\154\132\233\128\137\231\130\185\230\152\175\229\144\166\230\173\163\231\161\174!!! \230\156\172\229\156\186\230\136\152\230\150\151\231\154\132\233\128\137\231\130\185\228\184\186 ", self.npcPos)
    end
    BattleManager.battleRuntimeData.battleStartEnemyPos = self.npcPos
    self:Finish()
  end
end

function BattleB1P1CheckBattleSceneAction:FindPointAtGround(pos, isWrite)
  local findPos, _, isHit = LineTraceUtils.GetPointValidLocationByLine(pos)
  if findPos and isHit then
    if isWrite then
      pos.X = findPos.X
      pos.Y = findPos.Y
      pos.Z = findPos.Z
    end
    return true
  else
    return false
  end
end

return BattleB1P1CheckBattleSceneAction
