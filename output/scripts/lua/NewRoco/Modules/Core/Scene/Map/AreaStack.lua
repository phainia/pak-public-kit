local Class = _G.MakeSimpleClass
local AreaStack = Class("AreaStack")

function AreaStack:Ctor(priority_key)
  self.ZoneInfoArray = Array()
  self.area_func_map = {}
  self.priority_key = priority_key
end

function AreaStack:Clear()
  self.ZoneInfoArray:Clear()
end

function AreaStack:EnterArea(area_func_conf)
  local index = 1
  local already_exist = false
  if area_func_conf[self.priority_key] == nil then
    Log.Error("AreaFunc", area_func_conf.id, self.priority_key, "is null")
    return
  end
  for i, info in ipairs(self.ZoneInfoArray:Items()) do
    if area_func_conf[self.priority_key] < info.priority then
      index = i + 1
    end
    if area_func_conf.id == info.area_func_id then
      already_exist = true
    end
  end
  if not already_exist then
    self.ZoneInfoArray:Insert(index, {
      area_func_id = area_func_conf.id,
      priority = area_func_conf[self.priority_key]
    })
    self.area_func_map[area_func_conf.id] = true
  end
  return index, already_exist
end

function AreaStack:ExitArea(area_func_conf)
  local index = 0
  for i, info in ipairs(self.ZoneInfoArray:Items()) do
    if area_func_conf.id == info.area_func_id then
      index = i
    end
  end
  if 0 ~= index then
    self.ZoneInfoArray:RemoveAt(index)
    self.area_func_map[area_func_conf.id] = nil
  end
  return index
end

function AreaStack:GetFirstItem()
  return self.ZoneInfoArray:First()
end

function AreaStack:IsInArea(area_func_id)
  if self.area_func_map[area_func_id] then
    return true
  end
  return false
end

function AreaStack:GetAreaArray()
  return self.ZoneInfoArray
end

return AreaStack
