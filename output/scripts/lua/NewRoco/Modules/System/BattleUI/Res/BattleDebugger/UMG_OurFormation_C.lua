local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_OurFormation_C = Base:Extend("UMG_OurFormation_C")

function UMG_OurFormation_C:OnConstruct()
  self.debugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.ComboBoxStringPet:ClearOptions()
  self.ComboBoxStringPet.OnOpening:Add(self, self.FilterOptions)
end

function UMG_OurFormation_C:OnDestruct()
  self.ComboBoxStringPet.OnOpening:Remove(self, self.FilterOptions)
end

function UMG_OurFormation_C:FilterOptions()
  local filter = self.EditableTextBoxPet:GetText()
  for i, v in pairs(self.petNameLists) do
    if string.IsNilOrEmpty(filter) or v:find(string.lower(filter)) then
      if self.ComboBoxStringPet:FindOptionIndex(v) < 0 then
        self.ComboBoxStringPet:AddOption(v)
      end
    elseif self.ComboBoxStringPet:FindOptionIndex(v) >= 0 then
      self.ComboBoxStringPet:RemoveOption(v)
    end
  end
end

function UMG_OurFormation_C:OnItemUpdate(_data, datalist, index)
  self.debugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.index = index
  self.petNameLists = self.debugControl:GetAllPetList()
  self.NRCTextIdx:SetText("\229\174\160\231\137\169" .. self.index)
  if not _data then
    self.petNameLists = self.debugControl:GetAllMonsterList()
  end
  self:FilterOptions()
end

function UMG_OurFormation_C:GetSelectOption()
  return self.ComboBoxStringPet:GetSelectedOption()
end

function UMG_OurFormation_C:SetSelectOption(tempSelectPet)
  self.ComboBoxStringPet:SetSelectedOption(tempSelectPet)
end

return UMG_OurFormation_C
