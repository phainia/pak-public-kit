local natureConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.NATURE_CONF):GetAllDatas()
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_PersonalityIndividualValue_Small_C = Base:Extend("UMG_PersonalityIndividualValue_Small_C")

function UMG_PersonalityIndividualValue_Small_C:OnConstruct()
end

function UMG_PersonalityIndividualValue_Small_C:OnDestruct()
end

function UMG_PersonalityIndividualValue_Small_C:OnItemUpdate(_data, datalist, index)
  self.UiData = _data
  self.QuestionMark.btnLevelUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if 0 == self.UiData.type then
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    if self.UiData.IsIgnore then
      self:SetNatureIcon(self.attributeIcon, self.UiData.pos_effect)
      self:SetNatureIcon(self.attributeIcon_1, self.UiData.neg_effect)
      local ChangedNatureName
      for i, v in ipairs(natureConf) do
        if v.positive_effect == self.UiData.pos_effect and v.negative_effect == self.UiData.neg_effect then
          ChangedNatureName = v.name
          break
        end
      end
      if ChangedNatureName then
        self.NRCText_285:SetText(ChangedNatureName)
      end
    else
      self:SetNatureIcon(self.attributeIcon, self.UiData.share_pos_effect)
      self:SetNatureIcon(self.attributeIcon_1, self.UiData.share_neg_effect)
      local ChangedNatureName
      for i, v in ipairs(natureConf) do
        if v.positive_effect == self.UiData.share_pos_effect and v.negative_effect == self.UiData.share_neg_effect then
          ChangedNatureName = v.name
          break
        end
      end
      if ChangedNatureName then
        self.NRCText_285:SetText(ChangedNatureName)
      end
    end
    self:CheckHasNature()
  elseif 1 == self.UiData.type then
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    if self.UiData.IsIgnore and not self.UiData.HasTalent then
      self:SetNatureIcon(self.IndividualValueIon, self.UiData.cur_attribute)
    else
      self:SetNatureIcon(self.IndividualValueIon, self.UiData.attribute)
    end
    self:CheckHasTalent()
  end
end

function UMG_PersonalityIndividualValue_Small_C:CheckHasTalent()
  if self.UiData.HasTalent == nil then
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif not self.UiData.HasTalent and not self.UiData.IsIgnore then
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PersonalityIndividualValue_Small_C:CheckHasNature()
  if self.UiData.HasNature == nil then
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif not self.UiData.HasNature and not self.UiData.IsIgnore then
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.QuestionMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PersonalityIndividualValue_Small_C:OnItemSelected(_bSelected)
  if not _bSelected or self.UiData.HasTalent or self.UiData.HasNature or self.UiData.IsIgnore then
  elseif 1 == self.UiData.type then
    NRCModuleManager:DoCmd(PetUIModuleCmd.TryOpenRevisePanelByType, PetUIModuleEnum.PetTeamShareReviseType.Talent, {
      gid = self.UiData.gid,
      type = self.UiData.attribute
    })
  elseif 0 == self.UiData.type then
    local data = {
      gid = self.UiData.gid,
      share_pos_effect = self.UiData.share_pos_effect,
      share_neg_effect = self.UiData.share_neg_effect,
      pos_effect = self.UiData.pos_effect,
      neg_effect = self.UiData.neg_effect,
      natureName = self.UiData.natureName
    }
    NRCModuleManager:DoCmd(PetUIModuleCmd.TryOpenRevisePanelByType, PetUIModuleEnum.PetTeamShareReviseType.Nature, data)
  end
end

function UMG_PersonalityIndividualValue_Small_C:SetNatureIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_01_png.ui_pet_attribute_01_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_02_png.ui_pet_attribute_02_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_04_png.ui_pet_attribute_04_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_03_png.ui_pet_attribute_03_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_05_png.ui_pet_attribute_05_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_06_png.ui_pet_attribute_06_png'")
  end
end

function UMG_PersonalityIndividualValue_Small_C:GetNatureEffect(_effect)
  local attribute = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ATTRIBUTE_CONF):GetAllDatas()
  for i, v in ipairs(attribute) do
    if _effect == v.attribute then
      return v
    end
  end
end

function UMG_PersonalityIndividualValue_Small_C:OnDeactive()
end

function UMG_PersonalityIndividualValue_Small_C:OnTouchStarted(MyGeometry, InTouchEvent)
  _G.NRCEventCenter:RegisterEvent("UMG_PetImage3D_C", self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
  self:PlayAnimation(self.Press)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PersonalityIndividualValue_Small_C:OnRocoTouchEndHandler(MyGeometry, InTouchEvent)
  self:PlayAnimation(self.Up)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
end

return UMG_PersonalityIndividualValue_Small_C
