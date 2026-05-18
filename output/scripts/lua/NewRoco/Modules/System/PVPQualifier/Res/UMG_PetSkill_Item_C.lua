local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetSkill_Item_C = Base:Extend("UMG_PetSkill_Item_C")

function UMG_PetSkill_Item_C:OnConstruct()
end

function UMG_PetSkill_Item_C:OnDestruct()
end

function UMG_PetSkill_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if self.data.pet_base_cfg_id then
    self:UpdatePet()
    self:UpdateSkill()
    self.PetSwitcher:SetActiveWidgetIndex(0)
  else
    self.PetSwitcher:SetActiveWidgetIndex(1)
  end
end

function UMG_PetSkill_Item_C:UpdatePet()
  local pet_conf = _G.DataConfigManager:GetPetbaseConf(self.data.pet_base_cfg_id)
  if pet_conf then
    self.TxtPetName:SetText(pet_conf.name)
  end
  local iconPath = self.HeadIcon.GetIconPath(self.data.pet_base_cfg_id)
  self.HeadIcon:SetIconPath(iconPath)
  local types = PetUtils.GetPetTypesById(self.data.pet_base_cfg_id)
  self.Attr:Clear()
  self.Attr:InitGridView(types)
end

function UMG_PetSkill_Item_C:UpdateSkill()
  self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TxtSkillName_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Attr6:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.pet_skill_use_info and #self.data.pet_skill_use_info > 0 then
    local skill_id = self.data.pet_skill_use_info[1].skill_id
    local skill_conf = SkillUtils.GetSkillConf(skill_id)
    if not skill_conf then
      return
    end
    self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skill_conf.icon or "", _G.UIIconPath.SkillIconPath))
    self.TxtSkillName_1:SetText(skill_conf.name or "")
    local attr_data = {}
    local type_dic = _G.DataConfigManager:GetTypeDictionary(skill_conf.skill_dam_type)
    if type_dic then
      local type_path = type_dic.tips_res
      local name = "-"
      if 1 ~= skill_conf.damage_type then
        name = tostring(skill_conf.dam_para[1])
      end
      table.insert(attr_data, {Path = type_path, Name = name})
    end
    if #attr_data > 0 then
      self.Attr6:InitGridView(attr_data)
      self.Attr6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.SkillIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtSkillName_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_PetSkill_Item_C
