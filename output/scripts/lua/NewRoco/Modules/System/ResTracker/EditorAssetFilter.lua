local EditorAssetFilter = _G.Singleton:Extend("EditorAssetFilter")

function EditorAssetFilter:Ctor()
  self.ChainNodeClassNameFilterAssertEqualSet = {
    "WidgetBlueprint",
    "Blueprint",
    "AnimBlueprint",
    "UnrealEdEngine",
    "EditorEngine",
    "AnimSequence",
    "InvalidClassName"
  }
  self.AssetNodeClassNameFilterAssertEqualSet = {"Font", "FontFace"}
  self.ChainNodeObjNameFilterAssertContainSet = {"Default__"}
  self.AssetNodeObjNameFilterAssertContainSet = {"Default__"}
  self.Enable = true
end

function EditorAssetFilter:SetEnable(status)
  self.Enable = status
end

function EditorAssetFilter:FilterChain(RefChain)
  if self.Enable == false then
    return false
  end
  local AssetNode = RefChain:GetNode(0).Object
  if table.contains(self.AssetNodeClassNameFilterAssertEqualSet, AssetNode:GetClassName()) then
    return true
  end
  for idx, value in ipairs(self.AssetNodeObjNameFilterAssertContainSet) do
    if string.find(AssetNode:GetName(), value) then
      return true
    end
  end
  return false
end

function EditorAssetFilter:Filter(Object)
  if string.StartsWith(Object:GetClassName(), "UMG_ResTrack") then
    return true
  end
  if self.Enable == false then
    return false
  end
  if Object:IsInBlueprint() then
    return true
  end
  if Object:IsEditorOnly() then
    return true
  end
  if Object:IsClassDefaultObject() then
    return true
  end
  if table.contains(self.ChainNodeClassNameFilterAssertEqualSet, Object:GetClassName()) then
    return true
  end
  for idx, value in ipairs(self.ChainNodeObjNameFilterAssertContainSet) do
    if string.find(Object:GetName(), value) then
      return true
    end
  end
  return false
end

return EditorAssetFilter
