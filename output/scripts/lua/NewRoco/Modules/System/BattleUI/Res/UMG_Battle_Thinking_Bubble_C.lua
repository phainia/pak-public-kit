local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_Thinking_Bubble_C = _G.NRCPanelBase:Extend("UMG_Battle_Thinking_Bubble_C")

function UMG_Battle_Thinking_Bubble_C:IsShowThinking()
  if self.Switcher then
    return 0 == self.Switcher:GetActiveWidgetIndex()
  end
end

function UMG_Battle_Thinking_Bubble_C:ShowThinking(closeTime)
  self.Switcher:SetActiveWidgetIndex(0)
  self:Show()
  if closeTime and closeTime > 0 then
    self:DelaySeconds(closeTime, self.Hide, self)
  end
end

function UMG_Battle_Thinking_Bubble_C:ShowDoubt(closeTime)
  self.Switcher:SetActiveWidgetIndex(1)
  self:Show()
  if closeTime and closeTime > 0 then
    self:DelaySeconds(closeTime, self.Hide, self)
  end
end

function UMG_Battle_Thinking_Bubble_C:ShowEmoji(iconPath, teamEnum, closeTime)
  if teamEnum == BattleEnum.Team.ENUM_ENEMY then
    self.Switcher:SetActiveWidgetIndex(2)
    self.Icon:SetPath(iconPath)
  else
    self.Switcher:SetActiveWidgetIndex(3)
    self.EmojiImage:SetPath(iconPath)
  end
  self:Show()
  if closeTime and closeTime > 0 then
    self:DelaySeconds(closeTime, self.Hide, self)
  end
end

function UMG_Battle_Thinking_Bubble_C:Show()
  self.isHide = false
  self:StopAllAnimations()
  self:SetRenderOpacity(1)
  self:PlayAnimation(self.open)
end

function UMG_Battle_Thinking_Bubble_C:Hide()
  self.isHide = true
  self:StopAllAnimations()
  self:PlayAnimation(self.close)
end

function UMG_Battle_Thinking_Bubble_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    if self.isHide then
      self:SetRenderOpacity(0)
    end
  elseif Animation == self.open and not self.isHide then
    self:PlayAnimation(self.loop, 0, 10000)
  end
end

function UMG_Battle_Thinking_Bubble_C:IsValid()
  return self.Switcher and self.Icon
end

return UMG_Battle_Thinking_Bubble_C
