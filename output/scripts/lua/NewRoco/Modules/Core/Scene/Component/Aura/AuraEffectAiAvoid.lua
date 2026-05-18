local Base = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local AuraEffectAiAvoid = Base:Extend("AuraEffectAiAvoid")

function AuraEffectAiAvoid:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
end

function AuraEffectAiAvoid:CheckNeedView()
  return true
end

function AuraEffectAiAvoid:OnViewReady(View)
  local pos = UE4.FVector(self.Owner.Info.pos.x, self.Owner.Info.pos.y, self.Owner.Info.pos.z)
  self.pos = pos
  local rad = self.Owner.Config.aura_distance[1]
  self.rad = rad
  NRCModuleManager:DoCmd(SceneModuleCmd.RegisterBlockingArea, self.Owner.Info.id, pos, rad)
end

function AuraEffectAiAvoid:OnBeginOverlapPlayer(player)
end

function AuraEffectAiAvoid:OnEndOverlapPlayer(player)
end

function AuraEffectAiAvoid:Destroy()
  NRCModuleManager:DoCmd(SceneModuleCmd.UnregisterBlockingArea, self.Owner.Info.id)
  self.pos = nil
  self.rad = nil
end

return AuraEffectAiAvoid
