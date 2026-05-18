local UMG_NPCList_C = _G.NRCViewBase:Extend("UMG_NPCList_C")

function UMG_NPCList_C:OnConstruct()
  self.npcItems = {
    self.NPCItem1,
    self.NPCItem2,
    self.NPCItem3,
    self.NPCItem4,
    self.NPCItem5
  }
end

function UMG_NPCList_C:OnDestruct()
end

function UMG_NPCList_C:OnActive()
end

function UMG_NPCList_C:OnDeactive()
end

function UMG_NPCList_C:SetDatas(npcDatas)
  if self.npcItems == nil then
    self.npcItems = {
      self.NPCItem1,
      self.NPCItem2,
      self.NPCItem3,
      self.NPCItem4,
      self.NPCItem5
    }
  end
  local itemNum = #npcDatas
  for i = 1, 5 do
    if i <= itemNum then
      self.npcItems[i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.npcItems[i]:SetData(npcDatas[i])
      self.npcItems[i]:PlayItemShowAnim()
    else
      self.npcItems[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_NPCList_C:PlayOpenAnim()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
end

function UMG_NPCList_C:ClearSelectedState()
  if self.npcItems == nil then
    self.npcItems = {
      self.NPCItem1,
      self.NPCItem2,
      self.NPCItem3,
      self.NPCItem4,
      self.NPCItem5
    }
  end
  for i = 1, 5 do
    self.npcItems[i]:OnSelected(false)
  end
end

function UMG_NPCList_C:OnAnimationFinished(Anim)
  if Anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_NPCList_C
