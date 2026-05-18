local UMG_Activity_SeasonPreheating_RecordBook_C = _G.NRCPanelBase:Extend("UMG_Activity_SeasonPreheating_RecordBook_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_SeasonPreheating_RecordBook_C:OnConstruct()
  self:AddButtonListener(self.CloseButton, self.OnClickClose)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnClickNextClue)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnClickPreClue)
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnDestruct()
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnActive(itemObject)
  _G.NRCAudioManager:PlaySound2DAuto(40008039, "UMG_Activity_SeasonPreheating_RecordBook_C:OnActive")
  self.itemObject = itemObject
  self:RefreshUI()
end

function UMG_Activity_SeasonPreheating_RecordBook_C:RefreshUI()
  local itemObject = self.itemObject
  local cfg = itemObject and itemObject:GetCfg()
  self.DiscoverySite:SetText(cfg and cfg.manuscript_text_1 or "")
  local timeDetailData = ActivityUtils.ToTimeDetailData(itemObject and itemObject:GetFinishTimestamp() or 0)
  self.DiscoverTime:SetText(string.safeFormat(cfg and cfg.manuscript_text_2, timeDetailData.year, timeDetailData.month, timeDetailData.day))
  self.DescLeft:SetText(cfg and cfg.manuscript_text_3 or "")
  self.DescRight:SetText(cfg and cfg.manuscript_text_4 or "")
  self.Discoverer:SetText(string.safeFormat(cfg and cfg.manuscript_text_5, _G.DataModelMgr.PlayerDataModel:GetPlayerName()))
  local slot = itemObject and itemObject:GetSlot() or 0
  if slot > 0 then
    self.Switcher:SetActiveWidgetIndex(slot - 1)
  end
  if self:GetPreOrNextClue(itemObject, 1) then
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self:GetPreOrNextClue(itemObject, -1) then
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnAnimFinished(anim)
  if anim and anim == self.waitingFadeOutAnim then
    self:NewClueFadeIn()
  end
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnClickClose()
  if self:IsAnimationPlaying(self.In) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_Activity_SeasonPreheating_RecordBook_C:OnClickClose")
  self:OnClose()
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnPcClose()
  self:OnClickClose()
end

function UMG_Activity_SeasonPreheating_RecordBook_C:GetPreOrNextClue(clueObject, forwardStep)
  if not clueObject then
    return nil
  end
  local owner = clueObject:GetOwner()
  if not owner then
    return nil
  end
  local findObject
  local processObject = clueObject
  while processObject do
    local slot = processObject:GetSlot() or 0
    local forwardObject = owner:GetCollectItemObject(slot + forwardStep)
    if not forwardObject then
      break
    end
    if forwardObject:GetStatus() == ActivityEnum.ItemStatus.Finished then
      findObject = forwardObject
      break
    end
    processObject = forwardObject
  end
  return findObject
end

function UMG_Activity_SeasonPreheating_RecordBook_C:NewClueFadeIn()
  if not self.waitingFadeInFlag then
    return
  end
  self.waitingFadeInFlag = false
  self:RefreshUI()
  if self.waitingFadeInAnim then
    self:PlayAnimation(self.waitingFadeInAnim)
  end
end

function UMG_Activity_SeasonPreheating_RecordBook_C:SwitchClue(forwardStep)
  _G.NRCAudioManager:PlaySound2DAuto(40006004, "UMG_Activity_SeasonPreheating_C:SwitchClue")
  local itemObject = self.itemObject
  local switchItemObject = self:GetPreOrNextClue(itemObject, forwardStep)
  if switchItemObject then
    self.waitingFadeOutFlag = false
    self:StopAnimation(self.waitingFadeOutAnim)
    self:StopAnimation(self.waitingFadeInAnim)
    local fadeOutSlot = itemObject:GetSlot() or 0
    local faceInSlot = switchItemObject:GetSlot() or 0
    self.waitingFadeOutAnim = self["Clue_out_" .. fadeOutSlot]
    self.waitingFadeInAnim = self["Clue_in_" .. faceInSlot]
    self.itemObject = switchItemObject
    self.waitingFadeInFlag = true
    if self.waitingFadeOutAnim then
      self:PlayAnimation(self.waitingFadeOutAnim)
    else
      self:NewClueFadeIn()
    end
  end
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnClickNextClue()
  self:SwitchClue(1)
end

function UMG_Activity_SeasonPreheating_RecordBook_C:OnClickPreClue()
  self:SwitchClue(-1)
end

return UMG_Activity_SeasonPreheating_RecordBook_C
