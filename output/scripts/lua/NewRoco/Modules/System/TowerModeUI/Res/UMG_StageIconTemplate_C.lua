local Base = require("NewRoco.TUI.BP_ScrollViewItemBase_C")
local TowerModeEvent = reload("NewRoco.Modules.Core.TowerMode.TowerModeEvent")
local UMG_StageIconTemplate_C = Base:Extend("UMG_StageIconTemplate_C")

function UMG_StageIconTemplate_C:OnConstruct()
  self.SelectIndex = nil
end

function UMG_StageIconTemplate_C:OnDestruct()
  self.scrollView = nil
end

function UMG_StageIconTemplate_C:SetData(_data)
  Base.SetData(self, _data)
  self.uiData = _data
  self:OnAddEventListener()
  self:UpdateInfo()
end

function UMG_StageIconTemplate_C:OnAddEventListener()
  self.Btn.OnClicked:Add(self, self.OnClickBtn)
end

function UMG_StageIconTemplate_C:OnClickBtn()
  if self.SelectIndex == self._index then
    _G.NRCModuleManager:DoCmd(TowerModeCmd.OpenRewardPanel, self.uiData.RewardInfo)
  end
end

function UMG_StageIconTemplate_C:OnClickBtn_1()
  _G.NRCModuleManager:GetModule("TowerModeModule"):DispatchEvent(TowerModeEvent.OnClickTower, self._index)
end

function UMG_StageIconTemplate_C:UpdateInfo()
  self:SetTowerVisible()
  self:BGVisible()
end

function UMG_StageIconTemplate_C:SetTowerVisible()
  self.TowerCur_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TowerPost_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TowerPre_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TowerCur:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TowerPost:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TowerPre:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_StageIconTemplate_C:SelectState(SelectType)
  self.Switch:SetActiveWidgetIndex(SelectType)
  self:SetTowerVisible()
  self:SetLevelInfo(SelectType)
end

function UMG_StageIconTemplate_C:SetLevelInfo(SelectType)
  local uiData = self.uiData
  if 0 == SelectType then
    self.Level:SetText(uiData.LevelNumber)
    if 0 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(0)
      self.TowerCur:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif 1 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(1)
      self.TowerPost:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif -1 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(2)
      self.TowerPre:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.Level_1:SetText(uiData.LevelNumber)
    if 0 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(0)
      self.TowerCur_1:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif 1 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(1)
      self.TowerPost_1:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif -1 == uiData.IsPassType then
      self.state:SetActiveWidgetIndex(2)
      self.TowerPre_1:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_StageIconTemplate_C:BGVisible()
  self.widget:SetVisibility(UE4.ESlateVisibility.Visible)
  if -1 == self.uiData.stage then
    self.widget:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self:SelectState(1)
  end
end

function UMG_StageIconTemplate_C:SetScrollView(scrollView)
  Base.SetScrollView(self, scrollView)
  self.scrollView = scrollView
end

function UMG_StageIconTemplate_C:SetIndex(index)
  Base.SetIndex(self, index)
end

function UMG_StageIconTemplate_C:OnSelectionChange(_bSelected)
  if _bSelected then
    self.SelectIndex = self._index
    self:SelectState(0)
  else
    self.SelectIndex = nil
    self:SelectState(1)
  end
end

function UMG_StageIconTemplate_C:OnDeactive()
end

return UMG_StageIconTemplate_C
