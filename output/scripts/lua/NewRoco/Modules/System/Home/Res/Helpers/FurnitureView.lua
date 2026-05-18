local FurnitureHoverView = Class("FurnitureHoverView")

function FurnitureHoverView:Ctor()
  self.IconView = nil
  self.NameView = nil
  self.ComfortView = nil
  self.XNumView = nil
end

function FurnitureHoverView:BindIconView(IconView)
  self.IconView = IconView
end

function FurnitureHoverView:BindQualityColorView(QualityColorView)
  self.QualityColorView = QualityColorView
end

function FurnitureHoverView:BindQualityColorBgIcon(QualityColorBg)
  self.QualityColorBg = QualityColorBg
end

function FurnitureHoverView:BindNameView(NameView)
  self.NameView = NameView
end

function FurnitureHoverView:BindComfortValueView(ComfortView)
  self.ComfortView = ComfortView
  ComfortView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function FurnitureHoverView:BindXNumView(XNumView)
  self.XNumView = XNumView
end

function FurnitureHoverView:SetInCombination(bInCombination)
  self.bInCombination = bInCombination
end

function FurnitureHoverView:SetEnableCombinationName(bEnableCombinationName)
  self.bEnableCombinationName = bEnableCombinationName
end

function FurnitureHoverView:BindCombinationTag(Tag)
  self.CombinationTag = Tag
end

function FurnitureHoverView:SetFurnitureItemConf(Conf)
  self.FurnitureItemConf = Conf
  if self.IconView then
    if Conf.icon and Conf.icon ~= "noicon" then
      self.IconView:SetPath(Conf.icon)
    end
    self.IconView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.NameView then
    if self.bInCombination and self.bEnableCombinationName then
      self.NameView:SetText(string.format(LuaText.furniture_storage_unit, Conf.name or ""))
    else
      self.NameView:SetText(Conf.name or "")
    end
    self.NameView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.ComfortView then
    self.ComfortView:SetText(tostring(Conf.comfort or 0))
    self.ComfortView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.CombinationTag then
    if self.bInCombination then
      self.CombinationTag:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.CombinationTag:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if self.QualityColorView or self.QualityColorBg then
    local BagItemConf = DataConfigManager:GetBagItemConf(Conf.id)
    if self.QualityColorBg then
      self.QualityColorBg:SetPath(HomeIndoorSandbox.Enum.GetHomeItemQualityBgIcon(BagItemConf and BagItemConf.item_quality))
    end
    if self.QualityColorView then
      self.QualityColorView:SetColorAndOpacity(HomeIndoorSandbox.Enum.GetItemQualityColor(BagItemConf and BagItemConf.item_quality))
    end
  end
end

function FurnitureHoverView:SetInteriorFinishConf(Conf)
  if self.IconView and Conf.icon and Conf.icon ~= "noicon" then
    self.IconView:SetPath(Conf.icon)
  end
  if self.NameView then
    self.NameView:SetText(Conf.name or "")
  end
  if self.ComfortView then
    self.ComfortView:SetText(tostring(Conf.comfort or 0))
  end
  if self.QualityColorView then
    local BagItemConf = DataConfigManager:GetBagItemConf(Conf.id)
    self.QualityColorView:SetColorAndOpacity(HomeIndoorSandbox.Enum.GetItemQualityColor(BagItemConf and BagItemConf.item_quality))
  end
end

function FurnitureHoverView:SetFurnitureData(FurnitureData)
  self.FurnitureData = FurnitureData
  if FurnitureData.FurnitureItemConf then
    self:SetFurnitureItemConf(FurnitureData.FurnitureItemConf)
  else
    self:SetInteriorFinishConf(FurnitureData.InteriorFinishConf)
  end
  self:ResolveFurnitureNum()
end

function FurnitureHoverView:ResolveFurnitureNum()
  if self.FurnitureData.InteriorFinishConf then
    if self.XNumView then
      self.XNumView:SetText("")
    end
    return
  end
  if not self.FurnitureItemConf or not self.FurnitureData then
    if self.XNumView then
      self.XNumView:SetText("x0")
    end
    return
  end
  if self.XNumView then
    local Data = HomeIndoorSandbox.Module:GetData()
    local FurnitureData = self.FurnitureData or Data:GetFurnitureDataByConf(self.FurnitureItemConf)
    local Num = FurnitureData.RemainingNum or 0
    self.XNumView:SetText(string.format("x%s", Num))
  end
end

return FurnitureHoverView
