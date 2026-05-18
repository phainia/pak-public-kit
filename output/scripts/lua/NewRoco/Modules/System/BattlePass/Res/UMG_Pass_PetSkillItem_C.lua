local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local enum = reload("Data.Config.Enum")
local UMG_Pass_PetSkillItem_C = Base:Extend("UMG_Pass_PetSkillItem_C")

function UMG_Pass_PetSkillItem_C:OnConstruct()
end

function UMG_Pass_PetSkillItem_C:OnDestruct()
end

function UMG_Pass_PetSkillItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:UpdateItemInfo()
end

function UMG_Pass_PetSkillItem_C:UpdateItemInfo()
  self.skillConfig = nil
  if self.data then
    local skillConf = self.data
    self.skillConfig = skillConf
    self.SkillNameTxt:SetText(skillConf.name)
    self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skillConf.icon, _G.UIIconPath.SkillIconPath))
    self.SkillNengNum:SetText(skillConf.energy_cost[1])
    if skillConf.damage_type == enum.DamageType.DT_NONE then
      self.skillShuNumTxt:SetText("-")
    else
      self.skillShuNumTxt:SetText(skillConf.dam_para[1])
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    if typeDic then
      self.SkillShuIcon:SetPath(typeDic.tips_res)
    end
    self.OrderBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.OrderBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetSelectedSate(false)
end

function UMG_Pass_PetSkillItem_C:SetSelectedSate(isSelected)
  local visState = isSelected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden
  self.NRCImageSelect:SetRenderOpacity(0)
  self.nengliang_1:SetVisibility(visState)
  self.Line_1:SetVisibility(visState)
  local textColor = isSelected and "#565f70FF" or "#ffffffff"
  self.SkillNameTxt:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(textColor))
  self.SkillNengNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(textColor))
end

function UMG_Pass_PetSkillItem_C:SetOnNewState()
end

function UMG_Pass_PetSkillItem_C:SetOnNewStateRemove()
end

function UMG_Pass_PetSkillItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, self.skillConfig.id, false)
  end
end

function UMG_Pass_PetSkillItem_C:OnDeactive()
end

return UMG_Pass_PetSkillItem_C
