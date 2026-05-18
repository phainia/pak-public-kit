require("UnLuaEx")
local ResTrackerModuleEvent = require("NewRoco.Modules.System.ResTracker.ResTrackerModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local UMG_ResTrackResults_C = _G.NRCViewBase:Extend("UMG_ResTrackResults_C")
local EditorFilter = require("NewRoco.Modules.System.ResTracker.EditorAssetFilter")

function UMG_ResTrackResults_C:OnConstruct()
  self.EditorFilter = EditorFilter()
  self:AddButtonListener(self.ExportCurrentClass, self.ExportCurrent)
  self:AddButtonListener(self.ExportAllClass, self.ExportAll)
  self:AddButtonListener(self.FilterButton, self.ToggleFilter)
  self:ToggleFilter()
end

function UMG_ResTrackResults_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_ResTrackResults_C:OnActive()
  self.CurrentClass = nil
  self:RegisterEvent(self, ResTrackerModuleEvent.ClassItemClicked, self.SelectAssetClass)
end

function UMG_ResTrackResults_C:OnDeactive()
  self:UnRegisterAllEvent()
end

function UMG_ResTrackResults_C:ToggleFilter()
  if self.FilterState == nil then
    self.FilterState = true
  end
  self.FilterState = not self.FilterState
  self.EditorFilter:SetEnable(self.FilterState)
  if self.FilterState then
    self.FilterButton:SetBackgroundColor(UE4.FLinearColor(0.24, 1, 0.33, 1))
  else
    self.FilterButton:SetBackgroundColor(UE4.FLinearColor(1, 1, 1, 1))
  end
  self:BindResults(self.OriginalResult)
end

function UMG_ResTrackResults_C:ExportTab(ClassName)
  local filename = string.format("ResTrack/ResTrack_%s_%s_%s", os.date("%Y_%m_%d_%H_%M_%S"), ClassName, math.random(999999))
  local export = {}
  export[ClassName] = self:ProcessExportItem(ClassName)
  JsonUtils.DumpSaved(filename, export)
  Log.Warning("\229\175\188\229\135\186" .. ClassName)
end

function UMG_ResTrackResults_C:ProcessExportItem(ClassName)
  local Items = {}
  for idx, item in ipairs(self.ResultMap[ClassName]) do
    local str = string.format("%s[%s] ref by %s[%s]", item.AssetName, ClassName, item.ReferName, item.ReferClass)
    table.insert(Items, str)
    if item.FoldChains ~= nil then
      for idx, TheItem in ipairs(item.FoldChains) do
        local Chain = TheItem.Chain
        local ChainStr = "        " .. Chain:ToString()
        table.insert(Items, ChainStr)
      end
    elseif nil ~= item.Chain then
      local ChainStr = "        " .. item.Chain:ToString()
      table.insert(Items, ChainStr)
    end
  end
  return Items
end

function UMG_ResTrackResults_C:ExportCurrent()
  if self.ResultMap == nil or table.isEmpty(self.ResultMap) then
    Log.Warning("\231\187\147\230\158\156\228\184\186\231\169\186, \230\151\160\230\179\149\229\175\188\229\135\186")
    return
  end
  if nil == self.CurrentClass or self.CurrentClass == "All" then
    self:ExportAll()
  else
    self:ExportTab(self.CurrentClass)
  end
end

function UMG_ResTrackResults_C:ExportAll()
  if self.ResultMap == nil or table.isEmpty(self.ResultMap) then
    Log.Warning("\231\187\147\230\158\156\228\184\186\231\169\186, \230\151\160\230\179\149\229\175\188\229\135\186")
    return
  end
  local export = {}
  for ClassName, ItemList in pairs(self.ResultMap) do
    export[ClassName] = self:ProcessExportItem(ClassName)
  end
  local filename = string.format("ResTrack/ResTrack_%s_All_%s", os.date("%Y_%m_%d_%H_%M_%S"), math.random(999999))
  JsonUtils.DumpSaved(filename, export)
  Log.Warning("\229\175\188\229\135\186All")
end

function UMG_ResTrackResults_C:SelectAssetClass(ClassItem)
  local ClassName = ClassItem.data
  if self.CurrentClass == ClassName then
    return
  end
  Log.Warning("Select Class: " .. ClassName)
  self.CurrentClass = ClassName
  self.CurrentItem = ClassItem
  self:ShowResults()
end

function UMG_ResTrackResults_C:BindResults(_Results)
  if nil == _Results then
    return
  end
  Log.Warning("\232\181\132\230\186\144\230\149\176\231\155\174: " .. _Results:Length())
  self.OriginalResult = _Results
  self.ResultMap = self:ProcessRefResults(_Results)
  local Results = self.ResultMap
  local AssetClassList = {}
  for k, v in pairs(Results) do
    table.insert(AssetClassList, k)
  end
  local PriorityAssetClass = {
    "PaperSprite",
    "Texture",
    "Sprite",
    "Material",
    "Niagara",
    "Particle",
    "StaticMesh",
    "NRC",
    "User"
  }
  
  local function SortAsset(a, b)
    local len = #PriorityAssetClass
    local idx_a = len + 1
    local idx_b = len + 1
    for idx, v in ipairs(PriorityAssetClass) do
      if string.find(a, v) and len < idx_a then
        idx_a = idx
      end
      if string.find(b, v) and len < idx_b then
        idx_b = idx
      end
    end
    if idx_a == idx_b then
      return #a < #b
    end
    return idx_a < idx_b
  end
  
  table.sort(AssetClassList, SortAsset)
  table.insert(AssetClassList, 1, "All")
  self.AssetClassList = AssetClassList
  self.ResultClassList:InitList(AssetClassList)
  self:ShowResults()
end

function UMG_ResTrackResults_C:ShowResults()
  local items = {}
  local Results = self.ResultMap
  if not table.isEmpty(Results) then
    if self.CurrentClass == nil or self.CurrentClass == "All" or not Results[self.CurrentClass] == nil then
      for ClassName, ItemList in pairs(Results) do
        for idx, Item in ipairs(ItemList) do
          table.insert(items, Item)
        end
      end
    else
      for idx, Item in ipairs(Results[self.CurrentClass]) do
        table.insert(items, Item)
      end
    end
  end
  Log.Warning("\229\188\149\231\148\168\233\147\190\230\157\161\230\149\176: " .. #items)
  self.ResultList:InitList(items)
  Log.Warning("Results Bind Finish")
end

function UMG_ResTrackResults_C:ProcessRefResults(RefResults)
  local ResultMap = {}
  for i = 1, RefResults:Length() do
    local RefResult = RefResults:Get(i)
    local items = self:ProcessRefResult(RefResult)
    if 0 == #items then
    else
      local AssetClassName = RefResult.AssetObject:GetClassName()
      if nil == ResultMap[AssetClassName] then
        ResultMap[AssetClassName] = {}
      end
      for idx, item in ipairs(items) do
        table.insert(ResultMap[AssetClassName], item)
      end
    end
  end
  return ResultMap
end

function UMG_ResTrackResults_C:ProcessRefResult(RefResult)
  local Items = {}
  local ReferSet = {}
  local RefChains = RefResult.Chains
  local VisitedUMGNode = {}
  for i = 1, RefChains:Length() do
    local RefChain = RefChains:Get(i)
    local Item = self:ProcessRefChain(RefChain, VisitedUMGNode)
    if nil ~= Item then
      if nil == ReferSet[Item.ReferName] then
        table.insert(Items, Item)
        ReferSet[Item.ReferName] = Item
      else
        local TheItem = ReferSet[Item.ReferName]
        if nil == TheItem.FoldChains then
          TheItem.FoldChains = {}
        end
        table.insert(TheItem.FoldChains, Item)
      end
    end
  end
  return Items
end

function UMG_ResTrackResults_C:ProcessRefChain(RefChain, VisitedUMGNode)
  if self.EditorFilter:FilterChain(RefChain) then
    return nil
  end
  local Item = {}
  Item.Chain = RefChain
  local AssetNode = RefChain:GetNode(0)
  if not AssetNode.Object:IsValid() then
    return nil
  end
  Item.AssetName = AssetNode.Object:GetName()
  local UMGNode
  local LocalVisitedUMGNodeSet = {}
  for i = 1, RefChain:Num() - 1 do
    local Node = RefChain:GetNode(i)
    if not Node.Object:IsValid() then
      return nil
    end
    if self.EditorFilter:Filter(Node.Object) then
      return nil
    end
    if string.StartsWith(Node.Object:GetName(), "UMG_") or string.StartsWith(Node.Object:GetClassName(), "UMG_") then
      UMGNode = Node
    end
  end
  if UMGNode then
    Item.ReferName = UMGNode.Object:GetName()
    Item.ReferClass = UMGNode.Object:GetClassName()
  else
    Item.ReferName = RefChain:GetRootNode().Object:GetName()
    Item.ReferClass = RefChain:GetRootNode().Object:GetClassName()
  end
  return Item
end

return UMG_ResTrackResults_C
