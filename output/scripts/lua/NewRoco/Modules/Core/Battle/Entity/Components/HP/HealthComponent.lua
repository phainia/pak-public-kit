local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local Base = BattleComponent
local HealthComponent = BattleComponent:Extend("HealthComponent")

function HealthComponent:Ctor(owner)
  Base.Ctor(self)
  self.name = "HealthComponent"
  self.owner = owner
  self.hp = 0
  self.max_hp = 0
  self.shield = 0
  self.max_shield = 0
  self.CardEntity = nil
  self.OldHp = 0
end

function HealthComponent:InitByCard(Card)
  Base.InitByCard(self)
  self.CardEntity = Card
  self.hp = Card.hp
  self.PetName = Card.name
  self.shield = Card.shield
  self.OldHp = Card.hp
  self:InitAttr(Card)
end

function HealthComponent:InitAttr(Card)
  self.max_hp = Card.max_hp
  self.max_shield = Card.max_shield
end

function HealthComponent:UpdateByCard(Card)
  self:InitByCard(Card)
end

function HealthComponent:GetHp()
  return self.hp
end

function HealthComponent:GetMaxHp()
  return self.max_hp
end

function HealthComponent:GetShield()
  return self.shield
end

function HealthComponent:GetMaxShield()
  return self.max_shield
end

function HealthComponent:SetValue(newHp)
  local newValue = newHp
  if newValue < 0 then
    newValue = 0
  end
  if newValue > self:GetMaxHp() then
    newValue = self:GetMaxHp()
  end
  self.CardEntity.hp = newValue
  self.hp = newValue
end

function HealthComponent:SetShieldValue(newShield)
  local newValue = newShield
  if newValue < 0 then
    newValue = 0
  end
  if newValue > self:GetMaxShield() then
    newValue = self:GetMaxShield()
  end
  self.CardEntity.shield = newValue
  self.shield = newValue
end

function HealthComponent:TookDamage(damage, serverHpChange)
  local realDamage = damage > self.hp and self.hp or damage
  self:SetValue(self.hp + serverHpChange)
  return realDamage
end

function HealthComponent:TookShieldDamage(damage, serverShieldChange)
  local realDamage = damage > self.shield and self.shield or damage
  self:SetShieldValue(self.shield + serverShieldChange)
  return realDamage
end

function HealthComponent:GotHealing(healing)
  self:SetValue(self.hp + healing)
end

function HealthComponent:CatchPet()
  self.CardEntity.hp = 0
end

function HealthComponent:SetOldHp(_OldHp)
  self.OldHp = _OldHp
end

function HealthComponent:GetOldHp()
  return self.OldHp
end

return HealthComponent
