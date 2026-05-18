local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattlePassModuleEvent = require("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_Pass_Award_Tab_C = Base:Extend("UMG_Pass_Award_Tab_C")

function UMG_Pass_Award_Tab_C:OnConstruct()
end

function UMG_Pass_Award_Tab_C:OnDestruct()
end

function UMG_Pass_Award_Tab_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
  local isRoutineTask = 1 == self.data.taskType
  local name = isRoutineTask and LuaText.bp_task_routine or LuaText.bp_task_activity
  self.Text_Period:SetText(name)
  if false == isRoutineTask then
    self.Dot:SetupKey(145)
  else
    self.Dot:SetupKey(144)
  end
  self:OnSwitcherSwitcher(0)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Button.OnPressed:Add(self, self.OnClickButton)
end

function UMG_Pass_Award_Tab_C:OnItemSelected(_bSelected)
end

function UMG_Pass_Award_Tab_C:PlayOutAnimation()
  if self.select then
    self:PlayAnimationReverse(self.Press)
  end
  self.select = false
end

function UMG_Pass_Award_Tab_C:PlaySelectAnimation()
  if not self.select then
    self:StopAllAnimations()
    self:PlayAnimation(self.Press)
  end
  self.select = true
end

function UMG_Pass_Award_Tab_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Pass_Award_Tab_C:GetExpireTimeDateString(time)
  if time <= 59 then
    if time <= 0 then
      return LuaText.umg_pass_award_tab_1
    else
      return LuaText.umg_pass_award_tab_2
    end
  end
  local day = math.floor(time / 86400)
  local hour = math.floor(time % 86400 / 3600)
  local minute = math.floor(time % 86400 % 3600 / 60)
  local str = ""
  if day > 0 then
    str = day .. LuaText.umg_pass_award_tab_3
  end
  if hour > 0 then
    str = str .. hour .. LuaText.umg_pass_award_tab_4
  end
  if minute > 0 then
    str = str .. minute .. LuaText.umg_pass_award_tab_5
  end
  return str
end

function UMG_Pass_Award_Tab_C:OnClickButton()
  if self.data.is_open == false then
    local canTirggerTips = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.CanAwardTablTipsTirgger)
    if false == canTirggerTips then
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(1060, "UMG_Pass_Award_Tab_C:OnClickButton")
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1220002006, "UMG_Pass_Award_Tab_C:OnClickButton")
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.SelectBattlePassWeekIndex, self.index, self.data)
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetActiveSelectWeekIndex, self.index)
end

return UMG_Pass_Award_Tab_C
