local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_TerritoryTrial_EnemyInformation_C = _G.NRCPanelBase:Extend("UMG_TerritoryTrial_EnemyInformation_C")
UMG_TerritoryTrial_EnemyInformation_C.EffectType = {
  SetProps = "UMG_TerritoryTrial_EnemyInformation_C.EffectType.SetProps",
  SetState = "UMG_TerritoryTrial_EnemyInformation_C.EffectType.SetState"
}

function UMG_TerritoryTrial_EnemyInformation_C:OnConstruct()
  if self.Watch then
    self.Watch:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.Btn_Watch:SetVisibility(UE.ESlateVisibility.Visible)
  self.props = {}
  self.state = {}
  self.effectQueue = {}
  self.isFlushing = false
  self.isFlushScheduled = false
  local initState = {}
  initState.EnemyListCanvasPanelVisibility = UE.ESlateVisibility.Collapsed
  initState.listDataUpdateFlag = {}
  local tips1Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips1")
  local tips1 = tips1Conf and tips1Conf.msg or ""
  local tips2Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips2")
  local tips2 = tips2Conf and tips2Conf.msg or ""
  local tips3Conf = _G.DataConfigManager:GetLocalizationConf("territory_trial_battle_tips3")
  local tips3 = tips3Conf and tips3Conf.msg or ""
  initState.roundTextLabel = tips1
  initState.awardTextLabel = tips2
  initState.watchButtonLabel = tips3
  local prevState = self.state
  self.state = initState
  self:RenderWidget(self.props, self.props, prevState, initState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnActive()
  self:OnAddEventListener()
  local prevState, nextState = self:GetPrevAndNextState()
  nextState.listDataUpdateFlag = {}
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_TerritoryTrial_EnemyInformation_C:OnAddEventListener()
  self.Btn_Watch.OnClicked:Add(self, self.OnWatchButtonClick)
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_START, BattleEvent.BATTLE_PET_DIE, BattleEvent.CHEER_SWITCH)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnRemoveEventListener()
  self.Btn_Watch.OnClicked:Remove(self, self.OnWatchButtonClick)
end

function UMG_TerritoryTrial_EnemyInformation_C.DeriveStateFromProps(prevState, nextProps)
  return prevState
end

