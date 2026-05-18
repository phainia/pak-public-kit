local Class = _G.MakeSimpleClass
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local AuraEffectObject = Class("AuraEffectObject")
AuraEffectObject:SetMemberCount(8)

function AuraEffectObject:Ctor(Owner, Index, Effect)
  self.Owner = Owner
  self.Index = Index
  self.Type = Effect.aura_effect_type
  self.RawParams = Effect.params
  self.AudioID = 0
  self.AudioSessionID = 0
end

function AuraEffectObject:CheckNeedView()
  return false
end

function AuraEffectObject:OnViewReady(View)
end

function AuraEffectObject:OnBeginOverlapPlayer(player)
end

function AuraEffectObject:OnEndOverlapPlayer(player)
end

function AuraEffectObject:Destroy()
end

function AuraEffectObject:OnRemove(Killer, RemoveInfo)
end

function AuraEffectObject:OnRemoveOther(Victim, RemoveInfo)
end

function AuraEffectObject:GetBindNPC()
  return self.Owner:GetBindNPC()
end

function AuraEffectObject:GetTag()
  local Manager = self.Owner.Owner.FieldTagManager
  if not Manager then
    return nil
  end
  Log.Debug("GetTag With ID", self.Owner.Info.id)
  return Manager:Consume(self.Owner.Info)
end

function AuraEffectObject:GetEnvSys()
  local EnvSystem = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCachedMFEnvSystem)
  return EnvSystem
end

function AuraEffectObject:MakeEnvBound(ElementType, ReactionResult)
  local Bound = UE.FMFEnvBoundBase()
  Bound.AuraID = self.Owner.ID
  Bound.Extent = self.Owner:GetRange()
  Bound.CenterPos = SceneUtils.ConvertAbsoluteToRelative(self.Owner:GetLocation())
  Bound.ExpireTime = self.Owner.Config.time_last / 30000.0
  if nil ~= ElementType then
    Bound.ElementType = ElementType
  end
  if nil ~= ReactionResult then
    Bound.ElementReactionResult = ReactionResult
  end
  local Tag = self:GetTag()
  if Tag and Tag.change_info then
    Bound:ParseTags(Tag.data_length, Tag.change_info)
  end
  return Bound
end

function AuraEffectObject:GetAudioTag()
  return string.format("Aura%d", self.Owner.Info.id)
end

function AuraEffectObject:StartAudio()
  if 0 == self.AudioID then
    return
  end
  if 0 ~= self.AudioSessionID then
    return
  end
  self.AudioSessionID = _G.NRCAudioManager:PlaySound3DAtLocation(self.AudioID, SceneUtils.ConvertAbsoluteToRelative(self.Owner:GetLocation()), nil, self:GetAudioTag(), false, true)
end

function AuraEffectObject:StopAudio()
  if 0 == self.AudioID then
    return
  end
  if 0 == self.AudioSessionID then
    return
  end
  _G.NRCAudioManager:ReleaseSession(self.AudioSessionID, true, self:GetAudioTag(), false)
  self.AudioSessionID = 0
end

return AuraEffectObject
