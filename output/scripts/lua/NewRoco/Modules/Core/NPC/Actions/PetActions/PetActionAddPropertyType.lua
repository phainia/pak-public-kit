local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionAddPropertyType = Base:Extend("PetActionAddPropertyType")

function PetActionAddPropertyType:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionAddPropertyType:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionAddPropertyType:SetBeforeActionSettings(PetView)
  local Pet = PetView.sceneCharacter
  if not Pet then
    return nil
  end
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(Pet.ThrowSession.petData.base_conf_id)
  if not PetBaseConf then
    self:Finish(false)
    return nil
  end
  local DamageTypes = PetBaseConf.unit_type
  local PetDamageType
  PetDamageType = self:AddType(DamageTypes)
  local Stone = self:GetOwnerNPCView()
  if Stone and Stone.SetBeamColor then
    Stone:SetBeamColor(PetDamageType)
  end
end

function PetActionAddPropertyType:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  if 0 ~= rsp.ret_info.ret_code then
    self:Finish(false)
  end
end

function PetActionAddPropertyType:OnExecute()
  local Stone = self:GetOwnerNPCView()
  if not Stone or not Stone.OpenFinishDelegate then
    self:Finish(false)
    return
  end
  Stone.Runner = self.Runner
  Stone.OpenFinishDelegate:Add(self, self.OnStoneOpen)
  self:Submit()
end

function PetActionAddPropertyType:OnStoneOpen(Success)
  self:Finish(true)
end

function PetActionAddPropertyType:OnStop(reason)
  local Stone = self:GetOwnerNPCView()
  if not Stone then
    self:Finish(false)
    return
  end
  Stone.RocoSkill:StopCurrentSkill()
end

function PetActionAddPropertyType:AddType(DamageTypes)
  local PetDamageType
  local PetTypeNum = #DamageTypes
  for i = 1, PetTypeNum do
    PetDamageType = DamageTypes[i]
  end
  return PetDamageType
end

return PetActionAddPropertyType
