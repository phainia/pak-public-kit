local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_Battle_ReservesPets_Item_C = require("NewRoco.Modules.System.BattleUI.Res.UMG_Battle_ReservesPets_Item_C")
local DummyTable = require("Common.DummyTable")
local UMG_Battle_ReservesPets_C = _G.NRCPanelBase:Extend("UMG_Battle_ReservesPets_C")
local ItemData = UMG_Battle_ReservesPets_Item_C.Data
local ItemDesc = ItemData:Extend("UMG_Battle_ReservesPets_Item_Desc")

function UMG_Battle_ReservesPets_C:OnConstruct()
  self:BindCloseBtn()
end

function UMG_Battle_ReservesPets_C:OnDestruct()
end

function UMG_Battle_ReservesPets_C:OnActive(battlePlayer)
  if battlePlayer.teamEnm == BattleEnum.Team.ENUM_ENEMY then
    self:OnActiveAsEnemyTeam(battlePlayer)
  else
    self:OnActiveAsPlayerTeam(battlePlayer)
  end
  self:OnAddEventListener()
  self.isBattleState = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
  self:BindInputAction()
end

function UMG_Battle_ReservesPets_C:OnActiveAsPlayerTeam(battlePlayer)
  local reservesPetCards = battlePlayer:GetReservesPetCards()
  local commonPetCardList = {}
  local petGidToBuff145PetCardList = {}
  for i, card in ipairs(reservesPetCards) do
    local petInfo = card and card.petInfo
    local insideInfo = petInfo and petInfo.battle_inside_pet_info
    local buff145SourcePetId = insideInfo and insideInfo.buff145_source_pet or 0
    if 0 == buff145SourcePetId then
      table.insert(commonPetCardList, card)
    else
      local cardList = buff145SourcePetId and petGidToBuff145PetCardList and petGidToBuff145PetCardList[buff145SourcePetId] or {}
      table.insert(cardList, card)
      if petGidToBuff145PetCardList and buff145SourcePetId then
        petGidToBuff145PetCardList[buff145SourcePetId] = cardList
      end
    end
  end
  local petGidToCommonPetCard = {}
  for i, card in ipairs(commonPetCardList) do
    local petGid = card and card.guid
    if petGidToCommonPetCard and petGid then
      petGidToCommonPetCard[petGid] = card
    end
  end
  local buff145PetCount = 0
  local buff145PetCardListCanAddToOuterList = {}
  for petGid, battleCardList in pairs(petGidToBuff145PetCardList) do
    local sourceBattleCard = petGidToCommonPetCard and petGid and petGidToCommonPetCard[petGid]
    for j, card in ipairs(battleCardList) do
      if sourceBattleCard then
        buff145PetCount = buff145PetCount + 1
      else
        table.insert(buff145PetCardListCanAddToOuterList, card)
      end
    end
  end
  for i, card in ipairs(buff145PetCardListCanAddToOuterList) do
    table.insert(commonPetCardList, card)
  end
  local reservesPetNum = battlePlayer:GetPetNum() - #battlePlayer:GetInBattleCards()
  reservesPetNum = reservesPetNum - buff145PetCount
  local listDatas = {}
  local commonPetCardListCount = #commonPetCardList
  local ReservesPetsMax = math.max(BattleConst.ReservesPetsMax, commonPetCardListCount)
  for i = 1, ReservesPetsMax do
    local card = commonPetCardList[i]
    local petGid = card and card.guid
    local desc = ItemDesc()
    local subCardList = petGid and petGidToBuff145PetCardList and petGidToBuff145PetCardList[petGid] or {}
    desc:FillAsCard(card, subCardList, i, reservesPetNum)
    desc.OnTouchStart = _G.MakeWeakFunctor(self, self.OnTouchStartFromItem)
    table.insert(listDatas, desc)
  end
  self.List:InitGridView(listDatas)
  local itemCount = #listDatas
  self.List:SetItemCount(itemCount)
end

