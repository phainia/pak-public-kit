local Base = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local AuraEffectMagicFall = Base:Extend("AuraEffectMagicFall")

function AuraEffectMagicFall:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
end

function AuraEffectMagicFall:OnViewReady(View)
  Base.OnViewReady(self, View)
  local Npc = self:GetBindNPC()
  if Npc then
    Npc:SendEvent(NPCModuleEvent.BE_HIT_BY_STAR, self.RawParams[1])
  else
    Log.WarningFormat("[AuraEffectMagicFall] Invalid bind npc OnViewReady, id=%d", self.Owner.Info.create_actor_id)
  end
end

function AuraEffectMagicFall:Destroy()
  Base.Destroy(self)
  local Npc = self:GetBindNPC()
  if Npc then
    Npc:StopAnim("Hit3", 0.5)
  end
end

return AuraEffectMagicFall
