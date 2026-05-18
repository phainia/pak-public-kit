local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Battle_BuffInfoBox_C = Base:Extend("UMG_Battle_BuffInfoBox_C")

function UMG_Battle_BuffInfoBox_C:OnConstruct()
end

function UMG_Battle_BuffInfoBox_C:OnDestruct()
end

function UMG_Battle_BuffInfoBox_C:OnItemUpdate(_data)
  self.buffDataList = _data
  self.setupMax = #self.buffDataList.list
  self.setupCount = 0
  self.setupMaxDefault = 3
  self.isSet = false
  self.buffInfo = self.buffDataList.handler
  self:InsertBuffInfo()
end

function UMG_Battle_BuffInfoBox_C:SetScrollView(scrollView)
  Base.SetScrollView(self, scrollView)
  self.scrollView = scrollView
end

function UMG_Battle_BuffInfoBox_C:TryCheckSize()
  self.buffInfo:ForceLayoutPrepass()
  local scrollView = self.scrollView
  if self.setupCount > self.setupMaxDefault then
    if self.isSet then
      Log.Debug("UMG_Battle_BuffInfoBox_C: Ready to Set")
      local vec = self.buffInfo.ScaleSizeBox:GetDesiredSize()
      vec.Y = self.BuffInfoListingBox:GetDesiredSize().Y
      return
    else
      self.isSet = true
      self.buffInfo.ScaleSizeBox:SetHeightOverride(self.BuffInfoListingBox:GetDesiredSize().Y)
      self.buffInfo.ScaleSizeBox:SetWidthOverride(self.BuffInfoListingBox:GetDesiredSize().X)
      local vec = self.buffInfo.ScaleSizeBox:GetDesiredSize()
      local scrollViewSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(scrollView)
      vec.Y = self.BuffInfoListingBox:GetDesiredSize().Y - 16
      vec.X = self.BuffInfoListingBox:GetDesiredSize().X
      scrollViewSlot:SetSize(vec)
      Log.Debug("UMG_Battle_BuffInfoBox_C: Wait for another Tick")
      return
    end
  elseif self.setupCount >= self.setupMax then
    if self.isSet then
      Log.Debug("UMG_Battle_BuffInfoBox_C: Ready to Set")
      self.buffInfo.ScaleSizeBox:SetHeightOverride(self.BuffInfoListingBox:GetDesiredSize().Y)
      self.buffInfo.ScaleSizeBox:SetWidthOverride(self.BuffInfoListingBox:GetDesiredSize().X)
      local vec = self.buffInfo.ScaleSizeBox:GetDesiredSize()
      local scrollViewSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(scrollView)
      vec.Y = self.BuffInfoListingBox:GetDesiredSize().Y
      vec.X = self.BuffInfoListingBox:GetDesiredSize().X
      scrollViewSlot:SetSize(vec)
      return
    else
      self.isSet = true
      Log.Debug("UMG_Battle_BuffInfoBox_C: Wait for another Tick")
      return
    end
  else
    return
  end
end

function UMG_Battle_BuffInfoBox_C:OnPaint(Context)
  Base.OnPaint(self, Context)
end

function UMG_Battle_BuffInfoBox_C:InsertBuffInfo()
  _G.BattleResourceManager:LoadRes(self, _G.UEPath.UMG_Battle_BuffInfoItem_C, self.LoadBuffOver)
end

function UMG_Battle_BuffInfoBox_C:LoadBuffOver(res)
  if not UE4.UObject.IsValid(self) then
    return
  end
  local count = #self.buffDataList.list
  for i, v in ipairs(self.buffDataList.list) do
    local buffInfoItemModel = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), res)
    buffInfoItemModel:UpdateBuffInoItem(self, v)
    if i == count then
      buffInfoItemModel.line:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      buffInfoItemModel.line:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    if 0 == i % 2 then
      buffInfoItemModel.BG:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      buffInfoItemModel.BG:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    if self.BuffInfoListingBox then
      self.BuffInfoListingBox:AddChildToVerticalBox(buffInfoItemModel)
    end
  end
end

return UMG_Battle_BuffInfoBox_C
