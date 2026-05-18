local UMG_NpcInfo_ChallengeNPC_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_ChallengeNPC_C")

function UMG_NpcInfo_ChallengeNPC_C:OnActive()
end

function UMG_NpcInfo_ChallengeNPC_C:OnDeactive()
end

function UMG_NpcInfo_ChallengeNPC_C:OnAddEventListener()
end

function UMG_NpcInfo_ChallengeNPC_C:OnConstruct()
end

function UMG_NpcInfo_ChallengeNPC_C:OnDestruct()
end

function UMG_NpcInfo_ChallengeNPC_C:OnEnable(title, desc, icon, itemList, visitorIndex)
  print("\230\137\147\229\188\128ChallengeNPC Panel")
  self.npcName_7:SetText(title)
  self.npcDesc_5:SetText(desc)
  if itemList then
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Node_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.VisitorIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DungeonAwardList_2:InitGridView(itemList)
    self.Node_3:SetPath(icon)
  else
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Node_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.VisitorIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.VisitorIcon:SetPath(icon)
  end
  if visitorIndex and visitorIndex > 0 then
    self.IndexText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IndexText:SetText(tostring(visitorIndex))
  else
    self.IndexText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_NpcInfo_ChallengeNPC_C:OnDisable()
  print("\229\133\179\233\151\173ChallengeNPC Panel")
end

return UMG_NpcInfo_ChallengeNPC_C
