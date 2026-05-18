local MainUIModuleUtils = {}

function MainUIModuleUtils.SortMagicListByPriority(magicList)
  if not magicList or 0 == #magicList then
    return magicList
  end
  local sortedList = {}
  for i, item in ipairs(magicList) do
    sortedList[i] = item
  end
  table.sort(sortedList, function(a, b)
    local priorityA = math.huge
    local priorityB = math.huge
    local magicIdA = math.huge
    local magicIdB = math.huge
    if a then
      local bagItemConfA = _G.DataConfigManager:GetBagItemConf(a.id)
      if bagItemConfA and bagItemConfA.magic_id then
        magicIdA = bagItemConfA.magic_id
        local magicBaseConfA = _G.DataConfigManager:GetMagicBaseConf(bagItemConfA.magic_id)
        if magicBaseConfA and magicBaseConfA.magic_priority then
          priorityA = magicBaseConfA.magic_priority
        end
      end
    end
    if b then
      local bagItemConfB = _G.DataConfigManager:GetBagItemConf(b.id)
      if bagItemConfB and bagItemConfB.magic_id then
        magicIdB = bagItemConfB.magic_id
        local magicBaseConfB = _G.DataConfigManager:GetMagicBaseConf(bagItemConfB.magic_id)
        if magicBaseConfB and magicBaseConfB.magic_priority then
          priorityB = magicBaseConfB.magic_priority
        end
      end
    end
    if priorityA ~= priorityB then
      return priorityA < priorityB
    end
    return magicIdA < magicIdB
  end)
  return sortedList
end

return MainUIModuleUtils
