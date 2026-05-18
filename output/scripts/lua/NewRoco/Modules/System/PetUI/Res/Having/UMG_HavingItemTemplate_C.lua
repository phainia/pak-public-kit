local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HavingItemTemplate_C = Base:Extend("UMG_HavingItemTemplate_C")

function UMG_HavingItemTemplate_C:Initialize(Initializer)
end

function UMG_HavingItemTemplate_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_HavingItemTemplate_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_HavingItemTemplate_C:OnEnable()
end

function UMG_HavingItemTemplate_C:OnDisable()
end

function UMG_HavingItemTemplate_C:OnAddEventListener()
end

function UMG_HavingItemTemplate_C:OnRemoveEventListener()
end

function UMG_HavingItemTemplate_C:OnItemUpdate(data, datalist, index)
  self.index = index
  self.uiData = data
  self:updateItemInfo()
end

function UMG_HavingItemTemplate_C:updateItemInfo()
  if self.uiData.IsNullSlot and self.uiData.IsNullSlot == true then
    self:ChangeStateByIsHasSlot(UE4.ESlateVisibility.Hidden)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetClickable(false)
  else
    self:ChangeStateByIsHasSlot(UE4.ESlateVisibility.Visible)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:SetClickable(true)
    local bagItem = self.uiData.bagItem
    self:PlayAnimation(self.normal)
    if bagItem.level and bagItem.level > 0 then
      local Text = string.format("%d%s", bagItem.level, LuaText.umg_havingitemtemplate_1)
      self.NumText:SetText(Text)
      self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif bagItem.num ~= nil then
      self.NumText:SetText(bagItem.num)
      self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.NumText:SetText("")
    end
    self.ItemIcon:SetIconByBagItemID(bagItem.conf_id)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(bagItem.conf_id)
    if bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
    end
    self:ShowEquipPet()
  end
end

function UMG_HavingItemTemplate_C:ChangeStateByIsHasSlot(IsShow)
  self.Selected:SetVisibility(IsShow)
  self.TextBG:SetVisibility(IsShow)
  self.NumText:SetVisibility(IsShow)
  self.CanvasPanel_291:SetVisibility(IsShow)
  self.CanvasPanelTile:SetVisibility(IsShow)
  self.ItemIcon:SetVisibility(IsShow)
  self.BGColor:SetVisibility(IsShow)
end

function UMG_HavingItemTemplate_C:ShowEquipPet()
  if self.uiData.petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.petData.base_conf_id)
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.PetIcon:SetPath(modelConf.icon)
    self.PetIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.uiData.curPetData.gid == self.uiData.petData.gid then
      self.Inlay:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Inlay:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    self.CanvasPanelTile:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.CanvasPanelTile:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_HavingItemTemplate_C:Clear()
  self:PlayAnimation(self.normal)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NumText:SetText("")
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:SetQuality(1)
end

function UMG_HavingItemTemplate_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_HavingItemTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    self:PlayAnimation(self.select, 0, 9999)
  end
  if Animation == self.change2 then
  end
end

function UMG_HavingItemTemplate_C:OnItemSelected(selected)
  if self.uiData.IsNullSlot == nil then
    if selected then
      self:StopAllAnimations()
      self:PlayAnimation(self.change1)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_HavingItemTemplate_C:OnItemSelected")
      self:OnClick()
    else
      self:StopAllAnimations()
      self:PlayAnimation(self.change2)
    end
  end
end

function UMG_HavingItemTemplate_C:OnClick()
  if self.uiData and self.uiData.callbackCaller and self.uiData.callbackFunc then
    tcall(self.uiData.callbackCaller, self.uiData.callbackFunc, true, self.uiData)
  end
end

return UMG_HavingItemTemplate_C
