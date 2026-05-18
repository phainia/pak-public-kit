local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ExploreThings_Item_C = Base:Extend("UMG_ExploreThings_Item_C")

function UMG_ExploreThings_Item_C:OnConstruct()
end

function UMG_ExploreThings_Item_C:OnDestruct()
end

function UMG_ExploreThings_Item_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  local path = ""
  if _data.collectType == Enum.DungeonCollectionType.DCT_TREASURE_MIDBOX then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/5.5'"
  elseif _data.collectType == Enum.DungeonCollectionType.DCT_TREASURE_MAXBOX then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/4.4'"
  elseif _data.collectType == Enum.DungeonCollectionType.DCT_TREASURE_STAR_BLUE then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100629.100629'"
  elseif _data.collectType == Enum.DungeonCollectionType.DCT_TREASURE_STAR_YELLOW then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100679.100679'"
  elseif _data.collectType == Enum.DungeonCollectionType.DCT_TREASURE_COIN then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100662.100662'"
  end
  self.Icon:SetPath(path)
  if _data.curNum >= _data.needNum then
    self.Text_Time_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FF901DFF"))
  end
  self.Text_Time_1:SetText(_data.curNum .. "/" .. _data.needNum)
end

function UMG_ExploreThings_Item_C:OnItemSelected(_bSelected)
end

function UMG_ExploreThings_Item_C:OnDeactive()
end

return UMG_ExploreThings_Item_C
