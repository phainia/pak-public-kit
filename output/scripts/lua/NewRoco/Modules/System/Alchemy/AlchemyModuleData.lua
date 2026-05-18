local AlchemyModuleData = _G.NRCData:Extend("AlchemyModuleData")

function AlchemyModuleData:Ctor()
  NRCData.Ctor(self)
  self.AvailableRecipeMap = {}
end

function AlchemyModuleData:RefreshAvailableRecipeMap(exchangeRecipe, bIsFullUpdate)
  if bIsFullUpdate then
    self.AvailableRecipeMap = {}
  end
  if exchangeRecipe and exchangeRecipe.recipes and #exchangeRecipe.recipes > 0 then
    for i, v in ipairs(exchangeRecipe.recipes) do
      self.AvailableRecipeMap[v.exchange_id] = not not v.is_online_shared
    end
  end
end

function AlchemyModuleData:GetAllAvailableRecipeIds(bIsUseSharedRecipe)
  local result = {}
  for k, v in pairs(self.AvailableRecipeMap) do
    if false == v or bIsUseSharedRecipe then
      table.insert(result, k)
    end
  end
  return result
end

function AlchemyModuleData:CheckExchangeAvailable(exchangeId, bIsUseSharedRecipe)
  if bIsUseSharedRecipe then
    return self.AvailableRecipeMap[exchangeId] ~= nil
  end
  return self.AvailableRecipeMap[exchangeId] == false
end

return AlchemyModuleData
