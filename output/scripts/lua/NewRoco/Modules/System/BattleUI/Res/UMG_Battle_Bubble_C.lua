local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_Bubble_C = _G.NRCPanelBase:Extend("UMG_Battle_Bubble_C")

function UMG_Battle_Bubble_C:Show()
  self.IsClosing = false
  self.EmojiList = {
    self.Bubble,
    self.Bubble_1,
    self.Bubble_2
  }
  self.EmojiList[1]:SetContent(1, self)
  self.EmojiList[1].Switcher:SetActiveWidgetIndex(0)
  self.EmojiList[2]:SetContent(2, self)
  self.EmojiList[2].Switcher:SetActiveWidgetIndex(2)
  self.EmojiList[3]:SetContent(3, self)
  self.EmojiList[3].Switcher:SetActiveWidgetIndex(1)
  self:HideEmoList(false)
  self:OnRemoveEventListener()
  self:OnAddEventListener()
  self:StopAllAnimations()
  self:PlayAnimation(self.open)
end

function UMG_Battle_Bubble_C:Hide()
  if not self.IsClosing then
    self.EmojiCanvas:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.Btn_Bubble:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Return:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:StopAllAnimations()
    self.IsClosing = true
    self:PlayAnimation(self.close)
  end
end

function UMG_Battle_Bubble_C:OnActive()
  self:Show()
end

function UMG_Battle_Bubble_C:OnDeactive()
  self.EmojiList = nil
  self.Bubble:Release()
  self.Bubble_1:Release()
  self.Bubble_2:Release()
  self.Bubble_3:Release()
  self.Bubble_4:Release()
  self.Bubble_5:Release()
end

function UMG_Battle_Bubble_C:ShowEmoList()
  self.IsShowList = true
  self.EmojiCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Btn_Bubble:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Btn_Return:SetVisibility(UE4.ESlateVisibility.Visible)
  for i = 1, #self.EmojiList do
    self.EmojiList[i]:Show()
  end
end

function UMG_Battle_Bubble_C:HideEmoList(isAnim)
  self.IsShowList = false
  self.WillHideCount = #self.EmojiList
  self.EmojiCanvas:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Btn_Bubble:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.Btn_Return and self.Btn_Return.SetVisibility then
    self.Btn_Return:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    Log.Error("zgx there has a error at UMG_Battle_Bubble_C , Btn_Return is nil!!")
  end
  for i = 1, #self.EmojiList do
    self.EmojiList[i]:Hide(isAnim)
  end
end

function UMG_Battle_Bubble_C:EmoItemHideOver()
  if not self.IsShowList and self.WillHideCount > 0 then
    self.WillHideCount = self.WillHideCount - 1
    if 0 == self.WillHideCount then
      _G.BattleEventCenter:Dispatch(BattleEvent.EMO_HIDE_OVER)
    end
  end
end

function UMG_Battle_Bubble_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.Btn_Bubble)
  self:RemoveButtonListener(self.Btn_Return)
end

function UMG_Battle_Bubble_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Bubble, self.OnClickEmoList)
  self:AddButtonListener(self.Btn_Return, self.OnClickEmoBack)
end

function UMG_Battle_Bubble_C:OnClickEmoList()
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_WAIT_EMO_LIST)
end

function UMG_Battle_Bubble_C:OnClickEmoBack()
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_WAIT_EMO_BACK)
end

function UMG_Battle_Bubble_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    if self.IsClosing then
      self:DoClose()
    else
      self:Show()
    end
  end
end

return UMG_Battle_Bubble_C
