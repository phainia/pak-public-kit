local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Friend_EmojiTAB_C = Base:Extend("UMG_Friend_EmojiTAB_C")

function UMG_Friend_EmojiTAB_C:OnConstruct()
end

function UMG_Friend_EmojiTAB_C:OnDestruct()
end

function UMG_Friend_EmojiTAB_C:OnItemUpdate(_data, datalist, index)
  self.UiData = _data
  self.parent = _data.parent
  self.Icon_Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Icon:SetPath(self.UiData.icon)
end

function UMG_Friend_EmojiTAB_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Icon_Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.parent:InitEmoList(self.UiData.type)
  else
    self.Icon_Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Friend_EmojiTAB_C:OnDeactive()
end

return UMG_Friend_EmojiTAB_C
