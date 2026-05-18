local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local Base = AuraEffectObject
local AuraEffectElectric = Base:Extend("AuraEffectElectric")

function AuraEffectElectric:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
  self.AudioID = 1265
end

function AuraEffectElectric:OnViewReady(View)
  Base.OnViewReady(self, View)
  Log.Error("\230\148\190\231\148\181", self.Owner.ID)
  local EnvSys = self:GetEnvSys()
  local Bound = EnvSys and self:MakeEnvBound(UE.EEnvElementType.Electric, nil) or nil
  if EnvSys and Bound then
    EnvSys:AddBound(Bound)
  end
  self:StartAudio()
end

function AuraEffectElectric:Destroy()
  local EnvSys = self:GetEnvSys()
  if EnvSys then
    EnvSys:RemoveBound(self.Owner.ID)
  end
  self:StopAudio()
  Base.Destroy(self)
end

function AuraEffectElectric:OnRemove(Killer, RemoveInfo)
  local EnvSys = self:GetEnvSys()
  if EnvSys then
    EnvSys:RemoveBound(self.Owner.ID)
  end
end

return AuraEffectElectric
