local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_StateWatch_Item_C = Base:Extend("UMG_StateWatch_Item_C")

function UMG_StateWatch_Item_C:OnConstruct()
end

function UMG_StateWatch_Item_C:OnDestruct()
end

function UMG_StateWatch_Item_C:OnItemUpdate(_data, datalist, index)
  Log.Dump(_data, 3, "UMG_TUIList_C:BindData")
  self.index = index
  self.data = _data
  self:ShowItem()
end

function UMG_StateWatch_Item_C:OnItemSelected(_bSelected)
  self:ToggleDetail(_bSelected)
end

function UMG_StateWatch_Item_C:ToggleDetail(selected)
  if selected then
    if self.detail then
      self:ShowItem()
    else
      self:ShowDetail()
    end
  else
    if self.data == nil then
      return
    end
    self:ShowItem()
  end
end

function UMG_StateWatch_Item_C:ShowItem()
  self.detail = false
  local str = self.data.text
  self.Text:SetText(str)
  local str1 = self.data.text1
  self.Text_2:SetText(str1)
end

function UMG_StateWatch_Item_C:ShowDetail()
  Log.Warning("\229\177\149\231\164\186\231\187\134\232\138\130")
  self.detail = true
  local Item = self.data
  local str = Item.text .. "\n" .. Item.text3 .. "\n" .. Item.text3 .. "\n" .. Item.text3
  local str1 = Item.text1 .. "\n" .. Item.text4 .. "\n" .. Item.text3 .. "\n" .. Item.text3
  self.Text:SetText(str)
  self.Text_2:SetText(str1)
end

function UMG_StateWatch_Item_C:OnDeactive()
end

return UMG_StateWatch_Item_C
