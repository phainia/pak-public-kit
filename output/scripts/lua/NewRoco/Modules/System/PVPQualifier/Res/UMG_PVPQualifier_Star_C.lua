local UMG_PVPQualifier_Star_C = _G.NRCPanelBase:Extend("UMG_PVPQualifier_Star_C")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local PVPRankedMatchModuleCmd = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleCmd")

function UMG_PVPQualifier_Star_C:MappingAnimations()
  self.starShowAnimMap = {
    [0] = {},
    [1] = {},
    [2] = {},
    [3] = {}
  }
  self.starShowAnimMap[0][0] = self.Star_In_new_0
  self.starShowAnimMap[0][1] = self["Star_In_new_0+1"]
  self.starShowAnimMap[0][2] = self["Star_In_new_0+2"]
  self.starShowAnimMap[0][3] = self["Star_In_new_0+3"]
  self.starShowAnimMap[1][0] = self["Star_In_new_1-1"]
  self.starShowAnimMap[1][1] = self.Star_In_new_1
  self.starShowAnimMap[1][2] = self["Star_In_new_1+1"]
  self.starShowAnimMap[1][3] = self["Star_In_new_1+2"]
  self.starShowAnimMap[2][0] = self["Star_In_new_2-2"]
  self.starShowAnimMap[2][1] = self["Star_In_new_2-1"]
  self.starShowAnimMap[2][2] = self.Star_In_new_2
  self.starShowAnimMap[2][3] = self["Star_In_new_2+1"]
  self.starShowAnimMap[3][0] = self["Star_In_new_3-3"]
  self.starShowAnimMap[3][1] = self["Star_In_new_3-2"]
  self.starShowAnimMap[3][2] = self["Star_In_new_3-1"]
  self.starShowAnimMap[3][3] = self.Star_In_new_3
  self.starHideAnimMap = {}
  self.starHideAnimMap[1] = self.Star_Out_new_1
  self.starHideAnimMap[2] = self.Star_Out_new_2
  self.starHideAnimMap[3] = self.Star_Out_new_3
  self.starWidgetMap = {}
  self.starWidgetMap[1] = {
    self.Star01
  }
  self.starWidgetMap[2] = {
    self.Star02_1,
    self.Star02_2
  }
  self.starWidgetMap[3] = {
    self.Star03_1,
    self.Star03_2,
    self.Star03_3
  }
end

function UMG_PVPQualifier_Star_C:OnConstruct()
  self:MappingAnimations()
  self.fromStarNum = 0
  self.toStarNum = 0
  self.animFinishedCallback = nil
  self.playingStarAnim = nil
  self.playingRankAnim = nil
end

function UMG_PVPQualifier_Star_C:OnDestruct()
end

function UMG_PVPQualifier_Star_C:OnActive()
  self.Advantage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.fromStarNum = 0
  self.toStarNum = 0
  self.animFinishedCallback = nil
  self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PVPQualifier_Star_C:PlayOutAnimation(onFinishedCallback)
  if PVPRankedMatchModuleUtils.IsSelfMaxRankStar() then
    self:PlayRankAnimation(self.Out_Ranking)
    self.animFinishedCallback = onFinishedCallback
  else
    self:HideStars(onFinishedCallback)
  end
end

function UMG_PVPQualifier_Star_C:OnAnimationFinished(anim)
  if anim == self.playingStarAnim or anim == self.playingRankAnim then
    local curCallback = self.animFinishedCallback
    self.animFinishedCallback = nil
    if curCallback then
      curCallback()
    end
  end
end

function UMG_PVPQualifier_Star_C:SwitcherStarIndex(starNum, oldMasterScore, masterScore)
  if PVPRankedMatchModuleUtils.IsSelfMaxRankStar() then
    self.Advantage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_Plus:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local rankOrder = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_PVP_RANK_ORDER)
    local oldRank = rankOrder
    self.UMG_RollNumber:PlayRollNumberAnim(oldRank, rankOrder)
    if rankOrder > oldRank then
      self:PlayRankAnimation(self.Inup_Ranking)
    elseif oldRank == rankOrder then
      self:PlayRankAnimation(self.In_Ranking)
    else
      self:PlayRankAnimation(self.Indown_Ranking)
    end
    local rankMasterScore = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_PVP_RANK_MASTER_SCORE) or 0
    self.TextAdvantage:SetText(tostring(rankMasterScore))
    if oldMasterScore and masterScore and oldMasterScore ~= masterScore then
      self.TextAdvantage_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local deltaMasterScore = PVPRankedMatchModuleUtils.GetDeltaMasterScoreText(oldMasterScore, masterScore)
      self.TextAdvantage_1:SetText(deltaMasterScore)
    else
      self.TextAdvantage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local TopMasterInfo = _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.CmdGetTopMaster)
    local bTopMasterNext = TopMasterInfo.next_type == _G.ProtoEnum.PVP_RANK_MASTER_TYPE.PVP_RANK_MASTER_TYPE_TOP_MASTER
    if bTopMasterNext or TopMasterInfo.type ~= TopMasterInfo.next_type then
      self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if bTopMasterNext or TopMasterInfo.type < TopMasterInfo.next_type then
        self.ArrowSwitcher:SetActiveWidgetIndex(0)
      else
        self.ArrowSwitcher:SetActiveWidgetIndex(1)
      end
    else
      self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_Plus:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:ShowStars(starNum, starNum, true)
  end
end

function UMG_PVPQualifier_Star_C:ShowStars(oldStarNum, newStarNum, bFastShow, onFinishedCallback)
  oldStarNum = math.clamp(oldStarNum, 0, 3)
  newStarNum = math.clamp(newStarNum, 0, 3)
  if bFastShow then
    oldStarNum = newStarNum
  end
  self.Switcher_Star:SetActiveWidgetIndex(math.max(oldStarNum, newStarNum))
  local anim = self.starShowAnimMap[oldStarNum][newStarNum]
  self:PlayStarAnimation(anim, oldStarNum)
  self.fromStarNum = oldStarNum
  self.toStarNum = newStarNum
  self.animFinishedCallback = onFinishedCallback
end

function UMG_PVPQualifier_Star_C:HideStars(onFinishedCallback)
  local starNum = self.toStarNum
  self.Switcher_Star:SetActiveWidgetIndex(starNum)
  local anim = self.starHideAnimMap[starNum]
  self:PlayStarAnimation(anim, starNum)
  self.animFinishedCallback = onFinishedCallback
  self.fromStarNum = 0
  self.toStarNum = 0
end

function UMG_PVPQualifier_Star_C:PlayRankAnimation(anim)
  self:StopAnimation(self.playingRankAnim)
  self:PlayAnimation(anim)
  self.playingRankAnim = anim
end

function UMG_PVPQualifier_Star_C:PlayStarAnimation(anim, starNum)
  local starWidgets = self.starWidgetMap[starNum]
  if starWidgets then
    for i = 1, #starWidgets do
      local widget = starWidgets[i]
      widget:StopAllAnimations()
    end
  end
  self:StopAnimation(self.playingStarAnim)
  self:PlayAnimation(anim)
  self.playingStarAnim = anim
end

function UMG_PVPQualifier_Star_C:StopAllStarWidgetAnimation()
  for x = 1, #self.starWidgetMap do
    local starWidgets = self.starWidgetMap[x]
    for i = 1, #starWidgets do
      local widget = starWidgets[i]
      widget:StopAllAnimations()
    end
  end
end

return UMG_PVPQualifier_Star_C
