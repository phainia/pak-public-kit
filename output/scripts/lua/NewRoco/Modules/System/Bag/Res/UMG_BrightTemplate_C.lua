local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BrightTemplate_C = Base:Extend("UMG_BrightTemplate_C")

function UMG_BrightTemplate_C:OnConstruct()
end

function UMG_BrightTemplate_C:OnDestruct()
end

function UMG_BrightTemplate_C:OnItemUpdate(_data, datalist, index)
  self.data = _data[1]
  self.index = index
  self:SetData()
end

function UMG_BrightTemplate_C:SetData()
  local attribute_info = self.data.attribute_info
  local petlevel = PetUtils.GetPetStarsListByPetGID(self.data.gid)
  self.StarList:InitGridView(petlevel)
  self.Num:SetText(self.data.level)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      self.HeadIcon:SetIconPathAndMaterial(self.data.base_conf_id, self.data.mutation_type, self.data.glass_info)
    end
  end
  local TalentCount = 0
  if 0 ~= attribute_info.hp.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_HPMAX, attribute_info.hp.talent)
  end
  if 0 ~= attribute_info.attack.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_PHYATK, attribute_info.attack.talent)
  end
  if 0 ~= attribute_info.special_attack.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_SPEATK, attribute_info.special_attack.talent)
  end
  if 0 ~= attribute_info.defense.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_PHYDEF, attribute_info.defense.talent)
  end
  if 0 ~= attribute_info.special_defense.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_SPEDEF, attribute_info.special_defense.talent)
  end
  if 0 ~= attribute_info.speed.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIcon(TalentCount, Enum.AttributeType.AT_SPEED, attribute_info.speed.talent)
  end
  self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if 1 == TalentCount then
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 2 == TalentCount then
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BrightTemplate_C:SetTalentIcon(TalentCount, attributeCfg, num)
  local icon = self.attributeIcon
  local text = self.OwnedText
  if 1 == TalentCount then
    icon = self.attributeIcon
    text = self.OwnedText
  elseif 2 == TalentCount then
    icon = self.attributeIcon_1
    text = self.OwnedText_1
  elseif 3 == TalentCount then
    icon = self.attributeIcon_2
    text = self.OwnedText_2
  else
    return
  end
  text:SetText("+" .. num)
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

function UMG_BrightTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.canOpenTips then
      self:PlayAnimation(self.Select_In1)
      self:OpenTips()
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_PetCharacterTemplate_C:OnItemSelected")
      if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
        self:PlayAnimation(self.Select_In2)
      else
        self:PlayAnimation(self.Select_In)
      end
      self.canOpenTips = true
    end
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetTalentItemCanSelect, false)
  else
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self:PlayAnimation(self.Select_Out2)
    else
      self:PlayAnimation(self.Select_Out)
    end
    self.canOpenTips = false
  end
end

function UMG_BrightTemplate_C:OpenTips()
  local selectItem = self.Parent.GridView:GetSelectedItem()
  if selectItem and selectItem.index and selectItem.index == self.index then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.data)
  end
end

function UMG_BrightTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.Select_In or Animation == self.Select_In1 or Animation == self.Select_In2 then
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetTalentItemCanSelect, true, self.data)
  end
end

function UMG_BrightTemplate_C:SetParent(_Parent)
  self.Parent = _Parent
  self.UseAction = self.Parent.UseAction
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    self:SetColorType("292929FF", "62605EFF")
  else
    self:SetColorType("62605EFF", "272727FF")
  end
end

function UMG_BrightTemplate_C:SetColorType(ColorString, IconColorString)
  self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
  self.OwnedText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
  self.OwnedText_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
  self.attributeIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(IconColorString))
  self.attributeIcon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(IconColorString))
  self.attributeIcon_2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(IconColorString))
end

function UMG_BrightTemplate_C:OnDeactive()
end

return UMG_BrightTemplate_C
