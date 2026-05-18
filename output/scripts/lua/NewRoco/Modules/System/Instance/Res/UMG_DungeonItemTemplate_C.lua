local UIUtils = require("NewRoco.Utils.UIUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DungeonItemTemplate_C = Base:Extend("UMG_DungeonItemTemplate_C")

function UMG_DungeonItemTemplate_C:OnConstruct()
  self.itemId = nil
end

function UMG_DungeonItemTemplate_C:OnDestruct()
end

function UMG_DungeonItemTemplate_C:OnItemUpdate(_data, datalist, index)
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(_data)
  if BagItemConf then
    self.itemId = _data
    self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(BagItemConf.icon, _G.UIIconPath.BagItemPath))
    UIUtils.SetIconQuality(self.BGColor, BagItemConf.item_quality)
  end
end

function UMG_DungeonItemTemplate_C:OnClick()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.itemId, _G.Enum.GoodsType.GT_BAGITEM, false, 0, 0, false, UE4.FVector2D(-360, 0))
end

function UMG_DungeonItemTemplate_C:OnDeactive()
end

return UMG_DungeonItemTemplate_C
