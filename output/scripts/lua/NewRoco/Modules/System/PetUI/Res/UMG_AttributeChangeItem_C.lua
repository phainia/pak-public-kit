local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AttributeChangeItem_C = Base:Extend("UMG_AttributeChangeItem_C")

function UMG_AttributeChangeItem_C:OnConstruct()
  self:AddButtonListener(self.HeadButton, self.OnHeadButtonClick)
end

function UMG_AttributeChangeItem_C:OnDestruct()
end

function UMG_AttributeChangeItem_C:OnHeadButtonClick()
  if self.data and self.data.petData then
    _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.ShowChangePetConfirm, self.data.petData)
  end
end

function UMG_AttributeChangeItem_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    Log.Error("UMG_AttributeChangeItem_C:OnItemUpdate _data is nil")
    return
  end
  self.data = _data
  local petData = _data.petData
  if petData then
    self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
    self.PetLevel:SetText(petData.level)
  end
  self.NRCGridView_114:InitGridView(_data.itemList or {})
  self:SetAttributeChange(_data.mode, _data.param)
end

function UMG_AttributeChangeItem_C:SetAttributeChange(mode, param)
  self.Switcher:SetActiveWidgetIndex(mode)
  if param then
    if 0 == mode then
      self.NRCText_3:SetText(string.format(LuaText.skill_blood_tips_15, param.leftVal))
      self.NRCText_6:SetText(string.format(LuaText.skill_blood_tips_15, param.rightVal))
    elseif 1 == mode then
      self.Common_Attr1.BloodPulse:SetPath(param.leftVal.icon)
      self.Common_Attr1.TypeName2_1:SetText(param.leftVal.name)
      self.Common_Attr2.BloodPulse:SetPath(param.rightVal.icon)
      self.Common_Attr2.TypeName2_1:SetText(param.rightVal.name)
    end
  end
end

function UMG_AttributeChangeItem_C:OnItemSelected(_bSelected)
end

function UMG_AttributeChangeItem_C:OnDeactive()
end

return UMG_AttributeChangeItem_C
