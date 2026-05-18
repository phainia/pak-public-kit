local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local Base = AuraEffectObject
local AuraEffectPoison = Base:Extend("AuraEffectPoison")

function AuraEffectPoison:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
  self.AudioID = 1266
end

function AuraEffectPoison:OnViewReady(View)
  Base.OnViewReady(self, View)
  Log.Error("\230\148\190\230\175\146", self.Owner.ID)
  local EnvSys = self:GetEnvSys()
  local Bound = EnvSys and self:MakeEnvBound(UE.EEnvElementType.POISON, nil) or nil
  if EnvSys and Bound then
    EnvSys:AddBound(Bound)
  end
  self:StartAudio()
end

function AuraEffectPoison:Destroy()
  local EnvSys = self:GetEnvSys()
  if EnvSys then
    EnvSys:RemoveBound(self.Owner.ID)
  end
  self:StopAudio()
  Base.Destroy(self)
end

function AuraEffectPoison:OnRemove(Killer, RemoveInfo)
  local EnvSys = self:GetEnvSys()
  if EnvSys then
    EnvSys:RemoveBound(self.Owner.ID)
  end
end

return AuraEffectPoison
