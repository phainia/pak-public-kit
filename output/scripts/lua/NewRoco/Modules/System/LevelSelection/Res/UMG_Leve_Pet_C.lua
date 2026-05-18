local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_Pet_C = Base:Extend("UMG_Leve_Pet_C")

function UMG_Leve_Pet_C:OnConstruct()
end

function UMG_Leve_Pet_C:OnDestruct()
end

function UMG_Leve_Pet_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.isHaveData = self.data ~= nil and nil ~= self.data.pet_gid and 0 ~= self.data.pet_gid
  self.petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.pet_gid)
  if not self.petData then
    self.Switcher:SetActiveWidgetIndex(0)
    return
  end
  if self.isHaveData then
    self.Switcher:SetActiveWidgetIndex(1)
    self.HeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
    self.level:SetText(self.petData.level)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Leve_Pet_C:ShowSelectNull()
  self.Switcher:SetActiveWidgetIndex(2)
end

function UMG_Leve_Pet_C:ResetSelectNull()
  if 2 == self.Switcher:GetActiveWidgetIndex() then
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Leve_Pet_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCompileCurrentTeam, self.data.pet_gid, true)
  end
end

function UMG_Leve_Pet_C:OnDeactive()
end

return UMG_Leve_Pet_C
