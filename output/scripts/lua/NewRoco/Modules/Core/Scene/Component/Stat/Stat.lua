local Stat = Class()
Stat.StatApplyType = {
  BaseValue = 0,
  BaseValueOverride = 1,
  Percent = 2
}

function Stat:Ctor(name, value)
  self.name = name
  self.statValues = {}
  self.statValues[1] = {baseValue = value}
  self.statIds = {1}
  self.value = value
end

function Stat:Apply(newValue, applyType)
  applyType = applyType or Stat.StatApplyType.BaseValueOverride
  local id
  for k, v in pairs(self.statValues) do
    if -1 == v then
      id = k
      break
    end
  end
  id = id or #self.statIds + 1
  local statValue = {}
  local baseType = type(self.statValues[self.statIds[1]].baseValue)
  if applyType == Stat.StatApplyType.BaseValueOverride then
    if nil == newValue or type(newValue) == baseType then
      statValue.baseValueOverride = newValue
    elseif "string" == baseType then
      local newValueStr = UE.UNRCStatics.GetObjectPath(newValue)
      if "" ~= newValueStr then
        statValue.baseValueOverride = newValueStr
      end
    else
      Log.Error("Stat:Apply Value Type Miss Match ", baseType, type(newValue))
      return -1
    end
  elseif "number" == baseType then
    if applyType == Stat.StatApplyType.BaseValue then
      statValue.baseValue = newValue
    elseif applyType == Stat.StatApplyType.Percent then
      statValue.percent = newValue
    else
      Log.Error("Stat:Apply Unknown StatApplyType ", applyType)
      return -1
    end
  else
    Log.Error("Stat:Apply Can not Apply BaseValue or Percent to a Non Numeric Stat ", applyType)
    return -1
  end
  self.statValues[id] = statValue
  table.insert(self.statIds, id)
  return id
end

function Stat:ApplyByTable(valueTable)
  local baseType = type(self.statValues[self.statIds[1]].baseValue)
  if "number" ~= baseType then
    Log.Error("Stat:Apply Can not Apply BaseValueOverride or Percent to a Non Numeric Stat ", applyType)
    return -1
  end
  local id
  for k, v in pairs(self.statValues) do
    if -1 == v then
      id = k
      break
    end
  end
  id = id or #self.statIds + 1
  local statValue = {}
  statValue.baseValue = valueTable.baseValue
  statValue.percent = valueTable.percent
  statValue.baseValueOverride = valueTable.baseValueOverride
  self.statValues[id] = statValue
  table.insert(self.statIds, id)
  return id
end

function Stat:Remove(id)
  self.statValues[id] = -1
  local statId
  for k, v in pairs(self.statIds) do
    if v == id then
      statId = k
      break
    end
  end
  if nil == statId then
    Log.Error("RemoveStat error: can't find stat id", id)
    return
  end
  table.remove(self.statIds, statId)
end

function Stat:GetValue()
  local value = 0
  local percent = 0
  local baseOverridden = false
  if tonumber(self.statValues[self.statIds[1]].baseValue) then
    for i = #self.statIds, 1, -1 do
      local statValue = self.statValues[self.statIds[i]]
      if not baseOverridden then
        if statValue.baseValueOverride then
          value = statValue.baseValueOverride
          baseOverridden = true
        elseif statValue.baseValue then
          value = value + statValue.baseValue
        end
      end
      if statValue.percent then
        percent = percent + statValue.percent
      end
    end
    self.value = value * math.max(1 + percent, 0)
    return self.value
  else
    local latestId = self.statIds[#self.statIds]
    local statValue = self.statValues[latestId]
    self.value = statValue.baseValueOverride or statValue.baseValue
    return self.value
  end
end

function Stat:Num()
  return self.statIds and #self.statIds or 0
end

function Stat:OnClear()
  self.statValues = nil
  self.statIds = nil
end

return Stat
