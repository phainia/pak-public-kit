local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitRoundPlayAction = Base:Extend("BattleWaitRoundPlayAction")
FsmUtils.MergeMembers(Base, BattleWaitRoundPlayAction, {})

function BattleWaitRoundPlayAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitRoundPlayAction:OnEnter()
  self.timeout = 10
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PROCESS_ENERGY_TRACK_END, BattleEvent.BATTLE_PET_DEATH_PENDING_ANIMATION_FINISH, BattleEvent.BATTLE_PROCESS_EVOLUTION_END)
  self:StatusCheck()
end

function BattleWaitRoundPlayAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
end

function BattleWaitRoundPlayAction:AddWaitEnergyListener()
  self.IsAddWaitEnergyListener = true
end

function BattleWaitRoundPlayAction:RemoveWaitEnergyListener()
  self.IsAddWaitEnergyListener = false
end

function BattleWaitRoundPlayAction:OnWaitEnergyComplete()
  self:RemoveWaitEnergyListener()
  self:StatusCheck()
end

function BattleWaitRoundPlayAction:AddWaitDeathListener()
  self.IsAddWaitDeathListener = true
end

function BattleWaitRoundPlayAction:RemoveWaitDeathListener()
  self.IsAddWaitDeathListener = false
end

function BattleWaitRoundPlayAction:OnWaitDeathComplete()
  self:RemoveWaitDeathListener()
  self:StatusCheck()
end

function BattleWaitRoundPlayAction:AddWaitEvolutionListener()
  self.IsAddWaitEvolutionListener = true
end

function BattleWaitRoundPlayAction:RemoveWaitEvolutionListener()
  self.IsAddWaitEvolutionListener = false
end

function BattleWaitRoundPlayAction:OnWaitEvolutionComplete()
  self:RemoveWaitEvolutionListener()
  self:StatusCheck()
end

function BattleWaitRoundPlayAction:StatusCheck()
  if BattleUtils.IsWaitingForEnergy() then
    Log.Debug("BattleWaitRoundPlayAction: energy not finish")
    self:AddWaitEnergyListener()
    return
  end
  if BattleUtils.IsWaitingForDeath() then
    Log.Debug("BattleWaitRoundPlayAction: death not finish")
    self:AddWaitDeathListener()
    return
  end
  if BattleUtils.IsWaitingForEvolution() then
    Log.Debug("BattleWaitRoundPlayAction: evolution not finish")
    self:AddWaitEvolutionListener()
    return
  end
  self:Finish()
end

function BattleWaitRoundPlayAction:OnFinish()
  if BattleManager.isInBattle and BattleUtils.IsWaitingForDeath() then
    Log.Error("zgx \232\191\152\230\156\137\230\173\187\228\186\161\232\161\168\230\188\148\230\178\161\230\156\137\231\187\147\230\157\159\239\188\140\228\189\134\229\183\178\231\187\143\232\182\133\230\151\182")
    _G.BattleManager.battleRuntimeData.petDeathAnimationPendingCnt = 0
  end
end

function BattleWaitRoundPlayAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PROCESS_ENERGY_TRACK_END then
    if self.IsAddWaitEnergyListener then
      self:OnWaitEnergyComplete()
    end
    return true
  elseif eventName == BattleEvent.BATTLE_PET_DEATH_PENDING_ANIMATION_FINISH then
    if self.IsAddWaitDeathListener then
      self:OnWaitDeathComplete()
    end
    return true
  elseif eventName == BattleEvent.BATTLE_PROCESS_EVOLUTION_END then
    if self.IsAddWaitEvolutionListener then
      self:OnWaitEvolutionComplete()
    end
    return true
  end
end

return BattleWaitRoundPlayAction