function UMG_TerritoryTrial_EnemyInformation_C:RenderWidget(prevProps, nextProps, prevState, nextState)
  local prevIsShow = prevProps and prevProps.isShow
  local nextIsShow = nextProps and nextProps.isShow
  local prevEnemyListCanvasPanelVisibility = prevState and prevState.EnemyListCanvasPanelVisibility
  local nextEnemyListCanvasPanelVisibility = nextState and nextState.EnemyListCanvasPanelVisibility
  local prevPetGuidList = prevState and prevState.petGuidList or {}
  local nextPetGuidList = nextState and nextState.petGuidList or {}
  local prevMaxRoundCount = prevProps and prevProps.maxRoundCount
  local nextMaxRoundCount = nextProps and nextProps.maxRoundCount
  local prevRoundCount = prevState and prevState.currentRoundCount
  local nextRoundCount = nextState and nextState.currentRoundCount
  local prevCurrentAwardValue = prevState and prevState.currentAwardValue
  local nextCurrentAwardValue = nextState and nextState.currentAwardValue
  local prevCurrentAwardValueDisplay = prevState and prevState.currentAwardValueDisplay
  local nextCurrentAwardValueDisplay = nextState and nextState.currentAwardValueDisplay
  local prevRoundTextLabel = prevState and prevState.roundTextLabel
  local nextRoundTextLabel = nextState and nextState.roundTextLabel
  local prevAwardTextLabel = prevState and prevState.awardTextLabel
  local nextAwardTextLabel = nextState and nextState.awardTextLabel
  local prevWatchButtonLabel = prevState and prevState.watchButtonLabel
  local nextWatchButtonLabel = nextState and nextState.watchButtonLabel or ""
  if prevIsShow ~= nextIsShow then
    if nextIsShow then
      self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  if prevEnemyListCanvasPanelVisibility ~= nextEnemyListCanvasPanelVisibility then
    self.EnemyListCanvasPanel:SetVisibility(nextEnemyListCanvasPanelVisibility)
  end
  if prevPetGuidList ~= nextPetGuidList then
    local propsList = {}
    for i, petGid in ipairs(nextPetGuidList) do
      local battleCard = _G.BattleManager.battlePawnManager:GetCardByGuid(petGid)
      local petBaseConf = battleCard and battleCard.petBaseConf
      local modelConfId = petBaseConf and petBaseConf.model_conf
      local modelConf = _G.DataConfigManager:GetModelConf(modelConfId)
      local icon = modelConf and modelConf.icon
      local iconPath = NRCUtils:FormatConfIconPath(icon, _G.UIIconPath.HeadIconPath)
      local petName = battleCard and battleCard.name or ""
      local petState = battleCard and battleCard.petState
      local isDead = petState and petState:GetDead() or false
      local petInfo = battleCard and battleCard.petInfo
      local insideInfo = petInfo and petInfo.battle_inside_pet_info
      local trialInfo = insideInfo and insideInfo.trial_pet_info
      local isBoss = trialInfo and trialInfo.is_boss
      local guardEntries = trialInfo and trialInfo.guard_entrys or {}
      local isDefeat = isDead
      local isInBattle = battleCard and battleCard:IsInBattle() or false
      local inPrepareZone = battleCard and battleCard:IsPetInPrepareZone() or false
      if inPrepareZone then
        isInBattle = false
      end
      if isDefeat then
        isInBattle = false
      end
      local props = {}
      props.petGid = petGid
      props.iconPath = iconPath
      props.name = petName
      props.isBoss = isBoss
      props.isInBattle = isInBattle
      props.isDefeated = isDefeat
      props.guardEntries = guardEntries
      table.insert(propsList, props)
    end
    self.List:InitList(propsList)
  end
  local prevDefeatedEnemyPetCount = prevState and prevState.defeatedEnemyPetCount
  local currentDefeatedEnemyPetCount = nextState and nextState.defeatedEnemyPetCount
  local prevEnemyPetCount = prevState and prevState.enemyPetCount
  local currentEnemyPetCount = nextState and nextState.enemyPetCount
  if prevDefeatedEnemyPetCount ~= currentDefeatedEnemyPetCount or prevEnemyPetCount ~= currentEnemyPetCount then
    local defeatEnemyPetString = string.format("%s/%s", tostring(currentDefeatedEnemyPetCount), tostring(currentEnemyPetCount))
    self.Number:SetText(defeatEnemyPetString)
  end
  if prevCurrentAwardValue ~= nextCurrentAwardValue then
    local prevValue = prevCurrentAwardValue or 0
    local nextValue = nextCurrentAwardValue or 0
    local diff = nextValue - prevValue
    local diffStr = tostring(math.abs(diff))
    if diff < 0 then
      diffStr = "-" .. diffStr
    else
      diffStr = "+" .. diffStr
    end
    self.RecognitionText2:SetText(diffStr)
    self.RecognitionText2:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.RecognitionText2:SetRenderOpacity(0)
  end
  if prevCurrentAwardValueDisplay ~= nextCurrentAwardValueDisplay then
    self.RecognitionText:SetText(tostring(nextCurrentAwardValueDisplay))
  end
  if prevMaxRoundCount ~= nextMaxRoundCount or prevRoundCount ~= nextRoundCount then
    local textString = string.format("%s/%s", tostring(nextRoundCount), tostring(nextMaxRoundCount))
    self.RoundsText:SetText(tostring(textString))
  end
  if prevRoundTextLabel ~= nextRoundTextLabel then
    self.RoundsText1:SetText(tostring(nextRoundTextLabel))
  end
  if prevAwardTextLabel ~= nextAwardTextLabel then
    self.RecognitionText1:SetText(tostring(nextAwardTextLabel))
  end
  if prevWatchButtonLabel ~= nextWatchButtonLabel then
    self.TextBlock_367:SetText(tostring(nextWatchButtonLabel))
  end
end

