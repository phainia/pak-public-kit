local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local UMG_Handbook_Subject_Item2_C = _G.NRCViewBase:Extend("UMG_Handbook_Subject_Item2_C")

function UMG_Handbook_Subject_Item2_C:OnActive(info)
  self.data = info
  if self.tipsToogle == true then
    self:OnTipsOpenOrClose(false, index)
  end
  self.tipsToogle = false
  local switchIndex = 1 == info.state and 1 or 0
  self.NRCImage_1:SetVisibility(2 == info.state and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Switcher_2:SetActiveWidgetIndex(switchIndex)
  local dataList = {}
  for i, handReward in pairs(info.reward.pet_handbook_reward) do
    if handReward.award_type ~= _G.Enum.PetHandbookAward.AWARD_CATCH then
      local reward = {}
      reward.id = handReward.award_id
      reward.type = handReward.award_type
      reward.num = handReward.award_count
      table.insert(dataList, reward)
    end
  end
  self.Icon_List:InitGridView(dataList)
  self.Class:SetText(info.reward.pet_topic_complete_num)
  self.Dot:EnableAnimation()
  local redId = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OnCmdGetCurAreaHandBookRedId, 1, 4)
  self.Dot:SetupKey(redId, {
    info.handbookId,
    info.index
  })
end

function UMG_Handbook_Subject_Item2_C:OnDeactive()
  self:UnRegisterEvent(self, HandbookModuleEvent.OnSubjectTipsOpenOrClose, self.OnTipsOpenOrClose)
end

function UMG_Handbook_Subject_Item2_C:OnAddEventListener()
  self:AddButtonListener(self.Button_259, self.OnBtnClick)
  self:RegisterEvent(self, HandbookModuleEvent.OnSubjectTipsOpenOrClose, self.OnTipsOpenOrClose)
end

function UMG_Handbook_Subject_Item2_C:OnBtnClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_Handbook_Subject_Item2_C:OnBtnClick")
  if self:IsPlayingReceive() then
    return
  end
  if 0 == self.data.state then
    self:PlayAnimation(self.Receive)
    self:DispatchEvent(HandbookModuleEvent.OnSubjectTipsOpenOrClose, false)
    return
  elseif 1 == self.data.state then
  elseif 2 == self.data.state then
  end
  self:ToggleTips()
end

function UMG_Handbook_Subject_Item2_C:IsPlayingReceive()
  return self:IsAnimationPlaying(self.Receive)
end

function UMG_Handbook_Subject_Item2_C:SetLine(index, distance)
  local size = self.NRCImage_4.Slot:GetSize()
  self:StopAllAnimations()
  self:PlayAnimation(self.Default)
  self.NRCImage_4.Slot:SetSize(UE4.FVector2D(distance, size.y))
  if 1 == index % 2 then
    self.NRCImage_4:SetRenderTransformAngle(-15)
  else
    self.NRCImage_4:SetRenderTransformAngle(15)
  end
end

function UMG_Handbook_Subject_Item2_C:OnTipsOpenOrClose(tipsToogle, index)
  if self.data == nil then
    return
  end
  if self.tipsToogle ~= tipsToogle then
    if true == tipsToogle then
      if self.data.index == index then
        self.tipsToogle = tipsToogle
        self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self:PlayAnimation(self.Tips_in)
      elseif self.tipsToogle ~= false then
        self.tipsToogle = false
        self:PlayAnimation(self.Tips_out)
      end
    else
      self.tipsToogle = false
      self:PlayAnimation(self.Tips_out)
    end
  elseif self.tipsToogle == true then
    self.tipsToogle = false
    self:PlayAnimation(self.Tips_out)
  end
end

function UMG_Handbook_Subject_Item2_C:ToggleTips()
  if self:IsAnimationPlaying(self.Tips_in) or self:IsAnimationPlaying(self.Tips_out) then
    return
  end
  _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnSubjectTipsOpenOrClose, true, self.data.index)
end

function UMG_Handbook_Subject_Item2_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Handbook_Subject_Item2_C:OnAnimationFinished(anim)
  if anim == self.Receive then
    if self.data and 0 == self.data.state then
      _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.GetHandbookTopicAward, self.data.handbookId, self.data.index)
    end
  elseif anim == self.Tips_in then
  elseif anim == self.Tips_out then
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif anim == self.Default then
  end
end

return UMG_Handbook_Subject_Item2_C
