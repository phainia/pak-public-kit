local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FriendOnline_FruitItem_C = Base:Extend("UMG_FriendOnline_FruitItem_C")

function UMG_FriendOnline_FruitItem_C:OnConstruct()
end

function UMG_FriendOnline_FruitItem_C:OnDestruct()
end

function UMG_FriendOnline_FruitItem_C:OnItemUpdate(_data, datalist, index)
  if _data then
    local playerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
    if _data.uin == playerUin then
      self.NRCSwitcher_65:SetActiveWidgetIndex(1)
    else
      self.NRCSwitcher_65:SetActiveWidgetIndex(0)
    end
    local VisIndex = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorIndex, _data.uin) or 0
    self.Text_Sort:SetText(string.format("%dP", VisIndex))
    if _data.FruitInfo and type(_data.FruitInfo) == "table" then
      table.sort(_data.FruitInfo, function(a, b)
        local aId = a.fruit_id or 0
        local bId = b.fruit_id or 0
        if 0 == aId and 0 ~= bId then
          return false
        end
        if 0 == bId and 0 ~= aId then
          return true
        end
        return aId < bId
      end)
    end
    self.Item:InitGridView(_data.FruitInfo)
  end
end

function UMG_FriendOnline_FruitItem_C:OnItemSelected(_bSelected)
end

return UMG_FriendOnline_FruitItem_C
