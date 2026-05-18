local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Purchase_Item_C = Base:Extend("UMG_Purchase_Item_C")

function UMG_Purchase_Item_C:OnConstruct()
end

function UMG_Purchase_Item_C:OnDestruct()
end

function UMG_Purchase_Item_C:OnItemUpdate(_data, datalist, index)
  if _G.GlobalConfig.DebugOpenUI then
    local bigIcon = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/Item190/1.1'"
    self.propsbox.icon:SetPath(bigIcon)
    self.propsbox_1.icon:SetPath(bigIcon)
    self.propsbox_2.icon:SetPath(bigIcon)
    return
  end
  if nil == _data then
    return
  end
  self.data = _data
  self.index = index
  self.icons = {
    self.propsbox,
    self.propsbox_1,
    self.propsbox_2
  }
  for i = 1, #self.icons do
    if i > #self.data.DataList then
      self.icons[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.icons[i]:SetVisibility(UE4.ESlateVisibility.Visible)
      self.icons[i].btn.OnClicked:Clear()
      self.icons[i].btn.OnClicked:Add(self, function()
        self:OnClickItem(self.data.DataList[i])
      end)
      self:ShowItem(self.icons[i], self.data.DataList[i])
    end
  end
end

function UMG_Purchase_Item_C:OnClickItem(data)
  if data.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local Itemdata = _G.DataConfigManager:GetBagItemConf(data.item_id)
    if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
      local skillMachineid = Itemdata.item_behavior[1].ratio[1]
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, data.item_id, data.Type, false)
    end
  elseif data.Type == _G.Enum.GoodsType.GT_PET then
    local pet_id = data.item_id
    local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
    local param = {
      petbaseId = pet_conf.base_id,
      needBlur = false,
      notAcquired = false,
      isSketch = true
    }
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
    _G.NRCAudioManager:PlaySound2DAuto(1284, "UMG_Pass_Award_Item_C:OnItemSelected")
  elseif data.Type == _G.Enum.GoodsType.GT_FASHION_SUITS then
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OpenAppearanceSuitDetailsPanel, data.item_id)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, data.item_id, data.Type, false)
  end
end

function UMG_Purchase_Item_C:CancelSelect()
end

function UMG_Purchase_Item_C:ShowItem(icon, data)
  local curData = data
  local curIcon = icon
  curIcon.txtLV:SetText(string.format("X%s", curData.item_num))
  curIcon.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.data.isSenior and "FFC65FFF" or "F5EEE1FF"))
  local itemId = curData.item_id
  local itemName = ""
  local iconPath = ""
  local itemQuality = 0
  if curData.Type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if nil ~= vItemConf then
      itemQuality = vItemConf.item_quality
      itemName = vItemConf.type_desc
      iconPath = NRCUtils:FormatConfIconPath(vItemConf.bigIcon, _G.UIIconPath.BagItemPath)
    end
  elseif curData.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if nil ~= bagItemConf then
      itemQuality = bagItemConf.item_quality
      itemName = bagItemConf.name
      iconPath = NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath)
    end
  elseif curData.Type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if modelConf then
        iconPath = NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath)
      end
      itemName = petBaseConf.name
      itemQuality = petBaseConf.quality
    end
  elseif curData.Type == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local fashionConf = _G.DataConfigManager:GetFashionSuitsConf(itemId)
    if fashionConf then
      itemQuality = AppearanceUtils.GetSuitQuality(fashionConf.suit_grade)
      iconPath = fashionConf.suits_icon
    end
  end
  self:SetQuality(icon, itemQuality)
  curIcon.icon:SetPath(iconPath)
end

function UMG_Purchase_Item_C:SetQuality(icon, quality)
  if 0 == quality then
  elseif 1 == quality then
    icon.background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    icon.background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    icon.background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    icon.background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    icon.background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Purchase_Item_C:OnDeactive()
end

return UMG_Purchase_Item_C
