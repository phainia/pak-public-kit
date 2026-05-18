local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_SeasonPetCertification_BlessingMain_Item_C = Base:Extend("UMG_Activity_SeasonPetCertification_BlessingMain_Item_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_Activity_SeasonPetCertification_BlessingMain_Item_C:OnConstruct()
end

function UMG_Activity_SeasonPetCertification_BlessingMain_Item_C:OnDestruct()
end

function UMG_Activity_SeasonPetCertification_BlessingMain_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  local selected_gid = _data.parent:GetCurPetGid()
  if selected_gid then
    if selected_gid == _data.gid then
      self.bSelected = true
      self:PlayAnimation(self.select, self.select:GetEndTime() - 0.01)
    else
      self.bSelected = false
      self:PlayAnimation(self.Unselect, self.Unselect:GetEndTime() - 0.01)
    end
  elseif self.bSelected then
    self.bSelected = false
    self:PlayAnimation(self.Unselect, self.Unselect:GetEndTime() - 0.01)
  end
  if not _data then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    local icon = modelConf.icon
    if PetMutationUtils.GetMutationValue(_data.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      icon = modelConf.shiny_icon
    end
    self.ItemIcon:SetIconPathAndMaterial(_data.base_conf_id, _data.mutation_type, _data.glass_info)
    self.ItemIconMask:SetPath(icon)
  end
  self:UpdatePartnerMark()
  local petStatusText = _data.level or ""
  self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ItemIconMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NumText:SetText(petStatusText)
  self.UnderProtection:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if _data.team_index then
    self.number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_number:SetText(_data.team_index)
  else
    self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_SeasonPetCertification_BlessingMain_Item_C:UpdatePartnerMark()
  if not self.CollectCanvas then
    return
  end
  if self.data and self.data.partner_mark and self.data.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.data.partner_mark))
  else
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_SeasonPetCertification_BlessingMain_Item_C:OnItemSelected(_bSelected)
  if self.bSelected == _bSelected then
    return
  end
  self.bSelected = _bSelected
  if _bSelected then
    self:PlayAnimation(self.select)
    self.data.selectedCallback(self.data.parent, self.index)
  else
    self:PlayAnimation(self.Unselect)
  end
end

return UMG_Activity_SeasonPetCertification_BlessingMain_Item_C
