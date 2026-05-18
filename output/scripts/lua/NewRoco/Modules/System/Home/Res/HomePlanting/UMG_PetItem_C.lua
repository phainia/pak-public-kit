local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetItem_C = Base:Extend("UMG_PetItem_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_PetItem_C:OnConstruct()
  self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetItem_C:OnDestruct()
end

function UMG_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.petData = _data.data
  self.petInfo = _data
  self.bForceUnClickAble = false
  self.dataList = datalist
  if _data.panel then
    self.parentPanel = _data.panel
  end
  self:PlayAnimation(self.normal, 0, 1, UE4.EUMGSequencePlayMode.Forward, 999)
  self:SetPetData()
end

function UMG_PetItem_C:OnDespawn()
  self.bForceUnClickAble = nil
  if self.parentPanel and self.parentPanel.curPetListSelectIndex == self.index then
    self:StopAllAnimations()
    if self.NumText then
      self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
    end
    self:PlayAnimation(self.Unselect)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetItem_C:ShowPetStatus()
  local petStatusText = self.petData.level or ""
  local tagIcon1ResPath = ""
  if self.petInfo.isInHome then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("home_pet_check_in_suntitle").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_ruzhu_png.img_ruzhu_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetClickable(false)
  elseif self.petInfo.isTeam or self.petInfo.isBattleTeam then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("umg_travel_iconitem_2").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_bianduizhong_png.img_bianduizhong_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetClickable(false)
  elseif self.petInfo.isTravel then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("umg_travel_iconitem_3").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_lvxingjieshu_png.img_lvxingjieshu_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetClickable(false)
  elseif self.petInfo.isInGuard then
    petStatusText = _G.DataConfigManager:GetLocalizationConf("home_pet_check_in_suntitle").msg
    tagIcon1ResPath = "PaperSprite'/Game/NewRoco/Modules/System/Home/Raw/HomeMain/Frames/img_Plant_protectionIcon_png.img_Plant_protectionIcon_png'"
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetClickable(true)
  else
    self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetClickable(true)
  end
  self.bForceUnClickAble = not self.clickable
  self.NumText:SetText(petStatusText)
  if string.IsNilOrEmpty(tagIcon1ResPath) then
    self.UnderProtection:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.UnderProtection:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UnderProtection:SetPath(tagIcon1ResPath)
  end
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_PetItem_C:SetPetData()
  if not self.petData then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    local icon = modelConf.icon
    if PetMutationUtils.GetMutationValue(self.petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      icon = modelConf.shiny_icon
    end
    self.ItemIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
    self.ItemIconMask:SetPath(icon)
  end
  self:UpdatePartnerMark()
  self:ShowPetStatus()
end

function UMG_PetItem_C:OnItemSelected(_bSelected, _bScrollSelected)
  if _bSelected then
    self:StopAnimation(self.Unselect)
    if self.parentPanel and self.parentPanel.OnScrollPetItemSelected then
      self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
      self.TextBG_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if _bScrollSelected then
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 5)
      else
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1)
      end
      local bFireCallback = not _bScrollSelected
      if bFireCallback then
        self.parentPanel:OnScrollPetItemSelected(self, self.index, true)
      end
    end
  else
    self:StopAnimation(self.Select)
    self:PlayAnimation(self.UnSelect)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetItem_C:OnAnimationFinished(anim)
  if anim == self.Unselect then
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetItem_C:OnDeactive()
end

function UMG_PetItem_C:UpdatePartnerMark()
  if not self.CollectCanvas then
    return
  end
  if self.petData and self.petData.partner_mark and self.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.petData.partner_mark))
  else
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_PetItem_C
