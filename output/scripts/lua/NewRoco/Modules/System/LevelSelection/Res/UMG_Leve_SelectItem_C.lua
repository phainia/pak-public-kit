local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_SelectItem_C = Base:Extend("UMG_Leve_SelectItem_C")

function UMG_Leve_SelectItem_C:OnConstruct()
end

function UMG_Leve_SelectItem_C:OnDestruct()
end

function UMG_Leve_SelectItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_Leve_SelectItem_C:SetInfo()
  self.ScheduleList:InitGridView(self.data.targets)
  self.LevelSwitcher:SetActiveWidgetIndex(self.index - 1)
end

function UMG_Leve_SelectItem_C:SetDefeatState(DefeatState)
  if DefeatState == LevelSelectionEnum.DefeatState.Defeated then
    self.Hint:SetText(LuaText.challenge_text_40)
    self.ScheduleList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif DefeatState == LevelSelectionEnum.DefeatState.NotDefeated then
    self.Hint:SetText(LuaText.challenge_text_41)
    self.ScheduleList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif DefeatState == LevelSelectionEnum.DefeatState.Unlocked then
    self.Hint:SetText(LuaText.challenge_text_42)
    self.ScheduleList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Leve_SelectItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.SelectBossLevel, self.data)
  end
end

function UMG_Leve_SelectItem_C:OnDeactive()
end

return UMG_Leve_SelectItem_C
