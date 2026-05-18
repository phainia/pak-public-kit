local UMG_BP_Visible_Item_C = _G.NRCPanelBase:Extend("UMG_BP_Visible_Item_C")

function UMG_BP_Visible_Item_C:OnConstruct()
end

function UMG_BP_Visible_Item_C:SetNodes(selfNode, parentNode, umgParent)
  self.selfNode = selfNode
  self.parentNode = parentNode
  self.ParentUmg = umgParent
  self.VerticalContent:ClearChildren()
  self.childs = {}
  self:UpdateUI()
end

function UMG_BP_Visible_Item_C:UpdateUI()
  if self.selfNode then
    table.insert(self.childs, self:CreateNode(self.selfNode))
  elseif self.parentNode then
    if self.parentNode:IsGroupHead() then
      local gId = self.parentNode:GetGroupID()
      local groups = self.ParentUmg.performPlayer.PerformGroupLst[gId].GroupNodes
      for i = 1, 15 do
        for _, v in ipairs(groups) do
          if v:GetCastMoment() == i and v ~= self.parentNode then
            table.insert(self.childs, self:CreateNode(v))
          end
        end
        for j = gId + 1, #self.ParentUmg.performPlayer.PerformGroupLst do
          local head = self.ParentUmg.performPlayer.PerformGroupLst[j].GroupNodes[1]
          if head:GetCastMoment() == i and head:GetGroupRef() == gId then
            table.insert(self.childs, self:CreateNode(head))
          end
        end
      end
    end
  else
    for _, v in ipairs(self.ParentUmg.performPlayer.PerformClusterLst) do
      table.insert(self.childs, self:CreateNode(v.HeadGroup.HeadNode))
    end
  end
end

function UMG_BP_Visible_Item_C:CreateNode(node)
  local item = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), self.nodeClass)
  local slot = self.VerticalContent:AddChildToVerticalBox(item)
  slot:SetSize(UE4.FSlateChildSize(1, UE4.ESlateSizeRule.Fill))
  item:SetUI(node, self.ParentUmg, self.selfNode, self.parentNode)
  return item
end

function UMG_BP_Visible_Item_C:Clear()
  self.childs = nil
end

function UMG_BP_Visible_Item_C:OnDestruct()
  self.selfNode = nil
  self.parentNode = nil
  self.ParentUmg = nil
  self:Clear()
end

return UMG_BP_Visible_Item_C