function UMG_Battle_ReservesPets_C:OnActiveAsEnemyTeam(battlePlayer)
  local reservesPetInfos = battlePlayer:GetReservesPetInfos()
  local commonPetInfoList = {}
  local petGidToBuff145PetInfoList = {}
  for i, petInfo in ipairs(reservesPetInfos) do
    local insideInfo = petInfo and petInfo.battle_inside_pet_info
    local buff145SourcePetId = insideInfo and insideInfo.buff145_source_pet or 0
    if 0 == buff145SourcePetId then
      table.insert(commonPetInfoList, petInfo)
    else
      local petInfoList = buff145SourcePetId and petGidToBuff145PetInfoList and petGidToBuff145PetInfoList[buff145SourcePetId] or {}
      table.insert(petInfoList, petInfo)
      if petGidToBuff145PetInfoList and buff145SourcePetId then
        petGidToBuff145PetInfoList[buff145SourcePetId] = petInfoList
      end
    end
  end
  local petGidToCommonPetInfo = {}
  for i, petInfo in ipairs(commonPetInfoList) do
    local insideInfo = petInfo and petInfo.battle_inside_pet_info
    local petGid = insideInfo and insideInfo.pet_id
    if petGidToCommonPetInfo and petGid then
      petGidToCommonPetInfo[petGid] = petInfo
    end
  end
  local buff145PetCount = 0
  local buff145PetCardListCanAddToOuterList = {}
  for petGid, battleCardList in pairs(petGidToBuff145PetInfoList) do
    local sourceBattleCard = petGidToCommonPetInfo and petGid and petGidToCommonPetInfo[petGid]
    for j, card in ipairs(battleCardList) do
      if sourceBattleCard then
        buff145PetCount = buff145PetCount + 1
      else
        table.insert(buff145PetCardListCanAddToOuterList, card)
      end
    end
  end
  for i, card in ipairs(buff145PetCardListCanAddToOuterList) do
    table.insert(commonPetInfoList, card)
  end
  local inBattleCards = battlePlayer and battlePlayer:GetInBattleCards() or DummyTable
  local inBattleNormalPetCount = 0
  for _, card in ipairs(inBattleCards) do
    local petInfo = card and card.petInfo
    local insideInfo = petInfo and petInfo.battle_inside_pet_info
    local buff145SourcePetId = insideInfo and insideInfo.buff145_source_pet or 0
    if 0 == buff145SourcePetId then
      inBattleNormalPetCount = inBattleNormalPetCount + 1
    end
  end
  local totalCommonPetCount = battlePlayer and battlePlayer:GetPetNum() or 0
  local reservesPetNum = totalCommonPetCount - inBattleNormalPetCount
  local listDatas = {}
  local commonPetCardListCount = #commonPetInfoList
  local ReservesPetsMax = math.max(BattleConst.ReservesPetsMax, commonPetCardListCount)
  for i = 1, ReservesPetsMax do
    local info = commonPetInfoList[i]
    local insideInfo = info and info.battle_inside_pet_info
    local petGid = insideInfo and insideInfo.pet_id
    local desc = ItemDesc()
    local subInfoList = petGid and petGidToBuff145PetInfoList and petGidToBuff145PetInfoList[petGid] or {}
    desc:FillAsInfo(info, subInfoList, i, reservesPetNum)
    desc.OnTouchStart = _G.MakeWeakFunctor(self, self.OnTouchStartFromItem)
    table.insert(listDatas, desc)
  end
  self.List:InitGridView(listDatas)
  local itemCount = #listDatas
  self.List:SetItemCount(itemCount)
end

function UMG_Battle_ReservesPets_C:OnDeactive()
  self:UnBindInputAction()
  self:OnRemoveEventListener()
end

function UMG_Battle_ReservesPets_C:UpdatePlayerLeave()
end

function UMG_Battle_ReservesPets_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ReservesPets_C", self, _G.NRCPanelEvent.LoadPanelSucc, self.OnLoadPanelSucc)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ReservesPets_C", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ReservesPets_C", self, _G.NRCGlobalEvent.OnRocoTouchStart, self.OnRocoTouchStartHandler)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ReservesPets_C", self, _G.NRCGlobalEvent.OnRocoTouchMove, self.OnRocoTouchMoveHandler)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ReservesPets_C", self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
end

function UMG_Battle_ReservesPets_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.LoadPanelSucc, self.OnLoadPanelSucc)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchStart, self.OnRocoTouchStartHandler)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchMove, self.OnRocoTouchMoveHandler)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.OnRocoTouchEnd, self.OnRocoTouchEndHandler)
end

function UMG_Battle_ReservesPets_C:OnLoadPanelSucc(PanelData)
  if "BattleChangePetConfirmPanel" == PanelData.panelName then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Battle_ReservesPets_C:OnClosePanel(PanelData)
  if "BattleChangePetConfirmPanel" == PanelData.panelName then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Battle_ReservesPets_C:BindInputAction()
  if self.isBattleState then
    local mappingContext = self:AddInputMappingContext("IMC_CloseBattleTips")
    if mappingContext then
      mappingContext:BindAction("IA_CloseUI", self, "OnPcClose2")
    end
  else
    local mappingContext = self:AddInputMappingContext("IMC_CommonCloseUI")
    if mappingContext then
      mappingContext:BindAction("IA_CloseUI", self, "OnPcClose2")
    end
  end
end

