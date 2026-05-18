local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_CardDeck_C = NRCUmgClass:Extend("")

function UMG_Battle_CardDeck_C:Construct()
  self.deckUIList = {
    self.Card1,
    self.Card2,
    self.Card3,
    self.Card4,
    self.Card5,
    self.Card6
  }
  self.player = nil
  self.isSeriesFight = nil
  self.battleManager = _G.BattleManager
  self.currentLife = 0
  self:AddListener()
  self.isLeaderFight = false
  self.is1VN = false
  BattleEventCenter:Bind(self, BattleEvent.UI_UPDATE_PETNUM)
end

function UMG_Battle_CardDeck_C:Destruct()
  BattleEventCenter:UnBind(self)
  self:RemoveListener()
  table.clear(self.deckUIList)
  self.deckUIList = nil
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_CardDeck_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.UI_UPDATE_PETNUM then
    local player = (...)
    if player == self.player then
      self:UpdateData()
    else
    end
  end
end

function UMG_Battle_CardDeck_C:PlayerLeave()
  self.player = nil
  self.pet = nil
end

function UMG_Battle_CardDeck_C:AddListener()
  self.Button_Pet.OnClicked:Add(self, self.OnClickButton_Pet)
end

function UMG_Battle_CardDeck_C:RemoveListener()
  self.Button_Pet.OnClicked:Remove(self, self.OnClickButton_Pet)
end

function UMG_Battle_CardDeck_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Battle_CardDeck_C:Hide()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_CardDeck_C:InitView(player)
  self.player = player
  self.isSeriesFight = not self.player.model
  self:UpdateData()
end

function UMG_Battle_CardDeck_C:InitViewFor1VN(pet)
  self.player = pet.player
  self.pet = pet
  self.isSeriesFight = not self.player.model
  self.is1VN = true
  self:UpdateDataFor1VN()
end

