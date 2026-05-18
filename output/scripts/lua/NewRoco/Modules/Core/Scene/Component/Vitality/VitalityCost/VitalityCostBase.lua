local Class = _G.MakeSimpleClass
local VitalityCostBase = Class("VitalityCostBase")

function VitalityCostBase:Ctor(vitalityComp)
  self.vitalityComp = vitalityComp
  self._id = 0
  self._idName = "none"
end

function VitalityCostBase:Destroy()
end

function VitalityCostBase:OnUpdate(deltaTime)
end

function VitalityCostBase:SetID(inID)
  self._id = inID
  return true
end

function VitalityCostBase:GetID()
  return self._id
end

function VitalityCostBase:CostByID(costType, deltaTime)
  return true
end

function VitalityCostBase:GetIDName()
  return self._idName
end

function VitalityCostBase:Pause(bPause)
  self.isRunning = not bPause
end

function VitalityCostBase:IsRunning()
  return self.isRunning
end

return VitalityCostBase