function UMG_TerritoryTrial_EnemyInformation_C:OnWidgetDidUpdate(prevProps, nextProps, prevState, currentState)
  local prevListUpdateFlag = prevState and prevState.listDataUpdateFlag
  local nextListUpdateFlag = currentState and currentState.listDataUpdateFlag
  local prevCurrentAwardValue = prevState and prevState.currentAwardValue
  local nextCurrentAwardValue = currentState and currentState.currentAwardValue
  local prevScrollToFirstInBattleItemFlag = prevState and prevState.scrollToFirstInBattleItemFlag
  local nextScrollToFirstInBattleItemFlag = currentState and currentState.scrollToFirstInBattleItemFlag
  if prevListUpdateFlag ~= nextListUpdateFlag then
    local nextState = {}
    table.copy(currentState, nextState)
    local nextPetGidList = {}
    local enemyTeamList = _G.BattleManager.battlePawnManager:GetAllEnemyTeam(BattleEnum.Team.ENUM_TEAM)
    local enemyTeam = enemyTeamList and enemyTeamList[1]
    local inBattlePetsCardList = enemyTeam and enemyTeam:GetInBattleCards() or {}
    local reservePetsCardList = enemyTeam and enemyTeam:GetReservesPetCards() or {}
    local totalPetCount = #inBattlePetsCardList + #reservePetsCardList
    local deadPetCount = 0
    local defeatPointTotal = 0
    for i, card in ipairs(inBattlePetsCardList) do
      local gid = card and card.guid
      local petState = card and card.petState
      local isDead = petState and petState:GetDead()
      local petInfo = card and card.petInfo
      local insideInfo = petInfo and petInfo.battle_inside_pet_info
      local trialInfo = insideInfo and insideInfo.trial_pet_info
      local defeatPoint = trialInfo and trialInfo.defeat_point or 0
      table.insert(nextPetGidList, gid)
      if isDead then
        deadPetCount = deadPetCount + 1
        defeatPointTotal = defeatPointTotal + defeatPoint
      end
    end
    for i, card in ipairs(reservePetsCardList) do
      local gid = card and card.guid
      local petState = card and card.petState
      local isDead = petState and petState:GetDead()
      local petInfo = card and card.petInfo
      local insideInfo = petInfo and petInfo.battle_inside_pet_info
      local trialInfo = insideInfo and insideInfo.trial_pet_info
      local defeatPoint = trialInfo and trialInfo.defeat_point or 0
      table.insert(nextPetGidList, gid)
      if isDead then
        deadPetCount = deadPetCount + 1
        defeatPointTotal = defeatPointTotal + defeatPoint
      end
    end
    table.sort(nextPetGidList, UMG_TerritoryTrial_EnemyInformation_C.PetGidComparator)
    local nextRoundCount = _G.BattleManager:GetCurRound()
    nextState.petGuidList = nextPetGidList
    nextState.enemyPetCount = totalPetCount
    nextState.defeatedEnemyPetCount = deadPetCount
    nextState.currentRoundCount = nextRoundCount
    nextState.currentAwardValue = defeatPointTotal
    self:SetState(nextState)
  end
  if prevCurrentAwardValue ~= nextCurrentAwardValue then
    if nil == prevCurrentAwardValue then
      local _, nextState = self:GetPrevAndNextState()
      nextState.currentAwardValueDisplay = nextCurrentAwardValue
      self:SetState(nextState)
    else
      self:PlayAnimation(self.Add)
    end
  end
  if prevScrollToFirstInBattleItemFlag ~= nextScrollToFirstInBattleItemFlag then
    local petGuidList = currentState and currentState.petGuidList or {}
    local firstInBattleIndex
    for i, petGid in ipairs(petGuidList) do
      local battleCard = _G.BattleManager.battlePawnManager:GetCardByGuid(petGid)
      local petState = battleCard and battleCard.petState
      local isDead = petState and petState:GetDead() or false
      local isDefeat = isDead
      local isInBattle = battleCard and battleCard:IsInBattle() or false
      local inPrepareZone = battleCard and battleCard:IsPetInPrepareZone() or false
      if inPrepareZone then
        isInBattle = false
      end
      if isDefeat then
        isInBattle = false
      end
      if isInBattle then
        firstInBattleIndex = i
        break
      end
    end
    if firstInBattleIndex then
      firstInBattleIndex = firstInBattleIndex - 1
      if firstInBattleIndex < 0 then
        firstInBattleIndex = nil
      end
    end
    if firstInBattleIndex then
      self.List:ScrollToIndex(firstInBattleIndex, true)
    end
  end
end

