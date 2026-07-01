local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ExplanationDescriptionItem_C = Base:Extend("UMG_ExplanationDescriptionItem_C")

function UMG_ExplanationDescriptionItem_C:OnConstruct()
end

function UMG_ExplanationDescriptionItem_C:OnDestruct()
end

function UMG_ExplanationDescriptionItem_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  if nil == index then
    return
  end
  self.itemData = _data
  self.itemIndex = index
  self:UpdateView()
end

function UMG_ExplanationDescriptionItem_C:UpdateView()
  if self.itemData == nil or nil == self.itemIndex then
    return
  end
  if nil == self.itemData.eggTypeConfId then
    return
  end
  local eggTypeConf = _G.DataConfigManager:GetEggTypeConf(self.itemData.eggTypeConfId)
  if nil == eggTypeConf then
    return
  end
  self.TypeText:SetText(eggTypeConf.name)
  self.TypeText_1:SetText(eggTypeConf.ball_range_description)
  local typeIconPath = eggTypeConf.Icon
  if typeIconPath then
    self.Icon:SetPath(typeIconPath)
  end
end

function UMG_ExplanationDescriptionItem_C:OnItemSelected(_bSelected)
end

function UMG_ExplanationDescriptionItem_C:OnDeactive()
end

return UMG_ExplanationDescriptionItem_C
