require("UnLuaEx")
local UMG_EnergyBar_C = NRCUmgClass:Extend("")

function UMG_EnergyBar_C:Setup()
  local ChildrenCount = self.Container:GetChildrenCount()
  self.Children = {}
  if self.Direction then
    for i = ChildrenCount - 1, 0, -1 do
      table.insert(self.Children, self.Container:GetChildAt(i))
    end
  else
    for i = 0, ChildrenCount - 1 do
      table.insert(self.Children, self.Container:GetChildAt(i))
    end
  end
  self.VisibleCount = 0
end

function UMG_EnergyBar_C:Destruct()
  table.clear(self.Children)
  self.Children = nil
  NRCUmgClass.Destruct(self)
end

function UMG_EnergyBar_C:SetSlots(Count)
  for i, Slot in ipairs(self.Children) do
    Slot:Toggle(i <= Count, false, true)
  end
  self.VisibleCount = Count
end

function UMG_EnergyBar_C:SetEnergy(energy)
  if nil == energy then
    return
  end
  if self.VisibleCount == energy then
    if energy == #self.Children then
      self:PlayBlink()
    end
    return
  end
  for i, Slot in ipairs(self.Children) do
    Slot:Toggle(i <= energy, true, false)
  end
  self.VisibleCount = energy
end

function UMG_EnergyBar_C:PlayBlink()
  for _, Slot in ipairs(self.Children) do
    if Slot then
      Slot:PlayBlink()
    end
  end
end

return UMG_EnergyBar_C
