local UMG_NpcInfo_EctypeNPC_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_EctypeNPC_C")

function UMG_NpcInfo_EctypeNPC_C:OnActive()
end

function UMG_NpcInfo_EctypeNPC_C:OnDeactive()
end

function UMG_NpcInfo_EctypeNPC_C:OnAddEventListener()
end

function UMG_NpcInfo_EctypeNPC_C:OnConstruct()
end

function UMG_NpcInfo_EctypeNPC_C:OnDestruct()
end

function UMG_NpcInfo_EctypeNPC_C:OnEnable(name, desc, headIconPath, isHeadIconActive, rewardsList, isDone, collectionInfoList)
  self.npcName_1:SetText(name)
  self.npcDesc_1:SetText(desc)
  self:SetHeadIconActive(isHeadIconActive, headIconPath)
  self.DungeonAwardList:InitGridView(rewardsList)
  self.OffTheStocks:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if isDone then
    self.OffTheStocks:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.List:InitGridView(collectionInfoList)
end

function UMG_NpcInfo_EctypeNPC_C:OnDisable()
end

function UMG_NpcInfo_EctypeNPC_C:SetHeadIconActive(shouldActivate, headIconPath)
end

return UMG_NpcInfo_EctypeNPC_C
