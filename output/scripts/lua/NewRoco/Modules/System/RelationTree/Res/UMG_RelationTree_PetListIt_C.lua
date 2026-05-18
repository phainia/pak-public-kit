local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RelationTree_PetListIt_C = Base:Extend("UMG_RelationTree_PetListIt_C")

function UMG_RelationTree_PetListIt_C:OnConstruct()
end

function UMG_RelationTree_PetListIt_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    return
  end
  self._data = _data
  self.datalist = datalist
  self.index = index
  if 1 == #self._data then
    self.Switcher:SetActiveWidgetIndex(1)
    self.RelationTree_PetItem_3:SetData(self._data[1])
    if self._data[1].InteractionTreeTypeDefault ~= Enum.InteractiontreeTypeDefault.ITTD_EMPTY then
      self.Switcher_Line1:SetActiveWidgetIndex(1)
    else
      self.Switcher_Line1:SetActiveWidgetIndex(0)
    end
  else
    self.Switcher:SetActiveWidgetIndex(0)
    for i = 1, 3 do
      local ItemStr = string.format("RelationTree_PetItem_%d", i)
      local LineStr = string.format("Switcher_Line%d", i)
      if i <= #self._data then
        self[ItemStr]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self[LineStr]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if self._data[i].Unlock then
          if self._data[i].InteractionTreeTypeDefault == Enum.InteractiontreeTypeDefault.ITTD_CLOSE then
            local PetData = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetPetInfoData)
            local isCan = false
            if PetData then
              local BaseId = PetData.base_conf_id or 0
              local BondId = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetPetFashionBondID, BaseId)
              if BondId then
                local IsHaveAnim = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetBondInteractID, BondId)
                local IsHave = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetSelfIsHaveBondID, BondId)
                if IsHave and IsHaveAnim then
                  isCan = true
                end
              end
            end
            if isCan then
              self[LineStr]:SetActiveWidgetIndex(1)
            else
              self[LineStr]:SetActiveWidgetIndex(0)
            end
          else
            self[LineStr]:SetActiveWidgetIndex(1)
          end
        end
        self[ItemStr]:SetData(self._data[i])
      else
        self[ItemStr]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self[LineStr]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_RelationTree_PetListIt_C:UpdateSelectItemChange(NodeId)
  for i = 1, 3 do
    local ItemStr = string.format("RelationTree_PetItem_%d", i)
    if self[ItemStr] then
      self[ItemStr]:UpdateItemSelect(NodeId)
    end
  end
end

function UMG_RelationTree_PetListIt_C:OnItemSelected(_bSelected)
end

function UMG_RelationTree_PetListIt_C:OnDeactive()
end

function UMG_RelationTree_PetListIt_C:OnDestruct()
end

return UMG_RelationTree_PetListIt_C