function UMG_Battle_ReservesPets_C:UnBindInputAction()
  if self.isBattleState then
    local mappingContext = self:GetInputMappingContext("IMC_CloseBattleTips")
    if mappingContext then
      mappingContext:UnBindAction("IA_CloseUI")
    end
    self:RemoveInputMappingContext("IMC_CloseBattleTips")
  else
    local mappingContext = self:GetInputMappingContext("IMC_CommonCloseUI")
    if mappingContext then
      mappingContext:UnBindAction("IA_CloseUI")
    end
    self:RemoveInputMappingContext("IMC_CommonCloseUI")
  end
end

function UMG_Battle_ReservesPets_C:OnPcClose2()
  self:DoClose()
end

function UMG_Battle_ReservesPets_C:OnRocoTouchStartHandler(touchIndex, position)
  local dragContext = {}
  dragContext.touchIndex = touchIndex
  local startPositionX = position and position.X or 0
  local startPositionY = position and position.Y or 0
  local startPosition = UE.FVector2D(startPositionX, startPositionY)
  dragContext.startPosition = startPosition
  dragContext.currentPosition = startPosition
  self.dragContextFromMoveStart = dragContext
  self:TryInitDragContext()
end

function UMG_Battle_ReservesPets_C:OnRocoTouchMoveHandler(touchIndex, position)
  local dragContext = self.dragContext
  local dragContextTouchIndex = dragContext and dragContext.touchIndex
  if dragContext and dragContextTouchIndex == touchIndex then
    local positionX = position and position.X or 0
    local positionY = position and position.Y or 0
    local currentPosition = UE.FVector2D(positionX, positionY)
    dragContext.currentPosition = currentPosition
    local startPosition = dragContext and dragContext.startPosition
    local endPosition = dragContext and dragContext.currentPosition
    local DiffVectorX, DiffVectorY
    if startPosition and endPosition then
      local DiffVector = endPosition - startPosition
      DiffVectorX = DiffVector and DiffVector.X
      DiffVectorY = DiffVector and DiffVector.Y
    end
    local threshold = 30
    local DiffVectorYAbs = DiffVectorY and math.abs(DiffVectorY)
    local shouldDoClick = dragContext and dragContext.shouldDoClick
    if DiffVectorYAbs and threshold < DiffVectorYAbs then
      shouldDoClick = false
    end
    dragContext.shouldDoClick = shouldDoClick
  end
end

function UMG_Battle_ReservesPets_C:OnRocoTouchEndHandler(touchIndex)
  local dragContext = self.dragContext
  local dragContextTouchIndex = dragContext and dragContext.touchIndex
  if dragContext and dragContextTouchIndex == touchIndex then
    local shouldDoClick = dragContext and dragContext.shouldDoClick
    if shouldDoClick then
      local card = dragContext and dragContext.card
      local info = dragContext and dragContext.info
      self:OnPetInfoShow(card, info)
    end
  end
  self.dragContextFromMoveStart = nil
  self.dragContext = nil
  self.itemTouchContext = nil
end

function UMG_Battle_ReservesPets_C:OnTouchStartFromItem(touchContext)
  self.itemTouchContext = touchContext
  self:TryInitDragContext()
end

function UMG_Battle_ReservesPets_C:TryInitDragContext()
  local dragContextFromMoveStart = self.dragContextFromMoveStart
  local itemTouchContext = self.itemTouchContext
  if dragContextFromMoveStart and itemTouchContext then
    self:InitDragContext(dragContextFromMoveStart, itemTouchContext)
  end
end

function UMG_Battle_ReservesPets_C:InitDragContext(dragContextFromRocoTouchStart, touchContextFromItem)
  local dragContext = {}
  table.copy(dragContextFromRocoTouchStart, dragContext)
  dragContext.touchIndex = dragContextFromRocoTouchStart and dragContextFromRocoTouchStart.touchIndex
  dragContext.card = touchContextFromItem and touchContextFromItem.card
  dragContext.info = touchContextFromItem and touchContextFromItem.info
  dragContext.shouldDoClick = true
  self.dragContext = dragContext
end

function UMG_Battle_ReservesPets_C:OnPetInfoShow(card, info)
  if card then
    local petBaseConf = card and card.petBaseConf
    local petBaseConfId = petBaseConf and petBaseConf.id
    local petInfo = card and card.petInfo
    local insideInfo = petInfo and petInfo.battle_inside_pet_info
    local extraSdt = insideInfo and insideInfo.extra_sdt
    local data = {
      cardData = card,
      petData = {base_conf_id = petBaseConfId, extra_sdt = extraSdt}
    }
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleChangePetConfirmPanel, data)
  elseif info then
    local data = {battlePetInfo = info}
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleChangePetConfirmPanel, data)
  else
    Log.Warning("UMG_Battle_ReservesPets_Item_C:_OnPetInfoShow battlepet is invalid")
  end
end

return UMG_Battle_ReservesPets_C
