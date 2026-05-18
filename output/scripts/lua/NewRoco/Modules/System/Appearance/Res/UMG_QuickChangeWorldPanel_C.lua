local UMG_QuickChangeWorldPanel_C = _G.NRCPanelBase:Extend("UMG_QuickChangeWorldPanel_C")

function UMG_QuickChangeWorldPanel_C:OnActive()
  self.QuickChangeWorldView:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_QuickChangeWorldPanel_C:OnDeactive()
end

function UMG_QuickChangeWorldPanel_C:OnAddEventListener()
end

function UMG_QuickChangeWorldPanel_C:GetActorByName(name)
  return self.QuickChangeWorldView:getActorByName(name)
end

function UMG_QuickChangeWorldPanel_C:SpawnActor(modelClass, trans)
  return self.QuickChangeWorldView:SpawnActor(modelClass, trans)
end

function UMG_QuickChangeWorldPanel_C:GetViewportWorld()
  return self.QuickChangeWorldView:GetViewportWorld()
end

function UMG_QuickChangeWorldPanel_C:GetQuickChangeWorldView()
  return self.QuickChangeWorldView
end

function UMG_QuickChangeWorldPanel_C:CreateDynamicMaterialInstance(Parent, OptionalName)
  return self.QuickChangeWorldView:CreateDynamicMaterialInstance(Parent, OptionalName)
end

return UMG_QuickChangeWorldPanel_C
