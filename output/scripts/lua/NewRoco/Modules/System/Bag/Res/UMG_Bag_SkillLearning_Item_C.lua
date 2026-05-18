local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Bag_SkillLearning_Item_C = Base:Extend("UMG_Bag_SkillLearning_Item_C")

function UMG_Bag_SkillLearning_Item_C:OnConstruct()
  self.uiData = nil
end

function UMG_Bag_SkillLearning_Item_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_Bag_SkillLearning_Item_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetData(self.uiData)
  self:PlayAnimation(self.In)
end

function UMG_Bag_SkillLearning_Item_C:OnItemSelected(_bSelected)
end

function UMG_Bag_SkillLearning_Item_C:SetData(_data)
  self.uiData = _data
  if _data then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(self.uiData[2])
    self:PlayAnimation(self.Select_CanLearn)
    self.DelayId = _G.DelayManager:DelaySeconds(0.16, function()
    end)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData[1].base_conf_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if modelConf then
        self.PetHeadIcon:SetIconPathAndMaterial(self.uiData[1].base_conf_id, self.uiData[1].mutation_type, self.uiData[1].glass_info)
      end
    end
  end
end

function UMG_Bag_SkillLearning_Item_C:OnDeactive()
end

return UMG_Bag_SkillLearning_Item_C
