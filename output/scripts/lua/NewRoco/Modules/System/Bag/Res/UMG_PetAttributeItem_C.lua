local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetAttributeItem_C = Base:Extend("UMG_PetAttributeItem_C")

function UMG_PetAttributeItem_C:OnConstruct()
end

function UMG_PetAttributeItem_C:OnDestruct()
end

function UMG_PetAttributeItem_C:OnItemUpdate(_data, datalist, index)
  self.UiData = _data
  self.OwnedText:SetText(_data.NumText)
  if _data.IsGoodNature then
    self.Switcher_1:SetActiveWidgetIndex(0)
    self:SetNatureIcon(self.attributeIcon, _data.AttributeType)
    if self.UiData.bIsFrameItem then
      if self.UiData.AttributeType == self.UiData.petGoodNature then
        self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
        self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.UiData.AttributeType == self.UiData.petBadNature then
        self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
        self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
    elseif self.UiData.AttributeType == self.UiData.petGoodNature then
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  else
    self.Switcher_1:SetActiveWidgetIndex(1)
    self:SetNatureIcon(self.attributeIcon_1, _data.AttributeType)
    if self.UiData.bIsFrameItem then
      if self.UiData.AttributeType == self.UiData.petGoodNature then
        self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
        self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
      if self.UiData.AttributeType == self.UiData.petBadNature then
        self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
        self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      end
    elseif self.UiData.AttributeType == self.UiData.petBadNature then
      self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("C4C3B6FF"))
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  end
end

function UMG_PetAttributeItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.SetBagItemClickAble, "PetAttributePopUp", false)
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Bag_C:OnBtnEggClicked")
    self:PlayAnimation(self.Press)
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
    if self.Parent then
      self.Parent:OnItemSelected(self.UiData.AttributeType)
    end
  else
    self:PlayAnimation(self.Cancel)
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
end

function UMG_PetAttributeItem_C:SetParent(Parent)
  self.Parent = Parent
end

function UMG_PetAttributeItem_C:SetNatureIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_PetAttributeItem_C:OnDeactive()
end

function UMG_PetAttributeItem_C:OnAnimationFinished(Anim)
  if Anim == self.Press then
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.SetBagItemClickAble, "PetAttributePopUp", true)
  end
end

return UMG_PetAttributeItem_C
