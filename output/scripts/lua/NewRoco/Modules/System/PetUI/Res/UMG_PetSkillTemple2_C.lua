require("UnLuaEx")
local Enum = reload("Data.Config.Enum")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_ScrollViewItemBase_C")
local UMG_PetSkillTemple2_C = Base:Extend("UMG_PetSkillTemple2_C")

function UMG_PetSkillTemple2_C:Destruct()
  Base.Destruct(self)
  self.skillData = nil
  self.skillConfig = nil
  self.propIcon:ReleaseForce()
  self.skillIcon:ReleaseForce()
end

function UMG_PetSkillTemple2_C:SetData(_data)
  Base.SetData(self, _data)
  self.skillData = _data
  if self.skillData then
    self.skillConfig = _G.DataConfigManager:GetSkillConf(self.skillData.id)
  else
    self.skillConfig = nil
  end
  self:UpdateSkillInfo()
end

function UMG_PetSkillTemple2_C:SetSelectState(_flag)
  self.selectFlag = _flag
  if _flag then
    self.ImageSelect:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ImageSelect:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillTemple2_C:UpdateSkillInfo()
  if self.skillData and self.skillConfig then
    self.imageEmpty:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.skillIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.imageSkillIconBg:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillIcon:SetPath(self.skillConfig.icon)
    self.textSkillName:SetText(self.skillConfig.name)
    self.textSkillDesc:SetText(self.skillConfig.desc)
    if self.skillConfig.energy_cost[1] and self.skillConfig.energy_cost[1] > 0 then
      self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.textSkillUltimate:SetText(self.skillConfig.energy_cost[1])
    else
      self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    if self.skillConfig.cd_round[1] and self.skillConfig.cd_round[1] > 1 then
      self.Panel_SkillCD:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.textSkillCD:SetText(self.skillConfig.cd_round[1] - 1)
    else
      self.Panel_SkillCD:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    self.Panel_Prop:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local dam_para = self.skillConfig.dam_para[1]
    if dam_para and dam_para > 0 then
      self.textPropValue:SetText(dam_para)
    else
      self.textPropValue:SetText("\226\128\148")
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(self.skillConfig.skill_dam_type)
    if typeDic then
      self.propIcon:SetPath(typeDic.type_icon)
      self.propIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.propIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.textSkillMessage:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.textSkillName:SetText("")
    self.textSkillDesc:SetText("")
    self.textPropValue:SetText("")
    self.Panel_Prop:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Panel_SkillCD:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.imageEmpty:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.imageSkillIconBg:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.textSkillMessage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.skillData and self.skillData.is_equipped then
    self.imageEquip:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imageEquip:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if self.skillData and not self.skillData.is_learned then
    self.textUnLock:SetText(string.format(LuaText.umg_petskilltemple2_1, self.skillData.unlock_need_lv or -1))
    self.panelSkillLock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.skillIconMask:SetEffectMaterial(self.iconMaterial2)
    self.panelSkillText:SetRenderOpacity(0.7)
  else
    self.panelSkillLock:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.skillIconMask:SetEffectMaterial(self.iconMaterial1)
    self.panelSkillText:SetRenderOpacity(1)
  end
end

function UMG_PetSkillTemple2_C:OnSelectionChange(_bSelected)
  self.selectFlag = _bSelected
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_PetSkillTemple2_C:OnSelectionChange")
  else
  end
  local ani = self.select
  if self:IsAnimationPlaying(ani) then
    self:StopAnimation(ani)
  end
  if _bSelected then
    self:PlayAnimation(ani, 0, 0)
  else
    self:PlayAnimation(self.normal)
  end
end

return UMG_PetSkillTemple2_C
