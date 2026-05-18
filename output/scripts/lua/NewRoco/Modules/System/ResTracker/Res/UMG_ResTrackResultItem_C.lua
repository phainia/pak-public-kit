require("UnLuaEx")
local ResTrackerModuleEvent = require("NewRoco.Modules.System.ResTracker.ResTrackerModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ResTrackResultItem_C = Base:Extend("UMG_ResTrackResultItem_C")

function UMG_ResTrackResultItem_C:OnConstruct()
end

function UMG_ResTrackResultItem_C:OnDestruct()
end

function UMG_ResTrackResultItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self:ShowItem()
end

function UMG_ResTrackResultItem_C:ShowItem()
  self.detail = false
  local str = string.format("%s <- %s[%s]", self.data.AssetName, self.data.ReferName, self.data.ReferClass)
  self.Text:SetText(str)
end

function UMG_ResTrackResultItem_C:ShowDetail()
  Log.Warning("\229\177\149\231\164\186\231\187\134\232\138\130")
  self.detail = true
  local Item = self.data
  local str = string.format("%s <- %s[%s]", self.data.AssetName, self.data.ReferName, self.data.ReferClass)
  local num = 0
  if Item.FoldChains ~= nil then
    Log.Dump(Item, 5, "Dump Item Detail")
    for idx, Item in ipairs(Item.FoldChains) do
      local Chain = Item.Chain
      local FirstNode = Chain:GetNode(0)
      local line = string.format("\r\n\t%s[%s]", FirstNode.Object:GetName(), FirstNode.Object:GetClassName())
      for i = 1, Chain:Num() - 1 do
        local Node = Chain:GetNode(i)
        if not Node.Object:IsValid() then
          goto lbl_81
        end
        line = line .. string.format(" <- %s[%s]", Node.Object:GetName(), Node.Object:GetClassName())
      end
      str = str .. line
      num = num + 1
      ::lbl_81::
    end
  else
    local Chain = Item.Chain
    local FirstNode = Chain:GetNode(0)
    local line = string.format("\r\n\t%s[%s]", FirstNode.Object:GetName(), FirstNode.Object:GetClassName())
    for i = 1, Chain:Num() - 1 do
      local Node = Chain:GetNode(i)
      if not Node.Object:IsValid() then
        goto lbl_135
      end
      line = line .. string.format(" <- %s[%s]", Node.Object:GetName(), Node.Object:GetClassName())
    end
    str = str .. line
    num = num + 1
  end
  ::lbl_135::
  Log.Warning(num)
  if 0 == num then
    str = str .. string.format("\r\n\tPointer Is InValid.")
  end
  self.Text:SetText(str)
end

function UMG_ResTrackResultItem_C:ToggleDetail(selected)
  if selected then
    if self.detail then
      self:ShowItem()
    else
      self:ShowDetail()
    end
  else
    if self.data == nil then
      return
    end
    self:ShowItem()
  end
end

function UMG_ResTrackResultItem_C:OnItemSelected(selected)
  self:ToggleDetail(selected)
  if not selected then
    return
  end
  Log.Debug("UMG_ResTrackResultItem_C:OnClick: " .. tostring(self.data) .. ": " .. tostring(selected))
  local TrackerModule = _G.NRCModuleManager:GetModule("ResTrackerModule")
  TrackerModule:DispatchEvent(ResTrackerModuleEvent.ResultItemClicked, self.data)
end

return UMG_ResTrackResultItem_C
