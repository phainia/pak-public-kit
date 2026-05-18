local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local BattleFsmData = NRCClass()
BattleFsmData.BattleFsmEnum = {
  BattleFsm = "BattleFsm",
  RoundSelectFsm = "RoundSelectFsm"
}

function BattleFsmData:Ctor()
  self:InitializeFsmData()
  self.FsmManager = _G.FsmManager
  self.FsmManager:AddEventListener(self, FsmEnum.ManagerEvents.Changed, self.UpdateList)
  self:SetInitializeData()
  self:RegisterFsmEvent()
end

function BattleFsmData:InitializeFsmData()
  self.FsmStateListInfo = {}
  self.CurrentStateName = nil
  self.IsOpenBattleMain = false
  self.ActivateState = {}
end

function BattleFsmData:ClearInfo()
  self:RegisterFsmEvent()
end

function BattleFsmData:SetInitializeData()
  if self.IsOpenBattleMain then
    return
  end
  local RunningFsms = self.FsmManager.runningFsms
  for i = 1, #RunningFsms do
    if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm then
      self.IsOpenBattleMain = true
      local States = RunningFsms[i].states
      for j = 1, #States do
        local FsmState = States[j]
        self.ActivateState[FsmState:GetName()] = {}
        for k, FsmTransition in pairs(FsmState.transitions) do
          self.ActivateState[FsmState:GetName()][FsmTransition.next] = {IsActivate = false}
        end
      end
    end
  end
end

function BattleFsmData:RegisterFsmEvent()
  local RunningFsms = self.FsmManager.runningFsms
  for i = 1, #RunningFsms do
    if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm or RunningFsms[i]:GetName() == self.BattleFsmEnum.RoundSelectFsm then
      RunningFsms[i]:RegisterEvent(FsmEnum.Events.EnterState, self, self.OnEnterState)
      RunningFsms[i]:RegisterEvent(FsmEnum.Events.PostEnterAction, self, self.OnEnterAction)
    end
  end
end

function BattleFsmData:UpdateList(Fsm, StateName)
  if "Play" == StateName then
    self:RemoveFsmEvent()
    self:RegisterFsmEvent()
    self:SetInitializeData()
  end
end

function BattleFsmData:CleanFsmManager()
  if self.FsmManager then
    self.FsmManager:RemoveEventListener(self, FsmEnum.ManagerEvents.Changed, self.UpdateList)
    self:RemoveFsmEvent()
    self.FsmManager = nil
  end
end

function BattleFsmData:RemoveFsmEvent()
  if self.FsmManager then
    local RunningFsms = self.FsmManager.runningFsms
    for i = 1, #RunningFsms do
      if RunningFsms[i]:GetName() == self.BattleFsmEnum.BattleFsm or RunningFsms[i]:GetName() == self.BattleFsmEnum.RoundSelectFsm then
        RunningFsms[i]:RemoveEvent(FsmEnum.Events.EnterState, self, self.OnEnterState)
        RunningFsms[i]:RemoveEvent(FsmEnum.Events.PostEnterAction, self, self.OnEnterAction)
      end
    end
  end
end

function BattleFsmData:OnEnterState(Fsm, State)
  table.insert(self.FsmStateListInfo, {
    State = State,
    Action = {}
  })
  if Fsm:GetName() == self.BattleFsmEnum.BattleFsm then
    if not self.CurrentStateName then
      self.CurrentStateName = State:GetName()
    else
      self:SetActivatStateList(State)
      self.CurrentStateName = State:GetName()
    end
  end
  local IsHasFsm, FsmPane = self:GetFsmUIPanel()
  if IsHasFsm then
    FsmPane:ActivateStateChangeUpdate(self.ActivateState)
  end
end

function BattleFsmData:OnEnterAction(Fsm, FsmAction)
  if 0 == #self.FsmStateListInfo then
    if BattleManager.isInBattle then
      Log.Error("State\231\138\182\230\128\129\230\156\186\230\151\160\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\230\149\176\230\141\174 ")
    end
    return
  end
  if FsmAction.state == self.FsmStateListInfo[#self.FsmStateListInfo].State then
    table.insert(self.FsmStateListInfo[#self.FsmStateListInfo].Action, FsmAction)
  end
  if #self.FsmStateListInfo > 0 then
    local IsHasFsm, FsmPane = self:GetFsmUIPanel()
    if IsHasFsm then
      FsmPane:FsmStateListInfoChangeUpdate(self.FsmStateListInfo)
    end
  end
end

function BattleFsmData:SetActivatStateList(_State)
  if not self.CurrentStateName then
    Log.Error("\229\189\147\229\137\141\230\178\161\230\156\137\232\191\155\232\161\140\231\154\132State,\232\175\183\230\159\165\231\156\139\230\149\176\230\141\174\230\152\175\229\144\166\230\156\137\233\151\174\233\162\152")
    return
  end
  local State = self.ActivateState[self.CurrentStateName]
  if State and State[_State:GetName()] then
    State[_State:GetName()].IsActivate = true
  end
end

function BattleFsmData:GetFsmStateListInfo()
  return self.FsmStateListInfo
end

function BattleFsmData:GetActivateState()
  return self.ActivateState
end

function BattleFsmData:GetFsmUIPanel()
  local IsHasFsm, FsmPane = _G.NRCModeManager:DoCmd(BattleUIModuleCmd.IsHasFsmUIPanel)
  return IsHasFsm, FsmPane
end

return BattleFsmData
