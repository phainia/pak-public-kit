local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local UMG_Leve_CameraShot_Item_C = Base:Extend("UMG_Leve_CameraShot_Item_C")

function UMG_Leve_CameraShot_Item_C:OnConstruct()
end

function UMG_Leve_CameraShot_Item_C:OnDestruct()
end

function UMG_Leve_CameraShot_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_Leve_CameraShot_Item_C:SetInfo()
  local data = self.data
  self.TextSerialNumber:SetText(self.data.Text)
  self.Accomplish:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetClickable(true)
  if data.DefeatState then
    if data.DefeatState == LevelSelectionEnum.DefeatState.Defeated then
      self.Accomplish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_139:SetActiveWidgetIndex(1)
    elseif data.DefeatState == LevelSelectionEnum.DefeatState.NotDefeated then
      self.Accomplish:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NRCSwitcher_139:SetActiveWidgetIndex(1)
    elseif data.DefeatState == LevelSelectionEnum.DefeatState.Unlocked then
      self.NRCSwitcher_139:SetActiveWidgetIndex(0)
      self:SetClickable(false)
    end
  end
  local targets = self:GetTargetsInfo()
  self.ScheduleList:InitGridView(targets)
  self:StopAllAnimations()
  self:PlayAnimation(self.UnChange)
end

function UMG_Leve_CameraShot_Item_C:GetTargetsInfo()
  local TargetList = {}
  local finishNum = 0
  for i, Target in ipairs(self.data.targets) do
    table.insert(TargetList, Target)
    if Target.is_finish then
      finishNum = finishNum + 1
    end
    TargetList[i].is_finish = false
  end
  for i = 1, finishNum do
    TargetList[i].is_finish = true
  end
  return TargetList
end

function UMG_Leve_CameraShot_Item_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.change1)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.SelectCameraShotItem, self.data)
  elseif self.NRCImage:GetRenderOpacity() > 0 then
    self:PlayAnimation(self.UnChange)
  end
end

function UMG_Leve_CameraShot_Item_C:OnDeactive()
end

return UMG_Leve_CameraShot_Item_C
