require("UnLuaEx")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattlePerformEvent = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePerformEvent")
local UMG_Battle_EnergyBar_C = NRCUmgClass:Extend("")

function UMG_Battle_EnergyBar_C:Construct()
  self.battleManager = _G.BattleManager
  local team = self.battleManager.battlePawnManager:GetTeam(self.Direction and BattleEnum.Team.ENUM_TEAM or BattleEnum.Team.ENUM_ENEMY)
  local player = team and team.player
  if player then
    self:InitView(player)
  end
  self:AddListeners()
end

function UMG_Battle_EnergyBar_C:Destruct()
  self:RemoveListeners()
  self.player = nil
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_EnergyBar_C:AddListeners()
end

function UMG_Battle_EnergyBar_C:RemoveListeners()
end

function UMG_Battle_EnergyBar_C:InitView(player)
end

function UMG_Battle_EnergyBar_C:Hide()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_EnergyBar_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_Battle_EnergyBar_C:OnBattleEvent(eventName, ...)
end

function UMG_Battle_EnergyBar_C:OnUpdateEnergy()
end

return UMG_Battle_EnergyBar_C
