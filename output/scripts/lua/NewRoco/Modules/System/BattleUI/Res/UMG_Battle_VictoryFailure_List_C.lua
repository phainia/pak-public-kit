local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local UMG_Battle_VictoryFailure_List_C = Base:Extend("UMG_Battle_VictoryFailure_List_C")

function UMG_Battle_VictoryFailure_List_C:OnConstruct()
end

function UMG_Battle_VictoryFailure_List_C:OnDestruct()
  self:CancelDelay()
end

function UMG_Battle_VictoryFailure_List_C:OnItemUpdate(_data, datalist, index)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:CancelDelay()
  self.delayShowAnimId = _G.DelayManager:DelaySeconds((index - 1) * 0.05, self.DelayShowAnim, self)
  self.Describe:SetText(_data.des)
  self.Switcher:SetActiveWidgetIndex(_data.type)
  if 1 == _data.type then
    self.List:InitGridView(_data.Department)
  else
    self.Quantity:SetText(_data.Str)
  end
end

function UMG_Battle_VictoryFailure_List_C:CancelDelay()
  if self.delayShowAnimId then
    _G.DelayManager:CancelDelay(self.delayShowAnimId)
  end
  self.delayShowAnimId = nil
end

function UMG_Battle_VictoryFailure_List_C:DelayShowAnim()
  if self and UE4.UObject.IsValid(self) then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.In)
  end
  self.delayShowAnimId = nil
end

function UMG_Battle_VictoryFailure_List_C:OnItemSelected(_bSelected)
end

function UMG_Battle_VictoryFailure_List_C:OnDeactive()
  self:CancelDelay()
end

function UMG_Battle_VictoryFailure_List_C:OnTick()
end

function UMG_Battle_VictoryFailure_List_C:OnLogin()
end

function UMG_Battle_VictoryFailure_List_C:OnAnimationFinished(anim)
end

function UMG_Battle_VictoryFailure_List_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Battle_VictoryFailure_List_C
