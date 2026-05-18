local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetGrowUp_Icon_C = Base:Extend("UMG_PetGrowUp_Icon_C")

function UMG_PetGrowUp_Icon_C:OnConstruct()
end

function UMG_PetGrowUp_Icon_C:OnDestruct()
  self.btnItemIcon.OnClicked:Remove(self, self.OnBtnItemIconClick)
end

function UMG_PetGrowUp_Icon_C:OnActive()
end

function UMG_PetGrowUp_Icon_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:OnAddEventListener()
  self:SetPetNeedItemInfo()
  self:ClearSelectAnim()
end

function UMG_PetGrowUp_Icon_C:OnAddEventListener()
  self.btnItemIcon.OnClicked:Add(self, self.OnBtnItemIconClick)
end

function UMG_PetGrowUp_Icon_C:SetPetNeedItemInfo()
  if not self.uiData then
    self:SetQuality(0)
    self.itemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.txtFinish:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Panel_Count:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  end
  local _data = self.uiData
  local iconPath = ""
  local iconNum = _data.itemNum
  local bagNum = 0
  if _data.itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_data.itemId)
    if nil ~= vItemConf then
      self:SetQuality(vItemConf.item_quality)
      iconPath = vItemConf.bigIcon
    end
    bagNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_data.itemId)
  elseif _data.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(_data.itemId)
    if nil ~= bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
      iconPath = bagItemConf.icon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(_data.itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      iconPath = modelConf.icon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(_data.itemId)
    if cardSkinConf then
      self:SetQuality(cardSkinConf.card_quality)
      iconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
    end
  end
  if _data.bShowNum == true then
    self.Panel_Count:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Panel_Count:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.itemIcon:SetPath(iconPath)
  local itemCount = self.uiData.BagNum or bagNum
  local needCount = self.uiData.itemNum or 0
  local number = itemCount
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local numberStr_1 = tostring(needCount)
  local length_1 = string.len(numberStr_1)
  local Padding = UE4.FMargin()
  Padding.Left = 0
  Padding.Top = 0
  Padding.Right = 0
  Padding.Bottom = 0
  if itemCount >= needCount then
    self.itemCount:SetText(string.format("<span size=\"30\">%d</>", itemCount))
    self.itemCount_1:SetText(string.format("<span size=\"30\">/%d</>", needCount))
    if length >= 3 and 3 == length_1 then
      self.itemCount:SetText(string.format("<span size=\"20\">%d</>", itemCount))
      self.itemCount_1:SetText(string.format("<span size=\"26\">/%d</>", needCount))
      Padding.Bottom = 1.5
      self.itemCount.Slot:SetPadding(Padding)
    elseif length > 3 then
      self.itemCount:SetText(string.format("<span size=\"24\">%d</>", itemCount))
      Padding.Bottom = 1.5
      self.itemCount.Slot:SetPadding(Padding)
    end
  else
    self.itemCount:SetText(string.format("<span size=\"30\" color=\"#AF3D3EFF\">%d</>", itemCount))
    self.itemCount_1:SetText(string.format("<span size=\"30\">/</><span size=\"30\">%d</>", needCount))
    if length >= 3 and 3 == length_1 then
      self.itemCount:SetText(string.format("<span size=\"20\" color=\"#AF3D3EFF\">%d</>", itemCount))
      self.itemCount_1:SetText(string.format("<span size=\"26\">/%d</>", needCount))
      Padding.Bottom = 1.5
      self.itemCount.Slot:SetPadding(Padding)
    elseif length > 3 then
      self.itemCount:SetText(string.format("<span size=\"24\" color=\"#AF3D3EFF\">%d</>", itemCount))
      Padding.Bottom = 1.5
      self.itemCount.Slot:SetPadding(Padding)
    end
  end
end

function UMG_PetGrowUp_Icon_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_PetGrowUp_Icon_C:ClearSelectAnim()
  local ani = self.select
  if self:IsAnimationPlaying(ani) then
    self:StopAnimation(ani)
    self:PlayAnimation(self.normal)
  end
end

function UMG_PetGrowUp_Icon_C:txtFinishInfo()
  self.txtFinish:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Panel_Count:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetGrowUp_Icon_C:OnBtnItemIconClick()
  if self.uiData and self.uiData.itemId and self.uiData.itemId > 0 then
    local ani = self.select
    if not self:IsAnimationPlaying(ani) then
      self:PlayAnimation(ani, 0, 0)
    end
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.uiData.itemId, self.uiData.itemType)
  end
end

function UMG_PetGrowUp_Icon_C:OnDeactive()
end

return UMG_PetGrowUp_Icon_C
