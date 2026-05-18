local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleSeamlessEnterAction = BattleActionBase:Extend("BattleSeamlessEnterAction")

function BattleSeamlessEnterAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleSeamlessEnterAction:OnPreload()
end

function BattleSeamlessEnterAction:OnEnter()
  self.timeout = 60.0
  local Result = self.BattleManager:PrepareBattle()
  if not Result then
    self.fsm:SendEvent(BattleEvent.EnterNormalOver, self)
    return
  end
  self.BattleManager:OpenBattleEnterWindow()
end

function BattleSeamlessEnterAction:CheckEnterWindowReady()
  return BattleUtils.HasEnterWindow()
end

function BattleSeamlessEnterAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattleSeamlessEnterAction:OnTick(DeltaTime)
  if not self:CheckEnterWindowReady() then
    return
  end
  if not self:CheckBattlePrepareOver() then
    return
  end
  self:OnEnterWindowReady()
end

function BattleSeamlessEnterAction:OnEnterWindowReady()
  self.BattleManager:PlayBattleBGM()
  self:SetupPet()
  self:Finish()
end

function BattleSeamlessEnterAction:SetupPet()
  local firstPet = self.PawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local model = firstPet and firstPet.model
  local Cached = BattleUtils.GetTraceNpc()
  local transform = Cached.transform
  local NPCModule = BattleUtils.GetNPCModule()
  model:Abs_K2_SetActorTransform_WithoutHit(transform, false, false)
  NPCModule:RemoveNpc(Cached.id, true)
  BattleUtils.ClearTraceNpc()
  local dir = BattleUtils.GetPlayer():GetActorLocation() - model:Abs_K2_GetActorLocation()
  dir.Z = 0
  model:K2_SetActorRotation(dir:ToRotator(), false)
end

function BattleSeamlessEnterAction:OnExit()
  self.BattleManager = nil
  self.PawnManager = nil
end

return BattleSeamlessEnterAction
