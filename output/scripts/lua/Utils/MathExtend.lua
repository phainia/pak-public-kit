local MathExtend = {}

function MathExtend.GetRandomSequence_TArray(items, num)
  local ans = {}
  for i = 1, num do
    local last = items:Length() - (i - 1)
    local index = UE4.UKismetMathLibrary.RandomIntegerInRange(1, last)
    local item = items:Get(index)
    table.insert(ans, item)
    items:Swap(index, last)
  end
  return ans
end

function MathExtend.GetRandomSequence_LuaTable(items, num)
  local ans = {}
  for i = 1, num do
    local last = #items - (i - 1)
    local index = math.random(1, last)
    local item = items[index]
    table.insert(ans, item)
    items[index] = items[last]
    items[last] = item
  end
  return ans
end

local integer
return MathExtend
