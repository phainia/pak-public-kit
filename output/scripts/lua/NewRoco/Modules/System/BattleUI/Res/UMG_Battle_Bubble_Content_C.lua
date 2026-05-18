local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_Bubble_Content_C = _G.NRCViewBase:Extend("UMG_Battle_Bubble_Content_C")

function UMG_Battle_Bubble_Content_C:SetContent(index, father)
  self.index = index
  self.animName = _G.DataConfigManager:GetBattleGlobalConfig("battle_trainer_action_boy_" .. tostring(index)).str
  self.EmojiImage:SetPath(_G.DataConfigManager:GetBattleGlobalConfig("battle_trainer_emoji" .. tostring(index)).str)
  self.father = father
  self:OnRemoveEventListener()
  self:OnAddEventListener()
  if self.Btn and self.SetStyle then
    self.Btn:SetStyle()
  end
end

function UMG_Battle_Bubble_Content_C:Destruct()
  self.father = nil
  NRCViewBase.Destruct(self)
end

function UMG_Battle_Bubble_Content_C:OnAddEventListener()
  self:AddButtonListener(self.Btn, self.OnClickEmo)
end

function UMG_Battle_Bubble_Content_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.Btn)
end

function UMG_Battle_Bubble_Content_C:Show(isAnim)
  self:SetRenderOpacity(1)
  self:StopAllAnimations()
  self:PlayAnimation(self.open)
end

function UMG_Battle_Bubble_Content_C:Hide(isAnim)
  if isAnim then
    self:StopAllAnimations()
    self:PlayAnimation(self.close)
  else
    self:SetRenderOpacity(0)
  end
end

function UMG_Battle_Bubble_Content_C:OnAnimationFinished(Animation)
  if Animation == self.close and self.father then
    self.father:EmoItemHideOver()
  end
end

function UMG_Battle_Bubble_Content_C:OnClickEmo()
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_WAIT_EMO, self.index)
end

return UMG_Battle_Bubble_Content_C
