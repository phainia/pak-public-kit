local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoUseSkillCommand = Base:Extend("AutoUseSkillCommand")

function AutoUseSkillCommand:Ctor(skillId)
  Base.Ctor(self)
  self.SkillId = skillId
end

function AutoUseSkillCommand:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_STATE_SELECT)
end

function AutoUseSkillCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    if not BattleMain.isShowing then
      self:WaitToRepeat()
    elseif BattleMain._inPanelChanging then
      self:WaitToRepeat()
    elseif BattleMain._curOperateType == BattleEnum.Operation.ENUM_SKILL then
      local skillPanel = BattleMain.SkillPanel
      if skillPanel:IsVisible() then
        local skillList = skillPanel:GetItemList()
        local isClick = false
        for i = 1, #skillList do
          if skillList[i] and skillList[i].skill.skill_id == self.SkillId and not skillList[i].Mask:IsVisible() then
            isClick = true
            skillList[i]:_OnItemPressed()
            skillList[i]:_OnItemRelease()
            Log.Debug("BattleAutoTest \228\189\191\231\148\168\228\186\134\230\138\128\232\131\189 ", self.SkillId)
            break
          end
        end
        if not isClick then
          if skillPanel.GlobalSkillItem and skillPanel.GlobalSkillItem.skill.skill_id == self.SkillId and not skillPanel.GlobalSkillItem.Mask:IsVisible() then
            isClick = true
            skillPanel.GlobalSkillItem:_OnItemPressed()
            skillPanel.GlobalSkillItem:_OnItemRelease()
            Log.Debug("BattleAutoTest \228\189\191\231\148\168\228\186\134\230\138\128\232\131\189 ", self.SkillId)
          else
            self:WaitToRepeat()
          end
        end
      else
        self:WaitToRepeat()
      end
    else
      _G.BattleEventCenter:Dispatch(BattleEvent.CHANGE_OPERATE_TYPE, 4, true)
      self:WaitToRepeat()
    end
  else
    self:WaitToRepeat()
  end
end

function AutoUseSkillCommand:LogFinish()
  Log.Debug("BattleAutoTest  \228\189\191\231\148\168\230\138\128\232\131\189\231\187\147\230\157\159 ", self.SkillId)
end

function AutoUseSkillCommand:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function AutoUseSkillCommand:Break()
  Log.Error("BattleAutoTest.AutoUseSkillCommand \230\137\167\232\161\140\229\164\177\232\180\165 ,\232\166\129\228\189\191\231\148\168\231\154\132\230\138\128\232\131\189Id\228\184\186 ", self.SkillId)
  Base.Break(self)
end

function AutoUseSkillCommand:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_STATE_SELECT then
    self:CompleteCommand()
    return true
  end
end

return AutoUseSkillCommand
