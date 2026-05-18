local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_GorgeousMagic_C = _G.NRCPanelBase:Extend("UMG_GorgeousMagic_C")

function UMG_GorgeousMagic_C:OnConstruct()
  self.pageIndex = -1
  self.pageCount = 0
  self.sutiId = 0
end

function UMG_GorgeousMagic_C:OnDestruct()
end

function UMG_GorgeousMagic_C:OnActive(_suitId)
  self:_OnAddEventListener()
  self:_SetSuitId(_suitId)
end

function UMG_GorgeousMagic_C:OnDeactive()
  self:_OnRemoveEventListener()
end

function UMG_GorgeousMagic_C:_OnAddEventListener()
  self:AddButtonListener(self.Btn_Close, self._OnClickCloseBtn)
  self:AddButtonListener(self.Btn_Left, self._OnClickPrevBtn)
  self:AddButtonListener(self.Btn_Right, self._OnClickNextBtn)
  self:RegisterEvent(self, AppearanceModuleEvent.GorgeousMagicSuitIdChanged, self._OnEvent_GorgeousMagicSuitIdChanged)
end

function UMG_GorgeousMagic_C:_OnRemoveEventListener()
  self:RemoveButtonListener(self.Btn_Close)
  self:RemoveButtonListener(self.Btn_Left)
  self:RemoveButtonListener(self.Btn_Right)
  self:UnRegisterEvent(self, AppearanceModuleEvent.GorgeousMagicSuitIdChanged)
end

function UMG_GorgeousMagic_C:_OnClickCloseBtn()
  self:DoClose()
end

function UMG_GorgeousMagic_C:_OnClickPrevBtn()
  self:_SetPage(self.pageIndex - 1)
end

function UMG_GorgeousMagic_C:_OnClickNextBtn()
  self:_SetPage(self.pageIndex + 1)
end

function UMG_GorgeousMagic_C:_SetPage(_pageIndex)
  if not _pageIndex then
    return
  end
  if 0 == self.pageCount then
    return
  end
  local _clampedIndex = math.min(self.pageCount, math.max(1, _pageIndex))
  if self.pageIndex ~= _clampedIndex then
    self.pageIndex = _clampedIndex
    self:_OnPageIndexChanged()
  end
end

function UMG_GorgeousMagic_C:_SetPageCount(_pageCount)
  self.pageCount = _pageCount
  self:_SetPage(self.pageIndex)
end

function UMG_GorgeousMagic_C:_SetSuitId(_suitId)
  if _suitId and self.suitId ~= _suitId then
    self.suitId = _suitId
    self:_OnSuitIdChanged()
  end
end

function UMG_GorgeousMagic_C:_OnEvent_GorgeousMagicSuitIdChanged(_suitId)
  self:_SetSuitId(_suitId)
end

function UMG_GorgeousMagic_C:_OnSuitIdChanged()
  self:_RefreshCurrentPageContent()
end

function UMG_GorgeousMagic_C:_OnPageIndexChanged()
  self:_RefreshCurrentPageContent()
end

function UMG_GorgeousMagic_C:_RefreshCurrentPageContent()
  local _suitConf = _G.DataConfigManager:GetFashionSuitsConf(self.suitId)
  if _suitConf then
    self:_SetPageCount(#_suitConf.suit_effect_tips)
  end
  if _suitConf then
    self:_RefreshDotList(_suitConf)
    local _effectTipConf = _suitConf.suit_effect_tips[self.pageIndex]
    self:_RefreshTipContent(_effectTipConf)
  end
end

function UMG_GorgeousMagic_C:_RefreshDotList(_suitConf)
  local _tipsCount = #_suitConf.suit_effect_tips
  if _tipsCount > 1 then
    self.Dot_List:InitGridView(_suitConf.suit_effect_tips)
    self.Dot_List:SelectItemByIndex(self.pageIndex - 1)
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_GorgeousMagic_C:_RefreshTipContent(_effectTipConf)
  if _effectTipConf then
    self.Text1:SetText(_effectTipConf.tips_text)
    self.Picture.Image_35:SetPath(_effectTipConf.tips_image)
  else
    self.Text1:SetText("")
    self.Picture.Image_35:SetPath("")
  end
end

function UMG_GorgeousMagic_C:_RefreshPageBtns()
  self.Btn_Left:SetVisibility(1 == self.pageIndex and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  self.Btn_Right:SetVisibility(self.pageIndex == self.pageCount and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
end

return UMG_GorgeousMagic_C
