local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RelationTree_Dazzling_Item_C = Base:Extend("UMG_RelationTree_Dazzling_Item_C")
local UIUtils = require("NewRoco.Utils.UIUtils")

function UMG_RelationTree_Dazzling_Item_C:OnConstruct()
end

function UMG_RelationTree_Dazzling_Item_C:OnDestruct()
end

function UMG_RelationTree_Dazzling_Item_C:OnItemUpdate(_data, datalist, index)
  self.itemConf = _data
  self:InitPanel()
end

function UMG_RelationTree_Dazzling_Item_C:InitPanel()
  if self.itemConf then
    local itemQuality = self.itemConf.item_quality
    if 5 == itemQuality then
      self.Selected:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/AppearanceNew/Frames/img_xuancai_cheng_png.img_xuancai_cheng_png'")
    elseif 4 == itemQuality then
      self.Selected:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Appearance/Raw/AppearanceNew/Frames/img_xuancai_zi_png.img_xuancai_zi_png'")
    end
    UIUtils.SetIconQualityColor(self.QualityColor, itemQuality)
    local icon = self.itemConf.icon
    self.Icon:SetPath(icon)
    local name = self.itemConf.type_name
    self.SuitName:SetText(name)
  end
end

function UMG_RelationTree_Dazzling_Item_C:OnItemSelected(_bSelected)
end

function UMG_RelationTree_Dazzling_Item_C:OnDeactive()
end

return UMG_RelationTree_Dazzling_Item_C