function UMG_TerritoryTrial_EnemyInformation_C:OnWatchButtonClick()
  local prevState, nextState = self:GetPrevAndNextState()
  if prevState.EnemyListCanvasPanelVisibility == UE.ESlateVisibility.Collapsed then
    nextState.EnemyListCanvasPanelVisibility = UE.ESlateVisibility.SelfHitTestInvisible
    nextState.scrollToFirstInBattleItemFlag = {}
  else
    nextState.EnemyListCanvasPanelVisibility = UE.ESlateVisibility.Collapsed
  end
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnRoundStart()
  local prevState, nextState = self:GetPrevAndNextState()
  nextState.listDataUpdateFlag = {}
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnPetDie(battlePet)
  local prevState, nextState = self:GetPrevAndNextState()
  nextState.listDataUpdateFlag = {}
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnCheerSwitch(battlePet)
  local prevState, nextState = self:GetPrevAndNextState()
  nextState.listDataUpdateFlag = {}
  self:SetState(nextState)
end

function UMG_TerritoryTrial_EnemyInformation_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_START then
    self:OnRoundStart()
  elseif eventName == BattleEvent.BATTLE_PET_DIE then
    local battlePet = (...)
    self:OnPetDie(battlePet)
  elseif eventName == BattleEvent.CHEER_SWITCH then
    local battlePet = (...)
    self:OnCheerSwitch(battlePet)
  end
end

function UMG_TerritoryTrial_EnemyInformation_C:OnAnimationFinished(Anim)
  if Anim == self.Add then
    local prevState, nextState = self:GetPrevAndNextState()
    nextState.currentAwardValueDisplay = prevState.currentAwardValue
    self:SetState(nextState)
  end
end

function UMG_TerritoryTrial_EnemyInformation_C.PetGidComparator(gidA, gidB)
  gidA = gidA or 0
  gidB = gidB or 0
  return gidA < gidB
end

function UMG_TerritoryTrial_EnemyInformation_C:SetProps(nextProps)
  local prevProps = self.props
  self.props = nextProps
  local prevState = self.state
  local nextState = self.DeriveStateFromProps(prevState, nextProps)
  self.state = nextState
  self:ScheduleEffect({
    type = UMG_TerritoryTrial_EnemyInformation_C.EffectType.SetProps,
    prevProps = prevProps,
    currentProps = nextProps,
    prevState = prevState,
    currentState = nextState
  })
end

function UMG_TerritoryTrial_EnemyInformation_C:SetState(nextState)
  local prevState = self.state
  self.state = nextState
  self:ScheduleEffect({
    type = UMG_TerritoryTrial_EnemyInformation_C.EffectType.SetState,
    prevProps = self.props,
    currentProps = self.props,
    prevState = prevState,
    currentState = nextState
  })
end

function UMG_TerritoryTrial_EnemyInformation_C:ScheduleEffect(effectInfo)
  table.insert(self.effectQueue, effectInfo)
  if not self.isFlushScheduled then
    self.isFlushScheduled = true
    self:DelayFrames(1, self.ScheduleFlush, self)
  end
end

function UMG_TerritoryTrial_EnemyInformation_C:ScheduleFlush()
  self.isFlushScheduled = false
  self:FlushEffects()
end

function UMG_TerritoryTrial_EnemyInformation_C:FlushEffects()
  if self.isFlushing then
    return
  end
  self.isFlushing = true
  local currentQueue = self.effectQueue or {}
  self.effectQueue = {}
  if #currentQueue > 0 then
    local firstEffect = currentQueue[1]
    local lastEffect = currentQueue[#currentQueue]
    local mergedEffect = {
      type = firstEffect.type,
      prevProps = firstEffect.prevProps,
      prevState = firstEffect.prevState,
      currentProps = lastEffect.currentProps,
      currentState = lastEffect.currentState
    }
    self:RenderWidget(mergedEffect.prevProps, mergedEffect.currentProps, mergedEffect.prevState, mergedEffect.currentState)
    self:OnWidgetDidUpdate(mergedEffect.prevProps, mergedEffect.currentProps, mergedEffect.prevState, mergedEffect.currentState)
  end
  self.isFlushing = false
end

function UMG_TerritoryTrial_EnemyInformation_C:GetPrevAndNextState()
  local prevState = self.state
  local nextState = {}
  table.copy(prevState, nextState)
  return prevState, nextState
end

return UMG_TerritoryTrial_EnemyInformation_C
