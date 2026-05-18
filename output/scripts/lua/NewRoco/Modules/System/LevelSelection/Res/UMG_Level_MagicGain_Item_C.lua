local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Level_MagicGain_Item_C = Base:Extend("UMG_Level_MagicGain_Item_C")

function UMG_Level_MagicGain_Item_C:OnConstruct()
end

function UMG_Level_MagicGain_Item_C:OnDestruct()
end

function UMG_Level_MagicGain_Item_C:OnItemUpdate(_data, datalist, index)
  self.ruleId = _data
  self:PlayAnimation(self.Normal)
  local ruleConf = _G.DataConfigManager:GetBattleRuleConf(self.ruleId)
  if ruleConf then
    local curEquipId = self:GetCurEquipId()
    self.Equipped:SetVisibility(curEquipId == self.ruleId and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
    self.TextSkill:SetText(ruleConf.title)
    self.NRCTextDes_1:SetText(ruleConf.desc)
    self.SkillIcon:SetPath(ruleConf.icon)
  end
end

function UMG_Level_MagicGain_Item_C:GetCurEquipId()
  local BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if BossChallengeEventActivityObject and #BossChallengeEventActivityObject > 0 then
    local boss_challenge_data = BossChallengeEventActivityObject[1]:GetBossChallengeData()
    return boss_challenge_data.buff_rule_id
  end
  return 0
end

function UMG_Level_MagicGain_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCurSelectRuleBuffId, self.ruleId)
    self:PlayAnimation(self.Select)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_Level_MagicGain_Item_C:OnDeactive()
end

function UMG_Level_MagicGain_Item_C:OnAnimationFinished(anim)
end

return UMG_Level_MagicGain_Item_C
