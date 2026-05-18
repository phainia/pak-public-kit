local UMG_MechanismValidation_C = _G.NRCPanelBase:Extend("UMG_MechanismValidation_C")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")

function UMG_MechanismValidation_C:OnActive(ActiveType, NpcChallengeInfo, caller, callBack)
  if not NpcChallengeInfo then
    _G.DelayManager:DelayFrames(1, self.DoClose, self)
    return
  end
  if 0 == not NpcChallengeInfo.activity_id then
    self:OnClickBtn()
    return
  end
  self.BuffId = NpcChallengeInfo.buff_id
  self.EventId = NpcChallengeInfo.event_id
  self.ActiveId = NpcChallengeInfo.activity_id
  self.ActivityConf = _G.DataConfigManager:GetActivityConf(self.ActiveId)
  if not self.ActivityConf then
    Log.Error("\230\180\187\229\138\168\230\149\176\230\141\174\229\188\130\229\184\184\239\188\140\230\151\160\230\179\149\232\142\183\229\143\150\230\180\187\229\138\168\230\149\176\230\141\174 \230\180\187\229\138\168ID=", NpcChallengeInfo.activity_id)
    return
  end
  self.ActiveType = self.ActivityConf.activity_type
  self.ChallengeLevelId = NpcChallengeInfo.challenge_level_id
  self.caller = caller
  self.callBack = callBack
  self:SetPanelInfo()
  self:OnAddEventListener()
end

function UMG_MechanismValidation_C:OnDeactive()
  self:SetPlayerMove(true)
  self:DoCallBack()
end

function UMG_MechanismValidation_C:DoCallBack()
  if self.caller and self.callBack then
    self.callBack(self.caller)
  end
  self.caller = nil
  self.callBack = nil
end

function UMG_MechanismValidation_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.btnCloseRenamePanel, self.OnClickBtn)
  self:RemoveButtonListener(self.ThisWeek, self.OnClickThisWeek)
  self:RemoveButtonListener(self.Opponent, self.OnClickOpponent)
end

function UMG_MechanismValidation_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnClickBtn)
  self:AddButtonListener(self.ThisWeek, self.OnClickThisWeek)
  self:AddButtonListener(self.Opponent, self.OnClickOpponent)
end

function UMG_MechanismValidation_C:SetPlayerMove(enabled)
end

function UMG_MechanismValidation_C:SetPanelInfo()
  self:LoadAnimation(0)
  self:SetPlayerMove(false)
  if self.ActiveType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    self:SetNpcChallengeInfo()
  else
    self:SetBossChallengeInfo()
  end
end

function UMG_MechanismValidation_C:SetNpcChallengeInfo()
  self.CharacterPnael_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CharacterPnael:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CharacterPnael_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local baseId = self.ActivityConf.base_id[1]
  local NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(baseId)
  local curRule = NpcChallengeEventConf.rule[1]
  local ruleConf = _G.DataConfigManager:GetBattleRuleConf(curRule)
  self.TextOpponent:SetText(ruleConf.desc)
  local ChallengeConf = _G.DataConfigManager:GetNpcChallengeConf(self.ChallengeLevelId)
  self.NRCText_50:SetText(LuaText.challenge_text_27)
  local enemyRule = ChallengeConf.rule[1]
  ruleConf = _G.DataConfigManager:GetBattleRuleConf(enemyRule)
  self.TextThisWeek:SetText(ruleConf.desc)
  self.NRCText_104:SetText(LuaText.challenge_text_26)
end

function UMG_MechanismValidation_C:SetBossChallengeInfo()
  self.CharacterPnael_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.CharacterPnael:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CharacterPnael_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local ruleDescList = {}
  local buffDescList = {}
  local BossChallengeConf = _G.DataConfigManager:GetBossChallengeConf(self.ChallengeLevelId)
  for i = 1, #BossChallengeConf.description do
    local description = BossChallengeConf.description[i]
    table.insert(ruleDescList, {des = description})
  end
  if BossChallengeConf.rule then
    for _, ruleId in pairs(BossChallengeConf.rule) do
      local ruleConf = _G.DataConfigManager:GetBattleRuleConf(ruleId)
      table.insert(buffDescList, {
        ruleConf = ruleConf,
        petbaseId = BossChallengeConf.petbase
      })
    end
  end
  self.BuffList:InitGridView(buffDescList)
  self.DescribeList:InitGridView(ruleDescList)
  local baseId = self.ActivityConf.base_id[1]
  local EventConf = _G.DataConfigManager:GetBossChallengeEventConf(baseId)
  if EventConf and EventConf.rule and #EventConf.rule > 0 then
    self.RuleConf = _G.DataConfigManager:GetBattleRuleConf(EventConf.rule[1])
  end
  self.NRCText_196:SetText(LuaText.challenge_text_22)
  self.NRCText_50:SetText(LuaText.challenge_text_27)
  self.CharacterPnael:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.RuleConf then
    self.CharacterPnael_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextOpponent:SetText(self.RuleConf.desc)
  else
    self.CharacterPnael_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MechanismValidation_C:OnTick()
end

function UMG_MechanismValidation_C:OnLogin()
end

function UMG_MechanismValidation_C:OnConstruct()
end

function UMG_MechanismValidation_C:OnDestruct()
end

function UMG_MechanismValidation_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
    _G.BattleEventCenter:Dispatch(BattleEvent.MechanismValidationClosed)
  end
end

function UMG_MechanismValidation_C:OnClickBtn()
  self:LoadAnimation(2)
end

function UMG_MechanismValidation_C:OnClose()
end

function UMG_MechanismValidation_C:OnClickThisWeek()
end

function UMG_MechanismValidation_C:OnClickOpponent()
end

return UMG_MechanismValidation_C
