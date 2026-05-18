local UMG_PetEvolutionReward_C = _G.NRCPanelBase:Extend("UMG_PetEvolutionReward_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_PetEvolutionReward_C:OnConstruct()
  self.uiData = {}
  self.uiItem = {}
  local itemPanels = {}
  local itemIcons = {
    self.item1,
    self.item2,
    self.item3,
    self.item4
  }
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    table.insert(itemPanels, self.itemParent:GetChildAt(i))
  end
  self.uiItem.itemIcons = itemIcons
  self.uiItem.itemPanels = itemPanels
  self.uiItem.itemPanelSize = self.itemParent.Slot:GetSize()
end

function UMG_PetEvolutionReward_C:OnDestruct()
  table.clear(self.uiItem)
  self.uiData = nil
  self.uiItem = nil
end

function UMG_PetEvolutionReward_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  self.uiData.petData = _param.petData
  self.uiData.itemList = _param.rewardItems
  self:OnAddEventListener()
  self:updatePanelInfo()
end

function UMG_PetEvolutionReward_C:OnDeactive()
end

function UMG_PetEvolutionReward_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose, self.OnBtnCloseClick)
end

function UMG_PetEvolutionReward_C:OnRemoveEventListener()
end

function UMG_PetEvolutionReward_C:updatePanelInfo()
  self:updateItemInfo(self.uiData.itemList)
end

function UMG_PetEvolutionReward_C:updateItemInfo(_items)
  local itemTypeCount = _items and #_items or 0
  local itemPanels = self.uiItem.itemPanels
  local itemPanelCount = #itemPanels
  local itemPanelSize = self.uiItem.itemPanelSize
  local ChildrenCount = self.itemParent:GetChildrenCount()
  for i = 0, ChildrenCount - 1 do
    local index = i + 1
    local childItem = self.itemParent:GetChildAt(i)
    if i < itemTypeCount then
      self.uiItem.itemIcons[index]:SetData(_items[index])
      childItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      childItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetEvolutionReward_C:OnBtnCloseClick()
  local uiData = self.uiData
  local petData = uiData.petData
  if petData then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    local curEvolutionIndex = petData.evolution_chosen_idx and petData.evolution_chosen_idx + 1 or 1
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetEvolutionTaskPanel, {
      petData = petData,
      petBaseConf = petBaseConf,
      curEvolutionIndex = curEvolutionIndex
    })
  end
  self:DoClose()
end

return UMG_PetEvolutionReward_C
