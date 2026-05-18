local BattleRogueModuleData = _G.NRCData:Extend("BattleRogueModuleData")

function BattleRogueModuleData:Ctor()
  NRCData.Ctor(self)
  self.CurLevelID = -1
  self.CurNodeIndex = -1
  self.LevelInfo = {}
  self.CurEventIndex = -1
  self.UIEventDatas = {}
  self.CurEventInfos = nil
  self.CombineEventIndexes = {}
  self.CombineEventBitSet = {}
  self.CombineConfBitSet = {}
  self.CombineTypeMaxNum = {}
  self.EventResult = nil
  self.RogueCoinNum = nil
  self.RefreshNeedCoinNum = nil
  self.RefreshBaseCost = 0
  self.UIBuffDatas = {}
  self.CurBuffDatas = {}
  self.SelectCombineCardList = {}
  self.IsOpenSettlementTips = false
  self.SelectBuffList = {}
  self.CanChooseBuffNum = nil
  self.bFinishedChallenge = nil
  self.PetInfo = {}
end

function BattleRogueModuleData:GetUIEventDatas()
  return self.UIEventDatas
end

function BattleRogueModuleData:GetLevelInfo()
  return self.LevelInfo
end

function BattleRogueModuleData:GetCurrentUINodeInfo()
  return self.LevelInfo.Nodes[self.CurNodeIndex]
end

function BattleRogueModuleData:GetRefreshNeedCoinNum()
  return self.RefreshNeedCoinNum
end

function BattleRogueModuleData:GetCombineEventIndexes()
  return self.CombineEventIndexes
end

function BattleRogueModuleData:SetSelectCombineCardList(_SelectCombineCardList)
  self.SelectCombineCardList = _SelectCombineCardList or {}
end

function BattleRogueModuleData:GetSelectCombineCardList()
  return self.SelectCombineCardList
end

function BattleRogueModuleData:GetRogueCoinNum()
  return self.RogueCoinNum
end

function BattleRogueModuleData:AddOrRemoveCombineCard(Add, Index)
  if Add then
    table.insert(self.SelectCombineCardList, Index)
  else
    for i = #self.SelectCombineCardList, 1, -1 do
      if Index == self.SelectCombineCardList[i] then
        table.remove(self.SelectCombineCardList, i)
      end
    end
  end
  Log.Dump(self.SelectCombineCardList, 6, "BattleRogueModuleData:AddOrRemoveCombineCard")
end

function BattleRogueModuleData:SetIsOpenSettlementTips(_IsOpenSettlementTips)
  self.IsOpenSettlementTips = _IsOpenSettlementTips
end

function BattleRogueModuleData:GetIsOpenSettlementTips()
  return self.IsOpenSettlementTips
end

function BattleRogueModuleData:GetUIBuffDatas()
  return self.UIBuffDatas
end

function BattleRogueModuleData:GetCurBuffDatas()
  return self.CurBuffDatas
end

function BattleRogueModuleData:SetSelectBuffList(_SelectBuffList)
  self.SelectBuffList = _SelectBuffList or {}
end

function BattleRogueModuleData:AddOrRemoveBuffList(Add, _SelectBuffIndex)
  if Add then
    table.insert(self.SelectBuffList, _SelectBuffIndex)
  else
    for i = #self.SelectBuffList, 1, -1 do
      if _SelectBuffIndex == self.SelectBuffList[i] then
        table.remove(self.SelectBuffList, i)
      end
    end
  end
end

function BattleRogueModuleData:GetSelectBuffList()
  return self.SelectBuffList
end

function BattleRogueModuleData:SetPetInfo(_PetInfo)
  self.PetInfo = _PetInfo
end

function BattleRogueModuleData:GetPetInfo()
  return self.PetInfo
end

function BattleRogueModuleData:GetCanChooseBuffNum()
  return self.CanChooseBuffNum
end

return BattleRogueModuleData
