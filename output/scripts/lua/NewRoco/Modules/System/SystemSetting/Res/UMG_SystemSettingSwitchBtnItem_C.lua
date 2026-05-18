local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSettingSwitchBtnItem_C = Base:Extend("UMG_SystemSettingSwitchBtnItem_C")

function UMG_SystemSettingSwitchBtnItem_C:OnConstruct()
  self.SelectBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_SystemSettingSwitchBtnItem_C:OnDestruct()
end

function UMG_SystemSettingSwitchBtnItem_C:OnItemUpdate(_data, datalist, index)
  self.bSelected = false
  self.bIsFirstSelect = true
  self.index = index
  self.uiData = _data
  self:InitInfo()
end

function UMG_SystemSettingSwitchBtnItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.bSelected == _bSelected then
      if self.uiData.Parent then
        self.uiData.Parent:SwitchBtnListSelected()
      end
      return
    end
    self.bSelected = true
    self.SelectBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select_In)
    if self.bIsFirstSelect then
      self.bIsFirstSelect = false
    elseif self.uiData.Call and self.uiData.selectHandler then
      self.uiData.selectHandler(self.uiData.Call)
    end
  else
    self.bSelected = false
    self:PlayAnimationReverse(self.Select_In)
  end
end

function UMG_SystemSettingSwitchBtnItem_C:OnDeactive()
end

function UMG_SystemSettingSwitchBtnItem_C:InitInfo()
  if self.uiData.btnText then
    self.Text:SetText(self.uiData.btnText)
    self.Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Text:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SystemSettingSwitchBtnItem_C:OnAnimationFinished(anim)
end

return UMG_SystemSettingSwitchBtnItem_C
