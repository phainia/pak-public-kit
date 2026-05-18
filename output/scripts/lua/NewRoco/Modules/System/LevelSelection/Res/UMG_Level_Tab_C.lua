local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_Level_Tab_C = Base:Extend("UMG_Level_Tab_C")

function UMG_Level_Tab_C:OnConstruct()
end

function UMG_Level_Tab_C:OnDestruct()
end

function UMG_Level_Tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.TextTab:SetText(_data.title)
end

function UMG_Level_Tab_C:OnItemSelected(_bSelected)
  if _bSelected and self.isSelect ~= true then
    _G.NRCModuleManager:GetModule("LevelSelectionModule"):DispatchEvent(LevelSelectionModuleEvent.OnChangeBattleTab, self.index)
  end
end

function UMG_Level_Tab_C:OnSelectAnimation()
  if not self.isSelect then
    self.isSelect = true
    self:PlayAnimation(self.select)
  end
end

function UMG_Level_Tab_C:OnUnSelectAnimation()
  if self.isSelect then
    self.isSelect = false
    self:PlayAnimationReverse(self.select)
  end
end

function UMG_Level_Tab_C:OnDeactive()
end

return UMG_Level_Tab_C
