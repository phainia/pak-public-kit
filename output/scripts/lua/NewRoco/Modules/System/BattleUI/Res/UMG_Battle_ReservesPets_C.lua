local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local ItemDesc = _G.NRCClass:Extend("ItemDesc")

function ItemDesc:FillAsCard(card, index, reservesPetNum)
  self.card = card
  if self.card then
    self.reservesState = BattleEnum.ReservesPetState.Appeared
  elseif index <= reservesPetNum then
    self.reservesState = BattleEnum.ReservesPetState.NotAppeared
  else
    self.reservesState = BattleEnum.ReservesPetState.NotExist
  end
end

function ItemDesc:FillAsInfo(info, index, reservesPetNum)
  self.info = info
  if self.info then
    self.reservesState = BattleEnum.ReservesPetState.Appeared
  elseif index <= reservesPetNum then
    self.reservesState = BattleEnum.ReservesPetState.NotAppeared
  else
    self.reservesState = BattleEnum.ReservesPetState.NotExist
  end
end

local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_ReservesPets_C = _G.NRCPanelBase:Extend("UMG_Battle_ReservesPets_C")

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
  local reservesPetNum = battlePlayer:GetPetNum() - #battlePlayer:GetInBattleCards()
  local listDatas = {}
  for i = 1, BattleConst.ReservesPetsMax do
    local card = reservesPetCards[i]
    local desc = ItemDesc()
    desc:FillAsCard(card, i, reservesPetNum)
    table.insert(listDatas, desc)
  end
  self.List:InitGridView(listDatas)
end

function UMG_Battle_ReservesPets_C:OnActiveAsEnemyTeam(battlePlayer)
  local reservesPetInfos = battlePlayer:GetReservesPetInfos()
  local reservesPetNum = battlePlayer:GetPetNum() - #battlePlayer:GetInBattleCards()
  local listDatas = {}
  for i = 1, BattleConst.ReservesPetsMax do
    local info = reservesPetInfos[i]
    local desc = ItemDesc()
    desc:FillAsInfo(info, i, reservesPetNum)
    table.insert(listDatas, desc)
  end
  self.List:InitGridView(listDatas)
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
end

function UMG_Battle_ReservesPets_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.LoadPanelSucc, self.OnLoadPanelSucc)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
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

return UMG_Battle_ReservesPets_C
