local UMG_SimpleList_C = _G.NRCPanelBase:Extend("UMG_SimpleList_C")

function UMG_SimpleList_C:OnActive()
end

function UMG_SimpleList_C:OnDeactive()
end

function UMG_SimpleList_C:OnAddEventListener()
end

function UMG_SimpleList_C:OnConstruct()
end

function UMG_SimpleList_C:OnDestruct()
end

function UMG_SimpleList_C:SetListInfo(type)
  local itemList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, type)
  self.List:InitGridView(itemList)
end

return UMG_SimpleList_C
