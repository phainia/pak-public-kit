local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = AuraEffectObject
local NPC_ID = 60283
local AuraEffectBurn = Base:Extend("AuraEffectBurn")

function AuraEffectBurn:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
  local Pos = self.Owner.Info.pos
  self.Position = UE4.FVector(Pos.x, Pos.y, Pos.z)
  self.Extent = self.Owner:GetRange(150)
  self.bDestroyed = false
  self.AudioID = 1267
end

function AuraEffectBurn:OnViewReady(View)
  Base.OnViewReady(self, View)
  if self.Owner.bRestored then
    self:SetFire()
    return
  end
  local BindNPC = self:GetBindNPC()
  local BindNPCView = BindNPC and BindNPC.viewObj
  if not BindNPCView then
    self:SetFire()
    return
  end
  if not BindNPCView.bPlayingReleaseSkill then
    self:SetFire()
    return
  end
  BindNPC:AddEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnPetSetFire)
end

function AuraEffectBurn:OnPetSetFire(Pet)
  Pet:RemoveEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnPetSetFire)
  self:SetFire()
end

function AuraEffectBurn:WaitValidLand(RemainCount)
  if self.bDestroyed then
    return
  end
  local Val = self:FindValidLand()
  if nil == Val then
    if RemainCount > 0 then
      _G.DelayManager:DelaySeconds(0.5, self.WaitValidLand, self, RemainCount - 1)
    else
      Log.Error("Can't find valid land at all")
    end
  elseif Val then
    self:SetFire()
  end
end

function AuraEffectBurn:FindValidLand()
  local EnvSystem = self:GetEnvSys()
  if EnvSystem then
    local Result = UE4.FHitResult()
    local RelativePos = SceneUtils.ConvertAbsoluteToRelative(self.Position)
    local Hit = EnvSystem:TryFindLandscape(RelativePos, self.Extent, Result)
    if not Hit then
      Log.Error("Can't find land", tostring(self.Position))
      return nil
    end
    local Mat = Result.PhysMaterial
    if not Mat then
      Log.Error("can't find physical material")
      return false
    end
    if Mat.SurfaceType ~= UE.EPhysicalSurface.SurfaceType1 then
      self.Owner:DisableByClient()
      return false
    end
    return true
  else
    Log.Error("Can't find an env system")
    return false
  end
end

function AuraEffectBurn:SetFire()
  local EnvSystem = self:GetEnvSys()
  if EnvSystem then
    Log.Debug("SetFire....")
    local Bound = self:MakeEnvBound(UE.EEnvElementType.FIRE, UE.EEnvReactionResult.Burn)
    Bound.BufferTime = 0.5
    EnvSystem:AddBound(Bound)
    self:StartAudio()
  end
  if not self.Owner.bRestored then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    self.Fire = NPCModule:CreateLocalNPC(NPC_ID, self.Owner.Info.pos)
    if self.Fire.viewObj then
      self:OnFireViewReady(self.Fire.viewObj)
    else
      self.Fire:AddEventListener(self, NPCModuleEvent.VIEW_LOADED, self.OnFireViewReady)
    end
    self.Owner:EnableByClient()
  end
end

function AuraEffectBurn:OnFireViewReady()
  if not self.Fire then
    return
  end
  self.Fire:RemoveEventListener(self, NPCModuleEvent.VIEW_LOADED, self.OnFireViewReady)
  self.Fire.viewObj:SetRange(self.Owner:GetRange(100))
  self.Fire.viewObj:SetFire()
end

function AuraEffectBurn:Destroy()
  self:StopAudio()
  self.bDestroyed = true
  local EnvSystem = self:GetEnvSys()
  if EnvSystem then
    EnvSystem:RemoveBound(self.Owner.ID)
  end
  if not self.Fire then
    return
  end
  self.Fire:Disappear(true)
  self.Fire = nil
  Base.Destroy(self)
end

function AuraEffectBurn:OnRemove(Killer, RemoveInfo)
  if not Killer:HasEffect(Enum.AuraEffect.AE_WATER) then
    self:Destroy()
    return
  end
  self.KillerAura = Killer
  local Caster = Killer:GetBindNPC()
  local CasterView = Caster and Caster.viewObj
  if CasterView and CasterView.bPlayingReleaseSkill then
    Caster:AddEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnRemoveBurn)
  else
    local WaterEffect = Killer:GetEffectObject(Enum.AuraEffect.AE_WATER)
    if WaterEffect then
      WaterEffect:SetWater()
    end
    local EnvSystem = self:GetEnvSys()
    if EnvSystem then
      EnvSystem:RemoveBound(self.Owner.ID)
    end
  end
end

function AuraEffectBurn:OnRemoveBurn(Caster)
  Caster:RemoveEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnRemoveBurn)
  local KillerView = Caster.viewObj
  local FireNPC = self.Owner:GetBindNPC()
  local FireView = FireNPC and FireNPC.viewObj
  if not KillerView then
    self:Destroy()
    return
  end
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Tempreture_Extinguish", KillerView.RocoSkill, PriorityEnum.Active_Aura_Burn)
  if not Skill then
    self:Destroy()
    return
  end
  Skill:SetCaster(KillerView)
  if FireView then
    Skill:SetTargets({FireView})
    Skill:SetAdditions("Victim", FireView)
  end
  Skill:SetAdditions("Killer", KillerView)
  Skill:RegisterEventCallback("Head", self, self.SetHeadLookAt)
  Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillEnd)
  Skill:SetPassive(true)
  Skill:PlaySkill(self, self.OnSkillStart)
end

function AuraEffectBurn:OnSkillStart(Skill, Result)
  local WaterEffect = self.KillerAura:GetEffectObject(Enum.AuraEffect.AE_WATER)
  if WaterEffect then
    WaterEffect:SetWater()
  end
  self:Destroy()
  self.KillerAura = nil
end

function AuraEffectBurn:OnSkillEnd(Name, Skill)
end

function AuraEffectBurn:SetHeadLookAt(Name, Skill)
end

return AuraEffectBurn
