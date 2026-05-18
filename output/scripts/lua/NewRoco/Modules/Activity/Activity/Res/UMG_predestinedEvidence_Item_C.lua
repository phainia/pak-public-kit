local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_predestinedEvidence_Item_C = Base:Extend("UMG_predestinedEvidence_Item_C")

function UMG_predestinedEvidence_Item_C:OnConstruct()
  self:AddButtonListener(self.BadgeButton, self.OpenTips)
end

function UMG_predestinedEvidence_Item_C:OnDestruct()
  self:RemoveButtonListener(self.BadgeButton)
end

function UMG_predestinedEvidence_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.pet_base_id)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  self.PetHeadIcon:SetPath(modelConf.icon)
  local bloodConf = _G.DataConfigManager:GetPetBloodConf(_data.blood_id)
  self.Icon_1:SetPath(bloodConf.icon_flower)
  self.Array:SetText(string.format(_G.DataConfigManager:GetTaskConf(_data.task_id).task_des, petBaseConf.name))
  if _data.bind_pet then
    petBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.bind_pet)
    modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.PetHeadIcon_1:SetPath(modelConf.icon)
  else
    self.PetHeadIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_predestinedEvidence_Item_C:OpenTips()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.medal_id, self.uiData.medal_type, false)
end

function UMG_predestinedEvidence_Item_C:OnItemSelected(_bSelected)
end

function UMG_predestinedEvidence_Item_C:OnDeactive()
end

return UMG_predestinedEvidence_Item_C
