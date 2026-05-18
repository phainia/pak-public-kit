local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = _G.NRCPanelBase
local UMG_TerritoryTrialSettlement_C = Base:Extend("UMG_TerritoryTrialSettlement_C")

function UMG_TerritoryTrialSettlement_C:OnConstruct()
  self.props = {}
  self.state = {}
  local tips6Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips6")
  local tips6 = tips6Conf and tips6Conf.msg or ""
  local totalScoreLabelText = tips6
  local initState = {}
  initState.totalScoreLabelText = totalScoreLabelText
  self:SetState(initState)
end

function UMG_TerritoryTrialSettlement_C:OnDestruct()
end

function UMG_TerritoryTrialSettlement_C:OnActive(contextData)
  self.contextData = contextData
  self:OnAddEventListener()
  local callbackOwner = contextData and contextData.callbackOwner
  local onOpenCallback = contextData and contextData.onOpenCallback
  if onOpenCallback then
    tcall(callbackOwner, onOpenCallback, self)
  end
end

function UMG_TerritoryTrialSettlement_C:OnDeactive()
  local contextData = self.contextData
  local callbackOwner = contextData and contextData.callbackOwner
  local onCloseCallback = contextData and contextData.onCloseCallback
  if onCloseCallback then
    tcall(callbackOwner, onCloseCallback, self)
  end
  self:OnRemoveEventListener()
end

function UMG_TerritoryTrialSettlement_C:OnAddEventListener()
  self.Btn_Return.btnLevelUp.OnClicked:Add(self, self.HandleReturnButtonClick)
  self.Btn_FightAgain.btnLevelUp.OnClicked:Add(self, self.HandleFightAgainButtonClick)
end

function UMG_TerritoryTrialSettlement_C:OnRemoveEventListener()
  self.Btn_Return.btnLevelUp.OnClicked:Remove(self, self.HandleReturnButtonClick)
  self.Btn_FightAgain.btnLevelUp.OnClicked:Remove(self, self.HandleFightAgainButtonClick)
end

function UMG_TerritoryTrialSettlement_C:HandleReturnButtonClick()
  _G.BattleEventCenter:Dispatch(BattleEvent.CLICKED_Result_Close)
end

function UMG_TerritoryTrialSettlement_C:HandleFightAgainButtonClick()
  _G.BattleEventCenter:Dispatch(BattleEvent.TERRITORY_TRIAL_AGAIN)
end

function UMG_TerritoryTrialSettlement_C:SetProps(nextProps)
  local prevProps = self.props
  self.props = nextProps
  self:RenderWidget(prevProps, nextProps, self.state, self.state)
end

function UMG_TerritoryTrialSettlement_C:SetState(nextState)
  local prevState = self.state
  self.state = nextState
  self:RenderWidget(self.props, self.props, prevState, nextState)
end

function UMG_TerritoryTrialSettlement_C:RenderWidget(prevProps, nextProps, prevState, nextState)
  local prevIsShow = prevProps and prevProps.isShow
  local nextIsShow = nextProps and nextProps.isShow
  local prevTrialSettlementInfo = prevProps and prevProps.trialSettleInfo
  local nextTrialSettlementInfo = nextProps and nextProps.trialSettleInfo
  local remainRound = nextTrialSettlementInfo and nextTrialSettlementInfo.remain_round or 0
  local roundPoint = nextTrialSettlementInfo and nextTrialSettlementInfo.round_point or 0
  local defeatNum = nextTrialSettlementInfo and nextTrialSettlementInfo.defeat_num or 0
  local defeatPoint = nextTrialSettlementInfo and nextTrialSettlementInfo.defeat_point or 0
  local prevTotalPoint = prevTrialSettlementInfo and prevTrialSettlementInfo.total_point or -1
  local totalPoint = nextTrialSettlementInfo and nextTrialSettlementInfo.total_point or 0
  local prevTotalScoreLabelText = prevState and prevState.totalScoreLabelText
  local nextTotalScoreLabelText = nextState and nextState.totalScoreLabelText
  local prevHistoryMaxAward = nextProps and nextProps.prevHistoryMaxAward
  local historyMaxAward = nextProps and nextProps.historyMaxAward or 0
  if nextIsShow then
    self:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if prevIsShow ~= nextIsShow then
    if nextIsShow then
      self:PlayAnimation(self.Win_In)
    else
      self:DoClose()
    end
  end
  self.TotalScore:SetText(tostring(totalPoint))
  self.TextDefeat0:SetText(tostring(defeatNum))
  self.TextRemainingRounds:SetText(tostring(remainRound))
  local defeatPointString = string.format("+%s", tostring(defeatPoint))
  self.TextAddPoints1:SetText(defeatPointString)
  local roundPointString = string.format("+%s", tostring(roundPoint))
  self.TextAddPoints2:SetText(roundPointString)
  if prevTotalPoint ~= totalPoint then
    local pointToCompare = math.max(totalPoint, historyMaxAward)
    local rewards = self:GetRewardConfList()
    local displayRewards = {}
    local propsList = {}
    local firstReachIndex = -1
    for i, reward in ipairs(rewards) do
      local pointRequired = reward and reward.point_required or 0
      local reached = pointToCompare >= pointRequired
      if reached then
        firstReachIndex = i
        break
      end
    end
    if #rewards < 3 then
      for i, reward in ipairs(rewards) do
        table.insert(displayRewards, reward)
      end
    elseif -1 == firstReachIndex then
      for i = 1, 3 do
        local awardItem = rewards[i]
        if awardItem then
          table.insert(displayRewards, awardItem)
        end
      end
    else
      local currentIndex = firstReachIndex
      local prevIndex = currentIndex - 1
      local nextIndex = currentIndex - 1
      if nil == rewards[prevIndex] then
        currentIndex = currentIndex + 1
        prevIndex = currentIndex - 1
        nextIndex = currentIndex + 1
      end
      if nil == rewards[nextIndex] then
        currentIndex = currentIndex - 1
        prevIndex = currentIndex - 1
        nextIndex = currentIndex + 1
      end
      local indexList = {
        prevIndex,
        currentIndex,
        nextIndex
      }
      for i, index in ipairs(indexList) do
        local awardItem = rewards[index]
        if awardItem then
          table.insert(displayRewards, awardItem)
        end
      end
    end
    for i, reward in ipairs(displayRewards) do
      local props = {}
      local rewardText = reward and reward.reward_text or ""
      props.awardText = rewardText
      local pointRequired = reward and reward.point_required or 0
      local reached = pointToCompare >= pointRequired
      props.acquirementReached = reached
      table.insert(propsList, props)
    end
    self.CompletionDegree:InitGridView(propsList)
  end
  if prevHistoryMaxAward and totalPoint > prevHistoryMaxAward then
    self.NewRecord:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NewRecord:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if prevTotalScoreLabelText ~= nextTotalScoreLabelText then
    self.TotalScoreLabel:SetText(nextTotalScoreLabelText)
  end
end

function UMG_TerritoryTrialSettlement_C:GetRewardConfList()
  local targetTerritoryTrialConf = BattleUtils.GetTerritoryBattleConf()
  local rewards = targetTerritoryTrialConf and targetTerritoryTrialConf.point_reward or {}
  return rewards
end

return UMG_TerritoryTrialSettlement_C
