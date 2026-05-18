local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = AuraEffectObject
local AuraEffectReduceHP = Base:Extend("AuraEffectReduceHP")

function AuraEffectReduceHP:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
end

function AuraEffectReduceHP:CheckNeedView()
  return self.Owner.Config.aura_type == Enum.AuraType.AT_HARM
end

function AuraEffectReduceHP:PlayHurtEffect(Player)
  local Dir = Player:GetActorLocation()
  Dir.X = Dir.X - self.Owner.Info.pos.x
  Dir.Y = Dir.Y - self.Owner.Info.pos.y
  Dir.Z = Dir.Z - self.Owner.Info.pos.z
  Dir:Normalize()
  local Damage = self.RawParams[1] or 0
  if Damage >= self:GetPlayerHP(Player) then
    Player:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, Damage, Dir, true)
  else
    Player:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, Dir, false)
  end
end

function AuraEffectReduceHP:OnBeginOverlapPlayer(player)
  self:PlayHurtEffect(player)
end

function AuraEffectReduceHP:GetPlayerHP(Player)
  return Player.serverData.attrs.hp or 0
end

function AuraEffectReduceHP:OnEndOverlapPlayer(player)
end

return AuraEffectReduceHP
