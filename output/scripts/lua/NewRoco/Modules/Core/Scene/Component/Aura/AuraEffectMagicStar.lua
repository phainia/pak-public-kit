local Base = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local AuraEffectMagicStar = Base:Extend("AuraEffectMagicStar")
local bAttachToWidget = false

function AuraEffectMagicStar:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
  self.enable = false
  self.isInBattle = false
end

function AuraEffectMagicStar:OnViewReady(View)
  Base.OnViewReady(self, View)
  self:AttachStar()
  local Npc = self:GetBindNPC()
  if Npc then
    Npc:AddEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNpcDestroy)
  else
    Log.WarningFormat("[AuraEffectMagicStar] Invalid bind npc OnViewReady, id=%d", self.Owner.Info.create_actor_id)
  end
end

function AuraEffectMagicStar:CalcStarMarkLocation()
  local Npc = self:GetBindNPC()
  local attachComponent
  if bAttachToWidget then
    attachComponent = Npc.viewObj:GetComponentByClass(UE4.URocoWidgetComponent)
  else
    attachComponent = Npc.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  end
  local headSocket = BattleUtils.GetAttachPointNameByType(UE4.EFXAttachPointType.Head)
  local posHead = attachComponent:GetSocketLocation(headSocket)
  local bias = UE4.FVector(0, 0, 50)
  return posHead + bias
end

function AuraEffectMagicStar:OnTick(deltaTime)
end

function AuraEffectMagicStar:Destroy()
  self:RemoveStar()
  Base.Destroy(self)
end

function AuraEffectMagicStar:OnNpcDestroy(npc)
  npc:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNpcDestroy)
  self:RemoveStar()
end

function AuraEffectMagicStar:AttachStar()
  if self.enable then
    return
  end
  self.enable = true
end

function AuraEffectMagicStar:RemoveStar()
  if not self.enable then
    return
  end
  self.enable = false
end

return AuraEffectMagicStar
