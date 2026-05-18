local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetRestrainedRelation = Base:Extend("LuaActionGetRestrainedRelation")

function LuaActionGetRestrainedRelation:OnStart(owner)
  local Target = self.Target:GetValue(owner)
  if nil == Target then
    self.OutRestrainedRelation:SetValue(owner, 0)
    self:Finish(true)
    return
  end
  local SelfPetBaseId = owner.petbaseId
  if not SelfPetBaseId or 0 == SelfPetBaseId then
    self.OutRestrainedRelation:SetValue(owner, 0)
    self:Finish(true)
    return
  end
  local TargetPetBaseId = Target:GetPetbaseId()
  if 0 == TargetPetBaseId or SelfPetBaseId == TargetPetBaseId then
    self.OutRestrainedRelation:SetValue(owner, 0)
    self:Finish(true)
    return
  end
  local SelfPetBaseConf = _G.DataConfigManager:GetPetbaseConf(SelfPetBaseId)
  local TargetPetBaseConf = _G.DataConfigManager:GetPetbaseConf(TargetPetBaseId)
  if not SelfPetBaseConf or not TargetPetBaseConf then
    self.OutRestrainedRelation:SetValue(owner, 0)
    self:Finish(true)
    return
  end
  local SelfPetTypes = {}
  local TargetPetTypes = {}
  if SelfPetBaseConf.unit_type then
    for _, typeId in ipairs(SelfPetBaseConf.unit_type) do
      if typeId > 0 then
        table.insert(SelfPetTypes, typeId)
      end
    end
  end
  if TargetPetBaseConf.unit_type then
    for _, typeId in ipairs(TargetPetBaseConf.unit_type) do
      if typeId > 0 then
        table.insert(TargetPetTypes, typeId)
      end
    end
  end
  if 0 == #SelfPetTypes or 0 == #TargetPetTypes then
    self.OutRestrainedRelation:SetValue(owner, 0)
    self:Finish(true)
    return
  end
  local SelfRestrainTarget = 0
  for _, selfTypeId in ipairs(SelfPetTypes) do
    for _, targetTypeId in ipairs(TargetPetTypes) do
      local key = "type_restraint" .. targetTypeId
      local selfTypeDicInfo = _G.DataConfigManager:GetTypeDictionary(selfTypeId)
      if selfTypeDicInfo and selfTypeDicInfo[key] and selfTypeDicInfo[key] > 0 then
        SelfRestrainTarget = SelfRestrainTarget + selfTypeDicInfo[key]
      end
    end
  end
  local TargetRestrainSelf = 0
  for _, targetTypeId in ipairs(TargetPetTypes) do
    for _, selfTypeId in ipairs(SelfPetTypes) do
      local key = "type_restraint" .. selfTypeId
      local targetTypeDicInfo = _G.DataConfigManager:GetTypeDictionary(targetTypeId)
      if targetTypeDicInfo and targetTypeDicInfo[key] and targetTypeDicInfo[key] > 0 then
        TargetRestrainSelf = TargetRestrainSelf + targetTypeDicInfo[key]
      end
    end
  end
  local TotalResult = SelfRestrainTarget - TargetRestrainSelf
  local restraintRelation = 0
  if TotalResult > 0 then
    restraintRelation = 1
  elseif TotalResult < 0 then
    restraintRelation = 2
  end
  self.OutRestrainedRelation:SetValue(owner, restraintRelation)
  self:Finish(true)
end

return LuaActionGetRestrainedRelation
