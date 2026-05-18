local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_PetItemTemplate2_C = Base:Extend("UMG_PetItemTemplate2_C")

function UMG_PetItemTemplate2_C:OnConstruct()
end

function UMG_PetItemTemplate2_C:OnDestruct()
end

function UMG_PetItemTemplate2_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_PetItemTemplate2_C:OnTouchEnded")
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetItemTemplate2_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.petData = _data.data
  self.petInfo = _data
  self.dataList = datalist
  if _data.panel then
    self.parentPanel = _data.panel
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.normal)
  self:SetPetData()
  self.TextBG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.TextBG_2:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function UMG_PetItemTemplate2_C:OpItem(petDataWrapper)
  if 0 == petDataWrapper.type and self.petData and self.petData.gid == petDataWrapper.curPetData.gid then
    if petDataWrapper.curPetData.partner_mark and petDataWrapper.curPetData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
      local path = PetUtils.GetPetCollectTagIcon(petDataWrapper.curPetData.partner_mark)
      self.Star:SetPath(path)
      self.Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetItemTemplate2_C:ShowPetStatus()
  local petStatusText = self.petData.level or ""
  local levelText = self.petData.level or ""
  local tagIcon1ResPath = ""
  
  local function RefreshText(bPetAvailable, statusText)
    if bPetAvailable then
      self.StatusText:SetText(petStatusText)
      self.StatusText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.InTheFormationText:SetText(petStatusText)
      self.StatusText:SetText(levelText)
      self.StatusText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  
  if self.petInfo.isInHome then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("home_pet_check_in_suntitle").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_ruzhu_png.img_ruzhu_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    RefreshText(false, petStatusText)
    self:SetClickable(false)
  elseif self.petInfo.isTeam or self.petInfo.isBattleTeam then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("umg_travel_iconitem_2").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_bianduizhong_png.img_bianduizhong_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    RefreshText(false, petStatusText)
    self:SetClickable(false)
  elseif self.petInfo.isTravel then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("umg_travel_iconitem_3").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_lvxingjieshu_png.img_lvxingjieshu_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    RefreshText(false, petStatusText)
    self:SetClickable(false)
  elseif self.petInfo.isInGuard then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("home_pet_check_in_suntitle").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/Home/Raw/HomeMain/Frames/img_Plant_protectionIcon2_png.img_Plant_protectionIcon2_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    RefreshText(false, petStatusText)
    self:SetClickable(false)
  else
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    RefreshText(true, petStatusText)
    self:SetClickable(true)
  end
  if string.IsNilOrEmpty(tagIcon1ResPath) then
    self.Blackjiaobiao:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Blackjiaobiao_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Gender:SetActiveWidgetIndex(self.petInfo.gender - 1)
    self.Gender:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TagIcon_1:SetPath(tagIcon1ResPath)
    self.Blackjiaobiao:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Gender:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.petData.partner_mark and self.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
      self.Blackjiaobiao_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.petData.speciality_id then
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(self.petData.speciality_id)
    if PetTalentConf and 3 == PetTalentConf.type then
      self.Output:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Output:SetPath(PetTalentConf.icon)
    else
      self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetItemTemplate2_C:SetPetData()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petInfo.base_conf_id)
  if self.petData.partner_mark and self.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Star:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.petData.partner_mark))
  else
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    local icon = modelConf.icon
    if PetMutationUtils.GetMutationValue(self.petInfo.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      icon = modelConf.shiny_icon
    end
    self.ItemIcon:SetIconPathAndMaterial(self.petInfo.base_conf_id, self.petInfo.data.mutation_type, self.petInfo.data.glass_info)
    self.ItemIconMask:SetPath(icon)
  end
  self:ShowPetStatus()
end

function UMG_PetItemTemplate2_C:OnItemSelected(_bSelected, _bScrollSelected)
  self:StopAllAnimations()
  if _bSelected then
    if self.parentPanel and self.parentPanel.OnScrollPetItemSelected then
      if not _bScrollSelected then
        self.parentPanel:OnScrollPetItemSelected(self, self.index)
      end
      self:PlayAnimation(self.select)
    end
  else
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_PetItemTemplate2_C:OnDeactive()
end

return UMG_PetItemTemplate2_C
