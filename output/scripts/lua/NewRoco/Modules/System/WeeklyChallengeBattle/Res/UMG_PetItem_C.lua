local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetItem_C = Base:Extend("UMG_PetItem_C")

function UMG_PetItem_C:OnConstruct()
end

function UMG_PetItem_C:OnDestruct()
end

function UMG_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:_InitItem()
end

function UMG_PetItem_C:OnItemSelected(_bSelected)
end

function UMG_PetItem_C:OnDeactive()
end

function UMG_PetItem_C:_InitItem()
  if not self.uiData.gid or 0 == self.uiData.gid then
    self.Switcher:SetActiveWidgetIndex(0)
  else
    self.Switcher:SetActiveWidgetIndex(1)
    local balancedData = _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetPetBalancedDataByGid, self.uiData.gid)
    if balancedData then
      self.level:SetText(balancedData.level)
    else
      self.level:SetText(self.uiData.level)
    end
    self.HeadIcon:SetIconPathAndMaterial(self.uiData.base_conf_id, self.uiData.mutation_type, self.uiData.glass_info)
  end
end

function UMG_PetItem_C:UpdatePetData(newPetData)
  if newPetData.gid ~= self.uiData.gid then
    return
  end
  self.uiData = newPetData
  self:_InitItem()
end

return UMG_PetItem_C
