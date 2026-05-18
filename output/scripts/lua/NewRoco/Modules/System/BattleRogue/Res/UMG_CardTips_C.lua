local BattleRogueModuleEvent = require("NewRoco.Modules.System.BattleRogue.BattleRogueModuleEvent")
local UMG_CardTips_C = _G.NRCPanelBase:Extend("UMG_CardTips_C")

function UMG_CardTips_C:OnConstruct()
  self.data = self.module:GetData("BattleRogueModuleData")
  self.data:SetSelectCombineCardList(nil)
  self:OnAddEventListener()
end

function UMG_CardTips_C:OnDestruct()
end

function UMG_CardTips_C:OnActive()
  self:SetBaseInfo()
  self:SetCardList()
end

function UMG_CardTips_C:OnDeactive()
end

function UMG_CardTips_C:OnAddEventListener()
  self:AddButtonListener(self.UpdateBtn.btnLevelUp, self.OnUpdateBtn)
  self:AddButtonListener(self.CompoundBtn.btnLevelUp, self.OnCompoundBtn)
  self:AddButtonListener(self.ConFirmBtn.btnLevelUp, self.OnConFirmBtn)
  self:RegisterEvent(self, BattleRogueModuleEvent.OnUpdateEvents, self.OnUpdateEvents)
  self:RegisterEvent(self, BattleRogueModuleEvent.OnUpdateCoinNum, self.OnUpdateCoinNum)
end

function UMG_CardTips_C:SetBaseInfo()
  self:SetRogueCoinAndNeedCoin(self.data:GetRogueCoinNum(), self.data:GetRefreshNeedCoinNum())
end

function UMG_CardTips_C:SetRogueCoinAndNeedCoin(RogueCoin, RefreshNeedCoinNum)
  local MoneyList = {
    {
      moneyType = _G.Enum.VisualItem.VI_ROGUE_COIN,
      sum = RogueCoin,
      IsShowBuyIcon = false
    }
  }
  self.MoneyList:InitGridView(MoneyList)
  self.UpdateBtn:SetTitleTextAndIcon(nil, RefreshNeedCoinNum)
end

function UMG_CardTips_C:OnUpdateCoinNum(RogueCoin, RefreshNeedCoinNum)
  self:SetRogueCoinAndNeedCoin(RogueCoin, RefreshNeedCoinNum)
end

function UMG_CardTips_C:SetCardList()
  local UIEventDatas = self.data:GetUIEventDatas()
  self.CardList:InitGridView(UIEventDatas)
end

function UMG_CardTips_C:SuccessivelyCombine(Index)
end

function UMG_CardTips_C:OnUpdateEvents(UIEventDatas, CombineEventIndexes)
  self:SetCardList()
end

function UMG_CardTips_C:OnUpdateBtn()
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SendRefreshEventReq)
end

function UMG_CardTips_C:OnCompoundBtn()
  local CheckCombine = _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.CheckCombineIndexes, self.data:GetSelectCombineCardList())
  if not CheckCombine then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\144\136\230\136\144\229\164\177\232\180\165\232\175\183\233\135\141\230\150\176\233\128\137\230\139\169(\230\181\139\232\175\149)")
    return
  end
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SendCombineEventReq, self.data:GetSelectCombineCardList())
end

function UMG_CardTips_C:OnConFirmBtn()
  local SelectCombineCardList = self.data:GetSelectCombineCardList()
  if 1 ~= #SelectCombineCardList then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\233\128\137\230\139\169\230\156\137\232\175\175(\230\181\139\232\175\149)")
    return
  end
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.SendChooseRogueEventReq, SelectCombineCardList[1])
  _G.NRCModuleManager:DoCmd(BattleRogueModuleCmd.HideMainInfo, false)
  self:DoClose()
end

return UMG_CardTips_C