function UMG_Battle_CardDeck_C:SetLeftLife(leftLife)
  self.currentLife = leftLife
  for i = 1, #self.deckUIList do
    local widget = self.deckUIList[#self.deckUIList - (i - 1)]
    if i <= leftLife then
      widget:SetState({
        isAlive = true,
        isWild = false,
        isLeaderFight = true
      })
    else
      widget:SetState({
        isAlive = false,
        isWild = false,
        isLeaderFight = true
      })
    end
  end
end

function UMG_Battle_CardDeck_C:SetLeaderFight(leaderFight)
  self.isLeaderFight = leaderFight
end

function UMG_Battle_CardDeck_C:UpdateData()
  if BattleUtils.IsB1FinalBattleP1() then
    if self.player.teamEnm == BattleEnum.Team.ENUM_ENEMY then
      self:UpdateB1FinalBattleP1Data()
      return
    end
  elseif BattleUtils.IsB1FinalBattleP2() then
    if self.player.teamEnm == BattleEnum.Team.ENUM_ENEMY then
      self:UpdateB1FinalBattleP1Data()
    else
    end
    return
  elseif self.isLeaderFight or self.isSeriesFight then
    return
  end
  local cardCount = self:GetCardNumber()
  self.liveCount = self:GetSummonNumber()
  local liveRandomPetCount = self.player and self.player:GetLiveRandomPetCount() or 0
  local deadRandomPetCount = self.player and self.player:GetDeadRandomPetCount() or 0
  local deckUIList = self.deckUIList
  local listLength = #deckUIList
  local deskUiStateList = self:GetDeckCardStateListByPetCount(listLength, cardCount, self.liveCount, liveRandomPetCount, deadRandomPetCount)
  if self.isSeriesFight then
    table.reverse(deskUiStateList)
  end
  for i = 1, listLength do
    local widget = deckUIList[i]
    local state = deskUiStateList[i]
    widget:SetState(state)
  end
end

function UMG_Battle_CardDeck_C:UpdateB1FinalBattleP1Data()
  local cardCount = self:GetCardNumber()
  self.liveCount = self:GetSummonNumber()
  local deckCount = #self.deckUIList
  for i = 1, deckCount do
    local index = deckCount - i + 1
    local widget = self.deckUIList[index]
    if i > cardCount then
      widget:SetB1FinalBattleP1Empty()
    elseif i <= self.liveCount then
      widget:SetB1FinalBattleP1State(true)
    else
      widget:SetB1FinalBattleP1State(false)
    end
  end
end

function UMG_Battle_CardDeck_C:UpdateDataFor1VN()
  self.liveCount = 0
  local cheerCards = self.pet.card:GetCheerPets()
  self.liveCount = #cheerCards
  for i = 1, #self.deckUIList do
    local index = i
    if self.isSeriesFight then
      index = #self.deckUIList - (i - 1)
    end
    local widget = self.deckUIList[index]
    if i > self.liveCount then
      widget:SetState({
        isEmpty = true,
        isSeriesFight = self.isSeriesFight,
        isLeaderFight = self.isLeaderFight
      })
    else
      widget:Set1VNState(cheerCards[i], self.isLeaderFight)
    end
  end
end

function UMG_Battle_CardDeck_C:GetDeckCardStateListByPetCount(cardListLength, petCount, livePetCount, liveRandomPetCount, deadRandomPetCount)
  liveRandomPetCount = math.min(liveRandomPetCount, livePetCount)
  local liveNormalPetCount = math.max(livePetCount - liveRandomPetCount, 0)
  local deadCount = math.max(petCount - livePetCount, 0)
  deadRandomPetCount = math.min(deadRandomPetCount, deadCount)
  local deadNormalPetCount = math.max(deadCount - deadRandomPetCount, 0)
  local emptyCount = math.max(cardListLength - petCount, 0)
  local deskUiStateList = {}
  for i = 1, liveNormalPetCount do
    local state = {
      isAlive = true,
      isWild = self.isSeriesFight,
      isLeaderFight = false
    }
    table.insert(deskUiStateList, state)
  end
  for i = 1, liveRandomPetCount do
    local state = {
      isAlive = true,
      isWild = self.isSeriesFight,
      isLeaderFight = false,
      isRandomPet = true
    }
    table.insert(deskUiStateList, state)
  end
  for i = 1, deadNormalPetCount do
    local state = {
      isAlive = false,
      isWild = self.isSeriesFight,
      isLeaderFight = false
    }
    table.insert(deskUiStateList, state)
  end
  for i = 1, deadRandomPetCount do
    local state = {
      isAlive = false,
      isWild = self.isSeriesFight,
      isLeaderFight = false,
      isRandomPet = true
    }
    table.insert(deskUiStateList, state)
  end
  for i = 1, emptyCount do
    local state = {
      isEmpty = true,
      isSeriesFight = self.isSeriesFight,
      isLeaderFight = self.isLeaderFight
    }
    table.insert(deskUiStateList, state)
  end
  return deskUiStateList
end

function UMG_Battle_CardDeck_C:PlayEffectAnimation(animId, card)
  if animId == BattleConst.EffectAnimation.EnergyRecovery then
    self:PlayAnimation(self.EnergyRecovery)
    return
  end
  for _, deck in ipairs(self.deckUIList) do
    if deck.curState ~= BattleConst.DeckCardState.None and deck.card == card then
      deck:PlayAnimationById(animId)
      return
    end
  end
  local max = #self.deckUIList
  local startIndex, endIndex, skip = 1, max, 1
  if self.isSeriesFight then
    startIndex, endIndex, skip = max, 1, -1
  end
  if animId == BattleConst.EffectAnimation.Resurrection then
    for i = startIndex, endIndex, skip do
      if self.deckUIList[i].curState == BattleConst.DeckCardState.Dead then
        self.deckUIList[i]:SetState({
          isAlive = true,
          isWild = self.isSeriesFight,
          isLeaderFight = false
        })
        self.deckUIList[i]:PlayAnimationById(animId)
        return
      end
    end
  else
    local cards = self.player.deck.cards
    local targetIndex = 1
    local findIndex = 1
    for i, v in ipairs(cards) do
      if v == card then
        break
      end
      if v:IsAlive() then
        targetIndex = targetIndex + 1
      end
    end
    for i = startIndex, endIndex, skip do
      if self.deckUIList[i].curState == BattleConst.DeckCardState.Living then
        if targetIndex == findIndex then
          self.deckUIList[i]:PlayAnimationById(animId)
          return
        else
          findIndex = findIndex + 1
        end
      end
    end
  end
end

function UMG_Battle_CardDeck_C:GetCardNumber()
  return self.player and self.player:GetPetNum() or 0
end

function UMG_Battle_CardDeck_C:GetSummonNumber()
  if self.player then
    return self.player:GetSummonNumber()
  end
  return 0
end

function UMG_Battle_CardDeck_C:GetRealSummonNumber()
  if self.player then
    local summonNumber = self:GetSummonNumber()
    return math.min(summonNumber, self.player.roleInfo.base.hp)
  end
  return 0
end

function UMG_Battle_CardDeck_C:OnClickButton_Pet()
  if not self.player then
    return
  end
  local bVisualInvisible = true
  for i = 1, #self.deckUIList do
    local widget = self.deckUIList[i]
    if not widget:IsVisualEmpty() then
      bVisualInvisible = false
      break
    end
  end
  if bVisualInvisible then
    return
  end
  if self.is1VN then
    return
  end
  if BattleUtils.IsCrowdBattle() and self.player:IsEnemy() then
    return
  end
  NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.SwitchReservesPetsPanel, self.player)
end

return UMG_Battle_CardDeck_C
