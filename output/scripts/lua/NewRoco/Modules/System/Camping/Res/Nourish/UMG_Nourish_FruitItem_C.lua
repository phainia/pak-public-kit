local CampingModuleEvent = require("NewRoco.Modules.System.Camping.CampingModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_FruitItem_C = Base:Extend("UMG_Nourish_FruitItem_C")

function UMG_Nourish_FruitItem_C:OnConstruct()
end

function UMG_Nourish_FruitItem_C:OnDestruct()
end

function UMG_Nourish_FruitItem_C:OnItemUpdate(_data, datalist, index)
  Log.Error("\230\173\164\229\138\159\232\131\189\229\183\178\229\186\159\229\188\131\239\188\140\232\175\183\233\135\141\230\150\176\230\143\144\233\156\128\230\177\130")
  self.data = _data
  self.index = index
  self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.BagItem.id)
  self:SetQuality(bagItemConf.item_quality)
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
  self.Name:SetText(bagItemConf.name)
  if not self.data.PetBaseId then
    self.Describe:SetText("\230\156\170\233\133\141\231\189\174\232\175\165\230\158\156\229\174\158\231\154\132\231\178\190\231\129\181\229\174\182\230\151\143\230\143\143\232\191\176")
  else
    local petBaseInfo = _G.DataConfigManager:GetPetbaseConf(self.data.PetBaseId)
    self.Describe:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_use_tips").msg, petBaseInfo.name))
  end
  self.txtLV:SetText(self.data.BagItem.num)
  if 1 == self.data.type then
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 3 == self.data.type then
    self.Advantage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for i = 1, #self.data.pet_form_factor_tag do
    if self.data.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
      if 1 == self.data.type then
        self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
        break
      end
      self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      break
    end
    if i == #self.data.pet_form_factor_tag then
      self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Nourish_FruitItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCModeManager:DoCmd(CampingModuleCmd.SetSelectFruitItem, self.index, self.data)
    if self.CanOpenTips then
      self.CanOpenTips = false
      _G.NRCModeManager:DoCmd(CampingModuleCmd.OpenNourishFruitTips, self.data)
    else
      _G.NRCAudioManager:PlaySound2DAuto(1003, "CampingModule:OpenNourishRightFruit")
    end
    self.CanOpenTips = true
  else
    self.CanOpenTips = false
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Nourish_FruitItem_C:OnDeactive()
end

function UMG_Nourish_FruitItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_5)
  end
end

return UMG_Nourish_FruitItem_C
