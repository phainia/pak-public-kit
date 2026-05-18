local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SearchPetItem_C = Base:Extend("UMG_SearchPetItem_C")

function UMG_SearchPetItem_C:OnConstruct()
end

function UMG_SearchPetItem_C:OnDestruct()
end

function UMG_SearchPetItem_C:OnItemUpdate(_data, datalist, index)
  self:StopAllAnimations()
  self:PlayAnimation(self.DefaultAim)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.petBaseId)
  if PetBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
    if modelConf then
      self.HeadIcon:SetPath(modelConf.icon)
    end
  end
  self.data = _data
  self.SortText:SetText(PetBaseConf.name)
  self.Switcher:SetActiveWidgetIndex(0)
  self.Reduction:SetVisibility(_data.isShowReduction and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if _data.isShowReduction then
    self:StopAllAnimations()
    self:PlayAnimation(self.DefaultAim_2)
    self.Switcher:SetActiveWidgetIndex(1)
  end
  self.PetBaseId = _data.petBaseId
  self.clickToggle = false
end

function UMG_SearchPetItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BagScrrenItem_C:OnItemSelected")
    if self.data.isShowReduction then
      self:PlayAnimation(self.Cancel)
      return
    end
    self.clickToggle = not self.clickToggle
    if self.clickToggle then
      self:PlayAnimation(self.Press)
    else
      self:PlayAnimation(self.Cancel)
    end
  end
end

function UMG_SearchPetItem_C:OnAnimationFinished(Animation)
  if Animation == self.Cancel and self.data and self.data.isShowReduction then
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterCondition, _G.Enum.FilterRule.FIL_LEARNABLE, self.data)
  end
end

function UMG_SearchPetItem_C:OnDeactive()
end

return UMG_SearchPetItem_C
