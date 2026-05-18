local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_PastActivity_Item_C = Base:Extend("UMG_PastActivity_Item_C")

function UMG_PastActivity_Item_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_PastActivity_Item_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_PastActivity_Item_C:OnItemUpdate(_data, datalist, index)
  Base.OnItemUpdate(self, _data, datalist, index)
  local angles = {
    -3,
    -0.2,
    2.5,
    0
  }
  local slot = (index - 1) % #angles
  self:SetRenderTransformAngle(angles[slot + 1])
end

function UMG_PastActivity_Item_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  self:PlaySelectAnimation(_bSelected)
end

function UMG_PastActivity_Item_C:SetImagePath(_imagePath)
  self.Pet:SetPath(_imagePath)
end

function UMG_PastActivity_Item_C:SetRedPoint(_key, _extraKey)
  self.RedDot:SetupKey(_key, _extraKey)
end

function UMG_PastActivity_Item_C:SetSerialNumber(num)
  if num then
    self.TextSerialNumber:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextSerialNumber:SetText(string.format("%03d", num))
  else
    self.TextSerialNumber:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PastActivity_Item_C:SetTimeStr(timeStr)
  self.TextTime:SetText(timeStr)
end

function UMG_PastActivity_Item_C:PlayInAnimation()
  self:TryPlayAnimation(self.In, false, 0)
end

function UMG_PastActivity_Item_C:PlaySelectAnimation(_bSelected)
  if _bSelected then
    self:TryPlayAnimation(self.Reward_ready_loop, false, 0, true)
  else
    self:TryStopAnimation()
    self:TryPlayAnimation(self.normal, false, 0)
  end
end

return UMG_PastActivity_Item_C
