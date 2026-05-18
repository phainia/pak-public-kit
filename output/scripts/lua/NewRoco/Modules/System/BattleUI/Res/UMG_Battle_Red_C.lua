local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_Red_C = NRCPanelBase:Extend("UMG_Battle_Red_C")

function UMG_Battle_Red_C:OnConstruct()
  self:AddListener()
end

function UMG_Battle_Red_C:OnActive()
  if self:HasHPDefeatUI() then
    self:Hide()
  else
    self:Show()
  end
end

function UMG_Battle_Red_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.SHOW_HP_RED, BattleEvent.HIDE_HP_RED)
end

function UMG_Battle_Red_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_Red_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.SHOW_HP_RED then
    self:Show()
    return true
  elseif eventName == BattleEvent.HIDE_HP_RED then
    self:Hide()
    return true
  end
end

function UMG_Battle_Red_C.HasHPDefeatUI()
  local module = BattleUtils.GetBattleUIModule()
  if module then
    return module:HasPanel("BattleRoleHpDefeatedTipPanel")
  else
    return false
  end
end

function UMG_Battle_Red_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Blink, 0, 0)
end

function UMG_Battle_Red_C:Hide()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_Battle_Red_C:OnDestruct()
  self:RemoveListener()
end

return UMG_Battle_Red_C
