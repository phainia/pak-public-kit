local Base = require("NewRoco.Modules.System.BattleUI.Res.BattleUIItem.UMG_Battle_Round_Start_C")
local UMG_Battle_WaitingTeammatesCountdown_C = Base:Extend("UMG_Battle_WaitingTeammatesCountdown_C")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")

function UMG_Battle_WaitingTeammatesCountdown_C:OnActive(displayType, arg1, arg2)
  local contextData = {
    displayType = displayType,
    arg1 = arg1,
    arg2 = arg2,
    onOpenCallback = function()
    end,
    onCloseCallback = function()
    end
  }
  Base.OnActive(self, contextData)
  local tips = LuaText.wait_together_teammates
  self.Tips:SetText(tips)
  self.startCountDown = false
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if _G.BattleManager:IsInBattle() then
    _G.NRCEventCenter:RegisterEvent("UMG_Battle_WaitingTeammatesCountdown_C", self, BattleEvent.OnCloseBattleMainWindow, self.OnBattleOver)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if localPlayer then
      localPlayer.inputComponent:SetInputEnable(self, false, "WaitingTeammatesCountdown")
    end
    Log.Debug("UMG_Battle_WaitingTeammatesCountdown_C Active, Wait BattleOver")
  else
    self:OnBattleOver()
  end
  if localPlayer then
    localPlayer:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  end
end

function UMG_Battle_WaitingTeammatesCountdown_C:OnDeactive()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
    localPlayer.inputComponent:SetInputEnable(self, true, "WaitingTeammatesCountdown")
  end
  self:RemovePcInputBlock()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.OnCloseBattleMainWindow, self.OnBattleOver)
end

function UMG_Battle_WaitingTeammatesCountdown_C:Destruct()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.OnCloseBattleMainWindow, self.OnBattleOver)
  Base.Destruct(self)
end

function UMG_Battle_WaitingTeammatesCountdown_C:OnLogicStatusUpdated(owner, info)
  if owner and owner.LogicStatusComponent then
    local hasStatus, variant, extraData = owner.LogicStatusComponent:GetStatus(ProtoEnum.SpaceActorLogicStatus.SALS_WAIT_FOR_OTHERS)
    if not hasStatus then
      owner:OnWaitForOtherStatus(false)
    end
  end
end

function UMG_Battle_WaitingTeammatesCountdown_C:AddPcInputBlock()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_Block_2")
  if UE.UNRCEnhancedInputHelper.HasInputMappingContext(imc) then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
end

function UMG_Battle_WaitingTeammatesCountdown_C:RemovePcInputBlock()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_Block_2")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_Battle_WaitingTeammatesCountdown_C:Tick(Geometry, DeltaTime)
  if self.startCountDown then
    self:BurnTime(DeltaTime)
  end
end

function UMG_Battle_WaitingTeammatesCountdown_C:OnBattleOver()
  Log.DebugFormat("UMG_Battle_WaitingTeammatesCountdown_C:OnBattleOver")
  self:AddPcInputBlock()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer.inputComponent:SetInputEnable(self, true, "WaitingTeammatesCountdown")
  end
  self:PlayAnimation(self.fade_in)
  self.startCountDown = true
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.OnCloseBattleMainWindow, self.OnBattleOver)
end

return UMG_Battle_WaitingTeammatesCountdown_C
