local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SortItemAttributeItem1_C = Base:Extend("UMG_SortItemAttributeItem1_C")

function UMG_SortItemAttributeItem1_C:OnConstruct()
end

function UMG_SortItemAttributeItem1_C:OnDestruct()
end

function UMG_SortItemAttributeItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.UseAction = _data.UseAction
  if self.data.num and self.data.num > 0 then
    self.Switcher:SetActiveWidgetIndex(2)
    self.Switcher_1:SetActiveWidgetIndex(1)
    self.OwnedText:SetText("+" .. self.data.num)
    self.attributeIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("5e5d58FF"))
    self.attributeIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("5e5d58FF"))
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("7a7872FF"))
    self:SetClickable(false)
    self:SetTalentIcon(self.attributeIcon_2, self.data.type)
  else
    if self.data.ChangeTalent and self.data.ChangeTalent > 0 then
      self.OwnedText:SetText("+" .. self.data.ChangeTalent)
    else
      local unlock_attribute_quantity = _G.DataConfigManager:GetPetGlobalConfig("unlock_attribute_quantity").num
      self.OwnedText:SetText(string.format("+" .. (self.data.LevelNum + 1) * unlock_attribute_quantity))
    end
    self.attributeIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("292929FF"))
    self.attributeIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("292929FF"))
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605eFF"))
    self.Switcher:SetActiveWidgetIndex(1)
    self.Switcher_1:SetActiveWidgetIndex(0)
    self:SetTalentIcon(self.attributeIcon, self.data.type)
    self:SetClickable(true)
  end
end

function UMG_SortItemAttributeItem1_C:SetTalentIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_SortItemAttributeItem1_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Switcher:SetActiveWidgetIndex(0)
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetTalentChangeItemSelect, self.data.type)
  else
    self.Switcher:SetActiveWidgetIndex(1)
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
end

function UMG_SortItemAttributeItem1_C:OnDeactive()
end

return UMG_SortItemAttributeItem1_C
