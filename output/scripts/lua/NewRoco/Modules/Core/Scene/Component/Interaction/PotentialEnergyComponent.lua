local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local PotentialEnergyComponent = Base:Extend("PotentialEnergyComponent")

function PotentialEnergyComponent:Attach(owner)
  Base.Attach(self, owner)
  local ServerData = self.owner.serverData
  local PotentialEnergyInfo = ServerData and ServerData.potential_energy_info
  local PropertyTypeInfo = ServerData and ServerData.property_type_info
  self.potentialEnergy = PotentialEnergyInfo
  self.propertyType = PropertyTypeInfo
  SceneUtils.RegisterNPCVisibilityNotify(self, true)
end

function PotentialEnergyComponent:OnPotentialEnergyChanged(Old, New)
  local View = self:GetOwnerView()
  if not (View and Old) or not New then
    return
  end
  if Old.enabled and New.enabled then
    View:UpdatePotentialEnergy(New, true)
  elseif Old.enabled and not New.enabled then
    View:HidePotentialEnergy()
  else
    if not Old.enabled and New.enabled then
      View:ShowPotentialEnergy(New)
    else
    end
  end
  self.potentialEnergy = New
  self.owner.serverData.potential_energy_info = New
end

function PotentialEnergyComponent:OnPropertyTypeChange(Old, New)
  local View = self:GetOwnerView()
  if not View then
    return
  end
  local HasOld = Old and Old.property_types and #Old.property_types > 0
  local HasNew = New and New.property_types and #New.property_types > 0
  if HasOld and HasNew then
    if self:CheckPropertyTypesDiff(Old.property_types, New.property_types) then
      View:UpdatePropertyType(New, true)
    end
  elseif HasOld and not HasNew then
    View:HidePropertyType()
  else
    if not HasOld and HasNew then
      View:ShowPropertyType(New)
    else
    end
  end
  self.propertyType = New
  self.owner.serverData.property_type_info = New
end

function PotentialEnergyComponent:InitialPotentialEnergy(action)
  local View = self:GetOwnerView()
  if not View then
    return
  end
  if action.enabled then
    View:UpdatePotentialEnergy(action, false)
  end
end

function PotentialEnergyComponent:InitialPropertyType(action)
  local View = self:GetOwnerView()
  if not View then
    return
  end
  if action and action.property_types then
    View:UpdatePropertyType(action, false)
  end
end

function PotentialEnergyComponent:OnVisible()
  if self.potentialEnergy then
    self:InitialPotentialEnergy(self.potentialEnergy)
  end
  if self.propertyType then
    self:InitialPropertyType(self.propertyType)
  end
end

function PotentialEnergyComponent:OnInvisible()
end

function PotentialEnergyComponent:DeAttach()
  Base.DeAttach(self)
end

function PotentialEnergyComponent:Destroy()
  Base.Destroy(self)
end

function PotentialEnergyComponent:UpdateData(ServerData, isReconnect)
  if not isReconnect then
    return
  end
  self:OnPotentialEnergyChanged(self.potentialEnergy or {}, ServerData.potential_energy_info or {})
  self:OnPropertyTypeChange(self.propertyType or {}, ServerData.property_type_info or {})
end

function PotentialEnergyComponent:CheckPropertyTypesDiff(PropertyTypes, OtherPropertyTypes)
  if #PropertyTypes ~= #OtherPropertyTypes then
    return true
  end
  for i = 1, #PropertyTypes do
    if PropertyTypes[i] ~= OtherPropertyTypes[i] then
      return true
    end
  end
  return false
end

return PotentialEnergyComponent
