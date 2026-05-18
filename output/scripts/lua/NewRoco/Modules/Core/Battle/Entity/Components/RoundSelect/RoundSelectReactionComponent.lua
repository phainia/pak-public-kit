local PopupData = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupData")
local PopupAttributeInfo = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupAttributeInfo")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = BattleComponent
local RoundSelectReactionComponent = BattleComponent:Extend("RoundSelectReactionComponent")

function RoundSelectReactionComponent:Ctor(owner)
  Base.Ctor(self)
  self.owner = owner
  self:Clear()
  self:SetEnable(true)
  self.battleManager = _G.BattleManager
  _G.BattleEventCenter:Bind(self, BattleEvent.PUSHBACK_CMD_SENT, BattleEvent.ROUND_STATE_SELECT)
end

function RoundSelectReactionComponent:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PUSHBACK_CMD_SENT then
    self:Deactivate()
    return true
  elseif eventName == BattleEvent.ROUND_STATE_SELECT then
    self:Activate()
    return true
  end
end

function RoundSelectReactionComponent:Init()
  if 0 ~= self.owner:GetNpcID() then
    self.npcCfg = _G.DataConfigManager:GetNpcConf(self.owner:GetNpcID())
  end
end

function RoundSelectReactionComponent:Activate()
  if self.npcCfg then
    self:Clear()
    self:SetEnable(true)
  end
end

function RoundSelectReactionComponent:Deactivate()
  if self.npcCfg then
    self:SetEnable(false)
    self:Clear()
  end
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

function RoundSelectReactionComponent:OnTick(deltaTime)
  self.timer = self.timer + deltaTime
  if self.npcCfg and self.triggerIdx <= #self.npcCfg.overtime_action then
    local overtimeAction = self.npcCfg.overtime_action[self.triggerIdx]
    if self.timer >= overtimeAction.overtime then
      self.triggerIdx = self.triggerIdx + 1
      self:PerformOvertimeAction(overtimeAction)
    end
  end
end

function RoundSelectReactionComponent:Clear()
  self.timer = 0
  self.triggerIdx = 1
end

function RoundSelectReactionComponent:PerformOvertimeAction(overtimeAction)
  if overtimeAction.overtime_act then
    self.owner.BubbleComponent:Play(nil, overtimeAction.overtime_act)
  end
  if overtimeAction.overtime_notify then
    self.owner:UpdateDialogBox(overtimeAction.overtime_notify)
    self.owner:ShowDialogBox()
    self.owner:HideEmoji()
    self.owner:HideSkillPrediction()
    local time = _G.DataConfigManager:GetGlobalConfigNumByKeyType("texbox_show_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 1000) / 1000
    self.delayId = _G.DelayManager:DelaySeconds(time, self.PerformDialogFinish, self)
  end
end

function RoundSelectReactionComponent:PerformDialogFinish()
  if not _G.BattleManager.isInBattle then
    return
  end
  self.owner:HideDialogBox()
  self.owner:TryShowThinking()
  self.owner:TryShowSkillPrediction()
end

return RoundSelectReactionComponent
