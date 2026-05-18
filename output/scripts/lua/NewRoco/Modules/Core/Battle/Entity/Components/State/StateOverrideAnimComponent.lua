local PopupData = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupData")
local PopupAttributeInfo = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupAttributeInfo")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = BattleComponent
local StateOverrideAnimComponent = BattleComponent:Extend("StateOverrideAnimComponent")

function StateOverrideAnimComponent:Ctor(owner)
  Base.Ctor(self)
  self.owner = owner
  self:Clear()
  self:SetEnable(false)
  self.battleManager = _G.BattleManager
end

function StateOverrideAnimComponent:Init()
end

function StateOverrideAnimComponent:TriggerAll()
  if self.owner.card.petState:GetDrill() then
    self:PlayDrill()
  end
  if self.owner.card.petState:GetStatic() then
    self:PlayStatic()
  end
  if self.owner.card.petState:GetSleep() then
    self.owner:PlaySleeping()
  end
  if self.owner.card.petState:GetBackStab() then
    self.owner:TurnToBack()
  end
  if self.owner.card.petState:GetStun() then
    self:PlayStun()
  end
  if self.owner.card.petState:GetGhost() then
    self.owner:SetGhost(true)
  end
  if self.owner.card.petState:GetLeaderStun() then
    self:PlayLeaderStun()
  end
end

function StateOverrideAnimComponent:Deactivate()
end

function StateOverrideAnimComponent:OnTick(deltaTime)
end

function StateOverrideAnimComponent:Clear()
end

function StateOverrideAnimComponent:PlayDrill()
  if self.owner and self.owner.model then
    self.owner.model:PlayAnimByName(BattleConst.PetStateOverrideAnimName.DrillLoop, 1, 0, 0, 0, -1)
  else
    Log.Error("StateOverrideAnimComponent:PlayDrill missing player", self.owner)
  end
end

function StateOverrideAnimComponent:PlayStatic()
  self.owner:PlayAnimByName(BattleConst.PetStateOverrideAnimName.StaticLoop, 1, 0, 0, 0, -1)
end

function StateOverrideAnimComponent:PlayStun()
  self.owner:PlayStun()
end

function StateOverrideAnimComponent:PlayLeaderStun()
  Log.Warning("PlayBattleLeaderStun")
  if self.owner and self.owner.model then
    self.owner:RestartLeaderStun()
  else
    Log.Error("StateOverrideAnimComponent:PlayLeaderStun missing player", self.owner)
  end
end

return StateOverrideAnimComponent
