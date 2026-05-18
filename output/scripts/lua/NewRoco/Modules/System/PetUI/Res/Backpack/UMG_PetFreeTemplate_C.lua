local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetFreeTemplate_C = Base:Extend("UMG_PetFreeTemplate_C")

function UMG_PetFreeTemplate_C:OnConstruct()
  self.IsScrollSelect = false
end

function UMG_PetFreeTemplate_C:OnDestruct()
  self.TipsBtn.OnClicked:Remove(self, self.OnButtonClicked)
end

function UMG_PetFreeTemplate_C:OnItemUpdate(_data, datalist, index)
  self.PetInfo = _data
  self.petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetInfo.petData.base_conf_id)
  self.IsInTeam = _data.IsInTeam
  if _data.bgPath then
    self.BGColor:SetPath(_data.bgPath)
  end
  self.NotOpenAnim = false
  self:SetData()
  self.TipsBtn.OnClicked:Remove(self, self.OnButtonClicked)
  self.TipsBtn.OnClicked:Add(self, self.OnButtonClicked)
end

function UMG_PetFreeTemplate_C:OnButtonClicked()
  local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, self.PetInfo.petData.gid)
  if isTravel then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petwarehousemain_5)
  elseif self.petBaseConf.banFree and 1 == self.petBaseConf.banFree then
    local text = _G.DataConfigManager:GetLocalizationConf("remove_dimo_tips").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, text)
  end
end

function UMG_PetFreeTemplate_C:SetData()
  if not self.PetInfo.InitSelect then
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TipsBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:StopAllAnimations()
    self:PlayAnimation(self.normal)
  end
  if self.PetInfo.IsSelectFree then
    self.CheckCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if self.IsInTeam then
      self.State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.CheckCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PetInfo.petData.partner_mark and self.PetInfo.petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Star:SetPath(PetUtils.GetPetCollectTagIcon(self.PetInfo.petData.partner_mark))
  else
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local petList = self.PetInfo
  local modelConf = _G.DataConfigManager:GetModelConf(self.petBaseConf.model_conf)
  local icon = modelConf.icon
  if PetMutationUtils.GetMutationValue(petList.petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    icon = modelConf.shiny_icon
  end
  self.ItemIcon:SetIconPathAndMaterial(self.PetInfo.petData.base_conf_id, petList.petData.mutation_type, petList.petData.glass_info)
  self.NumText:SetText(self.PetInfo.petData.level)
end

function UMG_PetFreeTemplate_C:OnItemSelected(_bSelected)
  if not UE4.UObject.IsValid(self) then
    return
  end
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:StopAllAnimations()
    self:PlayAnimation(self.select)
    if not self.IsScrollSelect then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetWarehouseFreeInfo, self.PetInfo.petData, self.PetInfo.ListIndex)
    else
      self.IsScrollSelect = false
    end
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:StopAllAnimations()
    self:PlayAnimation(self.Unselect)
  end
end

function UMG_PetFreeTemplate_C:OnDeactive()
end

function UMG_PetFreeTemplate_C:OnAnimationFinished(anim)
  if anim == self.Tick_Out then
    self.CheckCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_PetFreeTemplate_C
