local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleComponent
local BattlePetHud = BattleComponent:Extend("BattlePetHud")

function BattlePetHud:Ctor(owner)
  Base.Ctor(self)
  self.name = "PetHudComponent"
  self.owner = owner
end

function BattlePetHud:InitByCard(Card)
end

return BattlePetHud
