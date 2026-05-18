local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MagicManualModuleEvent = reload("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_CompletionProgress_C = Base:Extend("UMG_CompletionProgress_C")

function UMG_CompletionProgress_C:OnConstruct()
end

function UMG_CompletionProgress_C:OnDestruct()
end

function UMG_CompletionProgress_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetClickable(true)
  self:SetState(self.uiData.state)
  if self.uiData.chapterConfData then
    self.RedDot:SetupKey(432, self.uiData.chapterConfData.id)
  else
    self.RedDot:SetupKey(165, self.uiData.id)
  end
end

function UMG_CompletionProgress_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.select)
    if self.uiData then
      if self.uiData.chapterConfData then
        _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OnOpenSeasonManualPanel, self.uiData.chapterConfData.id)
      else
        _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.SelectMagicChapter, self.uiData.id)
      end
    end
  else
    self:StopAllAnimations()
    self:PlayAnimationReverse(self.select)
  end
end

function UMG_CompletionProgress_C:SetState(state)
  if 0 == state then
    self.Switcher:SetActiveWidgetIndex(0)
  elseif 1 == state then
    self.Switcher:SetActiveWidgetIndex(1)
  elseif 2 == state then
    self.Switcher:SetActiveWidgetIndex(2)
  elseif 3 == state then
    self.Switcher:SetActiveWidgetIndex(3)
    self:SetClickable(false)
  end
end

function UMG_CompletionProgress_C:OnDeactive()
end

function UMG_CompletionProgress_C:OnTouchEnded(MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

return UMG_CompletionProgress_C
