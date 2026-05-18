local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionPotentialEnergy = Base:Extend("PetActionPotentialEnergy")

function PetActionPotentialEnergy:SetBeforeActionSettings(PetView)
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
  if #DamageTypes > 1 then
    PetDamageType = DamageTypes[2]
  else
    PetDamageType = DamageTypes[1]
  end
  local Stone = self:GetOwnerNPCView()
  if Stone then
    Stone:SetBeamColor(PetDamageType)
  end
end

function PetActionPotentialEnergy:OnExecute()
  local Stone = self:GetOwnerNPCView()
  if not Stone then
    self:Finish(false)
    return
  end
  Stone.Runner = self.Runner
  Stone.OpenFinishDelegate:Add(self, self.OnStoneOpen)
  self:Submit()
end

function PetActionPotentialEnergy:OnSubmit(rsp)
  Log.Debug("PetActionPotentialEnergy:OnSubmit")
  self:ConsumeOwnerActorTag()
  if 0 ~= rsp.ret_info.ret_code then
    self:Finish(false)
  end
end

function PetActionPotentialEnergy:OnStoneOpen(Success)
  self:Finish(Success)
end

function PetActionPotentialEnergy:OnStop(reason)
  local Stone = self:GetOwnerNPCView()
  if not Stone then
    self:Finish(false)
    return
  end
  Stone.RocoSkill:StopCurrentSkill()
end

function PetActionPotentialEnergy:OnFinish()
  Log.Debug("PetActionPotentialEnergy:OnFinish")
  local Stone = self:GetOwnerNPCView()
  if not Stone then
    return
  end
  if Stone.OpenFinishDelegate then
    Stone.OpenFinishDelegate:Remove(self, self.OnStoneOpen)
  end
end

return PetActionPotentialEnergy
